# Cask: it installs a virtual HID driver. config: home/.config/karabiner
# (via the ~/.config link)
{ ... }:
{
  my.casks = [ "karabiner-elements" ];

  my.configIgnore = [ "karabiner/automatic_backups" ];
}
