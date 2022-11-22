#!/bin/bash
# update defaults for macos 11.1

# thanks https://wilsonmar.github.io/dotfiles/

echo "Start update defaults setting..."

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `defaults.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

########################################
# SECTION: General                     #
########################################

# Set accent color to Green
defaults write -g AppleAccentColor -int 3
defaults write -g AppleHighlightColor -string "0.752941 0.964706 0.678431 Green"

# Set sidebar icon size to Large
defaults write -g NSTableViewDefaultSizeMode -int 3

# Desable tinting
defaults write -g AppleReduceDesktopTinting -int 1

# Always show scrollbars
defaults write -g AppleShowScrollBars -string "WhenScrolling"

########################################
# SECTION: Docs & Menu Bar             #
########################################

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock tilesize -float 75
defaults write com.apple.dock show-recents -bool false

# Remove all show-in-dock apps
defaults write com.apple.dock persistent-apps -array
# Remove all show-in-dock folders
defaults write com.apple.dock persistent-others -array

# Add default apps & folders
# see https://stackoverflow.com/a/59637792
__dock_app() {
    printf '%s%s%s%s%s' \
           '<dict><key>tile-data</key><dict><key>file-data</key><dict>' \
           '<key>_CFURLString</key><string>' \
           "$1" \
           '</string><key>_CFURLStringType</key><integer>0</integer>' \
           '</dict></dict></dict>'
}
defaults write com.apple.dock \
    persistent-apps -array "$(__dock_app /System/Applications/System\ Preferences.app)" \
        "$(__dock_app /System/Applications/Launchpad.app)" \
        "$(__dock_app /System/Applications/Mission\ Control.app)"

__dock_other() {
    printf '%s%s%s%s%s%s' \
           '<dict><key>tile-data</key><dict><key>showas</key><integer>1</integer>' \
           '<key>arrangement</key><integer>2</integer><key>displayas</key><integer>1</integer>' \
           '<key>file-data</key><dict><key>_CFURLString</key><string>' \
           "$1" \
           '</string><key>_CFURLStringType</key><integer>0</integer>' \
           '</dict></dict><key>tile-type</key><string>directory-tile</string></dict>'
}
defaults write com.apple.dock \
    persistent-others -array "$(__dock_other ~/Desktop/)" \
        "$(__dock_other ~/Downloads/)"

killall Dock

########################################
# SECTION: Mission Control             #
########################################

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

########################################
# SECTION: Spotlight                   #
########################################

# No changes now

########################################
# SECTION: Languages & Reagion         #
########################################

defaults write -g AppleLanguages -array "en-JP" "ja-JP"
defaults write -g AppleLocale -string "en_JP"
defaults write -g AppleMeasurementUnits -string "Centimeters"
defaults write -g AppleMetricUnits -bool true
defaults write -g AppleTemperatureUnit -string "Celsius"

# Set First day of week to Monday
defaults write -g AppleFirstWeekday -dict gregorian 2
# Set Time fromat to 24-Hour Time
defaults write -g AppleICUForce24HourTime -bool true

killall SystemUIServer

########################################
# SECTION: Software Update             #
########################################

# Disable auto system update
defaults write com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
defaults write com.apple.SoftwareUpdate AutomaticDownload -bool false
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool false
defaults write com.apple.SoftwareUpdate ConfigDataInstall -bool false

# Desable app store auto update
defaults write com.apple.commerce AutoUpdate -bool false

########################################
# SECTION: Sound                       #
########################################

defaults write com.apple.systemuiserver "NSStatusItem Visible Siri" -bool false
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -bool true
defaults write -g com.apple.sound.beep.flash -int 0
defaults write -g com.apple.sound.beep.sound -string "/System/Library/Sounds/Bottle.aiff"

########################################
# SECTION: Kyeboad                     #
########################################

defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2

# Disable Shortcuts > 
# Spotlight > Show Spotlight search
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"
# Screenshots > Copy picture of screen to clipboard
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 29 "<dict><key>enabled</key><false/></dict>"
# Screenshots > Copy picture of selected area to clipboard
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 "<dict><key>enabled</key><false/></dict>"

########################################
# SECTION: Trackpad                    #
########################################

defaults write -g com.apple.trackpad.forceClick -bool false
defaults write -g com.apple.trackpad.scaling -float 2

########################################
# SECTION: Mouse                       #
########################################

defaults write -g com.apple.mouse.doubleClickThreshold -float 0.5
defaults write -g com.apple.mouse.scaling -float 3

########################################
# SECTION: Finder                      #
########################################

# Enable spring-loading and set delay
defaults write -g com.apple.springing.enabled -bool true
defaults write -g com.apple.springing.delay -float 0.1

defaults write -g AppleShowAllExtensions -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# At Desktop
# Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
# Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist
# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 40" ~/Library/Preferences/com.apple.finder.plist

/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:textSize 12" ~/Library/Preferences/com.apple.finder.plist

/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy name" ~/Library/Preferences/com.apple.finder.plist

# Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true

# Expand print panel by default
defaults write -g PMPrintingExpandedStateForPrint -bool true

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

# If you want to change default finder window size,
# click close button with holding command key after resize window.
# https://apple.stackexchange.com/a/192959

killall Finder

echo "Done. Note that some of these changes require a logout/restart to take effect."
