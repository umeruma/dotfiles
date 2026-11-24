# CLI tools with no settings of their own
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo
    cloudflared
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

  # rclone: credentials; micro: runtime state beside its tracked config
  my.configIgnore = [ "lftp" "rclone" "micro/backups" "micro/buffers" ];
}
