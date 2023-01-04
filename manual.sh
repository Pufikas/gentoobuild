# 
#
#   FOLLOW THE DISK PARTITION AT THE GENTOO HANDBOOK
#   OR REFFER TO THE PARTITIONS.TXT
#



# stage 3 install
cd /mnt/gentoo

wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20221211T170150Z/stage3-amd64-desktop-openrc-20221211T170150Z.tar.xz

links gentoo.org/downloads/mirrors
gpg --verify stage3-amd64-<release>-<init>.tar.?(bz2|xz) #verify
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner #unpack
# might want to install the minimal openrc tar.xz
rm -rf stage3-
# Mirrors
# we might not need this - emerge --ask app-portage/mirrorselect
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
nano /mnt/gentoo/etc/portage/make.conf # configure the use flags

mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cat /mnt/gentoo/etc/portage/repos.conf/gentoo.conf


links github.com/Pufikas/gentoobuild # download zip file
unzip gentoo...

# place the make.conf file to /mnt/gentoo/etc/portage/make.conf

#
#   CHROOTING
#

# we can use mount.sh to do this auto
# make sure to add - chmod -x mount.sh for it to run
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
# end of mount.sh 
eselect profile list # choose a set with eselect profile set X

emerge --ask --verbose --update --deep --newuse @world
# emerge -avUDN @world

emerge --ask app-portage/cpuid2cpuflags
cpuid2cpuflags # checking if this is up
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags # copying

mkdir /etc/portage/package.license

# timezone
echo "Europe/Vilnius" > /etc/timezone
emerge --config sys-libs/timezone-data

nano -w /etc/locale.gen # uncomment these
# en_US ISO-8859-1
# en_US.UTF-8 UTF-8

locale-gen
eselect locale list # and select en_US

# FSTAB file
nano /etc/fstab # refer to partitions.txt

# reloading the env
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# linux firmware
emerge --ask sys-kernel/linux-firmware

# kernel sources
emerge --ask sys-kernel/gentoo-sources

# selecting kerner
eselect kernel list

# checking the kernel
ls -l /usr/src/linux

# compiling
cd /usr/src/linux

# installing the kernel auto
emerge --ask sys-kernel/genkernel
genkernel all

# CHECK THE NAMES OF KERNELS MODULES
ls /boot/vmlinu* /boot/initramfs*
# vmlinuz-5.15.80-gentoo... iitframs-5.15.80-gentoo...img


# kernel modules / finds all the kernel versions (replace the <kernel version> with the compiled one)
find /lib/modules/<kernel version>/ -type f -iname '*.o' -or -iname '*.ko' | less
# kernel version example /5.15.60-gentoo...

#
# DONT FORGET FSTAB FILE

# install dhcpcd
emerge --ask net-misc/dhcpcd
# enable it
rc-update add dhcpcd default
rc-service dhcpcd start
# emerge netifirc
emerge --ask --noreplace net-misc/netifrc
# start at boot
cd /etc/init.d
ln -s net.lo net.enp0s3
rc-update add net.enp0s3 default
# system logger
emerge --ask app-admin/sysklogd
# enable
rc-update add sysklogd default
# cron daemon
emerge --ask sys-process/cronie
rc-update add cronie default
# file indexing
emerge --ask sys-apps/mlocate
# time synchronize
emerge --ask net-misc/chrony
rc-update add chronyd default
# grub
emerge --ask --verbose sys-boot/grub
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
# install
grub-install --target=x86_64-efi --efi-directory=/boot
# if error
# mount -o remount,rw /sys/firmware/efi/efivars
grub-install --target=x86_64-efi --efi-directory=/boot --removable

# config 
grub-mkconfig -o /boot/grub/grub.cfg

# reboot
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot