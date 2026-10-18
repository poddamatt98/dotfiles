#!/usr/bin/env bash
# Fuzzy-find the root and prefix key bindings, and run the selected one.
# Meant to run inside display-popup.

# The popup closes as soon as this exits, so report errors in the status line instead.
if ! command -v fzf > /dev/null; then
    tmux display-message -d 5000 "fzf-keys: fzf not found in PATH ($PATH)"
    exit 1
fi

prefix=$(tmux show-options -gv prefix)

# One line per binding: table and key (both hidden), then the key and its description.
# Keys and commands come from the plain listing, which escapes special keys with a
# backslash ('\#', 'C-\\'); notes come from -N, which lists only the keys that have one.
list_keys() {
    local table=$1 label=$2
    awk -v table="$table" -v label="$label" '
        # -N lines: "x KEY   note". Checked by file name, since this one can be empty.
        FILENAME == ARGV[1] {
            note = $0
            sub(/^[^ ]+ +[^ ]+ +/, "", note)
            notes[$2] = note
            next
        }
        # plain lines: "bind-key [-r] -T TABLE KEY command..."
        {
            for (i = 1; i <= NF; i++) if ($i == "-T") break
            escaped = $(i + 2)
            key = ""
            for (j = 1; j <= length(escaped); j++) {
                c = substr(escaped, j, 1)
                if (c == "\\") c = substr(escaped, ++j, 1)
                key = key c
            }
            if (key ~ /^(M-)?(Mouse|Wheel|DoubleClick|TripleClick|SecondClick)/) next
            cmd = $0
            sub(/^bind-key +(-r +)?-T +[^ ]+ +[^ ]+ +/, "", cmd)
            desc = (key in notes) ? notes[key] : cmd
            printf "%s\t%s\t%s%-12s%s\n", table, key, label, key, desc
        }' <(tmux list-keys -N -T "$table" -P "x ") <(tmux list-keys -T "$table")
}

all_keys() {
    list_keys root "    "
    list_keys prefix "$prefix "
}

# Keys without a note (most plugin ones) show their command, cut short so long ones
# don't flood the search.
selected=$(all_keys |
    awk '{ if (length($0) > 120) $0 = substr($0, 1, 119) "…"; print }' |
    fzf \
        --reverse \
        --no-sort \
        --delimiter=$'\t' \
        --with-nth=3.. \
        --prompt 'keys> ')
if [ -z "$selected" ]; then
    exit 0
fi

# Quote a key name for a tmux command, so ';' or '"' aren't parsed as syntax.
# '#' is doubled because run-shell expands formats before parsing.
quote() {
    local k=${1//#/##}
    case "$k" in
        *"'"*) printf '"%s"' "$k" ;;
        *) printf "'%s'" "$k" ;;
    esac
}

table=$(cut -f1 <<< "$selected")
keys=$(quote "$(cut -f2 <<< "$selected")")
if [ "$table" = "prefix" ]; then
    keys="$(quote "$prefix") $keys"
fi

# Press the keys as if typed (-K), once the popup has closed and stopped taking input.
client=$(tmux display-message -p '#{client_name}')
tmux run-shell -b -C -d 0.1 "send-keys -K -c '$client' $keys"
