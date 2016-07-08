#!/bin/bash

# Finding id for unit based on WLAN0 MAC address and make a background picture of it 

rpi_id_mac=$(ifconfig | grep wlan0 | awk '{print $5}' | awk 'BEGIN {FS=":"} {print $1 ":" $2 ":" $3 ":" $4 ":" $5 ":" $6}')
sudo convert -size 560x85 xc:transparent -font Palatino-Bold -pointsize 72 -fill black -draw "text 20,55 '$rpi_id_mac' " /root/scripts/mac.png

# Copy frequently accessed files from SD card to memory

cp /root/scripts/bwctld.* /root/scripts/probefiles
cp /root/scripts/owampd.* /root/scripts/probefiles
cp /root/scripts/*.sh /root/scripts/probefiles
cp /root/scripts/probe.parameters /root/scripts/probefiles
cp /root/scripts/probe.measurements /root/scripts/probefiles
cp /root/scripts/wpa_supplicant.conf.* /root/scripts/probefiles

chmod +x ${SCRIPT_DIR}*.sh
#sudo chown pi ${SCRIPT_DIR}*
#sudo chgrp pi ${SCRIPT_DIR}*

# Also store the MAC adress without : in file for use as unique probe id

rpi_id=$(ifconfig | grep wlan0 | awk '{print $5}' | awk 'BEGIN {FS=":"} {print $1 $2 $3 $4 $5 $6}')
echo "I=" $rpi_id | awk '{print $1 $2}'> ${SCRIPT_DIR}probe.id

# echo "I=" $rpi_id | awk '{print $1 $2}'>> ${SCRIPT_DIR}probe.parameters

