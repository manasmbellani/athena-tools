#!/bin/bash
# 
# Script will perform quick git commit from the root folder of the repo with generic commit message
# 
# Args:
#      commit_msg: commit message for all the changes. By default, 'added or updated new tools or 
#                  techniques'
#      changes_to_commit: List of files to commit. By default, all aka '.'
#                         Can specify space separated list of files
#      folder_to_commmit_from: Folder to commit from.
# 
# Output: 
#      File Commit messages
# 

folder_to_commit_from=${1:-"."}
changes_to_commit=${2:-"."}
commit_msg=${3:-"added or updated new tools or techniques"}

# Current script directory
script_dir=$(dirname "$0")

echo "[*] Performing quick commit"
$script_dir/invoke_git_commit.sh "$commit_msg" "$folder_to_commit_from" "$changes_to_commit"
