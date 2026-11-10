# Plan 001: `mise run check` でリポジトリの整合性を 1 コマンドで確かめられるようにする

> Executor instructions: この計画を上から順に実行する。各ステップの Verify を実行し、
> 期待どおりの結果を確認してから次へ進む。「STOP conditions」に当てはまったら、
> 自分で工夫せずに止まって報告する。完了したら `plans/README.md` の該当行の
> Status を更新する（レビュアーから「索引は自分が管理する」と言われた場合を除く）。
>
> Drift check（最初に実行）:
> `git diff --stat 6e8371d..HEAD -- mise.toml mise.linux.toml mise.windows.toml script/unix nix/home-manager/tools/claude.nix AGENTS.md docs/mise.toml docs/README.md`
> 変更が出たら「Current state」の抜粋と現物を見比べ、食い違っていれば STOP。

## Status

- Priority: P1
- Effort: S
- Risk: LOW
- Depends on: none
- Category: dx
- Planned at: commit `6e8371d`, 2026-11-11

## Why this matters

このリポジトリには CI もテストも無く、AGENTS.md は「Build / Lint / Typecheck を通せ」と書きながらコマンド名を示していない。そのため、機械的に検出できるずれが 2 件残っていた。`mise.linux.toml` が存在しないディレクトリを参照していること、Claude Code 用スキルの一覧が macOS と Linux で食い違っていることである。

この計画は、検証を 1 つの mise タスクにまとめ、いま検出される 2 件のずれも一緒に直して、タスクが緑で終わる状態にする。以降の計画（002 以降）はこのタスクを検証ゲートとして使う。

## Current state

関係するファイル:

- `mise.toml` — ルートの mise 設定。全 OS 共通のタスク（`update`、`theme`）がある。
- `mise.linux.toml` — Linux 用の `[dotfiles]`（リンク宣言）とタスク。
- `mise.windows.toml` — Windows 用の `[dotfiles]` とタスク。
- `nix/home-manager/tools/claude.nix` — macOS で `~/.claude/skills/<name>` にリンクするスキルの一覧。
- `script/unix/_lib.zsh` — zsh スクリプト共通のヘルパー（`repo_root`、`require_cmd`）。
- `script/unix/update.zsh` — 既存 zsh スクリプトの手本。
- `AGENTS.md` — エージェント向けの手順書。
- `docs/mise.toml`、`docs/README.md` — ドキュメントサイト（Astro + bun）の設定と README。

`mise.toml`（全文）:

```toml
[settings]
# Required for `mise bootstrap` (packages, login shell, etc.)
experimental = true

[bootstrap.user]
login_shell = "/bin/zsh"

[tasks.update]
description = "Fetch latest changes"
run = "zsh script/unix/update.zsh"
run_windows = "pwsh -NoProfile -File script/win/update.ps1"

[tasks.theme]
description = "Install cendre theme (Terminal.app / Windows Terminal + bat cache for delta)"
run = "zsh script/unix/theme.zsh"
run_windows = "pwsh -NoProfile -File script/win/theme.ps1"

[tools]
gitleaks = "8"
```

`script/unix/update.zsh`（全文。新しいスクリプトはこの形に合わせる）:

```zsh
#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

local root
root=$(repo_root)
cd "$root"

require_cmd git

git pull --no-ff origin main
```

`mise.linux.toml:21-22`（22 行目の `home/.config/zsh` はリポジトリに存在しない。中身だった `herdr.zsh` がコミット `450f76f` で削除され、ディレクトリごと消えた）:

```toml
"~/.config/sheldon" = { source = "home/.config/sheldon", mode = "symlink" }
"~/.config/zsh" = { source = "home/.config/zsh", mode = "symlink" }
```

`nix/home-manager/tools/claude.nix:7-19`:

```nix
  skills = [
    "commit"
    "dev-crit"
    "dev-server"
    "git-wt"
    "improve"
    "natural-japanese"
    "orca-cli"
    "orchestration"
    "rex"
    "security-audit"
    "wtt-close"
    "wt-slots"
  ];
```

`mise.linux.toml:36-46`（`rex` と `wtt-close` の行が無い）:

