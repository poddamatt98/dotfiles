#!/usr/bin/env bash
# Fuzzy-find a tmux session and switch to it. Meant to run inside display-popup.

# The popup closes as soon as this exits, so report errors in the status line instead.
if ! command -v fzf > /dev/null; then
    tmux display-message -d 5000 "fzf-sessions: fzf not found in PATH ($PATH)"
    exit 1
fi

# Hidden field 1 is the session id used to switch; the rest is shown.
selected=$(tmux list-sessions -F $'#{session_id}\t#{session_name}#{?session_attached, *,}\t#{session_windows} windows\t#{pane_current_path}' | fzf \
    --reverse \
    --delimiter=$'\t' \
    --with-nth=2.. \
    --preview 'tmux capture-pane -ep -t {1}' \
    --preview-window 'right,60%')
if [ -z "$selected" ]; then
    exit 0
fi

tmux switch-client -t "$(cut -f1 <<< "$selected")"
