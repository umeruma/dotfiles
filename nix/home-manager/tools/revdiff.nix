# TUI diff/document review with inline annotations for AI agents
# (https://revdiff.com). Not in nixpkgs; built from revdiff's own flake
# (see flake.nix inputs).
{ config, inputs, pkgs, ... }:
let
  launcher = name: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.my.repo}/home/.claude/revdiff/${name}";
  };
in
{
  home.packages = [ inputs.revdiff.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  home.file = {
    ".claude/plugins/data/revdiff-revdiff/scripts/launch-revdiff.sh" = launcher "launch-revdiff.sh";
  };

  # Bundled themes revdiff writes on first run; --init-themes recreates them.
  # history/ keeps each review's annotations per repo.
  my.configIgnore = [
    "revdiff/themes/*"
    "!revdiff/themes/cendre"
    "revdiff/history"
  ];

  my.claudePlugins = {
    "revdiff@revdiff" = "umputun/revdiff";
  };
}
