#!/bin/bash
#
# Script is used to read out the steps to install 'pacu' credentials
#

if [ $# -lt 2 ]; then
    echo "[-] $0 run [profile=default] [region=ap-southeast-2]"
    exit 1
fi
profile=${2:-"default"}
region=${3:-"ap-southeast-2"}

echo "[*] Displaying creds for profile: $profile from ~/.aws/credentials"
cat ~/.aws/credentials | grep -A4 "[$profile]"

echo "
    # Launch pacu
    cd /opt/pacu
    python3 pacu.py 

    # Create new session e.g. $profile

    # Also set the region
    set_regions $region

    # Then install AWS keys from above
    set_keys"

    read "[!] Press any key to continue..."
fi