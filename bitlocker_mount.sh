#!/bin/bash
echo "-- BITLOCKER VOLUME MOUNT TOOL --"

read -rp "PARTITION (ej: sdb1): " PART
DEV_PATH="/dev/$PART"

# Does the partition exists?
if [ ! -b "$DEV_PATH" ]; then
    echo "Error: The partition $DEV_PATH doesn't exist."
    exit 1
fi

# Assignation of the mount directories. If you want other location or name, (for example, /media/disk) you need to change the values of the variables.
LOCKER="/mnt/bitlocker"
UNLOCKED="/mnt/bitlocker-unlocked"

# Creation of the mount directories (if they do not exist).
sudo mkdir -p "$LOCKER" "$UNLOCKED"

# Clean previous mount points (if they exist).
sudo umount "$UNLOCKED" 2>/dev/null
sudo umount "$LOCKER" 2>/dev/null

# Access to the bitlocker encrypted volume.
read -rsp "PASSWORD: " PASSW
echo
sudo dislocker -V "$DEV_PATH" -u"$PASSW" -- "$LOCKER"

if [ ! -f "$LOCKER/dislocker-file" ]; then
    echo "Error. The file dislocker-file could not be created."
    exit 1
fi

# Mount the volume.
sudo mount -o loop,rw -t ntfs "$LOCKER/dislocker-file" "$UNLOCKED"

# Confirmation.
if mountpoint -q "$UNLOCKED"; then
    echo "OK. Volume mounted in $UNLOCKED"
else
    echo "Error. The volume could not be mounted."
fi
