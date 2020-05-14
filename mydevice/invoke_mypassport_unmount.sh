#!/bin/bash
if [ $# -lt 1 ]; then

    echo "[-] $0 run [mypassport-name] [mount-path]"
    echo
    echo "Summary:"
    echo "This script unmounts an external My Passport drive to the specified "
    echo "This script unmounts the external My Passport drive to the specified "
    echo "mount path. To run the script, execute the script as:"
    echo "    $0 run"
    echo "Otherwise, this help text is displayed."
    echo 
    echo "Arguments:"
    echo "mypassport-name (str): Name of the external drive when attached. "
    echo "                       Defaults to 'My Passport'"
    echo "mount-path (file-path): Linux File path where the external drive was mounted."
    echo "                        Defaults to '/Volumes/NTFS/MyPassportNtfs/MyPassport'"
    exit
fi
mypassport_name=${2:-"My Passport"}
mount_path=${3:-"/Volumes/NTFS/MyPassportNtfs/MyPassport"}

echo "[*] Get MyPassport mount point..."
disk_mount_point=`diskutil list | grep -i "$mypassport_name" | tr -s "  " " " | awk -F" " '{print $7}'`

if [ -z "$disk_mount_point" ]; then
    echo "[-] disk mount point not found"
    exit
fi
full_disk_path="/dev/$disk_mount_point"

echo "[*] Unmounting existing disk mount point on full_disk_path: $full_disk_path..."
sudo umount $full_disk_path 2>/dev/null

echo "[*] Unmounting existing disk mount point on mount_path: $mount_path..."
sudo umount "$mount_path" 2>/dev/null

echo "[*] Unmounting existing disk mount point on diskutil_unmount: $mount_path..."
sudo diskutil unmount "$mount_path"

echo "[*] Check if mypassport external drive is mounted by listing the files..."
ls -l "$mount_path"
