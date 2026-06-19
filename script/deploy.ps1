#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$repo = Get-RepoRoot
Set-Location $repo

Write-DeveloperModeWarning
Install-DeploySubdirsWindows -RepoRoot $repo

if (-not (Get-Module -ListAvailable -Name PSDotFiles)) {
  throw 'PSDotFiles module is not installed. Run: Install-Module -Name PSDotFiles -Scope CurrentUser'
}

Import-Module PSDotFiles

$Global:DotFilesPath = $repo
Write-Host '==> Deploy home-win/ to home directory via PSDotFiles.'
$component = Get-DotFiles -Path $repo -Autodetect -ErrorAction SilentlyContinue | Where-Object Name -eq 'home-win'
if (-not $component) {
  throw 'PSDotFiles component not found: home-win'
}

$component | Install-DotFiles -Verbose -ErrorAction Stop
