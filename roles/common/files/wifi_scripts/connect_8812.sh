#!/bin/bash

# Reading in node ID from file
. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

${SCRIPT_DIR}stop_wireless.sh
# sudo service network-manager stop

systemctl stop wpa_supplicant
if [[ -f /var/run/wpa_supplicant/wlan0 ]]; then
    rm /var/run/wpa_supplicant/wlan0
fi

# Make sure kernel params for wifi are loaded
sysctl -p

# Associating with WLAN

cat /dev/null > ${SCRIPT_DIR}wpa_time.log
/sbin/wpa_supplicant -Dwext -iwlan0 -c ${SCRIPT_DIR}wpa_supplicant.conf.$1 -B -t -f ${SCRIPT_DIR}wpa_time.log

# waiting for association...
MAX_WAIT=60
curr_wait=0
while [[ ! $(cat ${SCRIPT_DIR}wpa_time.log | grep 'CTRL-EVENT-CONNECTED') ]]; do
    echo 'waiting...'
    sleep 5
    curr_wait=$((${curr_wait}+5))
    if [[ $curr_wait > $MAX_WAIT || $curr_wait == $MAX_WAIT ]]; then
        exit 1
    fi
done

wifi_asso=$(cat ${SCRIPT_DIR}wpa_time.log | grep 'Successfully \| CTRL-EVENT-CONNECTED' | awk 'BEGIN {FS=":"}NR==1{s=$1}END{print $1-s}')

# Acquiring IPv4 address and measure how long it takes

dhcp_start=`date +%s.%N`
dhclient -v wlan0 
dhcp_stop=`date +%s.%N`
dhcp_time=$(echo "$dhcp_stop-$dhcp_start"|bc) 

# Appending collected information to Zabbix report file

echo $I " wifi_asso_"$1  $wifi_asso | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report
echo $I " dhcp_time_"$1  $dhcp_time | awk '{print $1 " " $2 $3 " " $4}' >> ${SCRIPT_DIR}results_report

# Trying to acquire IPv6 address

# sudo dhclient -1 -6 -v wlan0 -cf /etc/dhcp/dhclient6.conf

# sudo service network-manager start
