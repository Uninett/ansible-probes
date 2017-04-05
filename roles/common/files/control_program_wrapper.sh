#!/bin/bash

# This script is meant to be run by systemd, to allow for  some
# conditional checks before the control program is started

PROGRAM_PATH="${1}"
RAMDISK_DIR="${2}"

# Wait until the interface is set up (eth0 will always set up,
# regardless of whether a cable is connected or not)
while [[ ! -f /sys/class/net/eth0/carrier ]]; do
    sleep 5
done

# Load settings in /etc/sysctl.conf
sysctl -p

exec "${PROGRAM_PATH}" "${RAMDISK_DIR}"
