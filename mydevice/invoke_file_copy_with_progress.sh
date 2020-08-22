#!/bin/bash
USAGE=" 
[-] Usage: $0 <srcfile/srcfolder> <dstfile/dstfolder> [method=rsync]

Description: 
Script copies file from source to destination via one of the following methods:
rsync

Parameters:
    srcfile/srcfolder: Source folder/file to copy across to destination
    dstfile/dstfolder: Destination folder/file to receive the files
    method: Method to use to copy the files across. By default, rsync.
"

if [ $# -lt 2 ]; then
    echo "$USAGE"
    exit 1
fi
srcfile="$1"
dstfile="$2"
method=${3:-"rsync"}

echo "[*] Checking if file: $srcfile exists"
if [ ! -e "$srcfile" ]; then
    echo "[-] srcfile: $srcfile to copy does not exist"
    exit 1
fi

if [ "$method" == "rsync" ]; then
    if [ -f "$srcfile" ]; then
        echo "[*] Copy the file from srcfile: $srcfile to dstfile: $dstfile"
        rsync -ah --progress "$srcfile" "$dstfile"
    elif [ -d "$srcfile" ]; then 
        echo "[*] Copying files recursively from srcfolder: $srcfile to dstfolder: $dstfile"
        srcfile=$(echo "$srcfile" | sed -E "s/\/$//g")
        rsync -arh --progress "$srcfile/" "$dstfile"
    else
        echo "[-] Unknown src type: $srcfile"
        exit 1
    fi
else
    echo "[-] Unknown method: $method"
    exit 1
fi
