# Agent multiplexer (https://herdr.dev). config: home/.config/herdr
# (via the ~/.config link); the layout functions are shared with Linux.
{ pkgs, ... }:
let
  # herdr-core (`hc`, https://herdr.dev/core/): the terminal runtime the
  # Herdr desktop app runs on. Not in nixpkgs; prebuilt binary from the
  # release manifest (https://releases.herdr.dev/core/latest.json).
  # Bump version + sha256 from that manifest; `hc update` can't write the store.
  herdr-core =
    let
      version = "0.1.14";
      target =
        {
          aarch64-darwin = {
            name = "macos-aarch64";
            sha256 = "ca524329d2e0630219550055dcc71f42aafd85fba356e0d543d6f51244487970";
          };
          x86_64-darwin = {
            name = "macos-x86_64";
            sha256 = "8e16ec43a17656f80e7d7f98292bf710c60c4aeff52941cca98fb24f37f35028";
          };
        }
        .${pkgs.stdenv.hostPlatform.system};
    in
    pkgs.stdenvNoCC.mkDerivation {
      pname = "herdr-core";
      inherit version;
      src = pkgs.fetchurl {
        url = "https://releases.herdr.dev/core/${version}/herdr-core-${target.name}.tar.gz";
        inherit (target) sha256;
      };
      sourceRoot = ".";
      installPhase = ''
        install -Dm755 herdr-core $out/bin/herdr-core
        ln -s herdr-core $out/bin/hc
      '';
    };
in
{
  home.packages = with pkgs; [
    herdr
    herdr-core
    jq # herdr.zsh parses herdr's JSON output
  ];

  programs.zsh.initContent = ''
    hr() { herdr "$@"; }
    # hdl / hdlm / hsl: dev layouts (editor + agent + terminal), ported from omarchy
    ${builtins.readFile ../../../home/.config/zsh/herdr.zsh}
  '';
}
