#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

curl -6 -s -w '\nDNS:\t%{time_namelookup}\nConn:\t%{time_connect}\nPreXf:\t%{time_pretransfer}\nStartXf:\t%{time_starttransfer}\nHTTP:\t%{time_total}\n' -o /dev/null --connect-timeout 20 http://www.google.com > ${SCRIPT_DIR}http.log

# Ignore values if curl timed out / failed
if [[ "$?" != "0" ]]; then
    exit 1
fi

sed -i 's/,/./g' ${SCRIPT_DIR}http.log

dns=$(cat ${SCRIPT_DIR}http.log | grep DNS | awk '{print $2}')
http=$(cat ${SCRIPT_DIR}http.log | grep HTTP | awk '{print $2}')

echo $I " dns_v6_"$1  $dns | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
echo $I " http_v6_"$1  $http | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
