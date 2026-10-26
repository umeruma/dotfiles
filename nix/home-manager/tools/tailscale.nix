# App Store Tailscale; its CLI lives inside the app bundle.
{ ... }:
{
  my.masApps."Tailscale" = 1475387142;

  programs.zsh.shellAliases.tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
}
