#Requires -Version 5.1
# Download fonts used by Windows Terminal into the per-user Fonts folder.
# Mirrors script/install-fonts.zsh (macOS Ghostty) for Moralerspace Neon only.
# - Moralerspace Neon — https://github.com/yuru7/moralerspace (SIL OFL)
#
# ChaliceIcons is macOS-only here: nvim skips Chalice on Windows (no WT
# equivalent of Ghostty font-codepoint-map), so installing the TTF is unused.
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

Add-Type -AssemblyName System.Drawing

$fontsDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$regPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
New-Item -ItemType Directory -Force -Path $fontsDir | Out-Null
if (-not (Test-Path -LiteralPath $regPath)) {
  New-Item -Path $regPath -Force | Out-Null
}

function Install-UserFontFile {
  param([Parameter(Mandatory)][string]$SourcePath)

  $name = [System.IO.Path]::GetFileName($SourcePath)
  $dest = Join-Path $fontsDir $name
  try {
    Copy-Item -LiteralPath $SourcePath -Destination $dest -Force
  } catch {
    if (Test-Path -LiteralPath $dest) {
      Write-Host "  skip $name (already installed / in use by another process)"
      return
    }
    throw
  }

  $collection = New-Object System.Drawing.Text.PrivateFontCollection
  try {
    $collection.AddFontFile($dest)
    $family = $collection.Families[0].Name
  } finally {
    $collection.Dispose()
  }

  # Style from filename (MoralerspaceNeon-Bold.ttf → Bold).
  $stem = [System.IO.Path]::GetFileNameWithoutExtension($name)
  $style = if ($stem -match '-(Regular|Bold|Italic|BoldItalic)$') { $Matches[1] } else { 'Regular' }
  $regName = "$family $style (TrueType)"
  New-ItemProperty -Path $regPath -Name $regName -Value $dest -PropertyType String -Force | Out-Null
  Write-Host "  installed $dest ($family $style)"
}

function Install-MoralerspaceNeon {
  $tag = $env:MORALERSPACE_TAG
  if (-not $tag) {
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/yuru7/moralerspace/releases/latest'
    $tag = $release.tag_name
  }
  if (-not $tag) {
    throw 'Could not resolve Moralerspace release tag (set MORALERSPACE_TAG=vX.Y.Z)'
  }

  $zipUrl = "https://github.com/yuru7/moralerspace/releases/download/$tag/Moralerspace_$tag.zip"
  $zipPath = Join-Path ([System.IO.Path]::GetTempPath()) ("Moralerspace-{0}.zip" -f [guid]::NewGuid().ToString('N'))
  $work = Join-Path ([System.IO.Path]::GetTempPath()) ("Moralerspace-{0}" -f [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path $work | Out-Null

  Write-Host "→ Moralerspace Neon ($tag)"
  try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -LiteralPath $zipPath -DestinationPath $work -Force
    $faces = Get-ChildItem -Path $work -Recurse -Filter 'MoralerspaceNeon-*.ttf'
    if (-not $faces) {
      throw "No MoralerspaceNeon-*.ttf found in $tag zip"
    }
    foreach ($face in $faces) {
      Install-UserFontFile -SourcePath $face.FullName
    }
  } finally {
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
    Remove-Item -Force $zipPath -ErrorAction SilentlyContinue
  }
}

Install-MoralerspaceNeon

Write-Host 'Done. Restart Windows Terminal (new window) so the font list reloads.'
Write-Host 'Then: mise run theme  (sets profiles.defaults.font to Moralerspace Neon).'
