#!/bin/bash
if [ $# -lt 1 ]; then
    echo "[-] $0 <ports-list=file/single-port/ports-list-commma-sep> [protocol]"
    exit 1
fi
ports_to_listen_file="$1"
protocol=${2:-"tcp"}

if [ -f "$ports_to_listen_file" ]; then
    ports_to_listen=$(cat "$ports_to_listen_file" | tr -s "\n" ",")
else
    ports_to_listen="$ports_to_listen_file"
fi

# Start listening on different ports
IFS=','
for port in $ports_to_listen; do
    echo "[*] Listening to port: $port on protocol: $protocol"
    if [ "$protocol" == "tcp" ]; then
        nohup nc -nvvlp "$port" &
    elif [ "$protocol" == "udp" ]; then
        nohup nc -u -nvvlp "$port" &
    else
        echo "[-] Unknown port: $port"
        exit 1
    fi
done
