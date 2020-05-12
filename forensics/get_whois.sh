#!/bin/bash
# 
# Get the Whois on the domains specified on the input
# 
# Usage:
#   ...<domains>... | $0 [method=whois]"
# 
# Args:
#     whois: Method to perform WhoIs on the domain
# 
method=${1:-"whois"}

domains=$(cat -)
IFS=$'\n'
for domain in $domains; do
    if [ "$method" == "whois" ]; then
        echo "[*] Performing WhoIs on domain: $domain via whois"
        whois "$domain"
    fi
done