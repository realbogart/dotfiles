#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

ln -s $SCRIPTPATH/.bashrc ~/.bashrc
ln -s $SCRIPTPATH/.zshrc ~/.zshrc
ln -s $SCRIPTPATH/nvim ~/.config
ln -s $SCRIPTPATH/tmux ~/.config

