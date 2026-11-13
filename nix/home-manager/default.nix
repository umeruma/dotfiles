# Every .nix file in ./tools holds one lifecycle: what is added and removed
# together (a GUI app, its CLI, its zsh settings). Deleting the file removes
# all of it.
{ config, lib, ... }:
{
  imports = [ ./dotfiles.nix ] ++ map (f: ./tools + "/${f}") (
    builtins.filter (lib.hasSuffix ".nix") (builtins.attrNames (builtins.readDir ./tools))
  );

  # Gathered into homebrew.casks / brews / masApps by nix/homebrew.nix
  options.my = {
    # Where this repo is checked out; links that point at the repo (not the
    # Nix store) use it, so edits apply without a switch.
    repo = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Codes/dotfiles";
    };
    # nixpkgs GUI apps; nix-darwin copies them to /Applications/Nix Apps
    apps = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    # Formulae nixpkgs lacks; a tap formula is written in full (user/tap/name)
    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    masApps = lib.mkOption {
      type = lib.types.attrsOf lib.types.ints.positive;
      default = { };
    };
    # Lines of home/.config/.gitignore (paths under ~/.config); written by dotfiles.nix
    configIgnore = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    # Claude Code plugins as "plugin@marketplace" = "owner/repo"; installed by claude.nix
    claudePlugins = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };
    # Claude Code HTTP MCP servers (user scope) as name = url; added by claude.nix
    claudeMcpServers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };
  };

  config.home.stateVersion = "26.05";
  config.targets.darwin.copyApps.enable = false;
}
