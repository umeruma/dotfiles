$env:DOTFILES = "$HOME\Codes\dotfiles"
$DotFilesPath = $env:DOTFILES

function dot {
  Set-Location $env:DOTFILES
}

$miseCommand = Get-Command mise -ErrorAction SilentlyContinue
if (-not $miseCommand) {
  $wingetMiseBin = Get-ChildItem -Path "$HOME\AppData\Local\Microsoft\WinGet\Packages" -Directory -Filter "jdx.mise*" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 |
    ForEach-Object { Join-Path $_.FullName "mise\bin" }

  if ($wingetMiseBin -and (Test-Path (Join-Path $wingetMiseBin "mise.exe"))) {
    $env:Path = "$wingetMiseBin;$env:Path"
    $miseCommand = Get-Command mise -ErrorAction SilentlyContinue
  }
}

if ($miseCommand) {
  (& mise activate pwsh) | Out-String | Invoke-Expression
}

# Cursor CLI (%LOCALAPPDATA%\cursor-agent) — User PATH may lag until a new login.
if (-not (Get-Command agent -ErrorAction SilentlyContinue) -and
    -not (Get-Command cursor-agent -ErrorAction SilentlyContinue)) {
  $cursorAgentHome = Join-Path $env:LOCALAPPDATA 'cursor-agent'
  if (Test-Path (Join-Path $cursorAgentHome 'agent.exe')) {
    $env:Path = "$cursorAgentHome;$env:Path"
  }
}

# herdr (%LOCALAPPDATA%\Programs\Herdr\bin) — same PATH lag as Cursor CLI.
if (-not (Get-Command herdr -ErrorAction SilentlyContinue)) {
  $herdrBin = Join-Path $env:LOCALAPPDATA 'Programs\Herdr\bin'
  if (Test-Path (Join-Path $herdrBin 'herdr.exe')) {
    $env:Path = "$herdrBin;$env:Path"
  }
}

# nv = New-Variable is a built-in PowerShell alias; drop it for LazyVim parity with zsh.
Remove-Alias nv -Force -ErrorAction SilentlyContinue
function nv { if ($args.Count) { nvim @args } else { nvim . } }
function lg { if ($args.Count) { lazygit @args } else { lazygit . } }
function hr { if ($args.Count) { herdr @args } else { herdr } }
