#!/bin/bash
# 
# Script checks if it is possible to create 'malmirror'
# 

if [ $# -lt 1 ]; then
# 
    echo "[-] $0 run [method=awscli] [profile=default] [region=ap-southeast-2]"
    exit 1
fi
method=${2:-"awscli"}
profile=${3:-"default"}
region=${4:-"ap-southeast-2"}

if [ "$method" == "" ]; then
    echo "[*] Checking if it is possible to create a 'malmirror' via awscli with\
profile: $profile and for region: $region"
    aws ec2 create-traffic-mirror-filter --profile=$profile --region=$region

echo "Make sure that if we create session, then you do delete it!
        aws ec2 delete-traffic-mirror-filter --traffic-mirror-filter-id \
<traffic-mirror-filter-id> --profile=$profile --region=$region

    Exploit for creating a malmirror is available here:
        https://github.com/RhinoSecurityLabs/Cloud-Security-Research/tree/master/AWS/malmirror

    Described here from RhinoLabs:
        https://rhinosecuritylabs.com/aws/abusing-vpc-traffic-mirroring-in-aws/"

else
    echo "[-] Unknown method: $method"
    exit 1
fi