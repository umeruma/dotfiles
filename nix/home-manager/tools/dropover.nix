# Dropover (App Store) with custom upload scripts. Dropover greys out
# symlinks in its file picker, so the scripts are copied, not linked.
{ config, lib, ... }:
{
  my.masApps."Dropover" = 1355679052;

  home.activation.dropoverScript = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run /bin/mkdir -p ~/"Library/Application Scripts/me.damir.dropover-mac"
    for s in upload-r2.sh upload-drive.sh; do
      run /usr/bin/install -m 755 \
        "${config.my.repo}/home/Library/Application Scripts/me.damir.dropover-mac/$s" \
        ~/"Library/Application Scripts/me.damir.dropover-mac/$s"
    done
  '';
}
