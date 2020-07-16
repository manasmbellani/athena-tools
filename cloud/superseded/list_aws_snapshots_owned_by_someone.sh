#!/bin/bash
# 
# Script to list all accessible AWS snapshots for a specific owner that we could 
# restore , by default - is there are any interesting content within these snapshots?
# 
# Requires ec2:DescribeSnapshots permission to be able to describe ALL snapshots
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=awscli] [owner=self|<...userid...>|public] [profile=default] \
[region=ap-southeast-2] [outfile=out-aws-images-<profile>-<region>.txt]"
    exit 1
fi
method=${2:-"awscli"}
owner=${3:-"self"}
profile=${4:-"default"}
region=${5:-"ap-southeast-2"}
outfile=${6:-"out-aws-snapshots-$owner-$profile-$region.txt"}

if [ "$method" == "awscli" ]; then
    if [ "$owner" == "public" ]; then
        echo "
        # To list public snapshots, look at permissions of snapshots given snapshot id <snapshot-id>,
    like \"snap/09ejdjqkkakka\"

    aws ec2 describe-snapshot-attribute --attribute createVolumePermission --snapshot-id <snapshot-id> --region $region --profile $profile 
    {                                                                                                                                                                      \"CreateVolumePermissions\": [
        {
            \"Group\": \"all\"                                                         
        }                     
    ],                      
    \"SnapshotId\": \"snap-0b49342abd1bdcb89\"

    # If \"Group\" set to \"all\" then this is a public snapshot.

    # To exploit, go to the SAME region within another account, and BUILD a volume from it.

    # then attach to an EC2 instance and explore it for credentials.

    # Taken from: 
        - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-modifying-snapshot-permissions.html
        - http://level4-1156739cfb264ced6de514971a4bef68.flaws.cloud/hint1.html
}"
    else
        echo "[*] List all AWS snapshots owned by owner: $owner for profile: \
    $profile, and region: $region via awscli"
        aws ec2 describe-snapshots --owner="$owner" --profile=$profile \
            --region=$region | tee "$outfile"

        echo "[*] List all AWS snapshots restorable by owner id: $owner for profile: \
    $profile and region: $region via awscli"
        aws ec2 describe-snapshots --restorable-by-user-ids="$owner" \
    --profile=$profile --region=$region | tee "$outfile"
    fi
else
    echo "[-] Unknown method: $method"
    exit 1
fi