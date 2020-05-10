#!/bin/bash
# 
# Script connects to HaveIBeenPwned API to download a list of all breaches for 
# a given breach(s),and outputs them into a file
# 
# Requires:
#     Apart from the standard tools pre-available in mac, Linux such as grep,
#     tee, curl, the script also requires jq >v1.6:
#         brew install jq
#         sudo apt-get -y install jq
#
# Args:
#     api-key: HaveIBeenPwned API key. Required.
#     breach-names/file: File with list of breachesto check. Required.
#     outfile: Output file to write the details of breaches
#     sleeptime: Number of secs to sleep between requests. By default, 3 secs.
# 
# Outputs: 
#     Breach Details for each breach in JSON format
# 
# Examples:
#     To get the breaches for each breach in file in-breach-names.txt:
#         ./list_breach_details_via_have_i_been_pwned.sh \
#             c....c in-breach-names.txt

if [ $# -lt 2 ]; then
    error "$0 <api-key> <breach-names/file> 
                 [outfile=out-have-i-been-pwend-breach-details.txt]
                 [sleep_time_in_secs=4]"
    exit
fi
api_key="$1"
breach_names_file="$2"
outfile=${3:-"out-have-i-been-pwned-breach-details.txt"}
sleep_time_in_secs=${4:-"4"}

if [ -f "$breach_names_file" ]; then
    verbose "Reading the breaches from file: $breach_names_file"
    breaches_to_check=$(cat "$breach_names_file")
else
    verbose "Reading the breaches from user input: $breach_names_file"
    breaches_to_check=$(echo "$breach_names_file" | tr -s "," "\n")
fi

verbose "Checking if breach details outfile: $outfile exists"
if [ -f "$outfile" ]; then

    verbose "Deleting the breach details outfile: $outfile"
    rm "$outfile"
fi

verbose "Starting loop through all the breach names"
IFS=$'\n'
for breach_name in $breaches_to_check; do

    verbose "Getting breach details for breach: $breach_name via HaveIBeenPwned API into outfile: $outfile..."
    curl -s "https://haveibeenpwned.com/api/v3/breach/$breach_name" -H "hibp-api-key: $api_key" \
        | jq -r "." | tee -a "$outfile" 

    verbose "Sleeping for time: $sleep_time_in_secs seconds"
    sleep "$sleep_time_in_secs"
done
