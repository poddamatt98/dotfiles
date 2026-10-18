#!/bin/sh
# Installs the plugins at the commits pinned in lazy-lock.json (lazy.nvim included), then runs the smoke test.
# Tests the checkout this script lives in, wherever it is.
set -e
cd "$(dirname "$0")/.."
XDG_CONFIG_HOME="$(cd .. && pwd)"
export XDG_CONFIG_HOME

nvim --headless "+Lazy! restore" +qa
echo
nvim --headless --cmd "luafile tests/smoke.lua"
