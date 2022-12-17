#!/bin/bash

mklabel gpt \
unit mib
mkpart primary 1 3 # 1 to 3 mb
name 1 grub
set 1 bios_grub on
mkpart primary 3 131 # 131mb for boot
name 2 boot
mkpart primary 131 4227 # ~4g
name 3 swap
mkpart primary 4227 -1 # -1 to use all space
name 4 rootfs
quit

mkfs.fat -F 32 /dev/sda2
mkfs.ext4 /dev/sda4
mkswap /dev/sda3
swapon /dev/sda3

mkdir --parents /mnt/gentoo
mount /dev/sda4 /mnt/gentoo