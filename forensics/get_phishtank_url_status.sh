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
#     jq: to parse the results 
# 
# Args:
#     username: Username to use for making phishtank check. By default, \
#         'anonymous'
#     api_key: APP Key from setting up an app. By default, none provided, which 
#         may have slightly higher rate limiting.
#     timeout: Timeout to use in seconds. By default, 5 seconds to prevent 
#          lockout.
# 
# Examples:
#     To check the status of url https://www.travel.com, http://www.travel.com":
#        echo -e "https://www.travel.com\nhttp://www.travel.com" \
#            | ./get_phishtank_url_status.sh 
# 
# 
# 
# 
username=${1:-"anonymous"}
api_key=${2:-""}
timeout=${3:-"5"}

urls=$(cat -)

IFS=$'\n'
for url in $urls; do

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

    # Sleep before making next request
    sleep "$timeout"
done