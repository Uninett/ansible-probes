#!/bin/bash

# Creating empty zabbix report file

cat /dev/null > ${SCRIPT_DIR}results_report
cat /dev/null > ${SCRIPT_DIR}results_report.clean

# Creating some other empty files used by scripts for temp purposes

cat /dev/null > ${SCRIPT_DIR}temp
cat /dev/null > ${SCRIPT_DIR}timestamp
cat /dev/null > ${SCRIPT_DIR}http.log

#sudo chown pi ${SCRIPT_DIR}*
#sudo chgrp pi ${SCRIPT_DIR}*

# Initializing log files on USB, if not already there 

#touch /mnt/usbdisk/measurements.log
#touch /mnt/usbdisk/index.log
