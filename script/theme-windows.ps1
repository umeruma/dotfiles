#Requires -Version 5.1
# Install cendre into Windows Terminal Fragments (opt-in; mirror of mise run theme on macOS).
# Source: https://github.com/Aejkatappaja/cendre extras/windows-terminal (hard / default depth).
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$repo = Get-RepoRoot
$src = Join-Path $repo 'extras\windows-terminal\cendre.json'
if (-not (Test-Path -LiteralPath $src)) {
  throw "Missing theme file: $src"
}

$destDirs = @(
  (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\cendre')
)
$previewRoot = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal Preview'
if (Test-Path -LiteralPath $previewRoot) {
  $destDirs += (Join-Path $previewRoot 'Fragments\cendre')
}

foreach ($dir in $destDirs) {
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $dest = Join-Path $dir 'cendre.json'
  Copy-Item -LiteralPath $src -Destination $dest -Force
  Write-Host "Installed cendre scheme -> $dest"
}

Write-Host "Restart Windows Terminal if it is open, then set Appearance → Color scheme to 'cendre'."
