#!/usr/bin/env bash

IFS=$'\n'

# Set bootloader block location
esp="/dev/sda"

# Find root partition UUID
pUUID=$(findmnt -no PARTUUID -T /)
label="EFISTUB"

# Set Kernel Parameters
kernel=$(ls /boot/*-linux 2>/dev/null)
kernel="${kernel//*\/}"

# Check if there any microcode we could use
microcode=$(ls /boot/*ucode.img 2>/dev/null)
microcode="${microcode//*\/}"

# If user has more than 2 initramfs, try adding both to EFI as separate
initramfss=()
for initramfs in $(ls /boot/*-linux.img 2>/dev/null); do
	initramfss+=(${initramfs//*\/})
done

# Additional arguments
args="quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3"

# Create bootable entry which loads with booster
for initramfs in ${initramfss[@]}; do
	efibootmgr -cd "${esp}" -L "${label}-${initramfs//-*}" -l "/${kernel}" -u "root=PARTUUID=${pUUID} rw initrd=\\${microcode} initrd=\\${initramfs} ${args}" -v
done