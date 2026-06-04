#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$repo = Get-RepoRoot
$config = Join-Path $repo 'win/apps.winget'

if (-not (Test-Path $config)) {
  throw "WinGet configuration not found: $config"
}

Write-Host "==> Install apps via winget configure ($config)"
Invoke-WingetConfigure -ConfigPath $config
