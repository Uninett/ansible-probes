#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

owping -6 -A AE -u topsi -k ${SCRIPT_DIR}owampd.pfs -t $SERVER_OWAMP6 -L 4 -P 8760-9760 > ${SCRIPT_DIR}owamp_out_v6.log

# Extracts jitter and packet loss results from owping

owj_v6=$(cat ${SCRIPT_DIR}owamp_out_v6.log | grep 'jitter' | awk '{print $4}')
if [[ "$owj_v6" == "nan" ]]; then
    owj_v6=""
fi
echo $I " owj_v6_"$1  $owj_v6 | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report

owpl_v6=$(cat ${SCRIPT_DIR}owamp_out_v6.log  | grep 'lost' | awk '{print $5}' | awk 'BEGIN {FS="("} {print $2}' | awk 'BEGIN {FS=")"} {print $1}' | awk 'BEGIN {FS="%"} {print $1}')
echo $I " owpl_v6_"$1  $owpl_v6 | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report

delay_min=$(awk '/one-way delay/{ print $5 }' ${SCRIPT_DIR}owamp_out_v6.log | awk 'BEGIN {FS="/"} { print $1 }')
echo "ow_delay_min_v6_$1" "$delay_min" >> ${SCRIPT_DIR}results_report

delay_median=$(awk '/one-way delay/{ print $5 }' ${SCRIPT_DIR}owamp_out_v6.log | awk 'BEGIN {FS="/"} { print $2 }')
echo "ow_delay_median_v6_$1" "$delay_median" >> ${SCRIPT_DIR}results_report

delay_max=$(awk '/one-way delay/{ print $5 }' ${SCRIPT_DIR}owamp_out_v6.log | awk 'BEGIN {FS="/"} { print $3 }')
echo "ow_delay_max_v6_$1" "$delay_max" >> ${SCRIPT_DIR}results_report

delay_error=$(awk '/one-way delay/{ print $7 }' ${SCRIPT_DIR}owamp_out_v6.log | grep -oE '[0-9]+\.[0-9]+')
echo "ow_delay_error_v6_$1" "$delay_error" >> ${SCRIPT_DIR}results_report
