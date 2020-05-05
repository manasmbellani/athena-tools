#!/usr/bin/env python3

import argparse
import json
import os
import re
import time
import vt

# Sleep time (in) between each request to meet Virustotal 
# limit
SLEEPTIME = 16

# Regex for MD5, 
HASH_REGEX = "^[A-Fa-f0-9]{32,64}$"

# Script details
DESCRIPTION = """
    Script provides ability to upload IOCs for verification in Virustotal. 
    This Script depends on VirusTotal(VT) python3 library which is the original 
    python3 published under the Virustotal Github account. This script takes 
    a set of files

    To install the requirements, run the following command: 
        python3 -m pip install vt-py

    Once installed, the API key can be downloaded by registering and signing-in
    to the https://www.virustotal.com from the top-right hand corner. Next, 
    supply a list of any hashes (MD5,SHA-1,SHA-256), domain OR urls in a file 
    one-per-line.

    For free VT account, as at 5th May 2020, VT has limit of 4 requests per 
    minute, so there is a sleeptime of approx 16 seconds by default to stay 
    within this limit. This can be specified to a smaller value by the user.

    Virustotal API info taken from: 
        https://virustotal.github.io/vt-py/howtoinstall.html
    
    Examples:
        To check the Virustotal stats for the testurl.com,testurl2.com:
            ./get_virustotal_iocs_info.py \
                -ak d0...eb \
                -i "testurl.com,testurl2.com"

        To check the Virustotal stats for IOCs in file in-iocs-to-check.txt:
            ./get_virustotal_iocs_info.py \
                -ak d0...eb \
                -i in-iocs-to-check.txt

        To get ALL Virustotal info for IOCs in file in-iocs-to-check.txt:
            ./get_virustotal_iocs_info.py \
                -ak d0...eb \
                -i in-iocs-to-check.txt \
                -all

        To get all AV Virustotal results for IOCs from file in-iocs-to-check.txt:
            ./get_virustotal_iocs_info.py \
                -ak d0...eb \
                -i in-iocs-to-check.txt \
                -av
"""

def is_hash(ioc):
# Function determines if a hash is specified by validation against Hash Regex
#
# Args:
#     ioc: IOC to test if it is hash
# 
# Returns:
#     True, if hash. False otherwise
# 
    m = re.match(HASH_REGEX, ioc)
    if m:
        return True
    else:
        False

parser = argparse.ArgumentParser(description=DESCRIPTION)
parser.add_argument("-ak", "--api-key", required=True,
    help="API Key to use for checking VT")
parser.add_argument("-i", "--iocs", required=True,
    help="Single IOC, comma-sep IOCs or files with multiple IOCs, one per line")
parser.add_argument("-s", "--sleeptime", default=SLEEPTIME,
    help="Sleep Time (in seconds)")
parser.add_argument("-av", "--avs", action="store_true",
    help="Dumps info about AV scan results for IOC in addition")
parser.add_argument("-all", "--all", action="store_true",
    help="Dumps ALL info about the IOC")
args = vars(parser.parse_args())

# Store IOCs to check here
iocs = []

print("[*] Checking if input is a single IOC or file")
if os.path.isfile(args['iocs']):
    
    print("[*] Reading IOCs from file: {api_key}".format(**args))
    with open(args['iocs'], 'r+') as f:
        for line in f:
            ioc = line.strip()
            if ioc:
                args['ioc'] = ioc
                print("[*] Adding IOC: {ioc} for analysis".format(**args))
                iocs.append(ioc)

else:
    print("[*] Reading IOCs from user")
    iocs = args['iocs'].split(",")

print("[*] Checking number of IOCs to get info on")
num_iocs = len(iocs)
args['num_iocs'] = num_iocs

print("[+] Number of IOCs to parse: {num_iocs}".format(**args))

print("[*] Initializing Virus total client with API key")
client = vt.Client(args['api_key'])

print("[*] Converting sleeptime to int")
sleep_time = int(SLEEPTIME)
args['sleep_time'] = sleep_time

print("[*] Looping through each IOC, and converting to lower-case")
for i, ioc in enumerate(iocs):

    try:
        print("[*] Check if IOC is a hash or domain/url")
        is_ioc_hash = is_hash(ioc)
        
        if is_ioc_hash:
            # Convert hash to lower-case for consistency
            ioc = ioc.lower()
            args['ioc'] = ioc.lower()

            print("[*] Use VT API to get info on hash ioc: {ioc}".format(**args))
            ioc_info = client.get_object("/files/" + ioc)

        else:
            args['ioc'] = ioc
            
            print("[*] Use VT API to get info on url ioc: {ioc}".format(**args))
            url_id = vt.url_id(ioc)
            ioc_info = client.get_object("/urls/{}", url_id)

        print("[+] IOC: {ioc} Analysis".format(**args))
        print(json.dumps(ioc_info.last_analysis_stats, indent=4))

        if args['avs']:
            print("[+] IOC: {ioc} AV detections")
            print(json.dumps(ioc_info.last_analysis_results, indent=4))

        if args['all']:
            print("[+] IOC: {ioc} All Info")
            print(json.dumps(ioc_info.to_dict(), indent=4))

    except Exception as e:
        args['err'] = str(e)
        args['err_class'] = str(e.__class__)
        print("[-] Error for ioc: {ioc}, err_class: {err_class}, error: {err}".format(**args))
        
    # Skip the wait if last IOC
    if i < len(iocs)-1:
        print("[*] Sleeping for {sleep_time} secs".format(**args))
        time.sleep(sleep_time)

print("[*] Closing the Virustotal client")
if client:
    client.close()
