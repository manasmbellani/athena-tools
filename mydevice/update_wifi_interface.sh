#!/bin/bash
# 
# Script can be used to modify Wifi status (turn it on/off) from command line
# Currently support on Mac OS X only.
# 
# Taken from:
#     https://osxdaily.com/2011/05/31/enable-disable-airport-wireless-connections-command-line/
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 <status=enable|disable> [wifi-interface=en0]"
    exit 1
fi
status=${1:-"enable"}
interface=${2:-"en0"}

os=$(uname)
if [ "$os" == "Darwin" ]; then
    if [ "$status" == "disable" ]; then
        interface_status="off"
    elif [ "$status" == "enable" ]; then
        interface_status="on"
    else
        echo "Unsupported status: $status"
        exit 1
    fi

    echo "[*] Setting Wifi status to '$interface_status'"
    networksetup -setairportpower en0 "$interface_status"
else
    echo "[-] Unsupported OS: $os"
    exit 1
fi