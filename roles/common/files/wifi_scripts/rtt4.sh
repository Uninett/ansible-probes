#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

ping -I wlan0 -c $RTT_SAMPLES $SERVER_RTT | grep 'min/avg/max' > ${SCRIPT_DIR}rtt4.log

rttv4_min=$(cat ${SCRIPT_DIR}rtt4.log |awk '{print $4}' | awk 'BEGIN {FS="\/"} {print $1}')
rttv4_avg=$(cat ${SCRIPT_DIR}rtt4.log |awk '{print $4}' | awk 'BEGIN {FS="\/"} {print $2}')
rttv4_max=$(cat ${SCRIPT_DIR}rtt4.log |awk '{print $4}' | awk 'BEGIN {FS="\/"} {print $3}')

echo $I " rttv4_min_"$1  $rttv4_min | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
echo $I " rttv4_avg_"$1  $rttv4_avg | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
echo $I " rttv4_max_"$1  $rttv4_max | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
