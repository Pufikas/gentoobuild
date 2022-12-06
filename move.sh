#!/bin/bash

find -maxdepth 1 -printf '%p\n' -type d -name "gentoobuild"
mv ~/Documents/gentoobuild/gentoo/locale.gen /etc/
mv ~/Documents/gentoobuild/gentoo/02locale.gen /etc/env.d/
mv ~/Documents/gentoobuild/gentoo/fstab /etc/
mv ~/Documents/gentoobuild/gentoo/hostname /etc/
mv ~/Documents/gentoobuild/gentoo/hosts /etc/
mv ~/Documents/gentoobuild/gentoo/hwclock /etc/conf.d/
mv ~/Documents/gentoobuild/gentoo/keymaps /etc/conf.d/
mv ~/Documents/gentoobuild/gentoo/make.conf /etc/portage/
mv ~/Documents/gentoobuild/gentoo/net /etc/conf.d/
mv ~/Documents/gentoobuild/gentoo/rc.conf /etc/
echo "Europe/Vilnius" > /etc/timezone
echo "Successfully moved files"
