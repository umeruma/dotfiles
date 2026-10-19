# Homebrew only installs what nixpkgs cannot: apps that are missing there,
# install drivers / system extensions, or must live in /Applications.
# Each tool file under nix/home-manager/tools declares its own casks and
# formulae and App Store apps (my.casks / my.brews / my.masApps); they are gathered here.
{ config, user, ... }:
let
  hm = config.home-manager.users.${user};
in
{
  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
    # Take over the Homebrew installed with the official script, keeping
    # its installed packages
    autoMigrate = true;
    # .zshenv puts /opt/homebrew/bin after the Nix profiles; brew shellenv
    # in /etc/zshrc would move it to the front
    enableZshIntegration = false;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # ponytail: "none" until every cask/brew in macos/Brewfile is declared
      # in a tool file; then "uninstall" so removing a line removes the app.
      cleanup = "none";
    };
    casks = hm.my.casks;
    brews = hm.my.brews;
    masApps = hm.my.masApps;
  };
}
