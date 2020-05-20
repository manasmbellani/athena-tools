#!/bin/bash
# 
# Script identifies actions to take when OS (Linux/Mac) is woken up e.g. waking 
# wifi up on Mac/iOS
# 

echo "[*] Determining OS in use"
os="$(uname)"

echo "[*] Getting running script's directory"
script_dir=$(dirname "$0")

if [ "$os" == "Darwin" ]; then
    echo "[*] Shutting down Wifi interface on Mac"
    $script_dir/update_wifi_interface.sh "enable"
else
    :
fi
