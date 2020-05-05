#!/usr/bin/env python3

import argparse
import json
import os
import time
import vt

# Sleep time (in) for a request
SLEEPTIME = 20

# Regex for MD5, 
HASH_REGEX="^[A-Fa-f0-9]{32,64}$"

# Script details
DESCRIPTION = """
    Script provides ability to upload IOCs for verification in 
    Virustotal. Script depends on VT python3 library 
"""


parser = argparse.ArgumentParser(description=DESCRIPTION)
parser.add_argument("-ak", 
                    "--api-key", 
                    required=True,
                    help="API Key to use for checking VT")
parser.add_argument("-i", 
                    "--iocs", 
                    required=True,
                    help="Single IOC or file with multiple, one per line")
parser.add_argument("-s",
                     "--sleeptime",
                     default=SLEEPTIME,
                     help="Sleep Time (in seconds)")
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
for ioc in iocs:
    args['ioc'] = ioc.lower()

    try:
        print("[*] Using Virustotal API to check for ioc: {ioc}".format(**args))
        ioc_info = client.get_object("/files/" + ioc)

        print("[+] IOC: {ioc}".format(**args))
        print(json.dumps(ioc_info.last_analysis_stats, indent=4))

    except Exception as e:
        args['err'] = str(e)
        args['err_class'] = str(e.__class__)
        print("[-] Error for ioc: {ioc}, err_class: {err_class}, error: {err}".format(**args))
        
    print("[*] Sleeping for {sleep_time} seconds before issuing next check".format(**args))
    time.sleep(sleep_time)

print("[*] Closing the Virustotal client")
if client:
    client.close()
    
