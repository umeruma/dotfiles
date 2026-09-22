# Generate Conventional Commit subject + description from STAGED changes only.
# Quiet while running — lazygit shows `loadingText` in the bottom status bar.
# Writes to .git/LAZYGIT_PENDING_COMMIT (lazygit's preserved message). When
# running inside Neovim ($env:NVIM), resolves nvim.exe in this process and
# injects `c` via RPC after a short delay (child pwsh has no mise PATH).
# Outside nvim / if nvim is missing: exit 1 with a hint; press `c` yourself.
$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
  [Console]::Error.WriteLine($Message)
  exit 1
}

$agent = Get-Command cursor-agent -ErrorAction SilentlyContinue
if (-not $agent) { $agent = Get-Command agent -ErrorAction SilentlyContinue }
if (-not $agent) {
  Fail 'cursor-agent not found (mise run install-apps, or: irm ''https://cursor.com/install?win32=true'' | iex)'
}

git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { Fail 'not a git repository' }

git diff --cached --quiet 2>$null
if ($LASTEXITCODE -eq 0) { Fail 'no staged changes (stage files first)' }

$stat = git diff --cached --stat
$diff = git diff --cached
if ($diff.Length -gt 24000) {
  $diff = $diff.Substring(0, 24000) + "`n`n[staged diff truncated]"
}

$prompt = @"
Write a git commit message for the STAGED changes only.
Ignore anything not in this staged diff.

Output format (exact):
Line 1: Conventional Commits subject only
  type(optional-scope): description
  English, imperative ("add" not "added"), max 72 characters
  Types: feat, fix, docs, style, refactor, perf, test, chore, ci
Then a blank line.
Then a short description body (1-3 sentences) explaining what and why.
No markdown, no bullets, no code fences, no surrounding quotes.

staged --stat:
$stat

staged diff:
$diff
"@

$errFile = [System.IO.Path]::GetTempFileName()
try {
  $rawOut = & $agent.Source -p --mode ask --output-format text --trust `
    --model composer-2.5-fast -- $prompt 2>$errFile
  $agentStatus = $LASTEXITCODE
} catch {
  $agentStatus = 1
  $rawOut = $null
}

if ($agentStatus -ne 0) {
  $err = ''
  if (Test-Path $errFile) { $err = (Get-Content -Raw $errFile).Trim() }
  Remove-Item -Force $errFile -ErrorAction SilentlyContinue
  $suffix = if ($err) { ": $err" } else { '' }
  Fail "cursor-agent failed (try: cursor-agent login, or set CURSOR_API_KEY)$suffix"
}
Remove-Item -Force $errFile -ErrorAction SilentlyContinue

# Native capture: string | string[] | (rarely) char[]. Never iterate char[].
$raw = if ($null -eq $rawOut) { '' }
  elseif ($rawOut -is [string] -or $rawOut -is [char[]]) { [string]$rawOut }
  else { (@($rawOut) | ForEach-Object { "$_" }) -join "`n" }

$lines = @(
  $raw -split "`r?`n" |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and $_ -notmatch '^```' } |
    ForEach-Object { $_ -replace '^["`]+', '' -replace '["`]+$', '' }
)

# Prefer the Conventional Commits subject line even if the model put prose first
# (otherwise that prose becomes summary and "fix(...): ..." lands in description).
$conv = '^(feat|fix|docs|style|refactor|perf|test|chore|ci)(\([^)]*\))?(!)?:\s+\S'
$subjectIdx = 0
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match $conv) { $subjectIdx = $i; break }
}

$subject = if ($lines.Count -gt $subjectIdx) { $lines[$subjectIdx] } else { '' }
$body = if ($lines.Count -gt ($subjectIdx + 1)) {
  ($lines[($subjectIdx + 1)..($lines.Count - 1)] -join "`n").Trim()
} else { '' }

if (-not $subject) { Fail 'empty commit subject from cursor-agent' }

# lazygit: first line = summary, remainder after "\n" = description (no blank line).
$pending = if ($body) { "$subject`n$body" } else { $subject }
$gitDir = (git rev-parse --git-dir).Trim()
[System.IO.File]::WriteAllText(
  (Join-Path $gitDir 'LAZYGIT_PENDING_COMMIT'),
  $pending,
  [System.Text.UTF8Encoding]::new($false)
)

# Inject `c` into the parent Neovim only when we can resolve nvim.exe here.
# A fresh `pwsh -NoProfile` from Start-Process often lacks mise/scoop PATH, so
# resolve the exe in this process and pass it via -EncodedCommand (avoids
# Windows quoting breakage on \\.\pipe\... addresses).
if ($env:NVIM) {
  $nvimExe = (Get-Command nvim -ErrorAction SilentlyContinue)?.Source
  if ($nvimExe) {
    $server = $env:NVIM
    $exeLit = $nvimExe.Replace("'", "''")
    $serverLit = $server.Replace("'", "''")
    $script = @"
Start-Sleep -Milliseconds 500
& '$exeLit' --server '$serverLit' --remote-send 'c' 2>`$null
"@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script))
    Start-Process -FilePath 'pwsh' -WindowStyle Hidden -ArgumentList @(
      '-NoProfile', '-EncodedCommand', $encoded
    ) | Out-Null
    exit 0
  }
}

Fail "Commit message written. Press c to open the commit panel.`n`n$subject$(if ($body) { "`n`n$body" })"
