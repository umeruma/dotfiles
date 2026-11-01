# https://opencode.ai. ~/.config/opencode is runtime state (plugins, node_modules), so it is ignored.
{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  my.configIgnore = [ "opencode" ];
}
