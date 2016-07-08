#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

# ping6 -c $2 rpiconf.labs.uninett.no | grep 'min/avg/max' > ${SCRIPT_DIR}rtt6.log
ping6 -c $RTT_SAMPLES $SERVER_RTT | grep 'min/avg/max' > ${SCRIPT_DIR}rtt6.log

rttv6_min=$(cat ${SCRIPT_DIR}rtt6.log |awk '{print $4}' | awk 'BEGIN {FS="\/"} {print $1}')
rttv6_avg=$(cat ${SCRIPT_DIR}rtt6.log |awk '{print $4}' | awk 'BEGIN {FS="\/"} {print $2}')
rttv6_max=$(cat ${SCRIPT_DIR}rtt6.log |awk '{print $4}' | awk 'BEGIN {FS="\/"} {print $3}')

echo $I " rttv6_min_"$1  $rttv6_min | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
echo $I " rttv6_avg_"$1  $rttv6_avg | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
echo $I " rttv6_max_"$1  $rttv6_max | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
