#!/bin/bash
#
# Script is used to check an account for AWS CIS Benchmark via the given profile
# Based on the script available here: https://github.com/awslabs/aws-security-benchmark
#
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=aws-cis-foundation-benchmark-checklist-py] \
[profile=default]"
    exit 1
fi
method=${2:-"awscli"}
profile=${3:-"default"}

if [ "$method" == "aws-cis-foundation-benchmark-checklist-py" ]; then
    echo "[*] Running AWS CIS Foundation Benchmark script on profile: $profile"
    cd /opt/aws-security-benchmark/aws_cis_foundation_framework
    python2 aws-cis-foundation-benchmark-checklist.py -p "$profile"
else
    echo "[-] Unknown method: $method"
    exit 1
fi