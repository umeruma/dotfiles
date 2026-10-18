# Config (~/.config/ghostty) is linked by mise.macos.toml [dotfiles]
{ pkgs, ... }:
{
  home.packages = [ pkgs.ghostty-bin ];
}
