#!/usr/bin/env bash
# Fuzzy-find a tmux window and switch to it. Meant to run inside display-popup.
#   fzf-windows.sh      windows of the current session
#   fzf-windows.sh -a   windows of all sessions

# The popup closes as soon as this exits, so report errors in the status line instead.
if ! command -v fzf > /dev/null; then
    tmux display-message -d 5000 "fzf-windows: fzf not found in PATH ($PATH)"
    exit 1
fi

# Hidden fields 1-2 are the session and window ids used to switch; the rest is shown.
if [ "$1" = "-a" ]; then
    list=(list-windows -a -F $'#{session_id}\t#{window_id}\t#{session_name}\t#{window_index}: #{window_name}#{?window_active, *,}\t#{pane_current_path}')
else
    list=(list-windows -F $'#{session_id}\t#{window_id}\t#{window_index}: #{window_name}#{?window_active, *,}\t#{pane_current_path}')
fi

selected=$(tmux "${list[@]}" | fzf \
    --reverse \
    --delimiter=$'\t' \
    --with-nth=3.. \
    --preview 'tmux capture-pane -ep -t {2}' \
    --preview-window 'right,60%')
if [ -z "$selected" ]; then
    exit 0
fi

session_id=$(cut -f1 <<< "$selected")
window_id=$(cut -f2 <<< "$selected")
tmux switch-client -t "$session_id" \; select-window -t "$window_id"
