#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

[[ $(type starship) ]] && echo "starship already installed."  || { curl -sS https://starship.rs/install.sh | sh; }

ln -s $SCRIPTPATH/.bashrc ~/.bashrc
ln -s $SCRIPTPATH/.zshrc ~/.zshrc
ln -s $SCRIPTPATH/nvim ~/.config
ln -s $SCRIPTPATH/tmux ~/.config

