# Config: home/.config/zed (via the ~/.config link)
{ pkgs, ... }:
{
  my.apps = [ pkgs.zed-editor ];

  programs.zsh.shellAliases.zed = "'/Applications/Nix Apps/Zed.app/Contents/MacOS/cli'";

  my.configIgnore = [ "zed/prompts" ];
}
