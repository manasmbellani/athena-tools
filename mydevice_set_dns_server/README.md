# mydevice_set_dns_server.sh
```
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
```
