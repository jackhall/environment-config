#!/usr/bin/bash

# path to this script's parent directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/common.sh

if [ ln --symbolic --interactive $DIR/nvim ~/.config ]; then
    echo "created link to neovim config in ~/.config/"
else
    echo "failed to configure neovim"
fi

if [ curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ]; then
    echo "installed neovim plugin manager to ~/.local/share/"
else
    echo "could not install neovim's plugin manager"
fi

found nvim
