#!/bin/bash
# 
# Script to open URLs in browser
# 

# Locations of browser in Linux to look for
LINUX_BROWSER_LOCATIONS="
/usr/bin/firefox
"
if [ "$#" -lt 1 ]; then
    echo "[-] ...<urls>... | $0 run [sleep_time=0]"
    exit 1
fi
sleep_time=${2:-"0"}

# Read the list of ALL urls
urls=$(cat -)

# Operating system in use
os=$(uname)

IFS=$'\n'
for url in $urls; do


    if [ "$os" == "Darwin" ]; then
    
        # Open the URL in default browser for Mac
        echo "[*] Opening the URL: $url in Mac"
        open "$url"

    elif [ "$os" == "Linux" ]; then
        
        # Loop through and find a browser to open URL with
        IFS=$'\n'
        for browser in $LINUX_BROWSER_LOCATIONS; do
            if [ ! -z "$browser" ]; then
                does_browser_exist=$(which "$browser")

                # Found a valid open browser
                if [ ! -z "$does_browser_exist" ]; then
                    echo "[*] Opening URL: $url via browser: $browser in Linux"
                    "$browser" "$url" 2>/dev/null 1>/dev/null &
                fi
            fi
        done
    else
        echo "[-] Unknown OS: $os"
        exit 1
    fi

    # Invoke sleep time if necessary
    if [ "$sleep_time" != "0" ]; then
        sleep "$sleep_time"
    fi
done