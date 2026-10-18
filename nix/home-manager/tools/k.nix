# https://github.com/supercrabtree/k (directory listings with git status)
{ inputs, ... }:
{
  programs.zsh.initContent = ''
    source ${inputs.k}/k.sh
  '';
}
