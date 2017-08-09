#!/bin/bash

# Unstable debootstrap version(1.0.86~bpo8+1 ->) may be required to be able to run second stage on host

if [[ "${EUID}" != 0 ]]; then
    echo "[!] Script must be run as root"
    exit
fi

echo "[+] Set up stable debian system"
# Executes debootstrap foreign stage to create system for another architecture
debootstrap --foreign --arch armhf stable rootfs http://ftp.debian.org/debian/

echo "[+] Alter permissions"
# Must alter permissions to allow ansible to read the file when copying to host
chmod 744 rootfs/root/
