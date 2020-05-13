#!/usr/bin/env python3
"""Script compresses a file via 7z installed on the device
"""
import os
import sys
import shlex
import argparse
import subprocess

def does_path_exist(file_folder_path):
    """Script checks whether the path exists or not
    
    Parameters
    ----------
    file_folder_path: str
        Does the file/folder path exists?

    Returns
    -------
    True, if the file path exist
    False, if the file path does not exist
    """
    return os.path.exists(file_folder_path)

def build_file_name(source_path):
    """Function builds the file path given the source path"""
    return (source_path + ".7z")

def compress_encrypt_file(params):
    """Compress/Encrypt file path given with the parameters
    
    Parameters
    ----------
    params: dict
        Parameters specified by the user which contain the source path,
        destination path, password to use if any
        
    """
    if sys.platform.lower() == "linux":
        params['7z_path'] = "/usr/bin/7z"
    elif sys.platform.lower() == "darwin":
        params['7z_path'] = "/usr/local/bin/7z"
    else:
        print("[-] Unknown OS: {}".format(sys.platform))
        sys.exit(1)

    if not params['password']:
        print("[*] Compressing file: {source_path} via 7z...".format(**params))
        subprocess.call(shlex.split("{7z_path} a \"{dest_path}\" \"{source_path}\"".format(**params)))
    else:
        print("[*] Compressing and Encrypting file: {source_path} via 7z...".format(**params))
        subprocess.call(shlex.split("{7z_path} a -mhe=on -p{password} \"{dest_path}\" \"{source_path}\"".format(**params)))

def remove_original_path(path_to_delete):
    """Removes the original file path
    
    Parameters
    ----------
    path_to_delete: str
        Path (File/Dir) to delete
    
    """
    if os.path.isdir(path_to_delete):
        shutil.rmtree(path_to_delete)
    elif os.path.isfile(path_to_delete):
        os.remove(path_to_delete)
    else:
        print("[-] Unable to delete file path: {}...".format(path_to_delete))
        sys.exit(1)

def main():
    """Function contains the main code to call when script is executed"""
    parser = argparse.ArgumentParser(description="Compresses a file via 7z installed on system")
    parser.add_argument("-s", "--source-path", dest="source_path", action="store", required=True)
    parser.add_argument("-d", "--dest-path", dest="dest_path", action="store")
    parser.add_argument("-p", "--password", dest="password", action="store")
    parser.add_argument("-ro", "--remove-original", dest="remove_original", action="store_true",
                        help="Remove the original file/dir that was compressed/encrypted, if set")
    params = vars(parser.parse_args())
    
    print("[*] Check if source path: {source_path} is specified...".format(**params))
    if not does_path_exist(params['source_path']):
        print("[-] Source path: {source_path} does not exist".format(**params))
        sys.exit(1)
    
    print("[*] Checking if destination path:{dest_path} is specified".format(**params))
    if not params['dest_path']:
        print("[*] Building destination file path...")
        params['dest_path'] = build_file_name(params['source_path'])
    elif os.path.isdir(params['dest_path']):
        print("[*] Building a destination file name from the destination file path...")
        dest_file_name = build_file_name(params['source_path'])
        params['dest_path'] += dest_file_name

    print("[*] Compressing/Encrypting file path: {source_path} -> {dest_path}".format(**params))
    compress_encrypt_file(params)
    
    if params['remove_original']:
        print("[*] Removing original file path: {source_path}".format(**params))
        remove_original_path(params['source_path'])


if __name__ == "__main__":
    main()

