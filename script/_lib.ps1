# Shared helpers for Windows dotfiles scripts.

function Get-RepoRoot {
  $root = Resolve-Path (Join-Path $PSScriptRoot '..')
  return $root.Path
}

function Test-CommandAvailable {
  param([Parameter(Mandatory)][string]$Name)
  return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Assert-CommandAvailable {
  param([Parameter(Mandatory)][string]$Name)
  if (-not (Test-CommandAvailable $Name)) {
    throw "Required command not found: $Name"
  }
}

function Test-DeveloperModeEnabled {
  try {
    $key = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction Stop
    return $key.AllowDevelopmentWithoutDevLicense -eq 1
  } catch {
    return $false
  }
}

function Write-DeveloperModeWarning {
  if (Test-DeveloperModeEnabled) {
    return
  }
  Write-Warning @"
Developer Mode does not appear to be enabled. PSDotFiles needs permission to create symbolic links.
Enable: Settings -> System -> For developers -> Developer Mode
Or run this shell as Administrator.
"@
}

function Invoke-WingetConfigure {
  param(
    [Parameter(Mandatory)][string]$ConfigPath
  )

  Assert-CommandAvailable winget

  $args = @(
    'configure',
    '-f', $ConfigPath,
    '--accept-configuration-agreements',
    '--disable-interactivity'
  )

  & winget @args
  if ($LASTEXITCODE -ne 0) {
    throw "winget configure failed (exit $LASTEXITCODE): $ConfigPath"
  }
}

function Install-DeploySubdirsWindows {
  param(
    [Parameter(Mandatory)][string]$RepoRoot
  )

  $listPath = Join-Path $RepoRoot '.deploy_subdir-windows'
  if (-not (Test-Path $listPath)) {
    Write-Host '(skip) .deploy_subdir-windows not found'
    return
  }

  Write-Host '==> Ensure required subdirectories exist (from .deploy_subdir-windows)'
  Get-Content $listPath | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) {
      return
    }
    $target = Join-Path $HOME $line
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    Write-Host "  mkdir -p $target"
  }
}
