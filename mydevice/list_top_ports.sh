#!/bin/bash
#
# Script will list the top ports for a particular protocol via: 
#     nmap
# 
if [ $# -lt 1 ]; then
    echo "[-] $0 run [method=nmap] [top-ports=1000] [protocol=tcp|udp]"
    exit 1
fi
method=${2:-"nmap"}
top_ports=${3:-"1000"}
protocol=${4:-"tcp"}

if [ "$method" == "nmap" ]; then
    if [ "$protocol" == "tcp" ]; then
        protocol_flag="-sS"
    else
        protocol_flag="-sU"
    fi

    /bin/bash -c "nmap $protocol_flag -Pn -n --top-ports $top_ports localhost -v -oG - \
        | grep -i 'Ports Scanned' \
        | grep -iEo '$protocol([^ ]+)' \
        | cut -d ';' -f2 \
        | cut -d ')' -f1 \
        | tr -s ',' '\n'"
else
    echo "[-] Unknown method: $method"
    exit 1
fi
