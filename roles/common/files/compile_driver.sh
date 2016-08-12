#!/bin/bash

# This script downloads the necessary files for cross
# compilation of the rtl8812au wifi-driver. It downloads
# files from both the remote raspberry pi, and from the
# internet.

# IMPORTANT. This script:
#       1. Only works when the remote RPi runs kali linux
#       2. Takes a long time (expect around 1 hour)

# ALSO IMPORTANT:
#   - Ordinary compilation dependencies must already
#     be present on the host machine. These dependencies
#     are mainly
#       * build-essential
#       * git
#       * rsync
#     but there may be more.

if [[ $# != 3 ]]; then
    echo "Usage: $(basename ${0}) <remote_ip> <remote_kernel_version> <preferred_driver_directory>"
    exit 1
fi

REMOTE_IP=${1}
REMOTE_KERNEL=${2}
DRIVER_DIR=${3}

# Install necessary programs (other programs may also
# be necessary)
# (Disabled, because the driver cannot compile without
# interventation if root is needed)
# sudo apt-get install build-essential git rsync

# Make a working directory
mkdir ~/arm-stuff
cd ~/arm-stuff

# Download the cross compilation toolchain
if [ ! -d "rpi-tools" ]; then
    echo "Downloading cross compilation toolchain..."
    git clone https://github.com/raspberrypi/tools.git rpi-tools
fi

# Copy the kernel source from the RPi
if [ ! -d "rpi-kernel-${REMOTE_KERNEL}" ]; then
    echo "Downloading remote kernel source..."
    rsync -chavzP root@${REMOTE_IP}:/usr/src/kernel rpi-kernel-${REMOTE_KERNEL}
fi

# Define some env vars for the compilation
export CCPREFIX=~/arm-stuff/rpi-tools/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin/arm-bcm2708-linux-gnueabi-

export KERNEL_SRC=~/arm-stuff/rpi-kernel-${REMOTE_KERNEL}/kernel

cd ${KERNEL_SRC}

# Clean up the kernel source tree
make mrproper

# Download the remote kernel configuration
rsync -chazP root@${REMOTE_IP}:/usr/src/*.config .config

# Compile the kernel
echo "Compiling linux kernel..."
make ARCH=arm CROSS_COMPILE=${CCPREFIX} oldconfig
make ARCH=arm CROSS_COMPILE=${CCPREFIX} -j $(nproc)

cd ~/arm-stuff

# Download driver
if [ ! -d "rtl8812au" ]; then
    echo "Downloading rtl8812au wifi driver..."
    git clone https://github.com/abperiasamy/rtl8812AU_8821AU_linux.git rtl8812au
fi

cd rtl8812au

# Modify driver's makefile
sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/g' Makefile

# Compile driver
echo "Compiling driver..."
make clean
make ARCH=arm CROSS_COMPILE=${CCPREFIX} KSRC=${KERNEL_SRC} -j $(nproc)

mv 8812au.ko ${DRIVER_DIR}/${REMOTE_KERNEL}-8812au.ko

echo "Done!"
