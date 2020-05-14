#!/usr/bin/env python3
import argparse
import colorama
import os
import re
import subprocess
import sys

import colorama
from termcolor import colored

DESCRIPTION = """
Script is used to connect an external MyPassport via mount or ntfs-3g (in that order)
"""

def print_message(msg):
    print(colored(msg, 'green'))

def print_error(msg):
    print(colored(msg, 'red'))

def exec_cmd(cmd):
    print_message("Executing command: {}...".format(cmd))
    status_code, output = subprocess.getstatusoutput(cmd)
    print(status_code, output)
    return (status_code, output)

def enable_color():
    colorama.init()

def main():
    parser = argparse.ArgumentParser(description=DESCRIPTION, 
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-d", "--mount-dir", 
                        default="/Volumes/NTFS/MyPassportNtfs/MyPassport", 
                        help="Mount directory")
    parser.add_argument("-n", "--disk-name",
                        default="My Passport",
                        help="My Passport external drive identifier")
    args = parser.parse_args()
    
    enable_color()

    print_message("Check if running as root user...")
    current_user_id = os.getuid()
    if current_user_id != 0:
        print_error("Run the script as root user... current user ID: {}".format(current_user_id))
        return 1

    print_message("Check if using a Mac as script is only supported for mac...")
    os_in_use = sys.platform.lower() 
    if os_in_use != "darwin":
        print_error("OS in use: {} is not supported".format(os_in_use))
        return 1


    print_message("Locate disk identifier for disk with name: {}...".format(args.disk_name))
    __, diskutil_output = exec_cmd('diskutil list')
    m = re.search("{}[ ]*(?P<size>[^ ]+)[ ]*(?P<size_unit>[^ ]+)[ ]*(?P<identifier>[a-z0-9]+)[ ]*$".format(args.disk_name), diskutil_output)
    if m:
        disk_identifier = m.group('identifier')
        print_message("disk identifier: {}".format(disk_identifier))
        dev_path = "/dev/" + disk_identifier
        print_message("dev_path: {}".format(dev_path))
    else:
        print_error("Is MyPassport connected, no disk identifier found...")
        return 1

    print_message("Checking if mount directory exists...")
    if os.path.isdir(args.mount_dir):
        print_message("Attempting to eject mount directory...")
        exec_cmd("umount {}".format(args.mount_dir))

        print_message("Attempting to eject mount directory by dev path...")
        exec_cmd("sudo diskutil unmount {}".format(dev_path))
    else:
        print_message("Creating mount directory and sub-dirs...")
        os.makedirs(args.mount_dir)

    print_message("Re-mounting MyPassport on path: {}...".format(args.mount_dir))
    mount_success, __ = exec_cmd("sudo mount -t ntfs -o rw,auto,nobrowse /dev/{} {}".format(disk_identifier, args.mount_dir))
    if mount_success != 0:
        print_message("Checking if NTFS-3g is installed...")
        is_ntfs_3g_installed, __ = exec_cmd("which ntfs-3g")
        if is_ntfs_3g_installed == 0:
            print_message("NTFS-3g is not installed...")

        print_message("Attempting to mount via ntfs-3g...")
        exec_cmd("sudo /usr/local/bin/ntfs-3g {} {} -olocal -oallow_other".format(dev_path, args.mount_dir))
    
    print_message("Check if mypassport has been mounted...")
    exec_cmd("ls -1 {}".format(args.mount_dir))

if __name__ == "__main__":
    sys.exit(main())

