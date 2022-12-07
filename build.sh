#!/bin/bash
# MAKE SURE TO RUN THIS SCRIPT AFTER MOUNTING PARTITIONS AND APPLYING THE EXTENSIONS
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'

printf ${CYAN}"Are you mounting this first time?"
read answer
if [ $answer = "y" ]
then
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
emerge --config sys-libs/timezone-data
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

emerge-webrsync
emerge --sync
eselect profile list
emerge --ask --verbose --update --deep --newuse @world

emerge --ask app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

emerge --ask sys-kernel/linux-firmware
emerge --ask sys-kernel/gentoo-sources
eselect kernel list
ls -l /usr/src/linux
make && make modules_install
make install
emerge --ask sys-kernel/genkernel
genkernel all
ls /boot/vmlinu* /boot/initramfs*
# 143
break
else
        printf ${MAGENTA}"Skipping...\n"
fi

