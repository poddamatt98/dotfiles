#!/usr/bin/env bash
# Loads tmux.conf on a private tmux server (installing the plugins if missing), then
# drives the fzf pickers through a real attached client, with a stub fzf choosing the
# line. Tests the checkout this script lives in, wherever it is.
set -euo pipefail
cd "$(dirname "$0")/.."
tmux_dir=$(pwd)

# Private HOME and socket dir, so the config's ~/.config/tmux paths resolve to this
# checkout and the test never touches a running tmux. XDG_CONFIG_HOME too: TPM reads
# the plugin list from there, and GitHub's runners set it to the real ~/.config.
work=$(mktemp -d)
export HOME="$work/home" TMUX_TMPDIR="$work" XDG_CONFIG_HOME="$work/home/.config"
mkdir -p "$HOME/.config"
ln -s "$tmux_dir" "$HOME/.config/tmux"
unset TMUX TMUX_PANE

t() { tmux -L test "$@"; }
cleanup() {
    t kill-server 2> /dev/null || true
    rm -rf "$work"
}
trap cleanup EXIT

failures=0
pass() { echo "ok:   $*"; }
fail() {
    echo "FAIL: $*"
    failures=$((failures + 1))
}
check() { # check <description> <expected> <actual>
    if [ "$2" = "$3" ]; then pass "$1"; else fail "$1 (expected '$2', got '$3')"; fi
}

# --- Config -------------------------------------------------------------------

t -f /dev/null new-session -d -s main -x 120 -y 40
# source-file, unlike loading the config at startup, reports errors and fails on them.
if out=$(t source-file "$HOME/.config/tmux/tmux.conf" 2>&1); then
    pass "tmux.conf loads without errors"
else
    fail "tmux.conf has errors:"$'\n'"$out"
fi

for plugin in tpm tmux vim-tmux-navigator; do
    if [ -d "plugins/$plugin" ]; then pass "plugin $plugin installed"; else fail "plugin $plugin missing"; fi
done
if [ -n "$(t show-options -gv @thm_bg)" ]; then pass "catppuccin loaded"; else fail "catppuccin not loaded"; fi

# Every binding needs a -N note: it's the description prefix ? shows.
missing=$(grep -n -E '^[[:space:]]*bind-key' tmux.conf | grep -v -E ' -N ' || true)
if [ -z "$missing" ]; then pass "every bind-key has a -N note"; else fail "bind-key without -N:"$'\n'"$missing"; fi

# --- Pickers ------------------------------------------------------------------

# Stub fzf: prints the first input line matching $PICK (grep -E).
mkdir -p "$work/bin"
cat > "$work/bin/fzf" << 'EOF'
#!/usr/bin/env bash
grep -E -m 1 "$PICK"
EOF
chmod +x "$work/bin/fzf"

# Attach a real client through a pseudo-terminal: switching and send-keys -K need one.
if script --version 2> /dev/null | grep -q util-linux; then
    attach=(script -qfc "tmux -L test attach -t main" /dev/null)
else
    attach=(script -q /dev/null tmux -L test attach -t main)
fi
(sleep 60 | TERM=xterm-256color "${attach[@]}" > /dev/null 2>&1 &)
for _ in $(seq 50); do
    [ -n "$(t list-clients)" ] && break
    sleep 0.1
done
[ -n "$(t list-clients)" ] || {
    fail "could not attach a client"
    exit 1
}

# The scripts call plain `tmux`: point them at the test server.
socket=$(t display-message -p '#{socket_path}')
pick() { # pick <regex> <script> [args...]: run a picker with the stub choosing <regex>
    local regex=$1
    shift
    TMUX="$socket,0,0" PATH="$work/bin:$PATH" PICK="$regex" bash "$@"
    sleep 0.5 # fzf-keys sends its keys 0.1s after exiting
}
client() { t list-clients -F "#{$1}"; }
tab=$'\t'

pick "^prefix${tab}\"${tab}" scripts/fzf-keys.sh
check 'fzf-keys runs prefix " (split)' 2 "$(t display-message -p -t main '#{window_panes}')"
pick "^prefix${tab};${tab}" scripts/fzf-keys.sh
check "fzf-keys runs prefix ; (last pane)" 1 "$(t display-message -p -t main '#{pane_index}')"

t new-session -d -s other -n first
t new-window -d -t other -n target.with.dots
pick ": target.with.dots" scripts/fzf-windows.sh -a
check "fzf-windows -a switches session and window" "other:target.with.dots" "$(client session_name):$(client window_name)"
pick ": first" scripts/fzf-windows.sh
check "fzf-windows switches window in the session" "first" "$(client window_name)"

pick "${tab}main" scripts/fzf-sessions.sh
check "fzf-sessions switches session" "main" "$(client session_name)"

# Without fzf on PATH, every picker fails instead of exiting silently.
mkdir -p "$work/nofzf"
ln -s "$(command -v tmux)" "$work/nofzf/tmux"
for script in scripts/fzf-*.sh; do
    if TMUX="$socket,0,0" PATH="$work/nofzf" "$(command -v bash)" "$script" > /dev/null 2>&1; then
        fail "$script exits 0 without fzf"
    else
        pass "$script fails without fzf"
    fi
done

echo
if [ "$failures" -gt 0 ]; then
    echo "$failures check(s) failed"
    exit 1
fi
echo "all checks passed"
