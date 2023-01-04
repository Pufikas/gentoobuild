#!/bin/bash
# does not work
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/ # dns info

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

# chroot

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"

mount /dev/sda1 /boot

# portage
emerge-webrsync
emerge --sync

printf("END OF SCRIPT\n")