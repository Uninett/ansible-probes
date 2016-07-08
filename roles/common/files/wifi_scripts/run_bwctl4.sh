#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

# From RPI to server (upload)

bwup_v4=$(sudo bwctl -4 -T iperf3 -q -c $SERVER_BWCTL4 AE AESKEY topsi ${SCRIPT_DIR}bwctld.keys -a5 | grep receiver | awk '{print $7}')

# From server to RPI (download)

bwdo_v4=$(sudo bwctl -4 -T iperf3 -q -o -s $SERVER_BWCTL4 AE AESKEY topsi ${SCRIPT_DIR}bwctld.keys -a5 | grep receiver | awk '{print $7}')

echo $I " bwup_v4_"$1  $bwup_v4 | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
echo $I " bwdo_v4_"$1  $bwdo_v4 | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
