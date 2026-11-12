# Terminal file manager (https://yazi-rs.github.io).
# Config and cendre theme: home/.config/yazi.
{ pkgs, ... }:
{
  home.packages = [ pkgs.yazi ];
}
