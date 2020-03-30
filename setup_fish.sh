#!/usr/bin/bash

# path to this script's parent directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/common.sh
require conda
require fish

if [ chsh -s `which fish` ]; then
    echo "changed shell to fish (must log out and in again to take effect)"
else
    echo "could not set fish as the default shell"
fi

if [ ln --symbolic --force $DIR/fish ~/.config ]; then
    echo "created link to fish config in ~/.config/"
else
    echo "could not configure fish"
fi

if [ ln --symbolic --no-target-directory $DIR/inputrc ~/.inputrc ]; then
    echo "created link to inputrc in home folder"
else
    echo "could not set vi-mode in shell"
fi

