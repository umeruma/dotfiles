{ config, pkgs, ... }:
let
  link = name: { source = config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/home/.cursor/${name}"; };
in
{
  home.packages = with pkgs; [
    code-cursor
    cursor-cli
  ];

  home.file.".cursor/settings.json" = link "settings.json";
  home.file.".cursor/hooks.json" = link "hooks.json";

  programs.zsh.initContent = ''
    # Editor Window; skip Agents/Glass on launch
    alias cursor='cursor --classic'
    ca() { cursor-agent "$@"; }
  '';

  my.configIgnore = [ "cursor" ];
}
