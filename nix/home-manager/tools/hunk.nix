# Review-first terminal diff viewer, for reading agent changes beside the
# agent (https://hunk.dev). Config: home/.config/hunk/config.toml.
{ pkgs, ... }:
{
  home.packages = [ pkgs.hunk ];

  my.configIgnore = [ "hunk/state.json" ];

  # The skill ships inside the package, so it follows hunk upgrades.
  home.file.".claude/skills/hunk-review".source = "${pkgs.hunk}/skills/hunk-review";
}
