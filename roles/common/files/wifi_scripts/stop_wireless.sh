#!/bin/bash

# echo "Logging off WLAN.."

sudo /sbin/wpa_cli logoff

# echo "Killing whatever is left..."

sudo /sbin/wpa_cli terminate

# IPv4 address release

sudo dhclient -r wlan0

