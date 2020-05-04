#!/bin/bash
# 
# Script identifies OS in use and puts the device to sleep in Mac Or Linux
# 
echo "[*] Determining OS in use"
os="$(uname)"

if [ "$os" == "Darwin" ]; then
    echo "[*] Putting macbook to sleep via pmset"
    pmset sleepnow
else
    echo "[*] Putting macbook to sleep via systemctl"
    systemctl suspend
fi
