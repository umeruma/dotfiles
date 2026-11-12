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
    ".claude/plugins/data/revdiff-planning-revdiff/scripts/launch-plan-review.sh" =
      launcher "launch-plan-review.sh";
  };

  my.claudePlugins = {
    "revdiff@revdiff" = "umputun/revdiff";
    "revdiff-planning@revdiff" = "umputun/revdiff";
  };
}
