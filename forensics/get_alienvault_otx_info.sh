#!/bin/bash
# 
# Script gets Alienvault Online Threat Exchange (OTX) info about an IOC using
# Direct Connect API. No API creds are needed for using this API.
#
# Alienvault Direct Connect API and the various sections are documented here: \
#      https://otx.alienvault.com/api
# 
# Please note that paging is not implemented so only the first page is currently
# returned. Review the 'next' and the 'page' flag in response to confirm if next
# page is present.
# 
# Requires:
#     jq, to parse the output. This can be installed with in Mac, Linux via brew
#         and apt-get respectively: 
#              brew install jq
#              
#              sudo apt-get -y install jq
# 
# Input:
#     List of IOCs one-per-line.
# 
# Args:
#     sections_to_get: Section of info to get via the API. 'all' will attempt to 
#         get ALL info, whereas a specific name e.g general, reputation will
#         attempt to get some info
#     sleep_timeout: Number of seconds to sleep between requests. By default, 
#         3s.
# 
# Example:
#     To get ALL info about IP: 8.8.8.8, run the command:
#         echo "8.8.8.8" | ./get_alientvault_info.sh 'all'
# 
#     To get ALL info about IP: 8.8.8.8, run the command:
#         echo "8.8.8.8" | ./get_alientvault_info.sh 'all'
# 



# User agent string to use for ALL operations
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36"

# Error name to generate when invalid IOC/format combination provided.
INVALID_IOC_FORMAT_ERROR="Invalid IOC/Format provided"

# Alienvault OTX domain
ALIENVAULT_OTX_DOMAIN="otx.alienvault.com"

# Alienvault Main API URL
ALIENVAULT_INDICATORS_API_URL="https://$ALIENVAULT_OTX_DOMAIN/api/v1/indicators"

# Valid sections for IPv4
IPV4_SECTIONS="general,reputation,geo,malware,url_list,passive_dns,http_scans"

# Valid sections for IPv6
IPV6_SECTIONS="general,reputation,geo,malware,url_list,passive_dns"

# Valid sections for Domains
DOMAIN_SECTIONS="general,geo,malware,url_list,whois,passive_dns"

# Valid sections for URLs
URL_SECTIONS="general,url_list"

# Determine the info to get about the IOC from user
sections_to_get=${1:-"all"}
sleep_timeout=${2:-"3"}

function get_format {
    # Function returns the format of the IOC provided. Currently, the function
    # supports identification of following types: md5, sha256, sha1, ipv4, ipv6,
    # domain, url
    # 
    # Args:
    #      ioc_value: IOC value to get the format
    # 
    # Returns:
    #     md5, sha256, sha1, ipv4, ipv6, domain, url, unknown
    # 
    local ioc_value="$1"

    # Regex format for IOCs
    local md5_regex="[a-fA-F0-9]{32}"
    local sha256_regex="[a-fA-F0-9]{64}"
    local sha1_regex="[a-fA-F0-9]{40}"
    local ipv4_regex="[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
    local ipv6_regex=".*:.*:.*"
    local domain_regex="[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_\.\-]{1,6}"
    local url_regex="/?[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_\.\-]{1,6}/?.*"

    local is_md5=$(echo "$ioc_value" | egrep -i "^$md5_regex$")
    local is_sha256=$(echo "$ioc_value" | egrep -i "^$sha256_regex$")
    local is_sha1=$(echo "$ioc_value" | egrep -i "^$sha1_regex$")
    local is_ipv4=$(echo "$ioc_value" | egrep -i "^$ipv4_regex$")
    local is_ipv6=$(echo "$ioc_value" | egrep -i "^$ipv6_regex$")
    local is_domain=$(echo "$ioc_value" | egrep -i "^$domain_regex$")
    local is_url=$(echo "$ioc_value" | egrep -i "$url_regex")

    if [ ! -z "$is_md5" ]; then
        format="md5"
    elif [ ! -z "$is_sha1" ]; then
        format="sha1"
    elif [ ! -z "$is_sha256" ]; then
        format="sha256"
    elif [ ! -z "$is_ipv4" ]; then
        format="ipv4"
    elif [ ! -z "$is_ipv6" ]; then
        format="ipv6"
    elif [ ! -z "$is_domain" ]; then
        format="domain"
    elif [ ! -z "$is_url" ]; then
        format="url"
    else
        format="unknown"
    fi

    echo "$format"
    if [ "$format" == "unknown" ]; then
        return 1
    else
        return 0
    fi
}

function get_alienvault_otx_url {
    # Function builds the URL API to query based on the IOC and the format of  
    # IOC provided
    # 
    # Args:
    #     ioc: IOC name e.g. domain, ipv4, ipv6, url, etc.
    #     format: Format of IOC e.g. domain, ipv6, ipv4, url
    #     sections_to_get: Sections to get e.g. All or specific sections to get
    #
    local ioc="$1"
    local format="$2"
    local sections_to_get="$3"

    # Store sections to loop through to build URLs here
    local sections=""

    # Store the URLs in this
    local alienvault_urls=""

    if [ -z "$ioc" ]; then
        echo "[-] $INVALID_IOC_FORMAT_ERROR: IOC value cannot be empty"
        return 1
    elif [ -z "$format" ]; then
        echo "[-] $INVALID_IOC_FORMAT_ERROR: Format cannot be empty"
        return 2
    else
        # Get the relevant section depending on the ioc format
        if [ "$format" == "domain" ]; then
            if [ "$sections_to_get" == "all" ]; then
                sections="$DOMAIN_SECTIONS"
            else
                sections="$sections_to_get"
            fi
        elif [ "$format" == "url" ]; then
            if [ "$sections_to_get" == "all" ]; then
                sections="$URL_SECTIONS"
            else
                sections="$sections_to_get"
            fi
        elif [ "$format" == "ipv4" ]; then
            if [ "$sections_to_get" == "all" ]; then 
                sections="$IPV4_SECTIONS"
            else
                sections="$sections_to_get"
            fi
        elif [ "$format" == "ipv6" ]; then
            if [ "$sections_to_get" == "all" ]; then
                sections="$IPV6_SECTIONS"
            else
                sections="$sections_to_get"
            fi
        else
            echo "[-] $INVALID_IOC_FORMAT_ERROR: No sections available for format: $format"
            return 3
        fi
       
        
        IFS=","
        for section in $sections; do
            if [ "$format" == "ipv4" ]; then
                alienvault_urls="$alienvault_urls,$ALIENVAULT_INDICATORS_API_URL/IPv4/$ioc/$section"
            elif [ "$format" == "ipv6" ]; then
                alienvault_urls="$alienvault_urls,$ALIENVAULT_INDICATORS_API_URL/IPv6/$ioc/$section"
            elif [ "$format" == "url" ]; then
                alienvault_urls="$alienvault_urls,$ALIENVAULT_INDICATORS_API_URL/url/$ioc/$section"
            elif [ "$format" == "domain" ]; then
                alienvault_urls="$alienvault_urls,$ALIENVAULT_INDICATORS_API_URL/domain/$ioc/$section"
            else
                echo "[-] $INVALID_IOC_FORMAT_ERROR: Unsupported format: $format"
                return 4
            fi
        done
        alienvault_urls=$(echo "$alienvault_urls" | sed -E "s/^,//g")
    fi

    # Return the alienvault URLs
    echo "$alienvault_urls"
    
}

# List of IOCs to query info on
iocs_to_query=$(cat -)

IFS=$'\n'
for ioc in $iocs_to_query; do
    if [ ! -z "$ioc" ]; then
        # Getting the IOC format
        ioc_format=$(get_format "$ioc")
        return_code_get_format=$?
        if [ "$return_code_get_format" == "0" ]; then
            echo "[+] IOC format for ioc: $ioc is: $ioc_format"
            
            # Get the Alienvault URLs
            alienvault_urls=$(get_alienvault_otx_url "$ioc" "$ioc_format" \
                "$sections_to_get")

            # Check if the AlienVault URLs were obtained without any errors
            return_code_getting_urls="$?"

            # Check if the Alienvault URLs could be obtained successfully
            if [ "$return_code_getting_urls" == "0" ]; then
                IFS=","
                for alienvault_url in $alienvault_urls; do

                    # Make CURL request to get the response
                    echo "[+] Getting info via URL: $alienvault_url for \
ioc: $ioc, format: $ioc_format"
                    resp=$(curl -s -A "$USER_AGENT" "$alienvault_url")

                    # Check if response was successful
                    err_code_curl="$?"
                    if [ "$err_code_curl" ]; then
                        # Parse successful response as JSON
                        echo "$resp" | jq -r "."

                    else
                        # print the curl raw response and error code
                        echo "[-] Error getting response for url: $alienvault_url"
                        echo "[-] Error: $err_code_curl, $resp"
                    fi

                    # Sleep for a few seconds before making next request
                    echo "[*] Sleeping for ""$sleep_timeout""s before next req"
                    sleep "$sleep_timeout"
                done
            else
                echo "[-] Error getting alienvault urls."
                echo "[-] Error: $return_code_getting_urls, $alienvault_urls"
            fi
        else
            echo "[-] Error getting IOC: $ioc format: $ioc_format"
        fi
    fi
done