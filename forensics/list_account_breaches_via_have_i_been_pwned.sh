#!/bin/bash
# 
# Script connects to HaveIBeenPwned API to download a list of all breaches for 
# a given account(s) and outputs them to a file
# 
# 
# Requires:
#     Apart from the standard tools pre-available in mac, Linux such as grep,
#     tee, curl, the script also requires jq >v1.6:
#         brew install jq
#         sudo apt-get -y install jq
# 
# Args:
#     api-key: HaveIBeenPwned API key. Required.
#     account-to-check/file-with-accounts: File with list of accounts to check 
#                                          for breaches. Required.
#     outfile: Output file to write the results of account breaches
#     sleeptime: Number of secs to sleep between requests. By default, 3 secs.
# 
# Outputs: 
#     Breaches for each account in JSON format
# 
# Examples:
#     To get the breaches for each username in file in-accounts.txt:
#         ./list_account_breaches_via_have_i_been_pwned.sh \
#             c....c in-accounts.txt
# 

if [ $# -lt 2 ]; then
    echo "[-] $0 <api-key> <account-to-check/file-with-accounts> 
                 [outfile=out-have-i-been-pwned-account-breaches.txt] 
                 [sleeptime=3]"
    exit
fi
api_key="$1"
file_account_to_check="$2"
outfile=${3:-"out-have-i-been-pwned-account-breaches.txt"}
sleeptime=${4:-"3"}

if [ -f "$file_account_to_check" ]; then
    echo "[*] Reading accounts from file: $file_account_to_check..."
    accounts_to_check=`cat "$file_account_to_check" | tr -s '\n' ','`
else
    echo "[*] Got single account: $accounts_to_check to run checks on..."
    accounts_to_check="$file_account_to_check"
fi

echo "[*] Removing any existing output files: $outfile..."
rm "$outfile" 2>/dev/null

IFS=','
for account in $accounts_to_check; do
    echo "[*] Getting the site breaches where account: $account details were leaked..." | tee -a "$outfile"
    curl -s "https://haveibeenpwned.com/api/v3/breachedaccount/$account?includeUnverified=true" -H "hibp-api-key: $api_key" | jq -r "." | tee -a "$outfile"

    echo "[*] Sleeping for $sleeptime seconds..."
    sleep $sleeptime

    echo "[*] Getting the pasties details where account: $account details were leaked within a paste..." | tee -a "$outfile"
    curl -s "https://haveibeenpwned.com/api/v3/pasteaccount/$account" -H "hibp-api-key: $api_key" | jq -r "." | tee -a "$outfile"

    echo "[*] Sleeping for $sleeptime seconds..."
    sleep $sleeptime
done
