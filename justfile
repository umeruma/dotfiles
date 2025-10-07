# dotfiles justfile
# Expected installation path: ~/Codes/dotfiles

# Variables
dotpath := justfile_directory()
uname_s := `uname -s`
expected_path := env_var("HOME") + "/Codes/dotfiles"

# Default recipe
default: help

# Self-documented help
help:
    @just --list

# Fetch changes for this repo
update:
    git pull origin main
    git submodule init
    git submodule update
    git submodule foreach git pull origin main

# Verify installation path
# check-path:
#     @echo "Current path: {{dotpath}}"
#     @echo "Expected path: {{expected_path}}"
#     #!/usr/bin/env bash
#     if [ "{{dotpath}}" != "{{expected_path}}" ]; then \
#         echo "⚠️  Warning: Not running from expected path"; \
#         echo "   Current:  {{dotpath}}"; \
#         echo "   Expected: {{expected_path}}"; \
#         echo "   Consider moving this repository to ~/Codes/dotfiles"; \
#     else \
#         echo "✅ Running from correct path"; \
#     fi

# Show dot files to deploy in this repo
list:
    @find home -name ".*" -not -name ".DS_Store" -type f | sort

# Remove the dot files which deployed
clean:
    @echo 'Remove dot files in your home directory...'
    #!/usr/bin/env bash
    set -euo pipefail
    # Remove dotfiles deployed from home/ directory
    for file in $(find home -name ".*" -not -name ".DS_Store" -maxdepth 1 -type f); do \
        target_file="$HOME/$(basename $file)"; \
        rm -vrf "$target_file" || true; \
    done
    # Remove .config directory symlinks
    if [ -d "home/.config" ]; then \
        for config in home/.config/*; do \
            if [ -d "$config" ]; then \
                rm -vrf "$HOME/.config/$(basename $config)" || true; \
            fi \
        done \
    fi

# Create symlink to home directory
deploy: clean
    @echo '==> Start to deploy dotfiles to home directory.'
    @echo ''
    #!/usr/bin/env bash
    set -euo pipefail
    # Deploy dotfiles from home/ directory
    for file in $(find home -name ".*" -not -name ".DS_Store" -maxdepth 1 -type f); do \
        target_file="$HOME/$(basename $file)"; \
        ln -sfnv "{{dotpath}}/$file" "$target_file"; \
    done
    # Deploy .config directory contents
    if [ -d "home/.config" ]; then \
        mkdir -p "$HOME/.config"; \
        for config in home/.config/*; do \
            if [ -d "$config" ]; then \
                ln -sfnv "{{dotpath}}/$config" "$HOME/.config/$(basename $config)"; \
            fi \
        done \
    fi

# Install apps
install-apps:
    #!/usr/bin/env bash
    if [ "{{uname_s}}" = "Linux" ]; then \
        brew bundle --file=./linux/Brewfile; \
        sudo apt-get install hugo; \
    elif [ "{{uname_s}}" = "Darwin" ]; then \
        brew bundle --file=./macos/Brewfile; \
    fi

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