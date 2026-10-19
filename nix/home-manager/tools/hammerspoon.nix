# Not in nixpkgs. Per-file links so runtime Spoons/ stays local.
{ config, ... }:
let
  link = name: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/home/.hammerspoon/${name}";
  };
in
{
  my.casks = [ "hammerspoon" ];
  home.file.".hammerspoon/init.lua" = link "init.lua";
  home.file.".hammerspoon/hide_menubar_for_meeting.lua" = link "hide_menubar_for_meeting.lua";
}
