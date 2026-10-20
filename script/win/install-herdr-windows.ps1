#Requires -Version 5.1
# Install herdr via the official Windows installer:
#   https://herdr.dev/docs/install/
#   powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 | iex"
#
# Idempotent: skips when `herdr` is already on PATH (or under the
# Programs\Herdr\bin compatibility alias).
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$herdrBin = Join-Path $env:LOCALAPPDATA 'Programs\Herdr\bin'

function Test-HerdrPresent {
  if (Test-CommandAvailable herdr) { return $true }
  if (Test-Path (Join-Path $herdrBin 'herdr.exe')) { return $true }
  return $false
}

if (Test-HerdrPresent) {
  Write-Host 'herdr already installed.'
  exit 0
}

Write-Host "Installing herdr (official: irm https://herdr.dev/install.ps1 | iex)..."
Invoke-RestMethod -Uri 'https://herdr.dev/install.ps1' | Invoke-Expression

# Installer puts the active release on User PATH and keeps Programs\Herdr\bin.
if ((Test-Path $herdrBin) -and ($env:Path -notlike "*$herdrBin*")) {
  $env:Path = "$herdrBin;$env:Path"
}

if (-not (Test-HerdrPresent)) {
  throw 'herdr install finished but herdr was not found. Open a new terminal, or check %LOCALAPPDATA%\Programs\Herdr\bin.'
}

Write-Host 'herdr ready. Next: herdr (or hr).'
