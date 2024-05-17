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

for automatic installation, run `archinstall` and go to **First Boot** section

### Partitioning the hard disk

```bash
# 2 partitions : 256M boot & 100%FREE filesystem
cfdisk /dev/sdX
```

### Install the base packages

Install the base packages using _pacstrap_:

`pacstrap -K /mnt base linux linux-firmware openssh git vim dhcpcd wpa_supplicant dialog netctl`

### Configuration

#### Generate the fstab file:

```
# -U UUID | -L Labels
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Log to partition:

`arch-chroot /mnt`

#### Initramfs

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
systemctl enable systemd-resoled.service
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

```

#### Network

```bash
wifi-menu
netctl list | start | enable
```
