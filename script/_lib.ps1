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
Developer Mode does not appear to be enabled. Without it, mise dotfiles apply
silently COPIES instead of creating symlinks, so edits made in your home
directory will not flow back into this repo.
Enable: Settings -> System -> For developers -> Developer Mode
Or run this shell as Administrator.
"@
}
