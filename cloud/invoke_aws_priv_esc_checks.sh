#
# Script to get the current user information/identity and privilege escalation 
# methods via either:
#  - rhino security's aws escalate script: 
#      https://github.com/RhinoSecurityLabs/Security-Research/blob/master/tools/aws-pentest-tools/aws_escalate.py
#  - pmapper script available for mapping privilege escalation
#      https://github.com/nccgroup/PMapper
#  - Cloudsploit checks:
#      https://github.com/cloudsploit/scan
#  - Cloudmapper:
#      https://github.com/duo-labs/cloudmapper
#  - CS-Suite
#      https://github.com/SecurityFTW/cs-suite 
#  - Look for shadow admins via CyberArk
#      https://github.com/cyberark/SkyArk/tree/master/AWStrace

# Rhinosecurity Lab's AWS Escalate directory
AWS_ESCALATE_DIR="/opt/Cloud-Security-Research/AWS/aws_escalate/"

if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=aws_escalate|pmapper|cloudsploit|cloudmapper\
|cs_suite|shadowadmins_cyberark] \
[profile=default]"
    exit 1
fi
method=${2:-"aws_escalate"}
profile=${3:-"default"}

if [ "$method" == "aws_escalate" ]; then
    echo "[*] Executing aws_escalate for profile: $profile in directory"
    python3 "$AWS_ESCALATE_DIR"/aws_escalate.py -p "$profile"
    
    echo \
    "Review the .csv file in Excel and look at the common findings from here:
        https://rhinosecuritylabs.com/aws/aws-privilege-escalation-methods-mitigation/
        https://rhinosecuritylabs.com/aws/aws-privilege-escalation-methods-mitigation-part-2/
        https://rhinosecuritylabs.com/aws/escalating-aws-iam-privileges-undocumented-codestar-api/

    Also, review the findings via google search:
        \"<finding-keyword-eg-codestar>\" site:rhinosecuritylabs.com

    Also note that IP may mean Instance Profile e.g. in CreateEC2InstanceWithExistingIP

    IMPORTANT: Check if 'aws-codestar-service-role' exists AND if 'codestar:*'/'codestar:CreateProjectFromTemplate' permission exists for user. If it does, then we can do privilege escalation:
        Blog: https://rhinosecuritylabs.com/aws/escalating-aws-iam-privileges-undocumented-codestar-api/
        Exploit: https://github.com/RhinoSecurityLabs/Cloud-Security-Research/tree/master/AWS/codestar_createprojectfromtemplate_privesc"
        
elif [ "$method" == "pmapper" ]; then
    echo "[*] Collect the information via Pmapper"
    pmapper --profile=$profile graph --create

    echo "[*] Build a graph that can be visualised through a browser"
    pmapper --profile=$profile visualize --filetype svg

    echo "[*] Run analysis to look for any vulnerable path privilege techniques"
    pmapper --profile=$profile analysiss

elif [ "$method" == "cloudsploit" ]; then
    echo "[!] First, modify  following file to configure creds with \
'SecurityAudit' role and comment all the other:"
    echo "[!] See here for more info: https://github.com/cloudsploit/scans"
    echo "[!] To modify the creds in the index.js file, run the command:"
    echo "[!]     vim /opt/cloudsploit-scans/index.js"
    echo "[!] Press any key to continue..."
    read 

    echo "[*] Running cloudsploit-scans in dir: /opt/cloudsploit-scans log to "
    echo "    outfile: $cwd/out-cloudsploit-scan-$profile.txt"
    cd /opt/cloudsploit-scans
    node index.js --csv=\"$cwd/out-cloudsploit-scan-$profile.txt\" \
        | egrep -iv \"not authorized|denied|error query\"
    
    echo "[!] Taken from here: https://github.com/cloudsploit/scans"

elif [ "$method" == "shadowadmins_cyberark" ]; then

    echo "# Enter the cloutrail bucket name, <bucket-name> and it's prefix, <bucket-prefix>
    cat ~/.aws/credentials | grep -A3 -i $profile | grep aws_access_key_id | head -n1 | cut -d ' ' -f3 > out-access-key-id.txt
    cat ~/.aws/credentials | grep -A3 -i $profile | grep aws_secret_access_key | head -n1 | cut -d ' ' -f3 > out-secret-access-key.txt
    access_key_id=\$(cat out-access-key-id.txt)
    secret_key=\$(cat out-secret-access-key.txt)
    cd /opt/SkyArk/AWStrace
    pwsh -c \"Import-Module .\\AWStealth.ps1 -Force; Download-CloudTrailLogFiles -AccessKeyID \$access_key_id -SecretKey \$secret_key -DefaultRegion $region -TrailBucketName <bucket-name> -BucketKeyPrefix <bucket-prefix>; Analyze-CloudTrailLogFiles
 
    # For required permissions on scan account, see: 
        https://github.com/cyberark/SkyArk/tree/master/AWStrace

    # Taken from:
        https://github.com/cyberark/SkyArk/"

elif [ "$method" == "cloudmapper" ]; then
    echo "
        # First setup aws-vault profile and enter the keys
        aws-vault add $profile

        # List all the AWS profiles
        aws-vault list 

        # Setup the Docker image
        docker build -t cloudmapper .
        aws-vault exec $profile --server --
        docker run -p 8000:8000 -it cloudmapper /bin/bash

        # Run the scan
        pipenv shell
        python cloudmapper.py report --account $profile
        python cloudmapper.py webserver --public

        # Currently, has issues with setup - gives 'cannot iterate over null'

        # Taken from:
            - aws-vault: https://github.com/99designs/aws-vault
            - cloudmapper: https://github.com/duo-labs/cloudmapper
    "
elif [ "$method" == "cs_suite" ]; then
    echo "
    # Scanning with AWS

    ## Clone cs-suite and go to cs-suite directory
    git clone https://github.com/SecurityFTW/cs-suite
    cd /opt/cs-suite 

    ## Prepare the config file in /opt/cs-suite/aws directory
    [default]
    output = json
    region = $region

    ## Prepare credentials file in /opt/cs-suite/aws directory
    [default]
    aws_access_key_id = XXXXXXXXXXXXXXX
    aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXX

    ## Run the scan
    docker run -v \$(pwd)/aws:/root/.aws -v \$(pwd)/reports:/app/reports securityftw/cs-suite -env aws

    # For Scanning AWS, Google Cloud, Digital Ocean, See https://github.com/SecurityFTW/cs-suite

    # Taken from: https://github.com/SecurityFTW/cs-suite"

else
    echo "[-] Method: $method not found"
    exit 1
fi