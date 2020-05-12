#!/bin/bash
# 
# Get the information on the IP
# 
# Usage:
#   ...<domains>... | $0 [method=ipinfo|whois]"
# 
# Args:
#     ipinfo: Method to perform IPInfo on the domain. Possible inputs: 
#          ipinfo.io/ipinfo
#          whois
#         
# 
if [ $# -lt 1 ]; then
    echo "[-] ...<domains>... | $0 <method=ipinfo|whois>"
    exit 1
fi
method=${1:-"ipinfo"}

ip_addrs=$(cat -)
IFS=$'\n'
for ip in $ip_addrs; do
    if [ "$method" == "ipinfo" ] || [ "$method" == "ipinfo.io" ]; then
        echo "[*] Getting info on IP: $ip via ipinfo.io"
        curl -s "ipinfo.io/$ip/json"
    elif [ "$method" == "whois" ]; then
        echo "[*] Getting info on IP: $ip via whois"
        whois "$ip"
    fi
done