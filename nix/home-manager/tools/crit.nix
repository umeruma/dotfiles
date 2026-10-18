# Inline code review for AI agent workflows (https://crit.md). Not in
# nixpkgs; built from crit's own flake (see flake.nix inputs).
{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.crit.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
