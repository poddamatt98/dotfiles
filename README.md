# dotfiles

My own macOS and Linux configuration. :D

## Setup

On a new machine, run:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/poddamatt98/dotfiles/main/scripts/setup.sh)
```
macOS doesn't ship `wget`, so use `curl` there:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/poddamatt98/dotfiles/main/scripts/setup.sh)
```

The script:
1. installs the tools with Homebrew, installing Homebrew itself if needed (on Linux, its
   prerequisites and zsh come from apt);
2. clones this repo into `~/dotfiles` (set `DOTFILES_DIR=<path>` to change it), or reuses
   an existing checkout;
3. links each config folder into `~/.config`. If one already exists there, it asks
   before moving it to `.bak`;
4. makes `~/.zshrc` source `zshrc`.

It's safe to run again, and from a checkout you can just run `scripts/setup.sh`.
