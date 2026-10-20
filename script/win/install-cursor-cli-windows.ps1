#Requires -Version 5.1
# Install Cursor CLI via the official Windows installer:
#   https://cursor.com/docs/cli/overview
#   irm 'https://cursor.com/install?win32=true' | iex
#
# Idempotent: skips when `agent` / `cursor-agent` is already on PATH
# (or present under %LOCALAPPDATA%\cursor-agent).
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$agentHome = Join-Path $env:LOCALAPPDATA 'cursor-agent'

function Test-CursorCliPresent {
  if (Test-CommandAvailable agent) { return $true }
  if (Test-CommandAvailable cursor-agent) { return $true }
  foreach ($name in @('agent.exe', 'cursor-agent.exe', 'agent.cmd', 'cursor-agent.cmd')) {
    if (Test-Path (Join-Path $agentHome $name)) { return $true }
  }
  return $false
}

if (Test-CursorCliPresent) {
  Write-Host "Cursor CLI already installed (agent / cursor-agent)."
  exit 0
}

Write-Host "Installing Cursor CLI (official: irm 'https://cursor.com/install?win32=true' | iex)..."
Invoke-RestMethod -Uri 'https://cursor.com/install?win32=true' | Invoke-Expression

# Installer adds %LOCALAPPDATA%\cursor-agent to the User PATH; refresh this session.
if ((Test-Path $agentHome) -and ($env:Path -notlike "*$agentHome*")) {
  $env:Path = "$agentHome;$env:Path"
}

if (-not (Test-CursorCliPresent)) {
  throw 'Cursor CLI install finished but agent/cursor-agent was not found. Open a new terminal, or check %LOCALAPPDATA%\cursor-agent.'
}

Write-Host 'Cursor CLI ready. Next: agent (or cursor-agent login).'
