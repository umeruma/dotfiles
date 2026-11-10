# Plan 005: Windows の `mise run clean` が、外すべきリンクだけを漏れなく外すようにする

> Executor instructions: この計画を上から順に実行する。各ステップの Verify を実行し、
> 期待どおりの結果を確認してから次へ進む。「STOP conditions」に当てはまったら、
> 自分で工夫せずに止まって報告する。完了したら `plans/README.md` の該当行の
> Status を更新する（レビュアーから「索引は自分が管理する」と言われた場合を除く）。
>
> Drift check（最初に実行）:
> `git diff --stat 6e8371d..HEAD -- script/win/clean.ps1 script/win/_lib.ps1 mise.windows.toml`
> `mise.windows.toml` は Plan 003 で 2 行目のコメントだけ変わっている可能性がある。
> それ以外の変更が出たら「Current state」の抜粋と現物を見比べ、食い違っていれば STOP。

## Status

- Priority: P2
- Effort: S
- Risk: LOW
- Depends on: none
- Category: bug
- Planned at: commit `6e8371d`, 2026-11-11

## Why this matters

`mise dotfiles apply` は、宣言から消したエントリのリンクを残す。そこで Windows では `mise run clean`（`script/win/clean.ps1`）で「リポジトリを指すリンク」を全部外してから、張り直す運用になっている。このスクリプトに 2 つの不具合がある。

- 取りこぼし: `~/.gitmessage` と `~/.cursor/settings.json` は `mise.windows.toml` がリンクしているのに、走査対象に入っていないので外れない。
- 誤爆: 「リンク先がリポジトリ内か」の判定が、区切り文字なしの前方一致になっている。リポジトリが `...\Codes\dotfiles` のとき、隣の `...\Codes\dotfiles-wt\...`（git-wt が worktree を置く場所）を指すリンクまで外してしまう。

計画作成時に、macOS 上の PowerShell 7.6 と一時ディレクトリで、両方とも再現を確認した。

## Current state

関係するファイル:

- `script/win/clean.ps1` — リポジトリを指すリンクを `$HOME` から外すスクリプト。
- `script/win/_lib.ps1` — 共通ヘルパー。`Get-RepoRoot` がリポジトリのルートを返す。読むだけ。
- `mise.windows.toml` — Windows の `[dotfiles]`（リンク宣言）。読むだけ。

`script/win/clean.ps1:17-29`（走査対象。`.gitmessage` と `.cursor` が無い）:

```powershell
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
```

`mise.windows.toml` の該当エントリ（走査対象に入っていないリンク）:

```toml
"~/.gitmessage" = { source = "home/.gitmessage", mode = "symlink" }
```

```toml
"~/.cursor/settings.json" = { source = "home/.cursor/settings.json", mode = "symlink" }
```

`script/win/clean.ps1:63-68`（判定。66 行目が区切り文字なしの前方一致）:

```powershell
  # Cannot use Resolve-Path: dangling links must still match.
  $target = [System.IO.Path]::GetFullPath($target)

  if (-not $target.StartsWith($RepoRoot, [StringComparison]::OrdinalIgnoreCase)) {
    return $false
  }
```

`script/win/clean.ps1:111-113`（112 行目の後半は事実と違う。`~/AppData/Local/nvim` や `~/.claude/skills/*` もディレクトリのエントリ）:

```powershell
# Prune dirs the sweep may have emptied, so whole-dir [dotfiles] entries can be
# applied in their place. ~/.agents is the only dir entry on Windows.
foreach ($dir in @("$HOME\.agents")) {
```

`script/win/_lib.ps1:3-6`（`$RepoRoot` の出どころ。末尾に区切り文字は付かない）:

```powershell
function Get-RepoRoot {
  $root = Resolve-Path (Join-Path $PSScriptRoot '../..')
  return $root.Path
}
```

