#!/bin/bash
# 
# Script will list all regions for a given profile - generally ALL regions 
# can be listed, however best to check
# 
# Requires:
#    AWSCli and JQ utility
# 
# Args:
#     profile: AWS profile. By default, 'default'
#     region: Region to use for making this request. By default, 'ap-southeast-2'
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [profile=default] [region=ap-southeast-2]"
    exit 1
fi
profile=${2:-"default"}
region=${3:-"ap-southeast-2"}

echo "[*] List all regions using the credentials profile: $profile"
aws ec2 describe-regions --profile=$profile --region=$region \
| jq -r ".Regions[].RegionName"