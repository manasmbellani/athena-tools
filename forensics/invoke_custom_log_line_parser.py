#!usr/bin/env python3 

import argparse
import os
import sys

DESCRIPTION = """
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
    args = parser.parse_args()
    args_dict = vars(args)

    print("[*] Checking input file: {infile} exists".format(**args_dict))
    if os.path.isfile()

if __name__ == "__main__":
    sys.exit(main())