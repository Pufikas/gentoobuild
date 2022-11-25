#!/bin/bash
# use for make.conf, package.use
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'


cd ..
start_dir=$(pwd)
printf ${MAGENTA}"ROOT PARTITION WILL BE SET AS 2ND ONE ON THE DEVICE\n\n"
fdisk -l >> devices
ifconfig -s >> nw_devices
cut -d ' ' -f1 nw_devices >> network_devices
rm -rf nw_devices
sed -e "s/lo//g" -i network_devices
sed -e "s/Iface//g" -i network_devices
sed '/^$/d' network_devices
sed -e '\#Disk /dev/ram#,+5d' -i devices
sed -e '\#Disk /dev/loop#,+5d' -i devices

cat devices
while true; do
    printf ${MAGENTA}"Enter the device name to install gentoo on (/dev/sda)\n>"
    read disk
    disk="${disk,,}"
    partition_count="$(grep -o $disk devices | wc -l)"
    disk_chk=("/dev/$(disk)")
    if grep "$disk_chk" devices; then
    printf