#!/bin/zsh

install_packages(){
  brew install fzf
  brew install tree
  brew install font-hack-nerd-font
  brew install ripgrep
  brew install neovim
  brew install --cask nikitabobko/tap/aerospace
}
 

echo "Installing packages..."
install_packages > /dev/null

echo "Making scripts executable..."
chmod +x $HOME/.config/scripts/*

echo "Configuring auto-sourcing..."
if [ -z "$PODDAMAT_CONFIG" ]; then
  echo "source $HOME/.config/zshrc" >> $HOME/.zshrc
else:
  echo "Auto-sourcing is already configured."
fi

echo "Reloading..."
source $HOME/.zshrc

clear

echo "HERE WE GO! LETSGOSKI 🍻"
