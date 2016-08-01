#!/usr/bin/env python3
import subprocess
import time
import logging
import sys
import os
import json


class Timer:
    def __init__(self):
        self.reset()

    def reset(self):
        self.start_time = time.time()

    def elapsed_time(self):
        return time.time() - self.start_time


class Script:
    def __init__(self, command, interval, args=[]):
        self.cmd = command
        self.args = args

        self._interval = interval
        self._timer = Timer()

    def is_ready(self, reset_if_ready=False):
        if self._timer.elapsed_time() > self._interval:
            if reset_if_ready:
                self._timer.reset()
            return True
        return False


class ScriptManager:
    def __init__(self):
        pass

    def load_scripts(self, script_configs):
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
        with open(path, 'r') as f:
            config = json.load(f)
        return config

    def run_scripts(self, io_manager):
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
        timeout_in_secs = 5*60
        command = [script_obj.cmd] + script_obj.args
        try:
            logging.info('Calling: {}'.format(command))
            subprocess.call(command, timeout=timeout_in_secs)
            logging.debug('Script process completed')
        except PermissionError as e:
            # Probably a malformed script name. Continue
            # trying to execute the other scripts
            logging.error('Script execution error: {}'.format(e))
        except subprocess.TimeoutExpired:
            logging.warning(
                    'The following script timed out after {} seconds:'
                    '{}'.format(timeout_in_secs, command))

    def run_script_once(self, command, args, io_manager):
        script = Script(command, 0, list(args))
        self.run_single_script(script, io_manager)


class IOManager:
    def __init__(self):
        pass

    def submit_results(self):
        try:
            # All results are saved in a specific file (called results_report)
            with open(full_path('results_report'), 'rb+') as f:
                results = f.read()
                if results != b'':
                    self.send_to_influxdb(results)

                # Clear the file when done submitting
                f.truncate(0)

        except FileNotFoundError:
            # Probably, no scripts have written to the file yet,
            # so it hasn't been created (but it should already
            # have been touched)
            return

    def send_to_influxdb(self, bin_string):
        influx_string = self.convert_to_influx_format(bin_string)

        if influx_string != b'':
            command = [full_path('submit_to_influxdb.sh'), influx_string]

            logging.info('Sending results to influxdb')
            response = subprocess.check_output(command)

            if response == b'204':
                logging.info('Results successfully received by influxdb.')
            else:
                logging.warning(
                        'Results were not successfully received by influxdb'
                        'http response code: {}'.format(response))

    def convert_to_influx_format(self, bin_string):
        p = subprocess.Popen(
                full_path('report2influxdb.pl'),
                stdout=subprocess.PIPE,
                stdin=subprocess.PIPE)

        result, error = p.communicate(input=bin_string)
        return result


def full_path(filename):
    prefix = str(sys.argv[1])
    if prefix[-1] != '/':
        prefix += '/'

    return prefix + str(filename)


def is_argument_valid():
    try:
        str(sys.argv[1])
        return True
    except Exception as e:
        print('Usage:', sys.argv[0], '<full_path_to_script_dir>')
    return False


def main():
    if not is_argument_valid():
        return

    # Export the script directory as an environment variable visible to
    # all child processes (the wifi scripts)
    os.environ['SCRIPT_DIR'] = full_path('')

    # Can be DEBUG, INFO, WARNING, ERROR and CRITICAL
    logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s %(levelname)s | %(message)s',
            filename=full_path('control_program.log'))

    logging.info('Initializing script and io manager')
    script_man = ScriptManager()
    configs = script_man.load_script_configs(full_path('script_configs.json'))
    script_man.load_scripts(configs)

    io = IOManager()

    # This script must be run first, because it connects to the internet.
    logging.info('Connecting wlan0 to the internet')
    script_man.run_script_once(full_path('connect_8812.sh'), ['any'], io)

    while True:
        script_man.run_scripts(io)
        io.submit_results()
        time.sleep(2)

if __name__ == '__main__':
    main()
