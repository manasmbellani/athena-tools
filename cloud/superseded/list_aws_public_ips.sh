#!/bin/bash
#
# Script is used to list all public IP addresses in AWS account via one of the
# following methods:
#     aws_public_ips
# 
#
# 
# To see the list of IPs, the policy permissions required are: 
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "apigateway:GET",
#         "cloudfront:ListDistributions",
#         "ec2:DescribeInstances",
#         "elasticloadbalancing:DescribeLoadBalancers",
#         "lightsail:GetInstances",
#         "lightsail:GetLoadBalancers",
#         "rds:DescribeDBInstances",
#         "redshift:DescribeClusters",
#         "es:ListDomainNames"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
#
# Taken from here:
#    https://github.com/arkadiyt/aws_public_ips
#
# 

if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=aws_public_ips] [profile=default] \
[region=ap-southeast-2] [outfile=out-aws-public-ips-<profile>-<region>.txt]"
    exit 1
fi
method=${2:-"aws_public_ips"}
profile=${3:-"default"}
region=${4:-"ap-southeast-2"}
outfile=${5:-"out-aws-public-ips-$profile-$region.txt"}

if [ "$method" == "aws_public_ips" ]; then
    echo "[*] List all IP addresses for profile: $profile and region: $region \
via 'aws_public_ips'"
    cd /opt/aws_public_ips
    AWS_PROFILE=$profile
    AWS_REGION=$region
    aws_public_ips -v | tee "$outfile"

else
    echo "[-] Unknown method: $method"
fi