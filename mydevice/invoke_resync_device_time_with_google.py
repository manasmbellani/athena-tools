#!/usr/bin/python3
import requests
import subprocess
import shlex
import sys

def exec_cmd(cmd):
    """Execute the command on system"""
    subprocess.Popen(shlex.split(cmd))

print("[*] Checking if running on supported Linux platform")
os = sys.platform
if os.lower() != "linux": 
    print("[-] Not running on support platform. Current platform: {}".format(os))
    sys.exit(1)

print("[*] Calling Google website to get headers ")
resp = requests.get("http://www.google.com")

print("[*] Getting current date from Google's response")
headers = resp.headers
day_date = headers["Date"]
day, date_timezone = day_date.split(",")
date_with_space, timezone = date_timezone.split("GMT")
correct_date = date_with_space.strip()

print("[*] Setting system date to Google's date")
exec_cmd("date -s '{}Z'".format(correct_date))
