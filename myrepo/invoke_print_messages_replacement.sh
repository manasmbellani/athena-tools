#!/bin/bash
# 
# Script to replace the common functions with echo counterparts e.g. echo '[-]
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 <script_name>"
    exit 1
fi
script_name="$1"

echo "[*] Replacing 'verbose' function in script: $script_name"
sed -i .bak 's/verbose "/echo "[*] /g' "$script_name"
sed -i .bak "s/verbose '/echo '[*] /g" "$script_name"

echo "[*] Replacing 'debug' function in script: $script_name"
sed -i .bak 's/debug "/echo "[*] /g' "$script_name"
sed -i .bak "s/debug '/echo '[*] /g" "$script_name"

echo "[*] Replacing 'info' function in script: $script_name"
sed -i .bak 's/info "/echo "[+] /g' "$script_name"
sed -i .bak "s/info '/echo '[+] /g" "$script_name"

echo "[*] Replacing 'error' function in script: $script_name"
sed -i .bak 's/error "/echo "[-] /g' "$script_name"
sed -i .bak "s/error '/echo '[-] /g" "$script_name"

echo "[*] Replacing 'warning' function in script: $script_name"
sed -i .bak 's/warning "/echo "[!] /g' "$script_name"
sed -i .bak "s/warning '/echo '[!] /g" "$script_name"

echo "[*] Removing the .bak file: $script_name.bak"
rm "$script_name.bak"