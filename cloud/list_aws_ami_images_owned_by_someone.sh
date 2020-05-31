#!/bin/bash
# 
# Script to list all accessible AWS images for a specific owner, by default
# owner is 'self' - is there are any interesting content within these images?
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=awscli] [owner=self] [profile=default] \
[region=ap-southeast-2] [outfile=out-aws-images-<profile>-<region>.txt]"
    exit 1
fi
method=${2:-"awscli"}
owner=${3:-"self"}
profile=${4:-"default"}
region=${5:-"ap-southeast-2"}
outfile=${6:-"out-aws-images-$owner-$profile-$region.txt"}

if [ "$method" == "awscli" ]; then
    echo "[*] List all AMIs/images owned by owner: $owner for profile: $profile \
and region: $region via awscli"
    aws ec2 describe-images --owners="$owner" --profile=$profile \
        --region=$region | tee "$outfile"
else
    echo "[-] Unknown method: $method"
    exit 1
fi