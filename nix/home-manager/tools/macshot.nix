# Keys come from HotkeyManager.swift in sw33tlie/macshot; slots are its
# HotkeySlot raw values (1-13). Modifiers are Carbon masks: cmdKey 256 +
# shiftKey 512 = 768. Key codes: kVK_ANSI_4 21, kVK_ANSI_5 23.
# ⌘⇧3 stays with macOS: macshot always opens its editor, even for full screen.
{ lib, ... }:
let
  hotkeys = {
    "" = 21; # 1 captureArea
    Record = 23; # 3 recordArea
  };
in
{
  my.casks = [ "macshot" ];

  targets.darwin.defaults."com.sw33tlie.macshot.macshot" =
    {
      showFloatingThumbnail = false;
    }
    // lib.listToAttrs (
      map (n: lib.nameValuePair "hotkeyDisabled_${toString n}" (n != 1 && n != 3)) (lib.range 1 13)
    )
    // lib.concatMapAttrs (name: code: {
      "hotkey${name}KeyCode" = code;
      "hotkey${name}Modifiers" = 768;
    }) hotkeys;

  targets.darwin.defaults."com.apple.screencapture".show-thumbnail = false;

  # A whole AppleSymbolicHotKeys dict via targets.darwin.defaults would wipe the
  # other system shortcuts, so only the screenshot entries are merged in:
  # 30/31 ⌘⇧4 (file/clipboard), 184 ⌘⇧5.
  home.activation.macshotSystemShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for id in 30 31 184; do
      run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
        -dict-add "$id" '{ enabled = 0; }'
    done
    run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
