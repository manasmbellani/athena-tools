#!/bin/bash
# 
# Script will get the information about Shodan API limits for the current plan 
# and how many credits are remaining.
#
# Info taken from: https://developer.shodan.io/api
# 
# Requires:
#     - jq, to parse the JSON output
#     - API key obtained from the Shodan website. First create an account on 
#       Shodan, then login and select 'Show API Key' on the top-right to get 
#       the API key.
#
# Args:
#     shodan_api_key: Shodan API key needs to be provided. Required.
# 
# Examples: 
#     To get your Shodan API plan credit info:
#     
#     SHODAN_API_KEY="sT....g1"
#     ./get_shodan_api_limits.sh "$SHODAN_API_KEY"
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 <shodan_api_key>"
    exit 1
fi
shodan_api_key="$1"

echo "[*] Requesting API limits via Shodan API"
curl -s https://api.shodan.io/api-info?key="$shodan_api_key" | jq -r "."
