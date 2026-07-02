#Requires -Version 5.1
# Create (or refresh) a Startup shortcut so kanata launches on login.
# Prerequisites:
#   - kanata installed:  mise run install-apps   (jtroo.kanata_gui)
#   - config deployed:   mise run deploy         (home-win/Documents/kanata/kanata.kbd)
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

# winget installs the portable zip and registers this exe as a command alias
# (a symlink under WinGet\Links), which stays stable across version upgrades.
$exeName = 'kanata_windows_gui_winIOv2_x64.exe'
$exePath = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\$exeName"

if (-not (Test-Path $exePath)) {
  throw @"
kanata was not found at:
  $exePath
Install it first:  mise run install-apps   (or: winget install jtroo.kanata_gui)
"@
}

$cfg = Join-Path $HOME 'Documents\kanata\kanata.kbd'
if (-not (Test-Path $cfg)) {
  throw "kanata config not found: $cfg  (run: mise run deploy)"
}

$startup = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startup 'Kanata.lnk'

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exePath
$shortcut.Arguments = "--cfg `"$cfg`""
$shortcut.WorkingDirectory = Split-Path $cfg
$shortcut.WindowStyle = 7  # minimized (GUI variant lives in the system tray)
$shortcut.Description = 'Kanata keyboard remapper'
$shortcut.Save()

Write-Host "==> Created startup shortcut: $shortcutPath"
Write-Host "    Target: $exePath --cfg $cfg"
Write-Host ''
Write-Host 'Start it now without logging out:'
Write-Host "    Start-Process '$shortcutPath'"
