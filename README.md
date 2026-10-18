# dotfiles

My own macOS and Linux configuration. :D

## Setup

Clone anywhere and run the setup script:
```bash
git clone https://www.github.com/poddamatt98/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh
```
It installs the tools with Homebrew (installing Homebrew itself if needed) and links each config folder
into `~/.config`. If one already exists there, it asks before moving it to `.bak`.
