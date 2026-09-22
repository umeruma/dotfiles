#Requires -Version 5.1
# Download fonts used by Windows Terminal / Neovim into the per-user Fonts folder.
# Mirrors script/install-fonts.zsh (macOS Ghostty).
# - Moralerspace Neon — https://github.com/yuru7/moralerspace (SIL OFL)
# - ChaliceIcons      — https://github.com/artlaman/chalice-icon-theme (MIT)
#
# Note: Windows Terminal has no Ghostty-style font-codepoint-map. Chalice PUA
# glyphs rely on DirectWrite fallback once the font is installed.
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

function Install-ChaliceIcons {
  $url = 'https://raw.githubusercontent.com/artlaman/chalice-icon-theme/master/dist/ChaliceIcons-Regular.ttf'
  $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("chalice-{0}" -f [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
  $tmp = Join-Path $tmpDir 'ChaliceIcons-Regular.ttf'
  Write-Host '→ ChaliceIcons-Regular.ttf'
  try {
    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
    $bytes = [System.IO.File]::ReadAllBytes($tmp)
    # TTF starts with 0x00010000 or 'OTTO' / 'true' / 'typ1'
    if ($bytes.Length -lt 4 -or (
        -not (($bytes[0] -eq 0 -and $bytes[1] -eq 1 -and $bytes[2] -eq 0 -and $bytes[3] -eq 0) -or
              ([System.Text.Encoding]::ASCII.GetString($bytes, 0, 4) -in @('OTTO', 'true', 'typ1'))))) {
      throw 'Chalice download does not look like a font'
    }
    Install-UserFontFile -SourcePath $tmp
  } finally {
    Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
  }
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

Install-ChaliceIcons
Install-MoralerspaceNeon

Write-Host 'Done. Restart Windows Terminal (new window) so the font list reloads.'
Write-Host 'Then: mise run theme  (sets profiles.defaults.font to Moralerspace Neon).'
