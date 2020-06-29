# forensics 
This folder contains a number of scripts that help in reviewing IPs, hosts on a 
regular basis. The scripts themselves have documentation on how to use them.

*All scripts provided here are based on publicly available tools and services*

## Misc
This section contains other tools/techniques and scripts to investigate IOCs/URLs

### Analysing Windows Systems
* Get folder properties via wmic: `wmic FSDIR where "drive='c:' and filename='test" get /format:list`. Taken from: https://www.hackingarticles.in/post-exploitation-using-wmic-system-command/
* Get the file properties via wmic `wmic datafile where name='c:\\windows\\system32\\demo\\demo.txt' get /format:list`. Taken from: https://www.hackingarticles.in/post-exploitation-using-wmic-system-command/
* Get diskdrive details via wmic: `wmic diskdrive get Name, Manufacturer, Model, InterfaceType, MediaLoaded, MediaType /format:list`. Taken from: https://www.hackingarticles.in/post-exploitation-using-wmic-system-command/
* Get information about memory chip: `wmic MEMORYCHIP get PartNumber, SerialNumber`. Taken from: https://www.hackingarticles.in/post-exploitation-using-wmic-system-command/

### Analysing ASNs
* List of all Autonomous Systems Numbers (ASNs): https://bgp.potaroo.net/cidr/autnums.html

### Analysing IPs


### Analysing URLs 
* Verify ISP reputation via Scamalytics: https://scamalytics.com/ip/isp
* Use `urlscanio` command available via pip and explained @ https://github.com/Aquarthur/urlscanio to submit URLs for scanning and taking screenshots via the API: https://urlscan.io/
