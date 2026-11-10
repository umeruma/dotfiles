# GUI apps with no settings or shell config of their own here.
# nixpkgs apps are pinned by flake.lock and land in /Applications/Nix Apps;
# casks are apps nixpkgs lacks or that install drivers / system extensions.
{ lib, pkgs, ... }:
let
  dev = {
    apps = [ pkgs.utm ];
    casks = [
      "homebrew-app" # BrewUI
      "kaleidoscope"
      "local"
      "orbstack"
      "orca"
      "smoothcsv"
      "transmit"
      "xcodes-app" # nixpkgs has only the xcodes CLI
      "yaak"
    ];
  };

  design = {
    casks = [
      "blender"
      "clop"
      "drawio"
      "figma"
      "gyazo"
      "handbrake-app" # nixpkgs handbrake is broken on darwin
    ];
  };

  audio = {
    casks = [
      "fission"
      "loopback" # installs an audio driver
      "soundsource" # installs an audio driver
    ];
  };

  display = {
    casks = [
      "deskpad"
      "saffsanity/sill/sill"
    ];
  };

  network = {
    casks = [
      "localsend"
      "nextdns-app" # nixpkgs nextdns is the CLI daemon, not the app
      "obscura-vpn"
    ];
  };

  productivity = {
    apps = with pkgs; [
      discord
      meetingbar
    ];
    casks = [
      "netnewswire"
      "notion" # nixpkgs notion is a window manager
      # Self-updates and migrates its data forward; nixpkgs lags behind, and
      # an older build cannot open the migrated data.
      "raycast"
    ];
  };

  utility = {
    apps = [ pkgs.openusage ];
    casks = [
      # nixpkgs builds it ad-hoc signed, so the Screen Recording grant never sticks
      "alt-tab"
      "cleanmymac"
      # "dockdoor-pro" # Dock replacement with widgets, profiles and window previews
    ];
  };

  categories = [
    dev
    design
    audio
    display
    network
    productivity
    utility
  ];
in
{
  my.apps = lib.concatMap (c: c.apps or [ ]) categories;
  my.casks = lib.concatMap (c: c.casks or [ ]) categories;
  my.configIgnore = [ "raycast" ];
}
