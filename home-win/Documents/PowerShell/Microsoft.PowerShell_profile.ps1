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
