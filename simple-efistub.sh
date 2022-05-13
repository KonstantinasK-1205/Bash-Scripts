#!/usr/bin/env bash

IFS=$'\n'

# Set EFI record label which you see in Boot Select
label="EFISTUB"

# Set bootloader block location
esp="/dev/sda"

# Additional kernel arguments
args="quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3"

# Find root partition UUID
pUUID=$(findmnt -no PARTUUID -T /)

# Set Kernel Parameters
kernel=$(ls /boot/*-linux 2>/dev/null)
kernel="${kernel//*\/}"

# Check if there any microcode we could use
microcode=$(ls /boot/*ucode.img 2>/dev/null)
microcode="${microcode//*\/}"

# Find root filesystem image, if there is more than one, add all
rootFSImages=()
for initramfs in $(ls /boot/*-linux.img 2>/dev/null); do
	rootFSImages+=(${initramfs//*\/})
done

# Create bootable entry which loads with initramfs
# if there is more than one initramfs, create record for each as there is a
# bug for example with booster, that sometimes it doesn't generate needed kernel
# resulting in non working boot, so if user has mkinitcpio image use it as backup
for initramfs in ${rootFSImages[@]}; do
	efibootmgr -cd "${esp}" -L "${label}-${initramfs//-*}" -l "/${kernel}" -u "root=PARTUUID=${pUUID} rw initrd=\\${microcode} initrd=\\${initramfs} ${args}" -v
done