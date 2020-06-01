#!/bin/bash
# 
# Script to brute-force AWS permissions for a user account using various methods
# 
# Args:
#     method: Method to use. Available methods:
#         nimbostratus: Using the old nimbostratus tool for dumping creds.
#         weirdaal:  Determine permissions via WeirdAAL:  
#             https://github.com/carnal0wnage/weirdAAL/wiki/Usag
# 
#         By default, consider using method 'nimbostratus'
#     profile: Credentials profile to use for running scans using this tool
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=nimbostratus|weirdaal] [profile=default]"
    exit 1
fi
method=${2:-"weirdaal"}
profile=${3:-"default"}

cwd="$(pwd)"
if [ "$method" == "nimbostratus" ]; then

    echo "[*] Switching to nimbosstratus repo"
    cd /opt/nimbostratus

    echo "[*] Getting credentials for nimbostratus from profile"
    access_key_id=$(cat ~/.aws/credentials | grep -A3 -i "$profile" \
        | grep aws_access_key_id | head -n1 | cut -d ' ' -f3)
    secret_access_key=$(cat ~/.aws/credentials | grep -A3 -i "$profile" \
        | grep aws_secret_access_key | head -n1 | cut -d ' ' -f3)

    echo "[*] Execute nimbostratus with credentials for profile: $profile"
    ./nimbostratus -v dump-permissions \
        --access-key "$access_key_id" \
        --secret-key "$secret_access_key"
elif [ "$method" == "weirdaal" ]; then

    # switch to the weirdAAL folder
    cd /opt/weirdAAL

    echo "[*] Get the access key ID, access secret key for profile: $profile"
    access_key_id=$(cat ~/.aws/credentials | grep -A3 -i "$profile" \
        | grep aws_access_key_id | head -n1 | cut -d ' ' -f3)

    echo "[*] Get the secret access key for the profile: $profile"
    secret_access_key=$(cat ~/.aws/credentials | grep -A3 -i "$profile" \
        | grep aws_secret_access_key | head -n1 | cut -d ' ' -f3)

    # Prepare the credentials template itself - with ONE key only containing 'default'
    cat<<EOF > .env
[default]
aws_access_key_id = $access_key_id
aws_secret_access_key = $secret_access_key
EOF

    echo "[*] Displaying .env file"
    cat ".env"

    echo "[*] Start running the recon on the AWS account for profile: $profile \
via weirdAAL"
    source weirdAAL/bin/activate; python3 weirdAAL.py -m recon_all -t "$profile"

    echo "[*] Get a list of all the available services via profile: $profile"
    source weirdAAL/bin/activate; python3 weirdAAL.py -m list_services_by_key \
        -t $profile

    echo "[!] Based on the services available, consider running each command \
for each module described here:
        https://github.com/carnal0wnage/weirdAAL/wiki/Usage"
else
    echo "[-] Unknown method: $method"
fi
