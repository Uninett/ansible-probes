#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

sudo ifconfig wlan0 > ${SCRIPT_DIR}ifconfig.log

myipv4=$(cat ${SCRIPT_DIR}ifconfig.log | grep 'inet addr' | awk '{print $2}' | awk 'BEGIN {FS=":"} {print $2}')
myipv6=$(cat ${SCRIPT_DIR}ifconfig.log | grep 'Scope:Global' | awk '{print $3}' | awk 'BEGIN {FS="\/"} {print $1}')

echo $I " myipv4 " $myipv4 | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " myipv6 " $myipv6 | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
