#!/bin/bash
# 
# Script identifies OS in use and puts the device to sleep in Mac Or Linux
# 

echo "[*] Determining OS in use"
os="$(uname)"

echo "[*] Getting running script's directory"
script_dir=$(dirname "$0")

if [ "$os" == "Darwin" ]; then
    echo "[*] Shutting down Wifi interface on Mac"
    $script_dir/update_wifi_interface.sh "disable"

    echo "[*] Putting macbook to sleep via pmset"
    pmset sleepnow
else
    echo "[*] Putting macbook to sleep via systemctl"
    systemctl suspend
fi
