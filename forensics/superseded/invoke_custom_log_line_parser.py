#!/usr/bin/env python3 
import argparse
import os
import re
import sys

DESCRIPTION = """
**This script is no longer updated/modified**

Script will perform custom parsing line-by-line on a log file.
 
User can provide a custom log file with some data, and this file will process
each line with a regex and write the data to an output file.

Examples:
    To process the file in-file.txt, run the command: 
        REGEX="^(?P<date>[0-9\-]+)$\s*(?P<method>[A-Za-z]+)"
        cat in-file.txt | ./invoke_custom_log_line_parser.py "$"
"""

def main():
    parser = argparse.ArgumentParser(description=DESCRIPTION)
    parser.add_argument('-r', '--regex', required=True, 
                        help="Regex to use. See examples of how to form regex")
    parser.add_argument('-i', '--infile', required=True, 
                        help="Input file to parse each line of regex")
    parser.add_argument("-hl", "--heading-line", action="store_true",
                        help="Specifies first line as heading to ignore")   
    parser.add_argument("-rl", "--return-lines", default="0",
                        help="Number of lines to output. By default, all") 
    parser.add_argument("-dl", "--delimiter", default="|",
                        help="Delimiter to use")
    args = vars(parser.parse_args())

    print("[*] Checking input file: {infile} exists".format(**args))
    if not os.path.isfile(args['infile']):
        print("[-] File: {infile} not found!".format(**args))
        return 1

    with open(args['infile'], 'r+') as f:
        print("[*] Parsing lines of file: {infile} with regex".format(**args))
        for i, l in enumerate(f):
            line = l.strip()
            m = re.search(args['regex'], line, re.I)
            if m:
                results = m.groupdict()
                


if __name__ == "__main__":
    sys.exit(main())
