#!/bin/bash
# 
# Summary:
#     Script will perform git commit from the root folder of the repo.
# 
# Description: 
#     Script will commit changes from the root of current repo OR from the root
#     of  a different specified folder using git
# 
# Args:
#      commit_msg: commit message for all the changes. Required.
#      changes_to_commit: List of files to commit. By default, all aka '.'
#                         Can specify space separated list of files
#      folder_to_commmit_from: Folder to commit from.
# 
# Output: 
#      File Commit messages
# 

if [ $# -lt 1 ]; then
    echo "[-] $0 <commit_msg> 
                 [changes_to_commit=.]
                 [folder-to-commit-from=.]"
    exit 1
fi
commit_msg="$1"
changes_to_commit=${2:-"."}
folder_to_commit_from=${3:-"."}

if [ "$folder_to_commit_from" != "." ] && [ ! -d "$folder_to_commit_from" ]; then
    echo "Folder to commit from: $folder_to_commit_from does not exist."
    exit 1
fi

echo "[*] Switching to root folder to commit from: $folder_to_commit_from"
cd "$folder_to_commit_from"

echo "[*] Getting the git root folder"
git_root_folder="$(git rev-parse --show-toplevel)"

echo "[*] Switching to the git root folder: $git_root_folder"
cd "$git_root_folder"

echo "[*] Pulling the latest changes via git pull"
git pull

echo "[*] Adding all specified changes to commit"
IFS=" "
for change in $changes_to_commit; do
    echo "[*] Adding change change: $changes_to_commit for commit"
    git add "$change"
done

echo "[*] Commiting changes with msg"
git commit -m "$commit_msg"

echo "[*] Pushing the changes via git"
git push
