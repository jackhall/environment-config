#!/usr/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

chsh -s `which fish`
echo "changed shell to fish (must log out and in again to take effect)"

ln --symbolic --force $DIR/fish ~/.config
echo "created link to fish config in ~/.config/"

ln --symbolic --interactive $DIR/nvim ~/.config
echo "created link to neovim config in ~/.config/"

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "installed neovim plugin manager to ~/.local/share/"

ln --symbolic --no-target-directory $DIR/inputrc ~/.inputrc
echo "created link to inputrc in home folder"
