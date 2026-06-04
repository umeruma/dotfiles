$env:DOTFILES = "$HOME\Codes\dotfiles"
$DotFilesPath = $env:DOTFILES

function dot {
  Set-Location $env:DOTFILES
}

if (Get-Command mise -ErrorAction SilentlyContinue) {
  (& mise activate pwsh) | Out-String | Invoke-Expression
}
