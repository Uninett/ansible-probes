#!/usr/bin/env python3
import subprocess
import time
import logging
import sys
import os
import json
from logging.handlers import RotatingFileHandler
from datetime import datetime
from elasticsearch import Elasticsearch
import re


logger = None


class Timer:
    """Used for keeping track of elapsed time"""
    def __init__(self):
        """Reset timer when instanced"""
        self.reset()

    def reset(self):
        """Set the timer's start time to the current time"""
        self.start_time = time.time()

    def elapsed_time(self):
        """Returns elapsed time as the difference between current time
        and last reset
        """
        return time.time() - self.start_time


class Script:
    """Data structure consisting of a shell command and a timer"""
    def __init__(self, command, interval, args=[]):
        """Arguments:
        command:    script name
        interval:   interval in seconds the script should be run
        args:       the command/script's arguments
        """
        self.cmd = command
        self.args = args

        self._interval = interval
        self._timer = Timer()

    def is_ready(self, reset_if_ready=False):
        """Returns true if the elapsed time is greater than the set interval"""
        if self._timer.elapsed_time() > self._interval:
            if reset_if_ready:
                self._timer.reset()
            return True
        return False


class ScriptManager:
    """Manages multiple scripts and calls them at specified intervals"""
    def __init__(self):
        pass

    def load_scripts(self, script_configs):
        """Parse script config and create Script instances for each entry.
        Add the entries to a scripts list"""
        self.scripts = []
        for config in script_configs:
            if config['enabled']:
                command = full_path(config['script_file'])
                interval = config['minute_interval'] * 60

                args = []
                if config['args'] is not None:
                    args = config['args'].split()

                self.scripts.append(Script(command, interval, args))

    def load_script_configs(self, path):
        """Load a json script config and return it as python datastructure"""
        with open(path, 'r') as f:
            config = json.load(f)
        return config

    def run_scripts(self, io_manager):
        """Run all (ready) scripts in the scripts list"""
        is_ready = {}

        # Save the "readiness" of each script before executing them,
        # because elapsed time while executing kan make the later
        # scripts more likely to run
        for script in self.scripts:
            is_ready[script] = script.is_ready(True)

        for script in self.scripts:
            if is_ready[script]:
                self.run_single_script(script, io_manager)

    def run_single_script(self, script_obj, io_manager):
        """Run a single script as a blocking subprocess, and log some
        possible errors"""
        timeout_in_secs = 5*60
        command = [script_obj.cmd] + script_obj.args
        try:
            logger.info('Calling: {}'.format(command))
            subprocess.call(command, timeout=timeout_in_secs)
            logger.debug('Script process completed')
        except PermissionError as e:
            # Probably a malformed script name. Continue
            # trying to execute the other scripts
            logger.error('Script execution error: {}'.format(e))
        except subprocess.TimeoutExpired:
            logger.warning(
                    'The following script timed out after {} seconds:'
                    '{}'.format(timeout_in_secs, command))
        except subprocess.CalledProcessError as e:
            logger.error('Script exiting with a non-zero return code: ' + str(e))

    def run_script_once(self, command, args, io_manager):
        """Run an ad-hoc script, that does not have its own Script instance"""
        script = Script(command, 0, list(args))
        self.run_single_script(script, io_manager)


