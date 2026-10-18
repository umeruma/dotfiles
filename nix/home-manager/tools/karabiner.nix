# Cask: it installs a virtual HID driver. karabiner.json is linked by
# mise.macos.toml [dotfiles]
{ ... }:
{
  my.casks = [ "karabiner-elements" ];
}
