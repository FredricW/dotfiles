#!/usr/bin/env bash

INPUT_YES="Y"
INPUT_NO="n"
INPUT_INFO="(${INPUT_YES}/${INPUT_NO})"
CURRENT_USER=$(whoami)
ORIGINAL_DIR=$PWD
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

echo "This script will install the following: git, homebrew, stow, node (via nvm), neovim, vim-plug, dracula, fonts. As well as my dotfiles repo."

read -p "Continue? ${INPUT_INFO}" -e SHOULD_CONTINUE

if [[ $SHOULD_CONTINUE != $INPUT_YES ]]; then
    echo "exiting"
    exit
fi

# go to home folder
cd ~

# install fonts
cd ~/Library/Fonts
if [[ ! -e "Source Code Pro for Powerline.otf" ]]; then 
    echo "Installing font: Source Code Pro for Powerline"
    curl -fsSL https://github.com/powerline/fonts/raw/master/SourceCodePro/Source%20Code%20Pro%20for%20Powerline.otf
    ls
fi
cd -; # go back to previous location


source $SCRIPTPATH/install_homebrew.sh
install_homebrew

source $SCRIPTPATH/brew_install.sh # helper function for installing packages only if they are not already installed
brew_install "git"
brew_install "stow" # symlink manager for dotfiles
brew_install "bat" # file reader with syntax highlighting
brew_install "hub" # Git/Github cli

# ohmyzsh
if [[ ! -d ~/.oh-my-zsh/ ]]; then
    echo "\nInstalling 'Oh my Zsh'"
    sudo sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sudo deluser $CURRENT_USER sudo # remove sudo access when done with this
else
    echo "\nOh my Zsh is already installed"
fi

source $SCRIPTPATH/install_node.sh
install_node

# install lsp (requires node/npm)
npm install -g typescript typescript-language-server
npm install -g vscode-langservers-extracted # html
npm install -g @angular/language-server

source $SCRIPTPATH/install_tmux.sh
install_tmux

source $SCRIPTPATH/install_vim.sh
install_neovim



# terminal monitor app
brew_install "bpytop"

echo "\nDone!"
cd $ORIGINAL_DIR
