# forensics 

## Scripts

### get_virustotal_iocs_info.py
```
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
```

## Misc
* TODO: Create custom log line parser 
* TODO: HaveIbeenPwned API to confirm database breaches
* TODO: Virustotal API script to get more info about hashes