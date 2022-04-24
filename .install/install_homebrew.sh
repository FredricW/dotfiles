#!/usr/bin/env bash

install_homebrew() {
    which -s brew
    if [[ $? != 0 ]] ; then
        echo "did not find homebrew, installing now..."
        # Install Homebrew
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "updating homebrew..."
        brew update
    fi
}

