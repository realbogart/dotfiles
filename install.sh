#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

[[ -d ~/.oh-my-zsh ]] && echo "oh-my-zsh already installed."  || { sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; }
[[ $(type starship) ]] && echo "starship already installed."  || { curl -sS https://starship.rs/install.sh | sh; }

ln -s $SCRIPTPATH/.bashrc ~/.bashrc
ln -s $SCRIPTPATH/.zshrc ~/.zshrc
ln -s $SCRIPTPATH/nvim ~/.config
ln -s $SCRIPTPATH/tmux ~/.config

