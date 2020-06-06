#!/bin/bash
#
# Script is used to invoke Subdomain Hijacking:
#    https://github.com/prevade/cloudjack
#
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=cloudjack] \
[profile=default]"
    exit 1
fi
method=${2:-"cloudjack"}
profile=${3:-"default"}

if [ "$method" == "cloudjack" ]; then
    echo "[*] Running AWS Cloudjack on profile: $profile to discover any \
subdomain enumeration e.g. deleted cloudfront web distribution and deleted \
CNAMEs in the cloudfront distribution "
    cd /opt/cloudjack
    python cloudjack.py -p "$profile" -o json
else
    echo "[-] Unknown method: $method"
    exit 1
fi