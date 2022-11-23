#!/bin/bash
# use for make.conf, package.use
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'
cd ..
start_dir=$(pwd)
printf ${MAGENTA}"MAKE SURE YOUR ROOT PARTITION IS THE 2ND ONE ON THE DEVICE\n\n"
fdisk -l >> devices
ifconfig -s >> nw_devices
cut -d ' ' -f1 nw_devices >> network_devices
rm -rf nw_devices
sed -e "s/lo//g" -i network_devices
sed -e "s/Iface//g" -i network_devices
sed '/^$/d' network_devices
sed -e '\#Disk /dev/ram#,+5d' -i devices
sed -e '\#Disk /dev/loop#,+5d' -i devices