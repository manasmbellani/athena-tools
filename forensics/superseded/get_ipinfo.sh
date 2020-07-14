#!/bin/bash
# 
# Get the information on IP such as geolocation using ipinfo.io website OR 
# perform whois to see registrant info
# 
# Usage:
#   ...<domains>... | $0 [method=ipinfo|whois]"
# 
# Requires: 
#     Nothing specific, as curl, whois are installed by default on Linux/Mac.
# 
# Args:
#     run: Provide 'run' to ensure that script runs, otherwise, usage printed.
#     ipinfo: Method to perform IPInfo on the domain. Possible inputs: 
#          ipinfo.io/ipinfo
#          whois
#          scamalytics
#          iphub
#          ipqualityscore
# 
# Examples:
#     To get the geolocation info about IP addresses "8.8.8.8" and "1.1.1.1":
#         echo -e "8.8.8.8\n1.1.1.1" | ./get_ip_from_domain.sh run 
#
#     To get the whois info about IP addresses "8.8.8.8" and "1.1.1.1":
#         cat ips.txt | ./get_ip_from_domain.sh run 'whois' 
# 
# 
if [ $# -lt 1 ]; then
    echo "[-] ...<ips>... | $0 run \
<method=ipinfo|whois|scamalytics|iphub|ipqualityscore>"
    exit 1
fi
method=${2:-"ipinfo"}

script_dir=$(dirname $0)

ip_addrs=$(cat -)
IFS=$'\n'
for ip in $ip_addrs; do
    if [ ! -z "$ip" ]; then
        if [ "$method" == "ipinfo" ] || [ "$method" == "ipinfo.io" ]; then
            echo "[*] Getting info on IP: $ip via ipinfo.io"
            curl -s "ipinfo.io/$ip/json"
        elif [ "$method" == "whois" ]; then
            echo "[*] Getting info on IP: $ip via whois"
            whois "$ip"
        elif [ "$method" == "scamalytics" ]; then
            echo "[*] Reviewing Scamalytics reputation for IP: $ip"
            url="https://scamalytics.com/ip/$ip"
            echo "$url" | $script_dir/../mydevice/invoke_url_in_browser.sh run
        elif [ "$method" == "iphub" ]; then
            echo "[*] Get reputation for IP: $ip via iphub website"
            url="https://iphub.info/?ip=$ip"
            echo "$url" | $script_dir/../mydevice/invoke_url_in_browser.sh run
        elif [ "$method" == "ipqualityscore" ]; then
            echo "[*] Get reputation for IP: $ip via ipqualityscore.com website"
            url="https://www.ipqualityscore.com/free-ip-lookup-proxy-vpn-test/lookup/$ip"
            echo "$url" | $script_dir/../mydevice/invoke_url_in_browser.sh run
        else
            echo "[-] Unknown method: $method"
        fi
        # Print line separator
        echo
        echo "[*] ------------------------------------------------------------"
        echo; echo
    fi
    
done