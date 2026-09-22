#Requires -Version 5.1
# Mirror of script/update.zsh: fetch latest from origin/main.
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/_lib.ps1"

$repo = Get-RepoRoot
Set-Location $repo

Assert-CommandAvailable git

git pull --no-ff origin main
if ($LASTEXITCODE -ne 0) {
  throw "git pull --no-ff origin main failed (exit $LASTEXITCODE)"
}
