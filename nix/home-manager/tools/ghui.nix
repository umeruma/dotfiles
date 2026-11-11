# GitHub TUI (https://github.com/kitlangton/ghui). Not in nixpkgs and its
# flake has only a devShell, so this installs the prebuilt release binary.
# Bump version and hash together to update.
{ pkgs, ... }:
let
  version = "0.9.1";
in
{
  home.packages = [
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "ghui";
      inherit version;
      src = pkgs.fetchurl {
        url = "https://github.com/kitlangton/ghui/releases/download/v${version}/ghui-darwin-arm64.tar.gz";
        hash = "sha256-jS1EJLQjgGnO7EXGEN+fCfQLvwHkDDCSV6quVnlUJNM=";
      };
      sourceRoot = ".";
      dontStrip = true;
      nativeBuildInputs = [
        pkgs.darwin.sigtool
        pkgs.cctools
      ];
      # The release binary ships with an invalid signature (as of 0.9.1) and
      # macOS SIGKILLs it (exit 137), so re-sign ad hoc. Drop the re-sign
      # once https://github.com/kitlangton/ghui/issues/69 is fixed.
      installPhase = ''
        install -Dm755 ghui $out/bin/ghui
        codesign -f -s - $out/bin/ghui
      '';
    })
  ];
}