```toml
"~/.claude/skills/commit" = { source = "home/.agents/skills/commit", mode = "symlink" }
"~/.claude/skills/dev-server" = { source = "home/.agents/skills/dev-server", mode = "symlink" }
"~/.claude/skills/git-wt" = { source = "home/.agents/skills/git-wt", mode = "symlink" }
"~/.claude/skills/dev-crit" = { source = "home/.agents/skills/dev-crit", mode = "symlink" }
"~/.claude/skills/wt-slots" = { source = "home/.agents/skills/wt-slots", mode = "symlink" }
# Installed via `npx skills add -g` (tracked through ~/.agents); declared here so fresh machines get the Claude Code link too.
"~/.claude/skills/natural-japanese" = { source = "home/.agents/skills/natural-japanese", mode = "symlink" }
"~/.claude/skills/orca-cli" = { source = "home/.agents/skills/orca-cli", mode = "symlink" }
"~/.claude/skills/orchestration" = { source = "home/.agents/skills/orchestration", mode = "symlink" }
"~/.claude/skills/security-audit" = { source = "home/.agents/skills/security-audit", mode = "symlink" }
"~/.claude/skills/improve" = { source = "home/.agents/skills/improve", mode = "symlink" }
```

`mise.windows.toml:71-81` も同じ並びで、やはり `rex` と `wtt-close` が無い。ただし Windows には Rex というアプリが無く（`docs/src/content/docs/decisions.md` に「Windows には Rex がないので、herdr を残している」とある）、`rex` と `wtt-close` はどちらも Rex 前提のスキルなので、Windows に無いのは正しい。Linux には Rex があるので、Linux には必要。

`AGENTS.md:18-22`:

```markdown
## Quality Gates (Keep Green)
- Build: Ensure builds and scripts are not broken
- Lint/Typecheck: Pass static analysis
- Tests: All existing tests must PASS; if none, record a small manual check
- Example report: `Build: PASS / Lint: PASS / Tests: N/A`
```

`docs/mise.toml`（全文）:

```toml
[tools]
bun = "1.3.14"
```

`docs/README.md:6-10`（`mise run dev` というタスクは今どこにも無い）:

````markdown
## Develop

```bash
mise run dev   # or: bun run dev
```
````

`docs/package.json` の scripts には `dev`（`astro dev`）、`build`（`astro build`）、`typecheck`（`astro check`）、`lint:docs`（`nimbus-docs lint`）がある。

守る規約:

- コードにコメントは基本書かない。書くのは、マジックナンバーの根拠と、コードから読み取れない回避策の理由だけ。「何をしているか」の説明や見出しコメントは書かない。
- Web プロジェクトの実行は `mise run ...` を正とする（だから docs にも mise タスクを足す）。
- 差分は最小にする。無関係な整形をしない。

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| 整合性チェック（この計画で作る） | `mise run check` | 最終行が `check: OK`、exit 0 |
| zsh 構文 | `zsh -n script/unix/check.zsh` | 出力なし、exit 0 |
| Nix 評価 | `nix flake check --no-build` | `✅ darwinConfigurations.AME (build skipped)`、exit 0 |
| docs チェック（この計画で作る） | `cd docs && mise run check` | `0 errors` と `lint clean`、exit 0 |

macOS で実行する前提。`nix flake check --no-build` と `shellcheck`、`bun run typecheck`、`bun run lint:docs` は、計画作成時にすべて成功することを確認済み。

## Scope

In scope（変更してよいのはこれだけ）:

- `script/unix/check.zsh`（新規）
- `mise.toml`
- `mise.linux.toml`
- `docs/mise.toml`
- `AGENTS.md`

Out of scope（関係がありそうでも触らない）:

- `mise.windows.toml` — Windows に `rex` と `wtt-close` を足さない（Rex が無い）。
- `nix/home-manager/tools/claude.nix` — 一覧は正しい。読むだけ。
- `docs/README.md` — `mise run dev` の記述は、この計画でタスクを足すことで正しくなる。文章は触らない。
- `.githooks/pre-commit` — チェックを pre-commit に組み込まない（コミットのたびに Nix を評価させない）。
- GitHub Actions の追加 — 別の検討事項。

## Git workflow

