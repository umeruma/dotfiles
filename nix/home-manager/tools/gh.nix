{ pkgs, ... }:
{
  home.packages = [ pkgs.gh ];

  programs.zsh.initContent = ''
    # https://cli.github.com/manual/gh_repo_gitignore_view
    gi() { gh repo gitignore "$@"; }
    # https://cli.github.com/manual/gh_repo_license_view
    gli() { gh repo license "$@"; }
  '';
}
