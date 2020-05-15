#!/bin/bash
# 
# Script will get the information about the Shodan API limits for our plan 
#
# Info taken from: https://developer.shodan.io/api
# 
# Requires:
#     jq, to parse the JSON output
#     
# 
# Args:
#     shodan_api_key: Shodan API key needs to be provided. Needs to be obtained 
#          by creating an API account on shodan and clicking on "Show API Key" 
#          on the top-right side of the page after logged-in. Required.
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 <shodan_api_key>"
    exit 1
fi
shodan_api_key="$1"

echo "[*] Requesting API limits via Shodan API"
curl -s https://api.shodan.io/api-info?key="$shodan_api_key" | jq -r "."
