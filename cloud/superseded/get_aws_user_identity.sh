#!/bin/bash
# 
# Script is used to get the identity of the account being used to make the
# request 
# 
# Requires:
#    AWSCli
# 
# Args:
#     method: Method to use. Following methods are currently available:
#         - sts: Use 'sts get-caller-identity' method
#         - iam: Use 'iam get-user' method
#         - boto3_sts: Use 'boto3 sts' method
#         - pacu
#     By default, use 'sts' method to get the caller identity.
# 
# By default, awshoney_check used.
#     profile: AWS profile. By default, 'default'
#     region: Region to use for making this request. By default, 'ap-southeast-2'
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=sts|iam|boto3_sts|pacu] [profile=default] \
[region=ap-southeast-2]"
    exit 1
fi
method=${2:-"sts"}
profile=${3:-"default"}
region=${4:-"ap-southeast-2"}

if [ "$method" == "sts" ]; then
    echo "[*] Running 'sts' to get user identity via profile: $profile, region:\ 
$region"


elif [ "$method" == "iam" ]; then
    echo "[*] Running 'iam' to get user identity via profile: $profile, region:\
$region"
    aws iam get-user --profile=$profile --region=$region

elif [ "$method" == "boto3_sts" ]; then
    echo "[*] Running 'boto3_sts' to get user identity via profile: $profile, region:\
$region"
    python3 -c "import boto3; boto3.setup_default_session(profile_name=\"$profile\");\
mysession = boto3.session.Session(profile_name=\"$profile\", region_name=\"$region\"); \
print(boto3.client('sts').get_caller_identity())"
else
    echo "[-] Unknown method: $method"
elif [ "$method" == "pacu" ]; then

    echo "[*] Credentials to add for Pacu..."
    $script_dir/put_aws_pacu_creds.sh run "$profile" "$region"

    echo "
        ## Execute the aws username enumeration to get more info
        run aws__enum_account
    "
    read "[!] Press any key to continue..."
else
    echo "[-] Unknown method: $method"
    exit 1
fi