class IOManager:
    def __init__(self):
        self.db_configs = {}
        try:
            with open(full_path('db_configs.json'), 'r') as f:
                self.db_configs = json.loads(f.read())
        except FileNotFoundError:
            logger.error('Cannot read db_configs.json. Will not be able to send '
                         'data to databases')

    def submit_results(self):
        """Read results_report file and send its content to databases"""
        try:
            # All results are saved in a specific file (called results_report)
            with open(full_path('results_report'), 'rb+') as f:
                results = f.read()
                if results != b'':
                    try:
                        if ('influxdb' in self.db_configs and
                                self.db_configs['influxdb']['status'] == 'enabled'):
                            self.send_to_influxdb(results)
                        if ('elastic' in self.db_configs and
                                self.db_configs['elastic']['status'] != 'disabled'):
                            self.send_to_elastic(results.decode('utf-8'))
                    except BrokenPipeError as e:
                        logger.warning('Network pipe was interrupted. Error: {}'.format(e))

                # Clear the file when done submitting
                f.truncate(0)

        except FileNotFoundError:
            # Probably, no scripts have written to the file yet,
            # so it hasn't been created (but it should already
            # have been touched)
            return

    def send_to_influxdb(self, bin_string):
        """Parse input string and send result to specified InfluxDB server"""
        influx_string = self.convert_to_influx_format(bin_string)

        if influx_string != b'':
            command = [full_path('submit_to_influxdb.sh'), influx_string]

            logger.info('Sending results to influxdb')
            try:
                response = subprocess.check_output(command)
            except subprocess.CalledProcessError as e:
                logger.error('Error sending result to db: ' + str(e))
                return

            if response == b'204':
                logger.info('Results successfully received by influxdb.')
            else:
                logger.warning(
                        'Results were not successfully received by influxdb. '
                        'http response code: {}'.format(response))

    def convert_to_influx_format(self, bin_string):
        """Run a script that converts the raw string argument to an
        InfluxDB-compliant entry, and return the result

        bin_string must be a binary string
        each line of bin_string should be in the format
            'dhcp_time_any 5.32'
        which will be converted to
            'dhcp_time_any,probe=?,id=? value=5.32 1471427785000000000'
        where the last number is a unix time stamp
        """
        p = subprocess.Popen(
                full_path('report2influxdb.pl'),
                stdout=subprocess.PIPE,
                stdin=subprocess.PIPE)

        result, error = p.communicate(input=bin_string)
        return result

    def send_to_elastic(self, string):
        """Send data to the elasticsearch server."""
        domain = port = index_prefix = ''
        if self.db_configs['elastic']['status'] == 'custom':
            domain = self.db_configs['elastic']['address']
            port = self.db_configs['elastic']['port']
            index_prefix = self.db_configs['elastic']['db_name']
        # In practice, the only other option will be 'uninett'
        else:
            # The probe will connect to UNINETT's elastic server through
            # an SSH tunnel
            domain = 'localhost'
            port = '9200'
            index_prefix = 'wifi-probe-uninett-'

        index = index_prefix + str(datetime.utcnow().strftime('%Y.%m.%d'))
        url = 'http://{}:{}'.format(domain, port)
        es = Elasticsearch([url])

        data = self.convert_to_elastic_format(string)

        # Read the probe's mac address (used as identification)
        mac = ''
        with open(full_path('probe_id.txt'), 'r') as f:
            mac = f.read().strip()
        if mac == '':
            logger.error('Unable to read MAC address from probe_id.txt')
            return

        logger.info('Sending results to Elasticsearch')
        try:
            res = es.index(index=index,
                           doc_type=mac,
                           body=data,
                           timeout='30s')
        except ConnectionRefusedError:
            logger.error('Unable to connect to Elasticsearch')
            return

        if res['created']:
            logger.info('Results successfully received by Elasticsearch')
        else:
            logger.warning(
                    'Results were not successfully received by Elasticsearch. '
                    'Response: {}'.format(res))

    def convert_to_elastic_format(self, string):
        # Convert from 'a 1\nb 2' to [['a', '1'], ['b', '2']]
        data_list = [pair.split() for pair in string.split('\n') if len(pair.split()) == 2]
        # Convert from [['a', '1'], ['b', '2']] to {'a': '1', 'b': '2'}
        data = {key: value for key, value in data_list}
        data['@timestamp'] = datetime.utcnow()

        # Convert string numbers ('12', '12.34') to interger/floats (12, 12.34)
        for key, value in data.items():
            if type(value) is str and re.fullmatch('[0-9]+((.|,)[0-9]+)?', value):
                value = value.replace(',', '.')
                data[key] = float(value) if '.' in value else int(value)

        return data


def full_path(filename):
    """Use the supplied argument to construct and return the full
    path to a script"""
    prefix = str(sys.argv[1])
    if prefix[-1] != '/':
        prefix += '/'

    return prefix + str(filename)


def is_argument_valid():
    """Return true if the user supplied a single string argument"""
    try:
        str(sys.argv[1])
        return True
    except Exception as e:
        print('Usage:', sys.argv[0], '<full_path_to_script_dir>')
    return False


def init_logger():
    """Set up a logger from python's logging module"""
    log_formatter = logging.Formatter('%(asctime)s %(levelname)s | %(message)s')
    log_file = full_path('control_program.log')

    handler = RotatingFileHandler(log_file, mode='a', maxBytes=16*1024*1024,
                                  backupCount=2, encoding=None, delay=0)
    handler.setFormatter(log_formatter)
    handler.setLevel(logging.INFO)

    global logger
    logger = logging.getLogger('root')
    logger.setLevel(logging.INFO)
    logger.addHandler(handler)


def main():
    if not is_argument_valid():
        return

    # Export the script directory as an environment variable visible to
    # all child processes (the wifi scripts)
    os.environ['SCRIPT_DIR'] = full_path('')

    init_logger()

    logger.info('Initializing script and io manager')

    script_man = ScriptManager()
    configs = script_man.load_script_configs(full_path('script_configs.json'))
    script_man.load_scripts(configs)

    io = IOManager()

    # This script must be run first, because it connects to the internet.
    logger.info('Connecting wlan0 to the internet')
    script_man.run_script_once(full_path('connect_8812.sh'), ['any'], io)

    # This is the main loop
    while True:
        script_man.run_scripts(io)
        io.submit_results()
        time.sleep(2)

if __name__ == '__main__':
    main()