- Branch: `advisor/001-add-check-task`
- コミットは Conventional Commits。例（`git log` より）: `fix(nvim): stop dimming dotfiles in neo-tree`、`feat(skills): add improve skill`。説明は英語の小文字命令形で 72 文字以内。
- この計画のコミット例: `feat(mise): add check task for dotfiles consistency`
- push しない。PR も作らない。

## Steps

### Step 1: `script/unix/check.zsh` を作る

次の内容で新規作成する（そのまま書き写す）。

```zsh
#!/usr/bin/env zsh

emulate -L zsh
set -eu
set -o pipefail

source "${0:A:h}/_lib.zsh"

cd "$(repo_root)"

local -i failed=0
fail() {
  print -u2 -r -- "FAIL: $*"
  failed=1
}

local f s
for f in mise.linux.toml mise.windows.toml; do
  for s in ${(f)"$(grep -o 'source = "[^"]*"' "$f" | sed -e 's/^source = "//' -e 's/"$//')"}; do
    [[ -e $s ]] || fail "$f: source not found: $s"
  done
done

# Rex does not exist on Windows, so its skills are not linked there.
local -a skills windows_skip=(rex wtt-close)
skills=(${(f)"$(sed -n '/^  skills = \[/,/^  \];/p' nix/home-manager/tools/claude.nix | grep -o '"[^"]*"' | tr -d '"')"})
(( ${#skills} )) || fail "nix/home-manager/tools/claude.nix: skills list not found"
for s in $skills; do
  [[ -d home/.agents/skills/$s ]] || fail "claude.nix: skill dir not found: home/.agents/skills/$s"
  grep -qF "\"~/.claude/skills/$s\"" mise.linux.toml || fail "mise.linux.toml: missing entry ~/.claude/skills/$s"
  (( ${windows_skip[(Ie)$s]} )) && continue
  grep -qF "\"~/.claude/skills/$s\"" mise.windows.toml || fail "mise.windows.toml: missing entry ~/.claude/skills/$s"
done

for f in script/unix/*.zsh script/linux/*.zsh home/.zshenv home/.zprofile home/.zshrc; do
  zsh -n "$f" || fail "zsh syntax: $f"
done

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning install script/macos/init.sh .githooks/pre-commit home/.config/lazygit/generate-commit-msg.sh || fail "shellcheck"
else
  print -r -- "(skip) shellcheck not installed"
fi

if [[ "$(uname -s)" == Darwin && -x /nix/var/nix/profiles/default/bin/nix ]]; then
  /nix/var/nix/profiles/default/bin/nix flake check --no-build || fail "nix flake check"
else
  print -r -- "(skip) nix flake check: macOS with Nix only"
fi

if (( failed )); then
  print -u2 -r -- "check: FAILED"
  exit 1
fi
print -r -- "check: OK"
```

コメントは `# Rex does not exist on Windows ...` の 1 行だけ残す（除外リストの根拠なので規約上書いてよい）。ほかのコメントは足さない。

Verify: `zsh -n script/unix/check.zsh` → 出力なし、exit 0

### Step 2: `mise.toml` に `check` タスクを足す

`[tasks.theme]` のブロックの直後（`[tools]` の前）に追加する。

```toml
[tasks.check]
description = "Check dotfiles consistency (link sources, skill lists, shell syntax, flake)"
run = "zsh script/unix/check.zsh"
run_windows = "pwsh -NoProfile -Command \"Write-Host '(skip) check: run on macOS or Linux'\""
```

Verify: `mise run check; echo "exit=$?"` → この時点では次の 3 行が出て `check: FAILED`、`exit=1` になる（Step 3 で直す）。これ以外の FAIL 行が出たら STOP。

```
FAIL: mise.linux.toml: source not found: home/.config/zsh
FAIL: mise.linux.toml: missing entry ~/.claude/skills/rex
FAIL: mise.linux.toml: missing entry ~/.claude/skills/wtt-close
```

### Step 3: `mise.linux.toml` のずれを直す

1. 22 行目 `"~/.config/zsh" = { source = "home/.config/zsh", mode = "symlink" }` を削除する。
2. `"~/.claude/skills/wt-slots" = ...` の行の直後に、次の 2 行を足す。

```toml
"~/.claude/skills/rex" = { source = "home/.agents/skills/rex", mode = "symlink" }
"~/.claude/skills/wtt-close" = { source = "home/.agents/skills/wtt-close", mode = "symlink" }
```

