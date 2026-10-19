# Mac App Store apps (IDs: `mas list`). Versions and updates are left to
# the App Store.
{ ... }:
{
  my.masApps = {
    "Apple Configurator" = 1037126344;
    "CotEditor" = 1024640650;
    "Craft" = 1487937127;
    "CrystalFetch" = 6454431289;
    "Day One" = 1055511498;
    "Developer" = 640199958;
    # Custom upload script is copied by dotfiles.nix
    "Dropover" = 1355679052;
    "Folder Quick Look" = 6753110395;
    "iA Writer" = 775737590;
    "iMovie" = 408981434;
    "Keynote" = 409183694;
    "Logic Pro" = 1615087040;
    "MenubarX" = 1575588022;
    "Numbers" = 409203825;
    "OpenIn" = 1643649331;
    "Pages" = 409201541;
    "pdmanager" = 6751735648;
    # nixpkgs tailscale is the CLI daemon; this is the network extension app
    "Tailscale" = 1475387142;
    "WorldWideWeb" = 1621370168;
    "Zavala" = 1546457750;
  };
}
