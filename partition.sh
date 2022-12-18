#!/bin/bash
printf ${MAGENTA}"Enter the device name to install gentoo on (/dev/sda)\n>"
    read disk
    disk="${disk,,}"
    disk_chk=("/dev/$(disk)")
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