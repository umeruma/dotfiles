# Config: home/.config/ghostty (via the ~/.config link)
{ pkgs, ... }:
{
  home.packages = [ pkgs.ghostty-bin ];
}
