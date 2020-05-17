#!/bin/bash
# Description:
#     Checks whether the URL is in phishtank via Phishtank API. Documented here:
#         https://www.phishtank.com/api_info.php
# 
#     If in phishtank database, then URL is printed with more details.
# 
# Input:
#     urls to check - single or one separated on each line.
# 
# Requires:
#     jq: to parse the results which can be installed with 'brew' in Mac and 
#         'apt-get' in linux:
#             brew install jq
#             sudo apt-get -y install jq
# 
#     Optionally, you can create an account on Phishtank, download an API key, 
# 
# Args:
#     run: If 'run' not specified, print usage only and don't run script.
#     username: Username to use for making phishtank check. Reported to Phishtank
#         when making API calls to prevent rate limits. By default, 'anonymous'. 
#     api_key: Optional App Key from setting up an app. By default, none 
#     provided, which may have slightly higher rate limiting.
#     timeout: Timeout to use in seconds between making multiple requests. By 
#         default, 5 seconds to prevent lockout.
# 
# Examples:
#     To check the phishtank status of urls https://www.travel.com, \
#     http://www.travel.com":
#         echo -e "https://www.travel.com\nhttp://www.travel.com" \
#             | ./get_phishtank_url_status.sh run
# 
#     To check the status of all URLs in the urls.txt: 
#         cat urls.txt | ./get_phishtank_url_status.sh run
#

if [ $# -lt 1 ]; then
    echo "[-] ...<urls>... | $0 run [username='anonymous'] [api_key=''] \
[timeout=5]"
    exit 1
fi
username=${2:-"anonymous"}
api_key=${3:-""}
timeout=${4:-"5"}

urls=$(cat -)

IFS=$'\n'
for url in $urls; do

    if [ ! -z "$url" ]; then
        # Form POST request data to API by supplying the API key (if provided), URL
        if [ -z "$api_key" ]; then
            post_data="format=json&url=$url"
        else
            post_data="format=json&url=$url&app_key=$api_key"
        fi

        echo "[*] Making POST request to check url: $url with username: $username"
        resp=$(curl -s -X POST -A "phishtank/$username" \
                -d "$post_data" "https://checkurl.phishtank.com/checkurl/")

        # Parse results
        in_database=$(echo "$resp" | jq -r ".results.in_database")
        phish_details_page=$(echo "$resp" | jq -r ".results.phish_detail_page")
        verified_at=$(echo "$resp" | jq -r ".results.verified_at")

        # Print results to user
        echo "[+] Success. url: $url, in_database: $in_database, \
verified_at: $verified_at, phish_url: $phish_details_page"

        echo "[*] Sleep for $timeout seconds before making next request"
        sleep "$timeout"

        # Print separator between multiple requests
        echo; 
        echo "[*] ------------------------------------------------------------"
        echo; echo
    fi
done