Verify: `mise run check; echo "exit=$?"` → 最終行 `check: OK`、`exit=0`

### Step 4: `docs/mise.toml` に docs 用タスクを足す

`docs/mise.toml` の末尾に追加する。

```toml

[tasks.dev]
description = "Start the docs dev server"
run = "bun run dev"

[tasks.build]
description = "Build the docs site"
run = "bun run build"

[tasks.check]
description = "Typecheck and lint the docs"
run = ["bun run typecheck", "bun run lint:docs"]
```

Verify: `cd docs && mise tasks | grep -E '^(dev|build|check) '` → 3 行出る。続けて `cd docs && mise run check` → `0 errors` を含む行と `lint clean` を含む行が出て exit 0。

`mise run dev` は起動したまま止まらないので、Verify では実行しない。

### Step 5: `AGENTS.md` にコマンド名を書く

`AGENTS.md:18-22` の「Quality Gates (Keep Green)」節を、次の内容に置き換える。

```markdown
## Quality Gates (Keep Green)
- `mise run check`: link sources exist, skill lists agree across OSes, shell syntax, shellcheck, `nix flake check --no-build` (macOS)
- `cd docs && mise run check`: `astro check` and `nimbus-docs lint`, after changing anything under `docs/`
- Windows scripts have no automated check; record a small manual check
- Example report: `check: PASS / docs check: PASS`
```

Verify: `grep -c 'mise run check' AGENTS.md` → `2`

## Test plan

このリポジトリにテストフレームワークは無い。`mise run check` 自体が検証手段になる。チェックが本当に失敗を検出することを、次の手順で一度だけ確かめる（確かめたら必ず元に戻す）。

1. `mise.linux.toml` の `"~/.claude/skills/rex"` の行を一時的に削除する。
2. `mise run check; echo "exit=$?"` → `FAIL: mise.linux.toml: missing entry ~/.claude/skills/rex` と `exit=1` が出る。
3. `git checkout -- mise.linux.toml` はしない（Step 3 の変更まで消える）。削除した 1 行を手で戻す。
4. `mise run check` → `check: OK`

## Done criteria

すべて満たすこと。

- [ ] `mise run check` が exit 0 で、最終行が `check: OK`
- [ ] `cd docs && mise run check` が exit 0
- [ ] `grep -c 'home/.config/zsh' mise.linux.toml` が `0`
- [ ] `grep -c '"~/.claude/skills/rex"' mise.linux.toml` が `1`、`grep -c '"~/.claude/skills/wtt-close"' mise.linux.toml` が `1`
- [ ] `git diff --stat 6e8371d -- mise.windows.toml nix` が空
- [ ] `git status --short` に出るのが In scope のファイルだけ（`home/.config/cloudflare/` は元からある未追跡ディレクトリなので無視する）
- [ ] `plans/README.md` の Status を更新した

## STOP conditions

次のどれかに当てはまったら、止まって報告する。

- 「Current state」の抜粋と現物が食い違っている。
- Step 2 の Verify で、挙げた 3 行以外の FAIL が出る。
- `nix flake check --no-build` が失敗する（この計画の変更は Nix に触れないので、失敗は別の原因）。
- `home/.config/zsh` が実在する（誰かが復活させている。エントリを消してはいけない）。
- 同じ Verify が、妥当な修正を試しても 2 回失敗する。

## Maintenance notes

- スキルを足すときは、`claude.nix` と `mise.linux.toml`、Rex 前提でなければ `mise.windows.toml` にも足す。忘れると `mise run check` が落ちる。
- Windows 専用にできないスキルが増えたら、`check.zsh` の `windows_skip` に足す。
- `check.zsh` は `claude.nix` の `skills = [` から `];` までを sed で切り出している。この書式（2 スペースのインデント）を変えるとチェックが `skills list not found` で落ちる。
- 見送ったこと: pre-commit への組み込みと GitHub Actions。前者はコミットを遅くし、後者は Nix の評価環境が要るので、別途判断する。
- `nix/home-manager/tools/zsh.nix:8` のコメントは `home/.config/zsh` に触れたままになる。Nix 側は挙動に影響しないので、この計画では直さない。
