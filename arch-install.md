# Arch install with live key guide

From <https://wiki.archlinux.org/title/Installation_guide>

Does not work with secure boot

## Live key

### Linux

`dd bs=4M if=path/to/archlinux-version-x86_64.iso of=/dev/sdx conv=fsync oflag=direct status=progress`

or

`Ventoy`

### Windows

`Ventoy`

---

## Live Boot

### Connect to Wifi

```bash
iwctl device list
iwctl station $device connect SSID
```

If no need for lvm or encrypt, run `archinstall` and go to **First Boot** section

### Partitioning the hard disk

```bash
# 2 partitions : 256M boot & 100%FREE filesystem
cfdisk /dev/sdX
```
#### Crypt

```bash
modprobe dm-crypt
cryptsetup luksFormat /dev/lvm_disk
cryptsetup open --type luks /dev/lvm_disk cryptlvm
```

#### LVM

```bash
pvcreate /dev/sdXx
vgcreate lvm /dev/sdXx
```

Create logical volumes, for a basic setup we'd need one for root, swap and home.

```bash
lvcreate -L 30G lvm -n root
lvcreate -L 8G lvm -n swap
lvcreate -l 100%FREE lvm -n home
```

### Format the file systems and enable swap

List existing partition using `lsblk`.

Format the boot partition first:

`mkfs.fat -F32 /dev/sdXx`

Format the other partitions:

```
mkfs.ext4 /dev/lvm/root
mkfs.ext4 /dev/lvm/home
```

Enable Swap:

```
mkswap /dev/lvm/swap
swapon /dev/lvm/swap
```

Mount the partitions:

```
mount /dev/lvm/root /mnt
mkdir -p /mnt/home
mount /dev/lvm/home /mnt/home
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
```

### Install the base packages

Install the base packages using _pacstrap_:

`pacstrap -K /mnt base linux linux-firmware openssh git vim dhcpcd wpa_supplicant dialog netctl lvm2`

### Configuration

#### Generate the fstab file:

```
# -U UUID | -L Labels
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Log to partition:

`arch-chroot /mnt`

#### Initramfs

First we need to edit `/etc/mkinitcpio.conf` to provide support for lvm2.
Edit the file and insert lvm2 between block and filesystems like so:

`HOOKS="base udev ... block lvm2 encrypt filesystems"`

Generate the initramfs image:

`mkinitcpio -P`

### Install a boot loader

Install systemd-boot to the EFI system partition:

`bootctl install`

```bash
#/boot/loader/loader.conf
default arch
timeout 4
editor 0
```

```bash
#/boot/loader/entries/arch.conf
title	Arch
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
# initrd  /intel|amd-ucode.img
options	UUID={UUID}:lvm2 root=/dev/lvm/root rw
# {UUID}=lwqlkdnwlkwndlqkwn << `blkid`
# options cryptdevice=UUID={UUID}:cryptlvm root=/dev/volume/root quiet rw

```

#### Windows Dual-Boot

```bash
cp -r /sdX/EFI/Microsoft /boot/EFI/Microsoft
bootctl list
bootctl update
```

### Root password

Set the root password with:

`passwd`

### Unmount the partitions and reboot

```bash
exit
umount -R /mnt
reboot
```

---

### First Boot

#### Set Config

```bash
dotfiles/install.sh
hostnamectl hostname {}
timedatectl set-ntp 1
timedatectl set-timezone {}
edit /etc/locale.gen -> `locale-gen`
systemctl enable dhcpcd.service
systemctl enable systemd-resoled.service
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

```

#### Network

```bash
wifi-menu
netctl list | start | enable
```
