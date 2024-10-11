#!/bin/sh

if [ ! -d ~/.tmux/plugins/tpm ]
then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tp
else
    echo "TPM is installed."
fi

if [ ! -d ~/.config/tmux/plugins/catppuccin/tmux ]
then
    mkdir -p ~/.config/tmux/plugins/catppuccin
    git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
else
    echo "Catpuccin is installed."
fi



