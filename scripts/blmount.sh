#!/bin/bash

# BITLOCKER VOLUME MOUNT TOOL BY rm4rts.

clear
echo "[/-\] BITLOCKER VOLUME MOUNT TOOL [/-\]"
echo -e "\n[+] Connected devices:"
echo
ls /dev
echo
read -rp "[+] Please, look at the /dev directory and enter the absolute route of the partition you want to access (For example: /dev/sdb1): " PART

# Does the partition exists? If it doesn't exist, the script finishes.
if [ ! -b "$PART" ]; then
	echo "[!] Error. The partition $PART does not exist. Try again. "
	echo "[!] Exiting..."
	sleep 1
	exit 1
fi

# Assignation of the mounting directories.
read -rp "[+] Where do you want to mount the dislocker-file file? " LOCKER
read -rp "[+] Where do you want to mount the accesible (unlocked) volume? " UNLOCKED

# If you don't want the program to be asking you everytime you execute it, change the values of $LOCKER and $UNLOCKED
#LOCKER="/mnt/bitlocker"
#UNLOCKED="/mnt/bitlocker-unlocked"

# Creation of the mount directories (if they do not exist).
sudo mkdir -p "$LOCKER" "$UNLOCKED"

# Clean previous mount points (if they exist).
sudo umount "$UNLOCKED" 2>/dev/null
sudo umount "$LOCKER" 2>/dev/null

# Access to the encrypted volume.
read -rsp "[+] Introduce the Bitlocker password of the volume: " PASSW
echo
sudo dislocker -V "$PART" -u"$PASSW" -- "$LOCKER"

if [ ! -f "$LOCKER/dislocker-file" ]; then
	echo "[!] Error."
	echo "[!] The file dislocker-file could not be created."
	echo "[+] Exiting..."
	sleep 1
	exit 1
fi

# Finally, it's time to mount the accesible volume.
sudo mount -o loop,rw -t ntfs "$LOCKER/dislocker-file" "$UNLOCKED"

# Confirmation that everything is OK.
if mountpoint -q "$UNLOCKED"; then
	echo "[+] OK. Volume correctly mounted in $UNLOCKED"
	echo "[!] Exiting..."
	sleep 1
else
	echo "[!] Error. The volume could not be mounted due to erros. Try again."
	echo "[!] Exiting..."
	sleep 1
	exit
fi
