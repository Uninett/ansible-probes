#!/bin/bash

# Loading interval T from file which gives time between measurements

. ${SCRIPT_DIR}probe.parameters

cp /root/scripts/commit.id.boot ${SCRIPT_DIR}commit.id.old

sudo service ntp stop
sudo ntpdate -b -u ntp.uninett.no
sudo service ntp start

CONT=true

while $CONT ; do
   ${SCRIPT_DIR}measurements.sh
   if [ -f ${SCRIPT_DIR}new.config.ready ];
   then
     CONT=false
   else
     CONT=true
   fi
   sleep $SLEEP_TIMER
done

# If new config has been downloaded from ytelse.labs.uninett.no the probe is reloaded

sudo shutdown -r 0
