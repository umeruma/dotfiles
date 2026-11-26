# https://opencode.ai. ~/.config/opencode is runtime state (plugins, node_modules),
# so it is ignored except tui.json and the TUI plugin it loads, which lets Rex
# bring the shown session back after a restart.
{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];
  programs.zsh.shellAliases.o = "opencode";

  my.configIgnore = [
    "opencode/*"
    "!opencode/tui.json"
    "!opencode/tui-plugins"
  ];
}
