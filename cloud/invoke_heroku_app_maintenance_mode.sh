#!/bin/bash
# Script will put a specified heroku app into maintenance mode
# Determine the heroku App ID by running the heroku app list
if [ $# -lt 2 ]; then
    echo "[-] $0 <app-id> <mode=on/off>"
    exit 1
fi
app_id="$1"
mode="$2"

if [ "$mode" == "on" ] || [ "$mode" == "off" ]; then
    heroku maintenance:$mode --app "$app_id"
else
    echo "[-] Unknown maintenance mode: $mode specified" 
    exit 1
fi
