{ pkgs, ... }:
{
  my.apps = [ pkgs.keka ];

  programs.zsh.shellAliases.keka = "${pkgs.keka}/Applications/Keka.app/Contents/MacOS/Keka --cli";
}
