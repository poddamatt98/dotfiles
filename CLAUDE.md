# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for macOS and Linux (apt-based). `scripts/setup.sh` (also run standalone, see `README.md`) clones the repo to `~/dotfiles` unless it finds an existing checkout, and symlinks each config folder into `~/.config`, so every tool picks up its config from its default XDG location (`~/.config/nvim`, `~/.config/tmux/tmux.conf`, `~/.config/ghostty/config`, `~/.config/aerospace/aerospace.toml`). Older macOS installs cloned the repo *as* `~/.config`, which setup detects and leaves alone. Many files hardcode `$HOME/.config/...` paths — keep that layout when adding or moving things, and add new top-level config folders to the link lists in `setup.sh`.

There is no build or test suite. "Verifying" a change means reloading the relevant tool:
- zsh: `zshrcrl` (alias for `source ~/.zshrc`)
- tmux: `prefix r` (prefix is `C-a`)
- nvim: restart; plugin state via `:Lazy`, health via `:checkhealth`
- aerospace: `aerospace reload-config`

Lua formatting follows `nvim/.stylua.toml`: run `stylua nvim/`.

## Bootstrap and shell

- `scripts/setup.sh` (bash, must stay bash 3.2-compatible for macOS) installs Homebrew if missing and the `BREW_FORMULAE` on both OSes. macOS also gets `MACOS_CASKS`; Linux first gets Homebrew's build prerequisites and zsh from apt, and the Hack Nerd Font from a release download, since casks are macOS-only. `zshrc` puts Linux Homebrew on `PATH`. It then links `SHARED_CONFIGS` (plus `MACOS_CONFIGS` on macOS) into `~/.config`, asking before moving an existing folder to `.bak` (the default), and appends `source "$HOME/.config/zshrc"` to `~/.zshrc` unless it's already there. Every step is skipped when already done, so it's safe to rerun.
- `zshrc` is sourced from `~/.zshrc`, not used directly. It builds a custom two-line prompt via `precmd`/`preexec` hooks (cwd, git branch/dirty, venv, AWS profile, exit status, command duration).

## tmux

- `tmux/tmux.conf` installs TPM and any missing plugin on startup (into the gitignored `tmux/plugins/`). Settings that catppuccin would overwrite go after the TPM `run-shell` line.
- `tmux/scripts/` holds the fzf pickers opened in popups: `prefix w` / `W` (windows), `prefix s` (sessions), `prefix ?` (key bindings, runs the selected one). Give every `bind-key` a `-N` note: it's the description `prefix ?` shows.
- After a change, run `tmux/tests/run.sh`, which must pass (it uses a private tmux server and `HOME`, and a stub fzf), and `shellcheck tmux/scripts/*.sh tmux/tests/*.sh`. CI runs both on push.

tmux uses vim-style pane navigation and integrates with `vim-tmux-navigator` on the Neovim side.

## Neovim

The Neovim config is maintained entirely by LLMs. **Read `nvim/README.md` before changing it.** It documents the layout, conventions, keymap prefixes and how to verify changes. In short:
- `lua/config/` holds core settings, and `lua/config/tools.lua` is the only place for LSP servers, formatters, linters and debuggers.
- `lua/plugins/` holds one lazy.nvim spec per file, imported automatically.
- After a change, run `nvim/tests/run.sh`, which must pass, and `stylua --check nvim`. CI runs both on push. Commit `lazy-lock.json` after updating plugins.
- Keep `nvim/README.md` in sync when you add files, keymap prefixes or conventions.

## Window manager

AeroSpace (`aerospace/aerospace.toml`, macOS only) is the tiling window manager. There is no custom status bar: SketchyBar was removed, and its config is in git history if it comes back.
