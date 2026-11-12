# Inline code review for AI agent workflows (https://crit.md). Not in
# nixpkgs; built from crit's own flake (see flake.nix inputs).
# Claude Code's /crit skills come from `crit install`, not the plugin: the
# plugin's ExitPlanMode hook would open crit alongside revdiff-planning.
{ inputs, lib, pkgs, ... }:
let
  crit = inputs.crit.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ crit ];

  home.activation.critSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run sh -c 'cd "$HOME" && ${crit}/bin/crit install --force claude-code >/dev/null'
  '';
}
