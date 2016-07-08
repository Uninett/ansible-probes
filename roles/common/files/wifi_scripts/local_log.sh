#!/bin/bash

# Store measurements on local USB device if present

if grep -qs '/mnt/usbdisk' /proc/mounts; then

cat ${SCRIPT_DIR}results_report.common | grep -v ssid_list > ${SCRIPT_DIR}local.log
cat ${SCRIPT_DIR}results_report.any >> ${SCRIPT_DIR}local.log

echo "$(date +"%m-%d-%y") "$(date +"%T")  > ${SCRIPT_DIR}timestamp

cat ${SCRIPT_DIR}local.log | awk '{printf $3 ";"}' > ${SCRIPT_DIR}values.log
paste ${SCRIPT_DIR}timestamp ${SCRIPT_DIR}values.log ${SCRIPT_DIR}ssid_list_body >> /mnt/usbdisk/measurements.log

# Create index file 

cat ${SCRIPT_DIR}local.log | awk '{printf $2 ";"}' > /mnt/usbdisk/index.log    

else
 echo
fi
