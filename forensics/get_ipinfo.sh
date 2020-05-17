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
    echo "[-] ...<ips>... | $0 run <method=ipinfo|whois>"
    exit 1
fi
method=${2:-"ipinfo"}

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
            
        fi
        # Print line separator
        echo
        echo "[*] ------------------------------------------------------------"
        echo; echo
    fi
    
done