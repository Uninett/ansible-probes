#!/bin/bash

probe_id=$(ifconfig eth0 | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | sed 's/://g')
echo $probe_id > probe_id.txt

# The existing scripts merge the ID with the measurement name
# by themselves, which makes it cumbersome to parse (and also
# breaks some of the scripts if the ID is non-empty). Therefore
# we set the old ID to be empty. This is a just a temporary fix.
echo "I=" > probe.id
