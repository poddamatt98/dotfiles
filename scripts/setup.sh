#!/usr/bin/env bash
# Sets up these dotfiles on macOS or Linux (apt-based): installs the tools with Homebrew,
# clones the repo if this isn't running from a checkout, links each config folder into
# ~/.config, and makes ~/.zshrc source zshrc.
# Safe to run again: installed tools, the checkout and existing links are reused.
# Runs standalone too:
#   bash <(curl -fsSL https://raw.githubusercontent.com/poddamatt98/dotfiles/main/scripts/setup.sh)
set -euo pipefail

REPO_URL="https://github.com/poddamatt98/dotfiles.git"
CONFIG="$HOME/.config"
OS="$(uname -s)"
DOTFILES="" # set by get_dotfiles

# Linked into ~/.config on every OS, and on macOS only.
SHARED_CONFIGS=(nvim tmux ghostty zshrc)
MACOS_CONFIGS=(aerospace)

# Installed with Homebrew on every OS. Casks are macOS-only.
BREW_FORMULAE=(fzf tree ripgrep tmux neovim tree-sitter-cli pre-commit)
MACOS_CASKS=(font-hack-nerd-font nikitabobko/tap/aerospace)

step() { printf '\n==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }

# --- Packages -----------------------------------------------------------------

# Prints the path of brew, or nothing. Checks the default install locations too, since
# a fresh install isn't on PATH yet.
find_brew() {
    command -v brew && return
    local brew
    for brew in /opt/homebrew/bin/brew /usr/local/bin/brew \
        /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
        if [ -x "$brew" ]; then
            echo "$brew"
            return
        fi
    done
}

# Installs Homebrew if missing and puts it on PATH for the rest of this script.
ensure_brew() {
    local brew
    brew="$(find_brew)"
    if [ -z "$brew" ]; then
        info "installing Homebrew"
        NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew="$(find_brew)"
        if [ -z "$brew" ]; then
            echo "Homebrew was installed but brew can't be found." >&2
            exit 1
        fi
    fi
    eval "$("$brew" shellenv)"
}

# zsh comes from apt rather than Homebrew: chsh only accepts shells in /etc/shells.
install_linux_prerequisites() {
    if ! command -v apt-get > /dev/null; then
        echo "Only apt-based distributions (Debian, Ubuntu, Pop!_OS) are supported." >&2
        exit 1
    fi
    sudo apt-get update -q
    sudo apt-get install -y -q build-essential procps curl file git zsh unzip fontconfig
}

# The Nerd Font is a cask, and casks are macOS-only.
install_nerd_font_linux() {
    # Not grep -q: it stops reading early, and pipefail then fails on fc-list's SIGPIPE.
    if fc-list : family | grep -i "Hack Nerd Font" > /dev/null; then
        info "Hack Nerd Font already installed"
        return
    fi
    info "installing Hack Nerd Font into ~/.local/share/fonts"
    local dir="$HOME/.local/share/fonts/HackNerdFont" zip
    zip="$(mktemp)"
    curl -fsSL -o "$zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
    mkdir -p "$dir"
    unzip -qo "$zip" -d "$dir"
    rm -f "$zip"
    fc-cache -f > /dev/null
}

# --- Checkout -----------------------------------------------------------------

is_checkout() { [ -d "$1/.git" ] && [ -f "$1/scripts/setup.sh" ]; }

# Sets DOTFILES to the first checkout found, so it never clones a second copy:
#   1. the checkout this script is running from;
#   2. ~/.config itself, for installs that cloned the repo as ~/.config;
#   3. the checkout an existing ~/.config/<name> link points into;
#   4. $DOTFILES_DIR (default ~/dotfiles), cloned there if it doesn't exist.
get_dotfiles() {
    local here name linked
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2> /dev/null && pwd)" || here=""
    if [ -n "$here" ] && is_checkout "$here"; then
        DOTFILES=$here
        info "using this checkout: $DOTFILES"
        return
    fi
    if is_checkout "$CONFIG"; then
        DOTFILES=$CONFIG
        info "using the checkout at $DOTFILES"
        return
    fi
    for name in "${SHARED_CONFIGS[@]}"; do
        linked="$(readlink "$CONFIG/$name" 2> /dev/null)" || continue
        if is_checkout "$(dirname "$linked")"; then
            DOTFILES="$(dirname "$linked")"
            info "using the checkout ~/.config/$name links into: $DOTFILES"
            return
        fi
    done
    DOTFILES="${DOTFILES_DIR:-$HOME/dotfiles}"
    if is_checkout "$DOTFILES"; then
        info "using the checkout at $DOTFILES"
        return
    fi
    if [ -e "$DOTFILES" ]; then
        echo "$DOTFILES exists but isn't a checkout of the dotfiles." >&2
        echo "Move it away, or pick another folder with DOTFILES_DIR=<path>." >&2
        exit 1
    fi
    info "cloning $REPO_URL into $DOTFILES"
    git clone -q "$REPO_URL" "$DOTFILES"
}

