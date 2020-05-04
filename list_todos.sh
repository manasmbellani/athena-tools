#!/bin/bash
# 
# Script will list all the TODOs in the current script folder. These are things 
# to-do.
# 
# Examples:
#     To discover the TODO items, run the command:
#         ./list_todos.sh

TODO_LABEL="TODO:"

script_folder="$(dirname $0)"

# Exclude from finding all labels in this script, otherwise show all labels, 
# color-coded
grep -r -n -i --color "$TODO_LABEL" "$script_folder" \
    | grep -v "list_todos.sh" \
    | grep -i --color "$TODO_LABEL"
