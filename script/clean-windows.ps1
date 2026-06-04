#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$repo = Get-RepoRoot
Set-Location $repo

if (-not (Get-Module -ListAvailable -Name PSDotFiles)) {
  throw 'PSDotFiles module is not installed. Run: Install-Module -Name PSDotFiles -Scope CurrentUser'
}

Import-Module PSDotFiles

$Global:DotFilesPath = $repo
Write-Host '==> Remove home-win/ symlinks from home directory.'

try {
  $component = Get-DotFiles -Path $repo -Autodetect | Where-Object Name -eq 'home-win'
  if (-not $component) {
    throw 'PSDotFiles component not found: home-win'
  }

  $component | Remove-DotFiles -Verbose -ErrorAction Stop
} catch {
  Write-Host "  (skip) $($_.Exception.Message)"
}