# Installs the git hook that formats files on commit (see .pre-commit-config.yaml).
install_git_hooks() {
    if [ -f "$DOTFILES/.git/hooks/pre-commit" ]; then
        info "pre-commit hook already installed"
        return
    fi
    (cd "$DOTFILES" && pre-commit install > /dev/null)
    info "installed the pre-commit hook in $DOTFILES"
}

# --- Links --------------------------------------------------------------------

# Asks a yes/no question, defaulting to yes (also when there's no terminal to ask on).
# Reads from the terminal when stdin isn't one, e.g. when this script is piped into bash.
confirm() {
    local answer=""
    printf '    %s [Y/n] ' "$1"
    if [ -t 0 ]; then
        read -r answer || answer=""
    else
        { read -r answer < /dev/tty; } 2> /dev/null || echo
    fi
    case "$answer" in
        [nN]*) return 1 ;;
        *) return 0 ;;
    esac
}

# Links ~/.config/<name> to this checkout. If something else is already there, asks
# before moving it to <name>.bak (or <name>.bak.<timestamp> if that's taken too).
link_config() {
    local name=$1 source="$DOTFILES/$1" target="$CONFIG/$1"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        info "$name already linked"
        return
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="$target.bak"
        if [ -e "$backup" ] || [ -L "$backup" ]; then
            backup="$target.bak.$(date +%Y%m%d-%H%M%S)"
        fi
        info "$target already exists."
        if ! confirm "Move it to $backup and link it to this checkout?"; then
            info "skipped $name"
            return
        fi
        mv "$target" "$backup"
    fi
    ln -s "$source" "$target"
    info "linked ~/.config/$name -> $source"
}

link_configs() {
    # The old setup cloned this repo as ~/.config itself: everything is already in place.
    if [ "$(cd "$DOTFILES" && pwd -P)" = "$(cd "$CONFIG" 2> /dev/null && pwd -P)" ]; then
        info "this checkout is ~/.config, nothing to link"
        return
    fi
    mkdir -p "$CONFIG"
    local name
    for name in "${SHARED_CONFIGS[@]}"; do link_config "$name"; done
    if [ "$OS" = Darwin ]; then
        for name in "${MACOS_CONFIGS[@]}"; do link_config "$name"; done
    fi
}

# --- zsh ----------------------------------------------------------------------

configure_zshrc() {
    # shellcheck disable=SC2016 # $HOME is meant to stay literal in ~/.zshrc
    local line='source "$HOME/.config/zshrc"'
    if [ -f "$HOME/.zshrc" ] && grep -qF '.config/zshrc' "$HOME/.zshrc"; then
        info "$HOME/.zshrc already sources zshrc"
    else
        echo "$line" >> "$HOME/.zshrc"
        info "added to ~/.zshrc: $line"
    fi
    if [ "$(basename "${SHELL:-}")" != zsh ]; then
        info "your login shell is ${SHELL:-unknown}; switch to zsh with: chsh -s \"\$(command -v zsh)\""
    fi
}

# --- Main ---------------------------------------------------------------------

case "$OS" in
    Darwin | Linux) ;;
    *)
        echo "Unsupported OS: $OS" >&2
        exit 1
        ;;
esac

if [ "$OS" = Linux ]; then
    step "Installing Homebrew prerequisites (apt)"
    install_linux_prerequisites
fi

step "Installing packages (Homebrew)"
ensure_brew
brew install "${BREW_FORMULAE[@]}"
if [ "$OS" = Darwin ]; then
    brew install --cask "${MACOS_CASKS[@]}"
else
    install_nerd_font_linux
fi

# After the packages: git comes with them (apt on Linux, Xcode tools via Homebrew on macOS).
step "Getting the dotfiles"
get_dotfiles
install_git_hooks

step "Linking configs into ~/.config"
link_configs

step "Configuring zsh"
configure_zshrc

printf '\nDone. Open a new terminal to load the config. HERE WE GO! LETSGOSKI 🍻\n'
