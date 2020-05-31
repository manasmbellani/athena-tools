#!/bin/bash
# 
# Script to list all accessible AWS snapshots for a specific owner that we could 
# restore , by default - is there are any interesting content within these snapshots?
# 
# Requires ec2:DescribeSnapshots permission to be able to describe ALL snapshots
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
outfile=${6:-"out-aws-snapshots-$owner-$profile-$region.txt"}

if [ "$method" == "awscli" ]; then
    echo "[*] List all AWS snapshots owned by the owner: $owner for profile: \
$profile, and region: $region via awscli"
    aws ec2 describe-snapshots --owner="$owner" --profile=$profile \
        --region=$region | tee "$outfile"

    echo "[*] List all AWS snapshots restorable by owner id: $owner for profile: \
$profile and region: $region via awscli"
    aws ec2 describe-snapshots --restorable-by-user-ids="$owner" \
--profile=$profile --region=$region | tee "$outfile"
else
    echo "[-] Unknown method: $method"
    exit 1
fi