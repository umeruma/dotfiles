#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$repo = Get-RepoRoot
Set-Location $repo

if (-not (Get-Module -ListAvailable -Name PSDotFiles)) {
  throw 'PSDotFiles module is not installed. Run: Install-Module -Name PSDotFiles -Scope CurrentUser'
}

Import-Module PSDotFiles

$DotFilesPath = $repo
Write-Host '==> Remove home-win/ symlinks from home directory.'

try {
  Remove-DotFiles home-win -Verbose -ErrorAction Stop
} catch {
  Write-Host "  (skip) $($_.Exception.Message)"
}
