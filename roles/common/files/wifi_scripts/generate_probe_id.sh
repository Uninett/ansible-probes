#!/bin/bash


mac=$(ifconfig wlan0 | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | sed 's/://g')
# The REALTEK check is to prevent selection of the interval wifi card on the rpi3
if [[ "$mac" == "" || ($(iwconfig wlan0 | grep REALTEK) == "" && $(lsb_release -a | grep Kali)) ]]; then
    mac=$(ifconfig wlan1 | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | sed 's/://g')
    if [[ "$mac" == "" || $(iwconfig wlan1 | grep REALTEK) == "" ]]; then
        echo "Unable to read wlan MAC"
        mac=''
    fi
fi

echo "$mac" > probe_id.txt

# probe_id=$(ifconfig eth0 | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | sed 's/://g')
# echo $probe_id > probe_id.txt

# The existing scripts merge the ID with the measurement name
# by themselves, which makes it cumbersome to parse (and also
# breaks some of the scripts if the ID is non-empty). Therefore
# we set the old ID to be empty. This is a just a temporary fix.
echo "I=" > probe.id
