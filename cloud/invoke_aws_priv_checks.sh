#
# Script to get the current user information/identity and privilege escalation 
# methods via rhino security's aws escalate script
#

# Rhinosecurity Lab's AWS Escalate directory
AWS_ESCALATE_DIR="/opt/Cloud-Security-Research/AWS/aws_escalate/"

if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=aws_escalate] [profile=default]"
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

else
    echo "[-] Method: $method not found"
    exit 1
fi