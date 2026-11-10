# GUI apps with no settings or shell config of their own here.
# nixpkgs apps are pinned by flake.lock and land in /Applications/Nix Apps;
# casks are apps nixpkgs lacks or that install drivers / system extensions.
{ pkgs, ... }:
{
  my.apps = with pkgs; [
    # utility ---
    discord
    meetingbar
    openusage

    # dev ---
    utm
  ];

  my.casks = [
    # utility ---
    "alt-tab" # nixpkgs build is ad-hoc signed, so Screen Recording never sticks
    "cleanmymac"
    # "dockdoor-pro" # Dock replacement with widgets, profiles and window previews
    "netnewswire"
    "raycast" # nixpkgs lags behind and can't open self-updated data
    "saffsanity/sill/sill"

    # network ---
    "localsend"
    "nextdns-app" # nixpkgs nextdns is the CLI daemon, not the app
    "obscura-vpn"

    # audio ---
    "loopback" # installs an audio driver
    "soundsource" # installs an audio driver

    # work ---
    "deskpad"
    "gyazo"
    "notion" # nixpkgs notion is a window manager

    # design ---
    "blender"
    "figma"

    # dev ---
    "clop"
    "drawio"
    "fission"
    "handbrake-app" # nixpkgs handbrake is broken on darwin
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

  my.configIgnore = [
    "raycast" # extensions and caches Raycast writes at runtime
  ];
}
