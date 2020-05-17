#!/bin/bash
# 
# Script will get  information about the IP by using the Shodan API. This does 
# not consume any Shodan Query API Credits as we are just querying IPs 
# one-by-one.
#
# Info taken from: https://developer.shodan.io/api
# 
# Requires:
#     - jq, to parse the JSON output which can be installed via brew in Mac, OR 
#       apt-get in Linux with following command:
#           brew install jq
#           sudo apt-get -y install jq
#     - API key obtained from the Shodan website. First create an account on 
#       Shodan, then login and select 'Show API Key' on the top-right to get 
#       the API key.
# 
# Input:
#    List of IPs to get info on, one-per-line
# 
# Args:
#     shodan_api_key: Shodan API key needs to be provided. Needs to be obtained 
#          by creating an API account on shodan and clicking on "Show API Key" 
#          on the top-right side of the page after logged-in. Required.
# 
# Examples:
#     To get info about IP 8.8.8.8 from Shodan, run the command:
#         SHODAN_KEY=sT...Gy
#         echo -e "8.8.8.8\n1.1.1.1" | ./get_shodan_ip_info.sh $SHODAN_KEY
# 
#     To get info about ALL IPs in file, ips.txt: 
#         cat ips.txt | ./get_shodan_ip_info.sh $SHODAN_KEY
# 
if [ $# -lt 1 ]; then
    echo "[-] ...<ip>... | $0 <shodan_api_key> [timeout=3]"
    exit 1
fi
shodan_api_key="$1"
timeout=${2:-"3"}

# IPs to get info on
ips=$(cat -)

# Loop through each IP provided and get info.
IFS=$'\n'
for ip in $ips; do
    if [ ! -z "$ip" ]; then
        echo "[*] Requesting info on IP: $ip via Shodan API"
        curl -s https://api.shodan.io/shodan/host/"$ip"?key="$shodan_api_key" \
            | jq -r "."

        echo "[*] Sleeping for $timeout seconds before querying next IP"
        sleep "$timeout"

        # Add separator for better output visibility
        echo
        echo "[*] ------------------------------------------------------------"
        echo; echo
    fi
done