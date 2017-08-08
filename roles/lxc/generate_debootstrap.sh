#!/bin/bash

echo "[+] Set up stable debian system"
debootstrap --foreign --arch armhf stable rootfs http://ftp.debian.org/debian/
