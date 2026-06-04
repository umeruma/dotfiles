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

$DotFilesPath = $repo
Write-Host '==> Deploy home-win/ to home directory via PSDotFiles.'
Install-DotFiles home-win -Verbose
