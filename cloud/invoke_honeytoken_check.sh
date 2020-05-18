#!/bin/bash
# 
# Script is used to check if credentials provided were honeytokens
# 
# Requires:
#    AWSCli and JQ command
# 
# Args:
#     method: Method to use. Following methods are currently available:
#         Using awshoney_checks which can check for honey tokens
#             https://github.com/RhinoSecurityLabs/Cloud-Security-Research/tree/master/AWS/awshoney_check
#         By default, 'awshoney_check' is availables.
# 
# By default, awshoney_check used.
#     profile: AWS profile. By default, 'default'
#     region: Region to use for making this request. By default, 'ap-southeast-2'
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=awshoney_check] [profile=default]"
    exit 1
fi
method=${2:-"awshoney_check"}
profile=${3:-"default"}

if [ "$method" == "awshoney_check" ]; then
    echo "[*] Running awshoney_check on credentials profile: $profile"
    python3 /opt/Cloud-Security-Research/AWS/awshoney_check/awshoney_check.py \
        -p "$profile"

    echo "[*] If 'ValidationException' received, then not likely honey token."
else
    echo "[-] Unknown method: $method"
fi