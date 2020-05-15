#!/usr/bin/env python3
# 
# Script will get a JPG screenshot for Web IP, domain, URL using wkhtmltoimage &
# wkhtml utility within python
# 
# More info available here: https://github.com/jarrekk/imgkit
# 
# Requires:
#     wkhtml installed via pip with command:
#         python3 -m pip install wkhtml
# 
#     wkhtmltoimage, installed via brew in Mac or apt-get in linux:
#         sudo apt-get -y install wkhtmltoimage
#         brew install wkhtmltoimage
# 
# Args:
#     urls: List of URLs comma-separated OR file with list of URLs to scan.
#         Required.
#     out: Output file name to use for screenshots. If not provided, by default,
#         name is prepared from filename.
# 

# Image type screenshot to get via imgkit
IMG_EXTENSION = ".jpg"

# Image prefix (to apply if outfile not provided)
IMG_PREFIX = "out-"

import argparse
import imgkit
import os
import sys

def main():
    parser = argparse.ArgumentParser(description="""
        Script takes a JPG screenshot of one or more URLs provided
    """)
    parser.add_argument("-u", "--urls", required=True,
                        help="List of URLs to get screenshot")
    parser.add_argument("-o", "--out-prefix", help="Output file/folder prefix")
    args = vars(parser.parse_args())

    print("[*] Checking if individual URLs or file of URLs provided")
    urls_to_screenshot = []
    if os.path.isfile(args['urls']):

        print("[*] Reading URLs from file: {urls}".format(**args))
        with open(args['urls'], 'r+') as f:
            for line in f.readlines():
                url = line.strip()
                urls_to_screenshot.append(url)

    else:

        print("[*] Reading URLs from user")
        urls_to_screenshot = args['urls'].split(",")

        # Removing white spaces
        urls_to_screenshot = [ url.strip() for url in urls_to_screenshot ]

    print("[*] Counting number of URLs to screenshot")
    num_urls_to_screenshot = len(urls_to_screenshot)
    print("[+] Number of URLs to screenshot: {}".format(num_urls_to_screenshot))

    print("[*] Looping through each URL to take screenshot")
    for i, url in enumerate(urls_to_screenshot):

        print("[*] Getting outfile for url: {}".format(url))
        if args['out_prefix']:
            # Build outfile from the outfile name provided by user
            outfile = args['out_prefix'] + "-" + i + IMG_EXTENSION
        else:
            # Build outfile from URL
            outfile = IMG_PREFIX + \
                url.replace(":", "-").replace("/", "-").replace(".", "-") + \
                IMG_EXTENSION    

        print("[*] Taking screenshot of URL: {} into outfile: {}".format(url,
            outfile))
        try:
            imgkit.from_url(url, outfile)
            print("[+] Screenshot for URL: {} was successful".format(url))
        except Exception as e:
            print("[-] Error when taking screenshot for URL: {}".format(url))
            print("[-] Error: {}, {}".format(e.__class__, str(e)))

if __name__ == "__main__":
    sys.exit(main())
