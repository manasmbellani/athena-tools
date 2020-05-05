#!/bin/bash
# 
# Summary:
#     Script will pull the changed files aka 'git pull'
# 
# Description: 
#     Script will pull the changes in the specified folder
#
# Args:
#      folder_to_pull_changes: Changes are pulled for the specific folder
# 
# Output: 
#      Details of changes pulled to the folder
# 
# Examples:
#     To show updated files in the current repo folder:
#         ./invoke_git_pull.sh
# 
#     To show updated files in the '/tmp/repo' repo folder:
#         ./invoke_git_pull.sh /tmp/repo
# 

folder_to_pull_changes=${1:-"."}

if [ "$folder_to_pull_changes" != "." ] && [ ! -d "$folder_to_pull_changes" ]; then
    echo "Folder to pull from: $folder_to_show_changes does not exist."
    exit 1
fi

echo "[*] Switching to root folder to commit from: $folder_to_pull_changes"
cd "$folder_to_pull_changes"

echo "[*] Getting the git root folder"
git_root_folder="$(git rev-parse --show-toplevel)"

echo "[*] Switching to the git root folder: $git_root_folder"
cd "$git_root_folder"

echo "[*] Show the changes via git pull"
git pull
