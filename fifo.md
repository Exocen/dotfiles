## usb live creation : dd or ether:
dd if=arch.iso of=/dev/sdX
## must have uefi run : ls /sys/firmware/efi/efivars
## partitionning 200M boot + rest:
cfdisk /dev/sdXX
mkfs.ext2 /dev/sdXX
## / root encryption:
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/sdXX
cryptsetup luksOpen /dev/sdXX luks
## lvm partitions:
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
# lvcreate --size 8G vg0 --name swap
lvcreate -l +100%FREE vg0 --name root
mkfs.ext4 /dev/mapper/vg0-root
# mkswap /dev/mapper/vg0-swap
## mount :
mount /dev/mapper/vg0-root /mnt
mkdir /mnt/boot
mount /dev/sdXX /mnt/boot
# swapon /dev/mapper/vg0-swap
## linux install
pacstrap -i /mnt base base-devel linux linux-firmware openssh git vim lvm man-db man-pages texinfo netctl wpa_supplicant dhcpcd dialog sudo
## fstab gen
genfstab -pU /mnt >> /mnt/etc/fstab
#tmpfs	/tmp	tmpfs	defaults,noatime,mode=1777	0	0
arch-chroot /mnt /bin/bash
passwd
## timedatectl
##locales
vim /etc/locale.gen (uncomment en_US.UTF-8 UTF-8)
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
#hosts
echo myhostname > /etc/hostname
# /etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.1.1	myhostname.localdomain	myhostname
## mkinitcpio
# vim /etc/mkinitcpio.conf
Add 'ext4' to MODULES
Add 'encrypt' and 'lvm2' to HOOKS before 'filesystems'
mkinitcpio -p linux
pacman -S grub
mkdir -p /mnt/boot/EFI/GRUB
grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB
##vim  /etc/default/grub edit the line GRUB_CMDLINE_LINUX sdxx:root
GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdXX:luks:allow-discards"
grub-mkconfig -o /boot/grub/grub.cfg
## finish
exit
umount -R /mnt
# swapoff -a
systemctl enable systemd-networkd systemd-resolved
