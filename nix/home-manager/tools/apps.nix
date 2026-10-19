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
    "airparrot"
    "blender"
    "cleanmymac"
    "clop"
    "deskpad"
    "devonthink"
    "dockdoor-pro" # Dock replacement with widgets, profiles and window previews
    "drawio"
    "figma"
    "fission"
    "gyazo"
    "handbrake-app" # nixpkgs handbrake is broken on darwin
    "local"
    "loopback" # installs an audio driver
    "macfuse" # installs a file system extension (ntfs-3g-mac, Mounty)
    "netnewswire"
    "nextdns-app" # nixpkgs nextdns is the CLI daemon, not the app
    "obscura-vpn"
    "orbstack"
    # Self-updates and migrates its data forward; nixpkgs lags behind, and
    # an older build cannot open the migrated data.
    "raycast"
    "notion" # nixpkgs notion is a window manager
    "smoothcsv"
    "transmit"
    "xcodes-app" # nixpkgs has only the xcodes CLI
    "yaak"
  ];
}
