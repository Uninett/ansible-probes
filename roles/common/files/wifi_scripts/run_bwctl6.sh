#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

# From RPI to server (upload)
bwup_v6=$(sudo bwctl -6 -T iperf3 -q -c $SERVER_BWCTL6 AE AESKEY topsi ${SCRIPT_DIR}bwctld.keys -a5 | grep receiver | awk '{print $7}')
# From server to RPI (download)

bwdo_v6=$(sudo bwctl -6 -T iperf3 -q -o -s $SERVER_BWCTL6 AE AESKEY topsi ${SCRIPT_DIR}bwctld.keys -a5 | grep receiver | awk '{print $7}')

echo $I " bwup_v6_"$1  $bwup_v6 | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
echo $I " bwdo_v6_"$1  $bwdo_v6 | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
