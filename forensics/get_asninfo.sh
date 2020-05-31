#!/bin/bash
# 
# Get the information on an ASN via different methods. The method supported is:
#     scamalytics/nmap_scamalytics
# 

# Sleep number of seconds
SLEEP_SECS=10

if [ $# -lt 1 ]; then
    echo "[-] ...<asns>... | $0 run \
<method=nmap_scamalytics>"
    exit 1
fi
method=${2:-"nmap_scamalytics"}

script_dir=$(dirname $0)

asns=$(cat -)
IFS=$'\n'
for asn in $asns; do
    if [ ! -z "$asn" ]; then
        if [ "$method" == "scamalytics" ] || [ "$method" == "nmap_scamalytics" ]; then
            echo "[*] Getting IP addresses on ASN: $asn via nmap"
            outfile="mktemp -u"
            nmap --script targets-asn --script-args targets-asn.asn="$asn" -oN "$outfile" 2>&1 1>/dev/null
            ip_in_asn=$(grep -oiE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" "$outfile" | head -n1)

            if [ ! -z "$ip_in_asn" ]; then
                echo "[*] Opening scamalytics to get info on asn: $asn via \
IP: $ip_in_asn"
                echo "$ip_in_asn" | $script_dir/get_ipinfo.sh run "scamalytics"

                # Delete the output file
                rm "$outfile"
                
                echo "[*] Pause for $SLEEP_SECS seconds before continuing"
                sleep "$SLEEP_SECS"
            else
                echo "[-] No IP found for asn: $asn"
            fi

            
        fi
        # Print line separator
        echo
        echo "[*] ------------------------------------------------------------"
        echo; echo
    fi
    
done