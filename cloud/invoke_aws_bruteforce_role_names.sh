#!/bin/bash
#
# Script to brute-force the AWS roles in an account
# 
# Brute-force role names within the account given an account ID using either:
#    - assume_role_enum.py script: 
#          /opt/Cloud-Security-Research/AWS/assume_role_enum
#
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=assume_role_enum] [profile=default] \
[account_id='']"
    exit 1
fi
method=${2:-"assume_role_enum"}
profile=${3:-"default"}
account_id="${4}"

if [ "$method" == "assume_role_enum" ]; then
    if [ -z "$account_id" ]; then
        echo "[-] account: $account_id must be provided for script to run"
    else
        cd /opt/Cloud-Security-Research/AWS/assume_role_enum
        python3 assume_role_enum.py -p "$profile" -i "$account_id"
    fi
else
    echo "[-] Unknown method: $method"
fi