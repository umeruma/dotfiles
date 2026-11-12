# System monitor (https://github.com/aristocratos/btop).
# Config and cendre theme: home/.config/btop.
{ pkgs, ... }:
{
  home.packages = [ pkgs.btop ];
}
