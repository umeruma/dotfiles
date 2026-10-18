# CLI tools with no settings of their own
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo
    ffmpeg
    gifsicle
    imagemagick
    lftp
    mas
    micro # config: ~/.config/micro, linked by mise.unix.toml [dotfiles]
    mkcert
    rclone
    rustc
    shellcheck
    websocat
  ];
}
