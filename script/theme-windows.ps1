#Requires -Version 5.1
# Install cendre into Windows Terminal Fragments and set it as the default
# color scheme in settings.json (opt-in; mirror of mise run theme on macOS).
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

function Set-WindowsTerminalColorScheme {
  param(
    [Parameter(Mandatory)][string]$SettingsPath,
    [Parameter(Mandatory)][string]$SchemeName
  )

  $raw = Get-Content -LiteralPath $SettingsPath -Raw -Encoding UTF8
  $settings = $raw | ConvertFrom-Json

  if ($null -eq $settings.profiles) {
    $settings | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{}) -Force
  }

  $profiles = $settings.profiles
  if ($null -eq $profiles.defaults) {
    $profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{ colorScheme = $SchemeName }) -Force
  } elseif ($null -eq $profiles.defaults.PSObject.Properties['colorScheme']) {
    $profiles.defaults | Add-Member -NotePropertyName colorScheme -NotePropertyValue $SchemeName
  } else {
    $profiles.defaults.colorScheme = $SchemeName
  }

  $json = $settings | ConvertTo-Json -Depth 100
  [System.IO.File]::WriteAllText(
    $SettingsPath,
    $json + [Environment]::NewLine,
    [System.Text.UTF8Encoding]::new($false)
  )
  Write-Host "Set profiles.defaults.colorScheme='$SchemeName' -> $SettingsPath"
}

$settingsPaths = @(
  (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
  (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
  (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json'),
  (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal Preview\settings.json')
) | Where-Object { Test-Path -LiteralPath $_ }

if (-not $settingsPaths) {
  Write-Warning "Windows Terminal settings.json not found; scheme fragment installed only. Open Windows Terminal once, then re-run: mise run theme"
} else {
  foreach ($path in $settingsPaths) {
    Set-WindowsTerminalColorScheme -SettingsPath $path -SchemeName 'cendre'
  }
}

Write-Host "Done. Restart Windows Terminal (not the OS) if it is already open."

# delta syntax highlighting uses bat's theme cache (cendre.tmTheme is deploy-linked).
$bat = Get-Command bat -ErrorAction SilentlyContinue
if ($bat) {
  & $bat.Source cache --build
  Write-Host "Rebuilt bat theme cache (cendre for delta)."
} else {
  Write-Warning "bat not on PATH; install via mise run install-apps, then re-run: mise run theme"
}
