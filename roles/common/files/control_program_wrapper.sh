#!/bin/bash

# This script is meant to be run by systemd, to allow for  some
# conditional checks before the control program is started

# Currently it only checks whether an ethernet cable is connected
# or not. It will not start if it is, because it will mess up
# the measurements.

PROGRAM_PATH="${1}"
RAMDISK_DIR="${2}"

# Wait until the interface is set up (eth0 will always set up,
# regardless of whether a cable is connected or not)
while [[ ! -f /sys/class/net/eth0/carrier ]]; do
    sleep 5
done

# True if ethernet cable is NOT connected
# if [[ "$(cat /sys/class/net/eth0/carrier)" == "0" ]]; then

# Because of some changes, it should now be possible to have the cable connected
# while doing measurements
exec "${PROGRAM_PATH}" "${RAMDISK_DIR}"

# else
#     echo "Ethernet cable connected. Will not execute program."
#     exit 0
# fi
