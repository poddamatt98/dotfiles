#!/bin/bash

# check first argument - will be the folder containing the projects
if [ -z "$1" ]; then
    ws_path="$WORKSPACE_PATH"
else
    ws_path="$1"
fi

# fuzzy-find inside the projects folder
project=$(ls "$ws_path" | fzf --tmux)


project_src_dir='src'

session_name="$project"

# check if tmux is running
tmux_running=$(pgrep tmux)

#if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
#    tmux -d
#fi

if ! tmux has-session -t "$session_name" 2>/dev/null; then

    first=1
    for dir in "$ws_path"/"$project"/"$project_src_dir"/*/; do
        window_name=$(basename "$dir")
        
        if [ $first -eq 1 ]; then
            first=0
            tmux new-session -d -s "$session_name" -n "$window_name" -c "$dir" nvim
        else
            tmux new-window -d -t "$session_name" -n "$window_name" -c "$dir" nvim
        fi
        tmux split-window -d -t "$session_name":"$window_name" -c "$dir"
    done
fi


if [[ -z $TMUX ]]; then
    tmux attach-session -t "$session_name"
else
    tmux switch-client -t "$session_name"
fi
