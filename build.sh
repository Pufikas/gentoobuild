#!/bin/bash
# MAKE SURE TO RUN THIS SCRIPT AFTER MOUNTING PARTITIONS AND APPLYING THE EXTENSIONS
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'


printf ${MAGENTA}"Starting\n>"
sleep 3

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
printf ${MAGENTA}"Mounted, continue?\n>"
        read mount
if [[ $mount = "y" ]]; then

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
sleep 5
emerge --ask net-misc/dhcpcd
rc-update add dhcpcd default
rc-service dhcpcd start
emerge --ask --noreplace net-misc/netifrc
cd /etc/init.d
ln -s net.lo net.enp0s3
rc-update add net.enp0s3 default
cd ..
cd ..
emerge --ask app-admin/sysklogd
rc-update add sysklogd default
emerge --ask sys-process/cronie
rc-update add cronie default
emerge --ask sys-apps/mlocate
emerge --ask net-misc/chrony
rc-update add chronyd default
emerge --ask --verbose sys-boot/grub
else
        printf ${MAGENTA}"Skipping...\n"
fi

