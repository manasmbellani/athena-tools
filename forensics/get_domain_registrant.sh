#!/bin/bash
USAGE="[-]
usage: $0 <domain> [info_to_get=registrant]

summary: Gets the resgistrant details via whois for a domain

parameters:
    domain: domain name to get info on 
    info_to_get: Information to get in regex format e.g. registrant will show ALL registrant fields. this field is case insensitive.

example: 
    to get the registrant info about google.com, run the command
    $0 google.com

"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
domain="$1"
info_to_get=${2:-"registrant"}

whois "$domain" | grep -i "$info_to_get"

