# Every .nix file in ./tools holds one lifecycle: what is added and removed
# together (a GUI app, its CLI, its zsh settings). Deleting the file removes
# all of it.
{ config, lib, ... }:
{
  imports = [ ./dotfiles.nix ] ++ map (f: ./tools + "/${f}") (
    builtins.filter (lib.hasSuffix ".nix") (builtins.attrNames (builtins.readDir ./tools))
  );

  # Gathered into homebrew.casks / homebrew.masApps by nix/homebrew.nix
  options.my = {
    # Where this repo is checked out; links that point at the repo (not the
    # Nix store) use it, so edits apply without a switch.
    repo = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Codes/dotfiles";
    };
    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    masApps = lib.mkOption {
      type = lib.types.attrsOf lib.types.ints.positive;
      default = { };
    };
  };

  config.home.stateVersion = "26.05";
}
