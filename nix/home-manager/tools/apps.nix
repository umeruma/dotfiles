# GUI apps with no settings or shell config of their own here.
# nixpkgs apps are pinned by flake.lock and land in ~/Applications/Home Manager Apps;
# casks are apps nixpkgs lacks or that install drivers / system extensions.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    discord
    meetingbar
    openusage
    slack
    utm
    vscode
    zed-editor
  ];

  my.casks = [
    "cleanmymac"
    "clop"
    "deskpad"
    "dockdoor-pro" # Dock replacement with widgets, profiles and window previews
    "figma"
    "gyazo"
    "handbrake-app" # nixpkgs handbrake is broken on darwin
    "loopback" # installs an audio driver
    "netnewswire"
    "nextdns-app" # nixpkgs nextdns is the CLI daemon, not the app
    # Self-updates and migrates its data forward; nixpkgs lags behind, and
    # an older build cannot open the migrated data.
    "raycast"
    "notion" # nixpkgs notion is a window manager
    "transmit"
    "xcodes-app" # nixpkgs has only the xcodes CLI
  ];
}
