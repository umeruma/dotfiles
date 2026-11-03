# Config: home/.config/ghostty (via the ~/.config link)
{ pkgs, ... }:
{
  my.apps = [ pkgs.ghostty-bin ];
}
