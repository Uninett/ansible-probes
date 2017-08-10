#!/bin/bash

# Unstable debootstrap version(1.0.86~bpo8+1 ->) may be required to be able to run second stage on host

if [[ "${EUID}" != 0 ]]; then
    echo "[!] Script must be run as root"
    exit
fi

echo "[+] Set up stable debian system"
# Executes debootstrap foreign stage to create system for another architecture
debootstrap --include ntp,fake-hwclock,rsync,bwctl-client,iperf3,curl,bc,python3,python3-pip,dnsutils,ntp,jq \
--foreign --arch armhf stable rootfs http://ftp.debian.org/debian/

echo "[+] Alter permissions"
# Must alter permissions to allow ansible to read the root folder when copying to host
chmod 744 rootfs/root/

echo "[+] Transfer owping"
cp ../../common/files/owping rootfs/usr/bin/owping

echo "[+] Alter permissions"
chmod 0755 rootfs/usr/bin/owping

echo "[+] Touch script directory"
mkdir rootfs/root/scripts

echo "[+] Transfer scripts"
cp ../../common/files/wifi_scripts/ rootfs/root/scripts/

echo "[+] Transfer templates"
cp ../../common/templates rootfs/root/scripts/

echo "[+] Transfer systemd unit files"
cp ../../common/templates/make_ramdisk.service rootfs/etc/systemd/system/
cp ../../common/templates/wifi_probing.service rootfs/etc/systemd/system/

echo "[+] Transfer control program"
cp ../../common/files/control_program.py rootfs/root/scripts/
cp ../../common/files/control_program_wrapper.sh rootfs/root/scripts/


# TODO: Handle script & db configs
""" After deployment:
Enable and start services,
pip3 install elasticsearch,
wpa_supplicant,
Use default influxdb config if specified,
Reload systemd unit files
"""
