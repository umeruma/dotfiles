# dotfiles justfile

# Default recipe
default: help

# Self-documented help
help:
    @just --list

# Variables
dotpath := justfile_directory()
uname_s := `uname -s`

# Show dot files to deploy in this repo
list:
    @find . -name ".*" -not -name ".gitignore" -not -name ".DS_Store" -type f | sort

# Create symlink to home directory
deploy:
    @echo '==> Start to deploy dotfiles to home directory.'
    @echo ''
    #!/usr/bin/env bash
    set -euo pipefail
    for file in $(find . -name ".*" -not -name ".gitignore" -not -name ".DS_Store" -maxdepth 1 -type f); do \
        ln -sfnv "{{dotpath}}/$file" "$HOME/$file"; \
    done
    mkdir -p "$HOME/.config"
    for config in config/*; do \
        if [ -d "$config" ]; then \
            ln -sfnv "{{dotpath}}/$config" "$HOME/.config/$(basename $config)"; \
        fi \
    done

# Fetch changes for this repo
update:
    git pull origin main
    git submodule init
    git submodule update
    git submodule foreach git pull origin main

# Install apps after clean, deploy
install: clean deploy
    bash ./init/setup.sh
    #!/usr/bin/env bash
    if [ "{{uname_s}}" = "Linux" ]; then \
        brew bundle --file=./linux/Brewfile; \
        sudo apt-get install hugo; \
    elif [ "{{uname_s}}" = "Darwin" ]; then \
        brew bundle --file=./macos/Brewfile; \
    fi

# Remove the dot files which deployed
clean:
    @echo 'Remove dot files in your home directory...'
    #!/usr/bin/env bash
    set -euo pipefail
    for file in $(find . -name ".*" -not -name ".gitignore" -not -name ".DS_Store" -maxdepth 1 -type f); do \
        rm -vrf "$HOME/$file" || true; \
    done

# Update macOS's defaults setting
defaults:
    #!/usr/bin/env bash
    if [ "{{uname_s}}" = "Darwin" ]; then \
        bash ./macos/defaults.sh; \
    fi

# Install Terminal theme
theme:
    #!/usr/bin/env bash
    if [ "{{uname_s}}" = "Darwin" ]; then \
        open ./macos/BirdsOfParadise.terminal; \
    fi