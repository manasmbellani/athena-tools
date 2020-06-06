#!/bin/bash
# 
# Script is used to display available AWS services via following methods:
#    - pacu: need to provide username to query the services that can be 
#            available.
#

if [ $# -lt 2 ]; then
    echo "[-] $0 run [method=pacu] [profile=default] [region=ap-southeast-2] \
[aws_user_name=root]"
    exit 1
fi
method=${2:-"pacu"}
profile=${3:-"default"}
region=${4:-"ap-southeast-2"}
user_name=${5:-"root"}

script_dir=$(dirname "$0")
 
if [ "$method" == "pacu" ]; then

    # Add AWS creds to Pacu
    $script_dir/put_aws_pacu_creds.sh run "$profile" "$region"

    pacu_checks="
    # Copy the following content to pacu-commands-file-raw.txt
    # Run the following command to get rid of comments
    
    # Load with command 'load_commands_file pacu_commands_file.txt':

    ## Check what detection services are in place within the account - supported services are CloudTrail, CloudWatch, Config, Shield, VPC, and GuardDuty
    run detection__enum_services 

    ## Are my keys honeytokens which are known to be fake keys? 
    run iam__detect_honeytokens

    ## Get the information about all the users, roles and groups
    run iam__enum_users_roles_policies_groups

    ## Attempt to get enumeration for all the permissions that the user has on the loaded keys
    run iam__enum_permissions

    ## Attempt to get the permissions that belong to all users and all roles
    run iam__enum_permissions --all-users --all-roles 

    ## Attempt to get the permissions for a particular user only
    run iam__enum_permissions --user-name $user_name

    ## Attempt to get enumeration for all the permissions that the user has on the loaded keys
    run iam__bruteforce_permissions

    ## Attempt to get the permissions that belong to all users and all roles
    run iam__bruteforce_permissions --all-users --all-roles 

    ## Attempt to get the permissions for a particular user only
    run iam__bruteforce_permissions --user-name $user_name

    ## Attempt to get the glue endpoints and press 'Y' to run across all regions
    run glue__enum

    ## Attempt to get the services spend via AWS
    run aws__enum_spend

    ## Get reports via AWS inspector for all regions through pacu
    run inspector__get_reports

    ## Get the creds and sensitive info from codebuild projects
    run codebuild__enum

    ## Get info about the user account itself including the email associated with the account
    run aws__enum_account

    ## Get all the EC2 instances within the region
    run ec2__enum

    ## Check if the termination protection is turned on for all the EC2 instances
    run ec2__check_termination_protection

    ## Check Lightsail for databases, websites, networks
    run lightsail__enum

    ## Get more info about the user via a credential report - contents saved to a CSV file itself.
    run iam__get_credential_report

    ## Get the user-data for the EC2 instances across all regions
    run ec2__download_userdata

    ## Get the list of all unencrypted volume snapshots across all regions
    run ebs__enum_volumes_snapshots

    ## Get the details of all the lambda functions in AWS account
    run lambda__enum 

    ## Run the IAM Privilege Escalation Scan to look for vulnerabilities
    run iam__privesc_scan --scan-only

    ## Look for lateral movements for VPN, Direct Connect for lateral movements
    run vpc__enum_lateral_movement --versions-only 

    ## Get information about the WAF from all regions
    run waf__enum

    ## Get the information about the Elastic Load Balancers
    run elb__enum_logging

    ## show all the information about the active AWS keys
    data
    "
    echo "$pacu_checks" | grep -viE '^$' | egrep -vi '^[ ]*#' \
        | sed -E 's/^[ ]*//' > in-pacu-commands-file.txt

    echo "[*] Launch and run Pacu with these commmands from \
file: in-pacu-commands-file.txt as follows: " 
    echo "     /opt/pacu/pacu.py"
    echo "     > load_commands_file in-pacu-commands-file.txt"


else
    echo "[-] Unknown method: $method"]
    exit 1
fi