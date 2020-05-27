#!/bin/bash
#
# Script is used to list all AWS S3 buckets with a given profile and within 
# the given region via awscli or s3scan, which also lists the S3 buckets
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=awscli|s3scan] [profile=default] \
[region=ap-southeast-2] [outfile=out-aws-s3-<profile>-<region>.txt]"
    exit 1
fi
method=${2:-"awscli"}
profile=${3:-"default"}
region=${4:-"ap-southeast-2"}
outfile=${5:-"out-aws-s3-$profile-$region.txt"}

if [ "$method" == "awscli" ]; then
    echo "[*] List all S3 buckets for profile: $profile and region: $region \
via awscli"
    aws s3 ls --profile=$profile --region=$region | tee "$outfile"
elif [ "$method" == "s3scan" ]; then
    echo "[*] Listing all s3 buckets for profile: $profile and region: $region \
via s3scan"
    cd /opt/s3scan
    python2 s3scan.py -p "$profile" -f text
else
    echo "[-] Unknown method: $method"
fi