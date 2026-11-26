# LazyVim (config: ~/.config/nvim, via the ~/.config link).
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

  # args pass through; n defaults to . (omarchy alias). With one path,
  # osc7577_exec (rex.nix) reports it made absolute, which the nvim resume rule
  # in rex/init.lua needs, so Rex can bring it back after a restart.
  programs.zsh.initContent = ''
    n() {
      if (( $# <= 1 )) && [[ $1 != [-+]* ]]; then
        osc7577_exec nvim "''${''${1:-.}:A}"
      else
        nvim "$@"
      fi
    }
  '';
}
