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
    # Custom upload script is copied by mise.macos.toml [dotfiles]
    "Dropover" = 1355679052;
    "OpenIn" = 1643649331;
    # nixpkgs tailscale is the CLI daemon; this is the network extension app
    "Tailscale" = 1475387142;
    "WorldWideWeb" = 1621370168;
  };
}
