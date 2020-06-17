#!/bin/bash
# 
# Script copies file from source to destination via one of the following methods:
#     rsync
# 
if [ $# -lt 2 ]; then
    echo "[-] $0 <srcfile> <dstfile> [method=rsync]"
    exit 1
fi
srcfile="$1"
dstfile="$2"
method=${3:-"rsync"}

echo "[*] Checking if file: $srcfile exists"
if [ ! -f "$srcfile" ]; then
    echo "[-] srcfile: $srcfile to copy does not exist"
    exit 1
fi

if [ "$method" == "rsync" ]; then
    echo "[*] Copy the file from srcfile: $srcfile to dstfile: $dstfile"
    rsync -ah --progress "$srcfile" "$dstfile"
fi
