# Choose a desktop openrc iso
# configure the user
passwd # passwd for root user

useradd -m -G users pufikas
passwd pufikas
# switch
su - pufikas

# To open handbook on second terminal press ALT + F2 
links wiki.gentoo.org/wiki/Handbook:AMD64
# Can be switched back to back with ALT + Fx keys


ifconfig 
# check if the net is eth0 or enp0s3
ping gentoo.org
# auto setup net
net-setup eth0 / or enp0s3

# or using dhcp
dhcpcd enp0s3 / or eth0

#
#     PARTITION
#

#   /dev/sda1	fat32 (UEFI) or ext4 (BIOS - aka Legacy boot)	256M	Boot/EFI system partition
#   /dev/sda2	(swap)	RAM size * 2	Swap partition
#   /dev/sda3	ext4	Rest of the disk	Root partition

fdisk /dev/sda
p
n, 1 , - , +256M # creating a disklabel /boot
# mark the partition as efi system
t, 1, 1

# swap partition
n, 2, - , +4G
t, 2
# root partition
n, 3, -, -,
p
w # save the partition

# apply the filesystems
mkfs.vfat -F 32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
# mounting
mkdir --parents /mnt/gentoo
mount /dev/sda3 /mnt/gentoo

date

#
#   DOWNLOADING STAGE TARBALL
#

cd /mnt/gentoo
links gentoo.org/downloads/mirrors/
gpg --verify stage3-amd64-<release>-<init>.tar.?(bz2|xz) #verify
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner #unpack

# place the make.conf file to /mnt/gentoo/etc/portage/make.conf

#
#   CHROOTING
#

mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
# check the file
cat /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

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

# mount boot
mount /dev/sda1 /boot
# portage
emerge-webrsync
emerge --sync
eselect profile list

emerge --ask --verbose --update --deep --newuse @world