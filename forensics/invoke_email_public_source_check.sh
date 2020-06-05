#!/bin/bash
#
# Script to verify if an email address exists in a public source online
# 
if [ $# -lt 1 ]; then
    echo "[-] ...<email>... | $0 run [method=hunter.io/hunter]"
    exit 1
fi
method=${2:-"hunter.io"}

# To get the list of emails for which to verify if the email is publicly 
# available
emails=$(cat -)

IFS=$'\n'
for email in $emails; do
    if [ "$method" == "hunter.io"] || [ "$method" == "hunter"] ; then
        email_prefix=$(echo "$email" | cut -d "@" -f1)
        email_domain=$(echo "$email" | cut -d "@" -f2)

        echo "[*] Search for first/last name via emaiil prefix: $email_prefix"
        url="https://hunter.io/email-finder/"
        echo "$url" | $script_dir/../mydevice/invoke_url_in_browser.sh run
        echo "[!] Locate the sources via hunter.io's 'source' option"
    fi
done