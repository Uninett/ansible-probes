#!/bin/bash

# Reading in node ID from file
. ${SCRIPT_DIR}probe.parameters
. ${SCRIPT_DIR}probe.id

uptime=$(cat /proc/uptime | awk '{print $1}')

# Scan WiFi, first just a dry-scan, then log to file
 
sudo iwlist wlan0 scan > /dev/null
sleep 5
sudo iwlist wlan0 scan > ${SCRIPT_DIR}scan.output

# Number of WiFi cells advertising the eduroam ssid in the 2.4GHz band
cells_2ghz_edur=$(cat ${SCRIPT_DIR}scan.output | grep 'Frequency\|ESSID' | awk 'BEGIN {FS=":"} {print $2}' | awk '{print $1}' | paste - - | grep "eduroam\"" | grep 2. | wc -l)

# Number of WiFi cells advertising the eduroam ssid in the 5GHz band
cells_5ghz_edur=$(cat ${SCRIPT_DIR}scan.output | grep 'Frequency\|ESSID' | awk 'BEGIN {FS=":"} {print $2}' | awk '{print $1}' | paste - - | grep "eduroam\"" | grep 5. | wc -l)

# Number of WiFi cells advertising the eduroam ssid
cells_edur=$((cells_2ghz_edur+cells_5ghz_edur))

# Number of WiFi cells in the 2.4GHz band
cells_2ghz=$(cat ${SCRIPT_DIR}scan.output | grep Frequency | awk 'BEGIN {FS=":"} {print $2}' | awk '{print $1}' | grep '^2.' | wc -l)

# Number of WiFi cells in the 5GHz band
cells_5ghz=$(cat ${SCRIPT_DIR}scan.output | grep Frequency | awk 'BEGIN {FS=":"} {print $2}' | awk '{print $1}' | grep '^5.' | wc -l)

# Total number of WiFi cells detected
cells_tota=$(cat ${SCRIPT_DIR}scan.output | grep Frequency | wc -l)


# Number of unique SSID's seen
cells_uniq_ssid=$(cat ${SCRIPT_DIR}scan.output | grep ESSID | awk 'BEGIN {FS="\""} {print $2}' | sort | uniq | wc -l) 

# Number of unique AP radio interfaces seen
cells_uniq_radi=$(cat ${SCRIPT_DIR}scan.output | grep Address | awk '{print $5}' | sort | uniq | wc -l)

# Number of unique AP Channels seen
cells_uniq_chan=$(cat ${SCRIPT_DIR}scan.output | grep Channel | awk '{print $4}' | awk 'BEGIN {FS="\)"} {print $1}' | sort | uniq | wc -l)

# Number of APs in Master mode
cells_num_mast=$(cat ${SCRIPT_DIR}scan.output | grep Mode | awk 'BEGIN {FS=":"} {print $2}' | wc -l)

# Finding the number of unique 2G and 5G channels used
cells_2g_freq=$(cat ${SCRIPT_DIR}scan.output | grep Frequency | awk 'BEGIN {FS=":"} {print $2}' | awk '{print $1}' | sort | uniq | grep '^2' | wc -l)
cells_5g_freq=$(cat ${SCRIPT_DIR}scan.output | grep Frequency | awk 'BEGIN {FS=":"} {print $2}' | awk '{print $1}' | sort | uniq | grep '^5' | wc -l)

#Creating list of SSIDs seen
cat ${SCRIPT_DIR}scan.output | grep ESSID | awk 'BEGIN {FS="\""} {print $2}' | sort | uniq | awk '{printf $1 " "}' > ${SCRIPT_DIR}ssid_list_body
echo $I " ssid_list " $ssid_list | awk '{print $1 " " $2 " "}' > ${SCRIPT_DIR}ssid_list_header
ssid_list=$(cat ${SCRIPT_DIR}ssid_list_header ${SCRIPT_DIR}ssid_list_body | awk '{printf $0 "'\''"}')

# Appending collected information to common Zabbix report files

echo $I " uptime " $uptime | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report

echo $I " cells_tota " $cells_tota | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_2ghz_edur " $cells_2ghz_edur | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_5ghz_edur " $cells_5ghz_edur | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_edur " $cells_edur | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_2ghz " $cells_2ghz | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_5ghz " $cells_5ghz | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report

echo $I " cells_uniq_ssid " $cells_uniq_ssid | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_uniq_radi " $cells_uniq_radi | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_uniq_chan " $cells_uniq_chan | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_num_mast " $cells_num_mast | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report

echo $I " cells_2g_freq " $cells_2g_freq | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report
echo $I " cells_5g_freq " $cells_5g_freq | awk '{print $1 " " $2 " " $3}' >> ${SCRIPT_DIR}results_report

echo $ssid_list >> ${SCRIPT_DIR}results_report
