{ pkgs, ... }:
{
  home.packages = [ pkgs.fzy ];

  programs.zsh.initContent = ''
    fzyselect() { fzy < <(find . -maxdepth 1); }
    alias -g F='$(fzyselect)'
  '';
}