Linux 版の同じ判定（`script/linux/clean.zsh:32`）は、区切り文字を付けて比べている。考え方はこれに合わせる:

```zsh
    if [[ $target == "$root/home" || $target == "$root/home/"* ]]; then
```

守る規約:

- コードにコメントは基本書かない。書くのは、コードから読み取れない回避策の理由だけ。古いコメントは、書き直さずに消す。
- 差分は最小にする。無関係な整形をしない。

## Commands you will need

macOS には PowerShell が入っていないので、Nix から一時的に実行する（リポジトリには何も書き込まれない）。

| Purpose | Command | Expected on success |
|---|---|---|
| PowerShell の起動確認 | `nix run --inputs-from . nixpkgs#powershell -- -NoProfile -Command '$PSVersionTable.PSVersion.Major'` | `7` |
| 動作テスト | 下の「Test plan」のスクリプト | 「Test plan」に書いた出力 |

## Scope

In scope（変更してよいのはこれだけ）:

- `script/win/clean.ps1`

Out of scope（関係がありそうでも触らない）:

- `script/win/_lib.ps1` — `Get-RepoRoot` の戻り値は変えない。ほかのスクリプトも使っている。
- `script/linux/clean.zsh` — Linux 版は Plan 002 で直す。
- `mise.windows.toml` — エントリは正しい。
- `clean.ps1` の `Test-ReparsePoint`、`Get-LinkTarget`、`Invoke-Sweep` — 正しく動いている。
- 走査の深さ（`$Depth = 6`）の変更。

## Git workflow

- Branch: `advisor/005-fix-windows-clean-script`
- コミットは Conventional Commits。例（`git log` より）: `fix(nvim): stop dimming dotfiles in neo-tree`。説明は英語の小文字命令形で 72 文字以内。
- この計画のコミット例: `fix(clean): match repo links exactly and scan cursor and gitmessage on windows`
- push しない。PR も作らない。

## Steps

### Step 1: 修正前の挙動を再現する

「Test plan」のスクリプトを、修正前のコードに対して実行する。

Verify: 出力が「Test plan」の表の「修正前」の列と一致する（`sibling` が消え、`.gitmessage` と `.cursor/settings.json` が残る）。一致しなければ STOP。

### Step 2: 走査対象に `.gitmessage` と `.cursor` を足す

`$scanRoots` の `'.gitconfig'` の次の行に `'.gitmessage'` を、`'.copilot'` の次の行に `'.cursor'` を足す。

```powershell
$scanRoots = @(
  '.gitconfig'
  '.gitmessage'
  '.claude'
  '.config'
  '.copilot'
  '.cursor'
  '.agents'
  ...
```

Verify: `grep -c "'.gitmessage'\|'.cursor'" script/win/clean.ps1` → `2`

### Step 3: 判定を「ルートそのもの、またはルート＋区切り文字で始まる」にする

66-68 行目の `if` を、次に置き換える。

```powershell
  $prefix = $RepoRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  if ($target -ne $RepoRoot -and -not $target.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
    return $false
  }
```

`DirectorySeparatorChar` を使うのは、macOS 上のテストでも同じコードが動くようにするため（Windows では `\`、macOS では `/`）。

Verify: `grep -c 'DirectorySeparatorChar' script/win/clean.ps1` → `1`

### Step 4: 事実と違うコメントを直す

112 行目の後半 ` ~/.agents is the only dir entry on Windows.` を削除する。111-112 行目は次の形になる。

```powershell
# Prune dirs the sweep may have emptied, so whole-dir [dotfiles] entries can be
# applied in their place.
```

Verify: `grep -c 'only dir entry' script/win/clean.ps1` → `0`

### Step 5: 修正後の挙動を確かめる

「Test plan」のスクリプトをもう一度実行する。

Verify: 出力が「Test plan」の表の「修正後」の列と一致する。

## Test plan

このリポジトリにテストフレームワークは無い。一時ディレクトリを `$HOME` に見立て、5 種類のリンクを置いて実際のスクリプトを動かす。本物のホームディレクトリには触れない。リポジトリには何も足さない。

次のスクリプトを、リポジトリのルートで実行する。

```bash
REPO=$PWD
T=$(mktemp -d)
mkdir -p "$T/.config" "$T/.cursor"
ln -s "$REPO/home/.gitmessage" "$T/.gitmessage"
ln -s "$REPO/home/.cursor/settings.json" "$T/.cursor/settings.json"
ln -s "$REPO/home/.config/starship.toml" "$T/.config/starship.toml"
ln -s "$REPO-wt/main/file" "$T/.config/sibling"
ln -s /etc/hosts "$T/.config/foreign"

