#!/bin/bash
# Script to check if AppStream is in use as it is vulnerable to leaking AWS
# Appstream 2.0 keys from the instances via Appstream e.g.
# 
#     
# 
# Exploit to steal the AWS keys via Appstream: 
#     https://github.com/RhinoSecurityLabs/Cloud-Security-Research/tree/master/AWS/appstream_awsowned_access_keys
# 

if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=awscli] [profile=default] [region=ap-southeast-2]"
    exit 1
fi
method=${2:-"awscli"}
profile=${3:-"default"}
region=${4:-"ap-southeast-2"}

if [ "$method" == "awscli" ]; then
    echo "[*] Get the list of all appstream stacks for profile: $profile, region: $region"
    aws appstream describe-stacks --profile=$profile --region=$region \
        | jq -r ".Stacks[]"
    
    echo "[*] Get the list of all appstream stacks for profile: $profile, region: $region"
    aws appstream describe-stacks --profile=$profile --region=$region \
        | jq -r ".Fleets[]"
else
    echo "[-] Unknown method: $method"
fi