# Playdate SDK is installed by hand into ~/Developer/PlaydateSDK
{ ... }:
{
  programs.zsh.initContent = ''
    export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"
    [[ -d "$PLAYDATE_SDK_PATH/bin" ]] && path=("$PLAYDATE_SDK_PATH/bin" $path)
  '';
}
