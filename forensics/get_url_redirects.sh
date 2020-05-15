#!/bin/bash
# 
# Script gets ALL redirects for a URL, domain OR IP using curl
# 
# Input:
#     List of URLs to get redirects for
# 
# Args:
#     run: Type 'run' to just run the script, otherwise the usage is displayed
#     method: Method to use 

# User agent to make single curl request with
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"

if [ $# -lt 1 ]; then
    echo "[-] ...<urls>... | $0 run [method=curl]"
    exit 1
fi
method=${2:-"curl"}

# Loop through each URL
urls=$(cat -)
for url in $urls; do

    # Ignore blank lines 
    if [ ! -z "$url" ]; then

        echo "[*] -------------------------------------------------------------"
        echo "[*] Get redirects for url: $url via method: $method"
        if [ "$method" == "curl" ]; then
            curl -A "$USER_AGENT" -s -i -v -L --http1.1 "$url" -o /dev/null 2>&1 \
                | egrep -i "Location:"
        else
            echo "[-] Unknown method: $method"
        fi
        echo "[*] -------------------------------------------------------------"
        echo; echo
    fi
done