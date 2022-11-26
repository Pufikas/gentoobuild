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
    printf "Would you like to auto partition the %s?"
    read auto_provs_ans
    wipefs -a $disk_chk
            parted -a optimal $disk_chk --script mklabel gpt
            parted $disk_chk --script mkpart primary 1MiB 3MiB
            parted $disk_chk --script name 1 grub
            parted $disk_chk --script set 1 bios_grub on
            parted $disk_chk --script mkpart primary 3MiB 131MiB
            parted $disk_chk --script name 2 boot
            parted $disk_chk --script mkpart primary 131MiB 4227MiB
            parted $disk_chk --script name 3 swap
            parted $disk_chk --script -- mkpart primary 4227MiB -1
            parted $disk_chk --script name 4 rootfs
            parted $disk_chk --script set 2 boot on
            part_1=("${disk_chk}1")
            part_2=("${disk_chk}2")
            part_3=("${disk_chk}3")
            part_4=("${disk_chk}4")
            mkfs.fat -F 32 $part_2
            mkfs.ext4 $part_4
            mkswap $part_3
            swapon $part_3
            rm -rf devices
            clear
            sleep 2
            break
             elif [ "$auto_prov_ans" = "n" ]; then
            printf ${MAGENTA}"Exiting"
            done
            printf "enter a number for the stage 3 you want to use\n"
printf "0 = regular\n1 = regular hardened\n2 = hardened musl\n3 = vanilla musl\n>"
read stage3select
printf ${CYAN}"Enter the username for your NON ROOT user\n>"
#There is a possibility this won't work since the handbook creates a user after rebooting and logging as root
read username
username="${username,,}"
printf ${CYAN}"Enter Yes to make a kernel from scratch, edit to edit the hardened config, or No to use the default hardened config\n>"
read kernelanswer
kernelanswer="${kernelanswer,,}"
printf ${CYAN}"Enter your Hostname\n>"
read hostname
printf ${CYAN}"Do you want to replace OpenSSL with LibreSSL (recommended) in your system?(yes or no)\n>"
read sslanswer
sslanswer="${sslanswer,,}"
printf ${CYAN}"Do you want to do performance optimizations. LTO -O3 and Graphite?(yes or no)\n>"
read performance_opts
performance_opts="${performance_opts,,}"
printf ${LIGHTGREEN}"Beginning installation, this will take several minutes\n"

#copying files into place
mount $part_4 /mnt/gentoo
mv deploygentoo-master /mnt/gentoo
mv deploygentoo-master.zip /mnt/gentoo/
mv network_devices /mnt/gentoo/deploygentoo-master/
cd /mnt/gentoo/deploygentoo-master

install_vars=/mnt/gentoo/deploygentoo-master/install_vars
cpus=$(grep -c ^processor /proc/cpuinfo)
pluscpus=$((cpus+1))
echo "$disk" >> "$install_vars"
echo "$username" >> "$install_vars"
echo "$kernelanswer" >> "$install_vars"
echo "$hostname" >> "$install_vars"
echo "$sslanswer" >> "$install_vars"
echo "$cpus" >> "$install_vars"
echo "$part_3" >> "$install_vars"
echo "$part_1" >> "$install_vars"
echo "$part_2" >> "$install_vars"
echo "$part_4" >> "$install_vars"
echo "$performance_opts" >> "$install_vars"
cat network_devices >> "$install_vars"
rm -f network_devices

case $stage3select in
  0)
    GENTOO_TYPE=latest-stage3-amd64
    ;;
  1)
    GENTOO_TYPE=latest-stage3-amd64-hardened
    ;;
  2)
    GENTOO_TYPE=latest-stage3-amd64-musl-hardened
    ;;
  3)
    GENTOO_TYPE=latest-stage3-amd64-musl-vanilla
    ;;
esac

            