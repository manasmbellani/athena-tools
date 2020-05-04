#!/bin/bash
# 
# Script enables/disables DNS servers on a Macbook or Linux PC
# 
# Script automatically determines the appropriate OS using 'uname' utility on Mac/Linux. For 
# Macbook, networksetup is used to manually set the DNS server IP address and clear. For Linux,
# the DHCP is used to simply re-request DHCP to clear the DNS servers. For setting the nameservers
# in Linux, /etc/resolv.conf file is updated
# 
# Args:
#     dnsaddr: New dns-server to set. Type 'empty' or 'clear' to remove all existing configured 
#                DNS servers. Required.
#     linux_int: Linux interface to reset DHCP.
#
# Output:
#     Whether the DNS server has been setup for this host
# 
# Examples:
#     To set dns server to 1.1.1.1, run the command:
#         ./mydevice_set_dns_server.sh 1.1.1.1
# 

if [ $# -lt 1 ]; then
    echo "[-] $0 <dnsaddr-eg-empty/1.1.1.1> [linux_int=eth0]"
    exit 1
fi
dns_addr="${1}"
linux_int=${2:-"eth0"}

# Get the current OS
os="$(uname)"

if [ "$os" == "Darwin" ]; then
    # Macbook in use
    if [ "$dns_addr" == "empty" ] || [ "$dns_addr" == "clear" ]; then
        # We clear the existing DNS servers in-use
        echo "[*] Clearing all DNS servers for Mac"
        networksetup -setdnsservers Wi-Fi "empty"
        
    else
        # Set the DNS server IP addr
        echo "[*] Adding IP address: $dns_addr for macbook via networksetup"
        networksetup -setdnsservers Wi-Fi "$dns_addr" 
    fi

elif [ "$os" == "Linux" ]; then
    if [ "$dns_addr" == "empty" ] || [ "$dns_addr" == "clear" ]; then
        # We clear all existing DNS servers in-use in Mac
        echo "[*] Clear existing DNS servers on interface: $linux_int"
        dhclient -r "$linux_int"; dhclient "$linux_int" 
    else
        # Set DNS server IP address in Linux
        echo "[*] Adding IP address: $dns_addr to /etc/resolv.conf"
        echo "nameserver $dns_addr" >> /etc/resolv.conf
    fi
else 
    echo "[-] Unknown OS: $os"
fi