HOME="$T" nix run --inputs-from "$REPO" nixpkgs#powershell -- -NoProfile \
  -File "$REPO/script/win/clean.ps1" 2>&1 | grep -E '^(unlink|Done)'

for f in .gitmessage .cursor/settings.json .config/starship.toml .config/sibling .config/foreign; do
  if [ -L "$T/$f" ]; then echo "kept:    $f"; else echo "removed: $f"; fi
done
rm -rf "$T"
```

`sibling` は、リポジトリの隣の `dotfiles-wt` を指すリンク（リンク先は実在しなくてよい）。`foreign` は、リポジトリと無関係な場所を指すリンク。

期待する出力（最後の 5 行）:

| リンク | 修正前 | 修正後 |
|---|---|---|
| `.gitmessage` | `kept` | `removed` |
| `.cursor/settings.json` | `kept` | `removed` |
| `.config/starship.toml` | `removed` | `removed` |
| `.config/sibling` | `removed` | `kept` |
| `.config/foreign` | `kept` | `kept` |

`Done` の行は、修正前が `Done (2 link(s) removed).`、修正後が `Done (3 link(s) removed).` になる。

スクリプトは冒頭で Developer Mode の警告を出す（macOS にはレジストリが無いため）。テストには影響しないので、`grep` で落としている。

## Done criteria

すべて満たすこと。

- [ ] 「Test plan」の出力が、表の「修正後」の列と一致する
- [ ] `Done (3 link(s) removed).` が出る
- [ ] `git diff --stat` に出るのが `script/win/clean.ps1` だけ
- [ ] `git status --short` に、テスト用のファイルが残っていない（`home/.config/cloudflare/` は元からある未追跡ディレクトリなので無視する）
- [ ] `plans/README.md` の Status を更新した

## STOP conditions

次のどれかに当てはまったら、止まって報告する。

- 「Current state」の抜粋と現物が食い違っている。
- Step 1 の出力が「修正前」の列と一致しない。
- 修正後に `foreign` が消える。判定が壊れている。本物のホームでは絶対に実行しない。
- `nix run --inputs-from . nixpkgs#powershell` が動かない。静的な確認だけで完了にしない。
- テストスクリプトの `HOME="$T"` を外して実行したくなった。外してはいけない。
- 同じ Verify が、妥当な修正を試しても 2 回失敗する。

## Maintenance notes

- `mise.windows.toml` の `[dotfiles]` に、いまの走査対象の外にリンクを足したら、`clean.ps1` の `$scanRoots` にも足す。忘れると、そのリンクは `clean` で外れない。
- テストは macOS 上の PowerShell で行っている。Windows 固有の点（ジャンクション、PowerShell 5.1 の `Target` プロパティ）は、このテストでは通らない。該当するコード（`Get-LinkTarget`）は変えていない。
- Linux 版（`script/linux/clean.zsh`）にも似た取りこぼしがあり、Plan 002 で直す。2 つのスクリプトは別々に手で保守している。
- レビューで見てほしい点: Step 3 の条件式。`$target -ne $RepoRoot` は PowerShell の既定で大文字小文字を区別しない比較になる（Windows のパスに合う）。
