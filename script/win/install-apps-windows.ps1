#Requires -Version 5.1
# Windows counterpart of install-apps.zsh:
# 1) mise [bootstrap.packages] via winget
# 2) Cursor CLI + herdr via official installers (not on winget)
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

Assert-CommandAvailable mise

& mise bootstrap packages apply -y
if ($LASTEXITCODE -ne 0) {
  throw "mise bootstrap packages apply failed (exit $LASTEXITCODE)"
}

& "$PSScriptRoot/install-cursor-cli-windows.ps1"
if ($LASTEXITCODE -ne 0) {
  throw "install-cursor-cli-windows.ps1 failed (exit $LASTEXITCODE)"
}

& "$PSScriptRoot/install-herdr-windows.ps1"
if ($LASTEXITCODE -ne 0) {
  throw "install-herdr-windows.ps1 failed (exit $LASTEXITCODE)"
}
