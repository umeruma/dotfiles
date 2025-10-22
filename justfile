# dotfiles justfile
# Expected installation path: ~/Codes/dotfiles

# Variables
dotpath := justfile_directory()
uname_s := `uname -s`
expected_path := env_var("HOME") + "/Codes/dotfiles"

# Default recipe
[private]
default: help

# Self-documented help
help:
    @just --list --unsorted

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
    @echo 'Clean dot files in your home directory...'
    stow -D -v -d {{dotpath}} -t ~ home

# Ensure subdirectories exist before deploying (reads from .deploy_subdir)
[private]
prepare-subdirs:
    #!/usr/bin/env bash
    set -euo pipefail
    echo '==> Ensure required subdirectories exist (from .deploy_subdir)'
    if [[ -f .deploy_subdir ]]; then
        while IFS= read -r path; do
            # Skip blank lines and comments (leading/trailing whitespace allowed)
            [[ "$path" =~ ^[[:space:]]*$ ]] && continue
            [[ "$path" =~ ^[[:space:]]*# ]] && continue
            # Trim leading/trailing whitespace
            path="${path#"${path%%[![:space:]]*}"}"
            path="${path%"${path##*[![:space:]]}"}"
            mkdir -p "$HOME/$path"
            echo "  mkdir -p $HOME/$path"
        done < .deploy_subdir
    else
        echo '  (skip) .deploy_subdir not found'
    fi

# Create symlink to home directory
deploy: clean prepare-subdirs
    @echo '==> Start to deploy dotfiles to home directory.'
    stow -v -d {{dotpath}} -t ~ home

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
