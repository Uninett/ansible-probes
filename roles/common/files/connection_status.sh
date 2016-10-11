#!/bin/bash

eth=$([[ $(ifconfig eth0 | awk '/inet /{print $2}') == "" ]] && echo 0 || echo 1)
wlan=$([[ $(ifconfig wlan0 | awk '/inet /{print $2}') == "" ]] && echo 0 || echo 1)

printf '{"eth0":%d,"wlan0":%d}\n' $eth $wlan
