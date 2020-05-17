#!/bin/bash
# 
# Script produces the TXT record for a domain which can be useful to determine 
# the email addresses that are used by the domain/organization. E.g. if SPF
# shows spf.protection.outlook.com then it is likely that the organizational 
# domain is using Microsoft. 
# 
# Input:
#     Domains to check
# 
# Args: 
#     run: Just type run to run the command, otherwise, use dig.
#     method: Method to use perform DNS resolution. Currently both host, dig 
#     are supported. By default, dig is used 
# 
# Example:
#     To get the TXT record for domains in file domains.txt
#         cat domains.txt | ./get_txt_for_domain run
# 

if [ $# -lt 1 ]; then
    echo "...<domains>... | $0 run [method=dig|host]" 
    exit 1
fi
method=${2:-"dig"}

domains="$(cat -)"

IFS=$'\n'
for domain in $domains; do
    if [ ! -z "$domain" ]; then
        echo "[*] Performing TXT record resolution on method: $method for \
            domain: $domain"
        if [ "$method" == 'dig' ]; then
            dig +noall +answer -t "TXT" "$domain"
        elif [ "$method" == "host" ]; then
            host -t "TXT" "$domain"
        else
            echo "[-] No method: $method found."
        fi

        echo "[*] ------------------------------------------------------------"
        echo; echo
    fi
done

