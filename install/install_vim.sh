#!/usr/bin/env bash

install_neovim() {
    echo "\nInstalling Neovim and dependencies:"

    brew_install "ripgrep"
    brew_install "neovim"

    BACKUP_DIR="~/.vim/backup_files/"

    if [[ ! -d $BACKUP_DIR ]]; then
        echo "Creating backup directory"
        mkdir -p $BACKUP_DIR
    fi

    # install vim-plug for Neovim
    if [[ ! -e ~/.local/share/nvim/site/autoload/plug.vim ]]; then
        echo "Vim Plug not found. Installing now..."
        #sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        #    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    fi

    nvim --headless +PlugInstall +qall
}

