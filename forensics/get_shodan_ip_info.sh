#!/bin/bash
# 
# Script will get  information about the IP by using the Shodan API. This does 
# not consume any Shodan Query API Credits.
#
# Info taken from: https://developer.shodan.io/api
# 
# Requires:
#     jq, to parse the JSON output
#     
# Input:
#    List of IPs to get info on, one-per-line
# 
# Args:
#     shodan_api_key: Shodan API key needs to be provided. Needs to be obtained 
#          by creating an API account on shodan and clicking on "Show API Key" 
#          on the top-right side of the page after logged-in. Required.
# 
if [ $# -lt 1 ]; then
    echo "[-] ...<ip>... | $0 <shodan_api_key>"
    exit 1
fi
shodan_api_key="$1"

# IPs to get info on
ips=$(cat -)

# Loop through each IP provided and get info.
IFS=$'\n'
for ip in $ips; do
    if [ ! -z "$ip" ]; then
        echo "[*] Requesting info on IP: $ip via Shodan API"
        curl -s https://api.shodan.io/shodan/host/"$ip"?key="$shodan_api_key" \
            | jq -r "."
    fi
done