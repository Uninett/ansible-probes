#!/bin/bash

. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

ping6 -I wlan0 -c5 -q www.uninett.no
ipv6=$?

echo $I " ipv6_"$1  $ipv6 | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report

echo "C=" $ipv6 | awk '{print $1 $2}'> ${SCRIPT_DIR}ip6stat.properties
