#!/bin/bash
# 
# Get the Whois on the domains, IPs specified on input
# 
# Usage:
#   ...<domains>... | $0 [method=whois]"
# 
# Args:
#     whois: Method to perform WhoIs on the domain
# 
# Examples:
#     TO perform the whois on hosts in file, hosts.txt:
#         cat hosts.txt | ./get_whois.sh
# 
method=${1:-"whois"}

domains=$(cat -)
IFS=$'\n'
for domain in $domains; do
    if [ "$method" == "whois" ]; then
        echo "[*] Performing WhoIs on domain: $domain via whois"
        whois "$domain"
    else
        echo "[-] Unkonwn method: $method"
    fi
    echo '[*] -----------------------------------------------------------------'
    echo; echo
done