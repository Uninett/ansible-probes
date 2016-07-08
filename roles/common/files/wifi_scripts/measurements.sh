#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.measurements
. ${SCRIPT_DIR}probe.id

wget -NrnpH -P/root/scripts/probefiles --cut-dirs=1 --quiet --reject "index.html*" $SCRIPTSURL

Start=$(date +%s)

#ping -c 10 158.38.212.149 > /dev/null

${SCRIPT_DIR}initiate.sh
${SCRIPT_DIR}scan.sh
${SCRIPT_DIR}connect_8812.sh any 

sleep 60

${SCRIPT_DIR}check_ipv6.sh any
. ${SCRIPT_DIR}ip6stat.properties

${SCRIPT_DIR}collect.sh any 

if [ $HTTPv4 == 1 ]; then ${SCRIPT_DIR}check_http_v4.sh any; fi
if [ $JITTERv4 == 1 ]; then ${SCRIPT_DIR}run_owping4.sh any ; fi
if [ $BWv4 == 1 ]; then ${SCRIPT_DIR}run_bwctl4.sh any; fi
if [ $RTTv4 == 1 ]; then ${SCRIPT_DIR}rtt4.sh any 10; fi

# Only run IPv6 tests if possible, the C variable
# comes from the ip6stat.properties file

if [ $C -eq 0 ]
then
 if [ $HTTPv6 == 1 ]; then ${SCRIPT_DIR}check_http_v6.sh any; fi
 if [ $JITTERv6 == 1 ]; then ${SCRIPT_DIR}run_owping6.sh any ; fi
 if [ $BWv6 == 1 ]; then ${SCRIPT_DIR}run_bwctl6.sh any; fi
 if [ $RTTv6 == 1 ]; then ${SCRIPT_DIR}rtt6.sh any 10; fi
fi

${SCRIPT_DIR}getIPinfo.sh any

${SCRIPT_DIR}local_log.sh

Stopp=$(date +%s)
Dur=$((Stopp-Start))

Tot_Dur=$((Dur+SLEEP_TIMER))

echo $I " looptime " $Dur | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " tot_looptime " $Tot_Dur | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report

cat ${SCRIPT_DIR}results_report | /root/scripts/report2influxdb.pl > ${SCRIPT_DIR}influxdb.txt 

curl -i -XPOST 'http://collectd:C0llectD@158.38.212.149:8086/write?db=wifimp' --data-binary @${SCRIPT_DIR}influxdb.txt

#${SCRIPT_DIR}report2zabbix.sh

sleep 2
 
${SCRIPT_DIR}stop_wireless.sh

${SCRIPT_DIR}empty_logs.sh
