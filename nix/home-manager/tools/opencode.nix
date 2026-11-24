# https://opencode.ai. ~/.config/opencode is runtime state (plugins, node_modules), so it is ignored.
{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];
  programs.zsh.shellAliases.o = "opencode";

  my.configIgnore = [ "opencode" ];
}
