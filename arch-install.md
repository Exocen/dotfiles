https://wiki.archlinux.org/title/Installation_guide

### Live key

#### Linux

`dd bs=4M if=path/to/archlinux-version-x86_64.iso of=/dev/sdx conv=fsync oflag=direct status=progress`

#### Windows

`Rufus`

---

## Live Boot

### Connect to Wifi

```bash
iwctl device list
iwctl station $device connect SSID
```

### Partitioning the hard disk

```bash
# 2 partitions : 512M boot & 100%FREE filesystem
cfdisk /dev/sdX
```

#### LVM

`pvcreate /dev/sdXx`
`vgcreate lvm /dev/sdXx`

Create logical volumes, for a basic setup we'd need one for root, swap and home.

```
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

`pacstrap -K /mnt base linux linux-firmware openssh git vim dhcpcd wpa_supplicant dialog netctl`

### Configuration

#### Generate the fstab file:

```
# -U UUID | -L Labels
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Change root:

`arch-chroot /mnt`

#### Initramfs

First we need to edit `/etc/mkinitcpio.conf` to provide support for lvm2.
Edit the file and insert lvm2 between block and filesystems like so:

`HOOKS="base udev ... block lvm2 filesystems"`

Generate the initramfs image:

`mkinitcpio -P`

### Install a boot loader

Install systemd-boot to the EFI system partition:

`bootctl install`

#### Windows Dual-Boot

```
cp -r /mnt/EFI/Microsoft /boot/EFI/Microsoft
bootctl list
bootctl update
```

### Root password

Set the root password with:

`passwd`

### Unmount the partitions and reboot

```
exit
umount -R /mnt
reboot
```

---

### First Boot

#### Set Config

```
hostnamectl
timedatectl
localectl
resolvctl
ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

#### Network

```
wifi-menu
netctl list | enable | start
```
