#!/bin/bash
# 
# Script gets ALL redirects for a URL, domain OR IP using curl and grep -E
# 
# Input:
#     List of URLs to get redirects for
# 
# Args:
#     run: Type 'run' to just run the script, otherwise the usage is displayed
#     method: Method to use. Currently, only curl is supported and is default.
#     timeout: Timeout to apply when accessing URL. By default, 5 seconds.
#     
# Example:
#     To get the URL redirects URLs in file urls.txt:
#         cat urls.txt | ./get_url_redirects.sh run
# 
# 

# User agent to make single curl request with
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"

if [ $# -lt 1 ]; then
    echo "[-] ...<urls>... | $0 run [method=curl] [timeout=5]"
    exit 1
fi
method=${2:-"curl"}
timeout=${3:-"5"}

# Loop through each URL
urls=$(cat -)

# Print the current time and hostname to review in logs as coming from this 
# device
current_time=$(date)
hostname=$(hostname)

echo "[+] Current time: $current_time, hostname: $hostname"

for url in $urls; do

    # Ignore blank lines 
    if [ ! -z "$url" ]; then

        echo "[*] Get redirects for url: $url via method: $method"
        if [ "$method" == "curl" ]; then
            curl -A "$USER_AGENT" --max-time "$timeout" -s -i -v -L --http1.1 \
"$url" -o /dev/null 2>&1 | grep -Ei "Location:"
        else
            echo "[-] Unknown method: $method"
        fi
        echo "[*] -------------------------------------------------------------"
        echo; echo
    fi
done