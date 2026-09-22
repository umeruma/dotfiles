#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$repo = Get-RepoRoot
Set-Location $repo

Write-DeveloperModeWarning

# Remove every symlink / junction under the scan roots whose target points
# into this repo — including dangling ones. Real files and dirs (app runtime
# state) are never touched. Mirrors script/clean.zsh; `mise dotfiles` has no
# unlink command, so removed [dotfiles] entries need this sweep to avoid
# leaving stale links behind.

$scanRoots = @(
  '.gitconfig'
  '.claude'
  '.config'
  '.copilot'
  '.agents'
  'Documents\PowerShell'
  'Documents\kanata'
  'AppData\Local\lazygit'
  'AppData\Local\nvim'
  'AppData\Roaming\herdr'
  'AppData\Roaming\bat'
) | ForEach-Object { Join-Path $HOME $_ }

function Test-ReparsePoint {
  param([Parameter(Mandatory)][System.IO.FileSystemInfo]$Item)
  return ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
}

function Get-LinkTarget {
  param([Parameter(Mandatory)][System.IO.FileSystemInfo]$Item)
  # PS 7 exposes LinkTarget; PS 5.1 exposes Target as a string[].
  if ($Item.PSObject.Properties.Name -contains 'LinkTarget' -and $Item.LinkTarget) {
    return $Item.LinkTarget
  }
  if ($Item.Target) {
    return @($Item.Target)[0]
  }
  return $null
}

$script:Removed = 0

function Remove-RepoLink {
  param(
    [Parameter(Mandatory)][System.IO.FileSystemInfo]$Item,
    [Parameter(Mandatory)][string]$RepoRoot
  )

  $target = Get-LinkTarget -Item $Item
  if (-not $target) {
    return $false
  }
  if (-not [System.IO.Path]::IsPathRooted($target)) {
    $target = Join-Path (Split-Path -Parent $Item.FullName) $target
  }
  # Cannot use Resolve-Path: dangling links must still match.
  $target = [System.IO.Path]::GetFullPath($target)

  if (-not $target.StartsWith($RepoRoot, [StringComparison]::OrdinalIgnoreCase)) {
    return $false
  }

  Write-Host "unlink: $($Item.FullName) -> $target"
  if ($Item -is [System.IO.DirectoryInfo]) {
    # Deletes the link itself, not what it points at.
    [System.IO.Directory]::Delete($Item.FullName, $false)
  } else {
    [System.IO.File]::Delete($Item.FullName)
  }
  $script:Removed++
  return $true
}

function Invoke-Sweep {
  param(
    [Parameter(Mandatory)][string]$Path,
    [Parameter(Mandatory)][string]$RepoRoot,
    [int]$Depth = 6
  )

  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  if (-not $item) {
    return
  }

  if (Test-ReparsePoint -Item $item) {
    # Never recurse through a link — that would walk back into the repo.
    [void](Remove-RepoLink -Item $item -RepoRoot $RepoRoot)
    return
  }

  if ($item -is [System.IO.DirectoryInfo] -and $Depth -gt 0) {
    foreach ($child in Get-ChildItem -LiteralPath $item.FullName -Force -ErrorAction SilentlyContinue) {
      Invoke-Sweep -Path $child.FullName -RepoRoot $RepoRoot -Depth ($Depth - 1)
    }
  }
}

Write-Host "Removing links pointing into $repo ..."
foreach ($root in $scanRoots) {
  Invoke-Sweep -Path $root -RepoRoot $repo
}

# Prune dirs the sweep may have emptied, so whole-dir [dotfiles] entries can be
# applied in their place. ~/.agents is the only dir entry on Windows.
foreach ($dir in @("$HOME\.agents")) {
  $item = Get-Item -LiteralPath $dir -Force -ErrorAction SilentlyContinue
  if ($item -is [System.IO.DirectoryInfo] -and -not (Test-ReparsePoint -Item $item)) {
    if (-not (Get-ChildItem -LiteralPath $dir -Force -ErrorAction SilentlyContinue)) {
      Remove-Item -LiteralPath $dir -Force
      Write-Host "rmdir:  $dir"
    }
  }
}

Write-Host "Done ($script:Removed link(s) removed)."
