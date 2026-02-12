#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

# Script to build git-credential-1password and deploy via stow

TOOLS_ROOT="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$TOOLS_ROOT/.." && pwd)"
GIT_CRED_ROOT="$TOOLS_ROOT/git-credential-1password"

echo "==> Building git-credential-1password..."
cd "$GIT_CRED_ROOT"

# Build the binary
go build -o bin/git-credential-1password

echo "✓ Build complete: $GIT_CRED_ROOT/bin/git-credential-1password"

echo "==> Updating git-credential-1password via stow..."
cd "$TOOLS_ROOT"
stow -v git-credential-1password -t "$REPO_ROOT"

echo "✓ Deployment complete! Binary symlinked to $REPO_ROOT/bin/git-credential-1password"
