#!/bin/sh
# Installs the plugins pinned in lazy-lock.json, then runs the smoke test.
# Tests the checkout this script lives in, wherever it is.
set -e
cd "$(dirname "$0")/.."
XDG_CONFIG_HOME="$(cd .. && pwd)"
export XDG_CONFIG_HOME

nvim --headless "+Lazy! install" +qa
nvim --headless --cmd "luafile tests/smoke.lua"
