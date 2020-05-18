#!/bin/bash
# 
# Script to brute-force AWS permissions for a user account using various methods
# 
# Args:
#     method: Method to use. Available methods:
#         nimbostratus: Using the old nimbostratus tool for dumping creds.
#         By default, consider using method 'nimbostratus'
#     profile: Credentials profile to use for running scans using this tool
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=nimbostratus] [profile=default]"
    exit 1
fi
method=${2:-"nimbostratus"}
profile=${3:-"default"}

cwd="$(pwd)"
if [ "$method" == "nimbostratus" ]; then

    echo "[*] Switching to nimbosstratus repo"
    cd /opt/nimbostratus

    echo "[*] Getting credentials for nimbostratus from profile"
    access_key_id=$(cat ~/.aws/credentials | grep -A3 -i "$profile" \
        | grep aws_access_key_id | head -n1 | cut -d ' ' -f3)
    secret_access_key=$(cat ~/.aws/credentials | grep -A3 -i "$profile" \
        | grep aws_secret_access_key | head -n1 | cut -d ' ' -f3)

    echo "[*] Execute nimbostratus with credentials for profile: $profile"
    ./nimbostratus -v dump-permissions \
        --access-key "$access_key_id" \
        --secret-key "$secret_access_key"
else
    echo "[-] Unknown method: $method"
fi
