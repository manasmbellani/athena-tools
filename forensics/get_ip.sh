#!/bin/bash
# 
# Resolve the IP to hostnames
# 
# Usage:
#   ...<domains>... | $0 [method=host|nslookup]"
# 
# Args:
#     method: Method/utility to perform IP resolution for domain. By default, 
#         host. Possible values: host, nslookup
# 
method=${1:-"host"}

domains=$(cat -)
IFS=$'\n'
for domain in $domains; do
    if [ "$method" == "host" ]; then
        echo "[*] Performing IP resolution on domain: $domain via 'host'"
        host "$domain" | grep 'has address'
    elif [ "$method" == "nslookup" ]; then
        echo "[*] Performing IP resolution on domain: $domain via 'nslookup'"
        nslookup "$domain"
    fi
done