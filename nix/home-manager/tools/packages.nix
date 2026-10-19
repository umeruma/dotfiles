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
    micro # config: home/.config/micro (via the ~/.config link)
    mkcert
    rclone
    rustc
    shellcheck
    websocat
  ];
}
