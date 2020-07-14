#!/bin/bash
# 
# Resolve the IP to hostnames using either 'host/nslookup' utility
# 
# Requires:
#     No special requirement. Either 'host' OR 'nslookup' which is installed by
#     default on Linux/Mac.
# 
# Usage:
#   ...<domains>... | $0 run [method=host|nslookup]"
# 
# Args:
#     run: Type 'run' to ensure that hostname resolution happens. Otherwise, 
#         only 'usage' is printed.
#     method: Method/command to perform IP resolution for a domain. By default, 
#         host. Possible values: host, nslookup
# 
# Examples:
#     To get the IP address of hostname 'www.google.com, www.msn.com':
#         echo -e "www.google.com\nwww.msn.com" | ./get_ip_from_domain.sh run 
#     
#     To get the IP address of hostnames from file, hostnames.txt, using 'host' 
#     utility:
#         cat hostnames.txt | ./get_ip_from_domain.sh run 
# 

if [ $# -lt 1 ]; then
    echo "[-] ...<domains>... | ./get_ip_from_domain.sh run \
        [method=host|nslookup]"  
    exit 1
fi
method=${2:-"host"}

domains=$(cat -)
IFS=$'\n'
for domain in $domains; do
    if [ ! -z "$domain" ]; then
        if [ "$method" == "host" ]; then
            echo "[*] Performing IP resolution on domain: $domain via 'host'"
            echo
            host "$domain" | grep 'has address'
            echo
            
        elif [ "$method" == "nslookup" ]; then
            echo "[*] Performing IP resolution on domain: $domain via 'nslookup'"
            echo
            nslookup "$domain"
            echo
        else
            echo "[-] Unknown method/command: $method. Skipping resolution for \
domain: $domain"
        fi

        # Print the separator for better visibility of output
        echo "[*] ------------------------------------------------------------"
        echo; echo
    fi
done