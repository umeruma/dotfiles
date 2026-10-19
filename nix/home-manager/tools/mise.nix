# mise itself is installed by `install` (mise.run) and drives bootstrap and
# project runtimes; only its shell hook lives here.
{ ... }:
{
  programs.zsh.initContent = ''
    eval "$(mise activate zsh)"
    export MISE_STATUS_MESSAGE_SHOW_ENV=true
    export MISE_STATUS_MESSAGE_SHOW_TOOLS=true

    # dottrack <path>: move ~/<path> into home/, to be linked by dotfiles.nix
    dottrack() {
      if [[ -z "$1" ]]; then
        echo "Usage: dottrack <file_or_directory>"
        return 1
      fi
      local target="$HOME/$1"
      if [[ ! -e "$target" ]]; then
        echo "Error: $target does not exist"
        return 1
      fi
      if [[ "$1" == .config/* ]]; then
        echo "~/.config already links to home/.config: drop it from home/.config/.gitignore and git add it"
        return 0
      fi
      mkdir -p "$DOTFILES_HOME/''${1:h}"
      mv "$target" "$DOTFILES_HOME/$1"
      echo "✓ Moved to home/$1. Add it to nix/home-manager/dotfiles.nix, git add, then: mise run switch"
    }
  '';
}
