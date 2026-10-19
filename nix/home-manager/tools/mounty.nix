# Mounty: mounts NTFS drives read-write, through ntfs-3g-mac on macFUSE.
{ ... }:
{
  my.casks = [
    "macfuse" # installs a file system extension
    "mounty"
  ];
  my.brews = [ "gromgit/fuse/ntfs-3g-mac" ];
}
