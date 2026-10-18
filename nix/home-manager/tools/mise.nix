# mise itself is installed by `install` (mise.run) and drives bootstrap,
# [dotfiles] links and project runtimes; only its shell hook lives here.
{ ... }:
{
  programs.zsh.initContent = ''
    eval "$(mise activate zsh)"
    export MISE_STATUS_MESSAGE_SHOW_ENV=true
    export MISE_STATUS_MESSAGE_SHOW_TOOLS=true

    # dottrack <path>: move ~/<path> into home/ and link it back via [dotfiles]
    dottrack() {
      if [[ -z "$1" ]]; then
        echo "Usage: dottrack <file_or_directory>"
        return 1
      fi
    
      local target="$HOME/$1"
    
      # ホームディレクトリに存在するか確認
      if [[ ! -e "$target" ]]; then
        echo "Error: $target does not exist"
        return 1
      fi
    
      # [dotfiles] にエントリ追加 + 実体を home/ へコピー
      mise -C "$DOTFILES_HOME" dotfiles add --path "$DOTFILES_HOME/mise.dotfiles.toml" --yes --source "home/$1" "$target"
    
      # 元ファイルを symlink に置換（内容同一なので --force 不要）
      mise -C "$DOTFILES_HOME" dotfiles apply --yes
    
      echo "✓ Tracked: $1 (entry added to mise.toml [dotfiles])"
    }
  '';
}
