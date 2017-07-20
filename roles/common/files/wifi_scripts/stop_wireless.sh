#!/bin/bash

# echo "Logging off WLAN.."

sudo /sbin/wpa_cli logoff

# echo "Killing whatever is left..."

sudo /sbin/wpa_cli terminate
sudo killall wpa_supplicant

# IPv4 address release

sudo dhclient -r wlan0

# Restart networking

sudo /etc/init.d/networking restart
