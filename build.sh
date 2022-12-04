#!/bin/bash

WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'

cd ..
printf ${MAGENTA}"ROOT PARTITION WILL BE SET AS 2ND ONE ON THE DEVICE\n\n"
fdisk -l >> devices
ifconfig -s >> nw_devices
cut -d ' ' -f1 nw_devices >> network_devices
rm -rf nw_devices