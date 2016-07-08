#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

while [[ $(iwconfig wlan0 | grep unassociated) ]]; do
    sleep 1
done

iwconfig wlan0 > ${SCRIPT_DIR}wifi.out 
numlines=$(wc -l ${SCRIPT_DIR}wifi.out | awk '{print $1}')

if [ $numlines -gt 6 ] 
then
 wifi_freq=$(cat ${SCRIPT_DIR}wifi.out | grep Frequency | awk 'BEGIN {FS=" "} {print $2}' | awk 'BEGIN {FS=":"} {print $2}')
 wifi_apid=$(cat ${SCRIPT_DIR}wifi.out | grep Point | awk 'BEGIN {FS=" "} {print $6}')
 wifi_conn=$(cat ${SCRIPT_DIR}wifi.out | grep Rate | awk 'BEGIN {FS=" "} {print $2}' | awk 'BEGIN {FS=":"} {print $2}')

 val1=$(cat ${SCRIPT_DIR}wifi.out | grep Quality | awk 'BEGIN {FS=" "} {print $2}' | awk 'BEGIN {FS="="} {print $2}' | awk 'BEGIN {FS="/"} {print $1}')
 val2=$(cat ${SCRIPT_DIR}wifi.out | grep Quality | awk 'BEGIN {FS=" "} {print $2}' | awk 'BEGIN {FS="="} {print $2}' | awk 'BEGIN {FS="/"} {print $2}')

 wifi_qual=$(echo "scale=2;$val1/$val2"|bc -l)

 val1=$(cat ${SCRIPT_DIR}wifi.out | grep Signal | awk 'BEGIN {FS=" "} {print $4}' | awk 'BEGIN {FS="="} {print $2}' | awk 'BEGIN {FS="/"} {print $1}' )
 val2=$(cat ${SCRIPT_DIR}wifi.out | grep Signal | awk 'BEGIN {FS=" "} {print $4}' | awk 'BEGIN {FS="="} {print $2}' | awk 'BEGIN {FS="/"} {print $2}' ) 

 wifi_sign=$(echo "scale=2;$val1/$val2"|bc -l)
 
 # Appending collected information to Zabbix report file

 echo $I " wifi_freq_"$1  $wifi_freq | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
 echo $I " wifi_apid_"$1  $wifi_apid | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
 echo $I " wifi_sign_"$1  $wifi_sign | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
 echo $I " wifi_qual_"$1  $wifi_qual | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
 echo $I " wifi_conn_"$1  $wifi_conn | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
else
 echo "Err" >> ${SCRIPT_DIR}wifi_fail.log
fi
exit
