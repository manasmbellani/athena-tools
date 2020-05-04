#!/bin/bash
# 
# Script clears disk space by removing unwanted packages from Linux using apt-get
# 
echo "[*] Removing unwanted packages..."
sudo apt-get -y autoremove
echo; echo

echo "[*] Clearing cached packages from system..."
sudo apt-get -y autoclean
echo; echo
