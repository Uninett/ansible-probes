#!/bin/bash

if grep -qs '/mnt/usbdisk' /proc/mounts; then
 echo "yes"
else
 echo "no"
fi
