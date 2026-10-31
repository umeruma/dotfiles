# Dropover (App Store) with a custom upload script. Dropover greys out
# symlinks in its file picker, so the script is copied, not linked.
{ config, lib, ... }:
{
  my.masApps."Dropover" = 1355679052;

  home.activation.dropoverScript = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run /bin/mkdir -p ~/"Library/Application Scripts/me.damir.dropover-mac"
    run /usr/bin/install -m 755 \
      "${config.my.repo}/home/Library/Application Scripts/me.damir.dropover-mac/upload-r2.sh" \
      ~/"Library/Application Scripts/me.damir.dropover-mac/upload-r2.sh"
  '';
}
