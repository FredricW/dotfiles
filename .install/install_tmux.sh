#!/usr/bin/env bash

install_tmux() {
    brew_install "tmux"
    brew_install "tmuxinator"

    if [[ ! -d ~/.tmux/plugins/tpm/ ]]; then
        echo "\nCloning tmux plugin manager"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

