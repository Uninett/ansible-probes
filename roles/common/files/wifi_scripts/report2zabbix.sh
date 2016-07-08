# Send non-empty report files to Zabbix

if [ -s ${SCRIPT_DIR}results_report ]
then
 cat ${SCRIPT_DIR}results_report | grep -v ssid_list | awk '{ if (length($3)>0) print $1 " " $2 " " $3; else print $1 " " $2 " 0"}' > ${SCRIPT_DIR}temp
 cat ${SCRIPT_DIR}results_report | grep ssid_list >> ${SCRIPT_DIR}temp
 cp ${SCRIPT_DIR}temp ${SCRIPT_DIR}results_report.clean
 sudo zabbix_sender -z vltrd001.oam.uninett.no -i ${SCRIPT_DIR}results_report.clean
fi
