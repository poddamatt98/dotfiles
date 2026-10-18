# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal macOS dotfiles. The repo is meant to be cloned **as `~/.config`** (`git clone --recurse-submodules -j8 https://www.github.com/poddamatt98/dotfiles.git .config` from `$HOME`), so every tool picks up its config from its default XDG location (`~/.config/nvim`, `~/.config/tmux/tmux.conf`, `~/.config/ghostty/config`, `~/.config/aerospace/aerospace.toml`, `~/.config/sketchybar/sketchybarrc`). Many files hardcode `$HOME/.config/...` paths — keep that layout when adding or moving things.

There is no build or test suite. "Verifying" a change means reloading the relevant tool:
- zsh: `zshrcrl` (alias for `source ~/.zshrc`)
- tmux: `prefix r` (prefix is `C-a`)
- nvim: restart; plugin state via `:Lazy`, health via `:checkhealth`
- sketchybar: `sketchybar --reload`

Lua formatting follows `nvim/.stylua.toml`: run `stylua nvim/`.

## Bootstrap and shell

- `scripts/setup.sh` installs Homebrew packages (fzf, ripgrep, tmux, neovim, aerospace, nerd font), chmods `scripts/*`, and appends `source $HOME/.config/zshrc` to `~/.zshrc`. It uses the `PODDAMAT_CONFIG` env var (exported by `zshrc`) as the "already configured" guard.
- `zshrc` is sourced from `~/.zshrc`, not used directly. It builds a custom two-line prompt via `precmd`/`preexec` hooks (cwd, git branch/dirty, venv, AWS profile, exit status, command duration), sets `PROJECTS_PATH`, and binds `Ctrl-f` to the tmux project picker.

## tmux project workflow

Two session pickers live in `scripts/`:
- `tmux-sessionizer.sh` — fzf over directories in `$PROJECTS_PATH`, creates/attaches a session named after the dir.
- `my_tmux.sh` — the one actually bound (zsh `Ctrl-f` and tmux `prefix f`). fzf over `$WORKSPACE_PATH` (or `$1`), and for a new session creates one window per subdirectory of `<project>/src/`, each running `nvim` with a split shell. Note it reads `WORKSPACE_PATH`, while `zshrc` only exports `PROJECTS_PATH`.

tmux uses vim-style pane navigation and integrates with `nvim-tmux-navigator` on the Neovim side.

## Neovim

The Neovim config is maintained entirely by LLMs. **Read `nvim/README.md` before changing it.** It documents the layout, conventions, keymap prefixes and how to verify changes. In short:
- `lua/config/` holds core settings, and `lua/config/tools.lua` is the only place for LSP servers, formatters, linters and debuggers.
- `lua/plugins/` holds one lazy.nvim spec per file, imported automatically.
- After a change, run `nvim/tests/run.sh`, which must pass, and `stylua --check nvim`. CI runs both on push. Commit `lazy-lock.json` after updating plugins.
- Keep `nvim/README.md` in sync when you add files, keymap prefixes or conventions.

## Window manager and bar

AeroSpace (`aerospace/aerospace.toml`) launches SketchyBar on startup and fires the custom `aerospace_workspace_change` event with `FOCUSED_WORKSPACE` on every workspace switch. `sketchybar/sketchybarrc` creates one item per `aerospace list-workspaces --all` subscribed to that event, and `sketchybar/plugins/aerospace.sh` highlights the focused one. Changes to workspace handling usually touch both configs.
