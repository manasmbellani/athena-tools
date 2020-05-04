#!/bin/bash
# 
# Summary:
#     Script will display each line change aka 'git diff'
# 
# Description: 
#     Script will show all changes in the specified folder OR the current git
#     folder, by default.
# 
# Args:
#      folder_to_show_changes: Changes are shown from the specific folder
# 
# Output: 
#     Individual line changes within the folder
#
# Examples:
#     To show line changes in the current root repo folder:
#         ./invoke_git_diff.sh 
# 
#     To show line changes in the '/tmp/repo' repo folder:
#         ./invoke_git_diff.sh "/tmp/repo" 
# 

folder_to_show_changes=${1:-"."}

if [ "$folder_to_show_changes" != "." ] && [ ! -d "$folder_to_show_changes" ]; then
    echo "Folder to commit from: $folder_to_show_changes does not exist."
    exit 1
fi

echo "[*] Switching to root folder to commit from: $folder_to_show_changes"
cd "$folder_to_show_changes"

echo "[*] Getting the git root folder"
git_root_folder="$(git rev-parse --show-toplevel)"

echo "[*] Switching to the git root folder: $git_root_folder"
cd "$git_root_folder"

echo "[*] Show the changes via git diff"
git diff
