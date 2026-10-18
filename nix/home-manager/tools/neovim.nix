# LazyVim (config: ~/.config/nvim, linked by mise.macos.toml [dotfiles]).
# ripgrep / fd / tree-sitter are LazyVim requirements.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    tree-sitter
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # args pass through; n defaults to . (omarchy alias)
  programs.zsh.initContent = ''
    n() { nvim "''${@:-.}"; }
  '';
}
