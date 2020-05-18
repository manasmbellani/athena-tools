#!/bin/bash
# 
# Get the Whois on the domains, IPs specified on input
# 
# Usage:
#   ...<domains>... | $0 run [method=whois]"
# 
# Args:
#     run: Type 'run' to run the script, otherwise, usage displayed.
#     whois: Method to perform WhoIs on domain
# 
# Examples:
#     TO perform the whois on hosts in file, hosts.txt:
#         cat hosts.txt | ./get_whois.sh
# 
if [ $# -lt 1 ]; then
    echo "[-] ...<domains/ips>... | $0 run [method=whois]"
    exit 1
fi
method=${2:-"whois"}

domains=$(cat -)
IFS=$'\n'
for domain in $domains; do
    if [ "$method" == "whois" ]; then
        echo "[*] Performing WhoIs on domain: $domain via whois"
        whois "$domain"
    else
        echo "[-] Unkonwn method: $method. Cannot perform whois"
    fi
    echo '[*] -----------------------------------------------------------------'
    echo; echo
done