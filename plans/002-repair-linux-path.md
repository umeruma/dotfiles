# Plan 002: Linux のセットアップ経路を、macOS の Nix 移行後の実態に合わせて直す

> Executor instructions: この計画を上から順に実行する。各ステップの Verify を実行し、
> 期待どおりの結果を確認してから次へ進む。「STOP conditions」に当てはまったら、
> 自分で工夫せずに止まって報告する。完了したら `plans/README.md` の該当行の
> Status を更新する（レビュアーから「索引は自分が管理する」と言われた場合を除く）。
>
> Drift check（最初に実行）:
> `git diff --stat 6e8371d..HEAD -- home/.zshrc home/.zshenv mise.linux.toml script/linux/clean.zsh home/.config/lazygit/config.yml install`
> `mise.linux.toml` は Plan 001 で変わっているはず（`~/.config/zsh` の行が消え、スキル 2 行が増えている）。
> それ以外の変更が出たら「Current state」の抜粋と現物を見比べ、食い違っていれば STOP。

## Status

- Priority: P1
- Effort: S
- Risk: MED（Linux 実機で確かめられない。macOS 上の静的チェックと、一時ディレクトリでの動作テストで代える）
- Depends on: plans/001-add-check-task.md
- Category: bug
- Planned at: commit `6e8371d`, 2026-11-11

## Why this matters

macOS は Nix（home-manager）に移り、zsh の設定は `nix/home-manager/tools/*.nix` に書くようになった。Linux（Omarchy）は今も `home/.zshrc` と mise の `[dotfiles]` を使っているが、移行のあと手が入っておらず、いくつか壊れている。

- git-wt が入っていない Linux では、シェルを開くたびにエラーが出る。
- lazygit の `A`（AI でコミットメッセージを作る）が、スクリプトがリンクされていないので動かない。
- `mise run clean` が、`extras/` へのリンクと `~/.gitmessage`・`~/.gitignore` を外さない。

どれも小さな修正で直る。

## Current state

関係するファイル:

- `home/.zshrc` — Linux だけが使う zsh の設定（macOS は home-manager が生成する）。
- `home/.zshenv` — Linux だけが使う環境変数の設定。
- `mise.linux.toml` — Linux の `[dotfiles]`（リンク宣言）。
- `script/linux/clean.zsh` — リポジトリへのリンクを `$HOME` から外すスクリプト（`mise run clean`）。
- `home/.config/lazygit/config.yml` — lazygit の設定。macOS と Linux で共有。
- `install` — macOS / Linux 共通のインストーラ。

`home/.zshrc:110-135`（112 行目の `eval` にガードが無い。同じファイルの sheldon・zoxide・starship は `command -v` でガードされている）:

```zsh
# --- git-wt (git worktree manager) --------
# https://github.com/k1LoW/git-wt?tab=readme-ov-file
eval "$(git wt --init zsh)"

wt() {
  local line
  line="$(git wt | tail -n +2 | fzy)" || return
  [[ -n "$line" ]] || return
  git wt "$(printf '%s\n' "$line" | awk '{print $(NF-1)}')"
}

wr() {
  # git-wt で管理されているディレクトリを fzy で選択して削除
  local line
  line="$(git wt | tail -n +2 | fzy)" || return
  [[ -n "$line" ]] || return
  local dir="$(printf '%s\n' "$line" | awk '{print $(NF-1)}')"
  git wt -d "$dir"
}

# ga <branch>: add a worktree and switch to it. gd [branch]: delete it from the main worktree.
ga() { git wt "$@"; }
gd() {
  local target="${1:-$(git branch --show-current)}"
  cd "$(git rev-parse --path-format=absolute --git-common-dir)/.." && git wt -d "$target"
}
```

ガードの手本（`home/.zshrc:104-108`）:

```zsh
# --- starship (prompt) --------------------
# Replaces pure; one config for zsh and PowerShell (home/.config/starship.toml).
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
```

git-wt の実行ファイル名は `git-wt`。

`home/.zshenv:44`（macOS 側の `nix/home-manager/tools/zsh.nix:50` は末尾に `opencode` がある）:

```zsh
export HOMEBREW_FORBIDDEN_FORMULAE="python python3 pip npm pnpm yarn claude"
```

`home/.zshenv:49-51`（50 行目は古い。enhancd はもう使っておらず、`.zshrc` は `is_agent_shell` を呼んでいない）:

```zsh
# AI agent subprocesses (Cursor, Claude Code, Codex, opencode, Gemini, …)
# Used by .zshrc to skip interactive-only sheldon plugins (enhancd).
# Export AI_AGENT=1 to force the agent side.
```

`mise.linux.toml` の lazygit の行（スクリプトの行が無い）:

```toml
# runtime-write dirs: per-file links only
"~/.config/lazygit/config.yml" = { source = "home/.config/lazygit/config.yml", mode = "symlink" }
```

`home/.config/lazygit/config.yml:28-34`（34 行目がスクリプトを呼ぶ。28 行目のコメントは古い。`mise.macos.toml` に `[dotfiles]` は無い）:

```yaml
# The script is linked via mise.macos.toml.
customCommands:
  - key: 'A'
    context: 'files'
    description: 'AI commit message → open prefilled commit panel'
    loadingText: 'Generating commit message…'
    command: '$HOME/.config/lazygit/generate-commit-msg.sh'
```

`mise.linux.toml` の古いコメント（`~/.cursor/hooks.json` の直前の 4 行。`~/.claude/settings.json` の追跡をやめたときに、説明だけが残った）:

```toml
# Claude Code plugins are declared, not vendored: ~/.claude/plugins holds git
# clones and version-stamped caches, so only the declaration is tracked here.
# Claude Code writes back through this link, so settings it manages itself
# (theme, marketplaces it adds) land in the repo as real changes.
"~/.cursor/hooks.json" = { source = "home/.cursor/hooks.json", mode = "symlink" }
```

`script/linux/clean.zsh:12-38`（32 行目は `$root/home` 配下しか見ない。`mise.linux.toml` は `extras/delta/cendre.gitconfig` と `extras/bat/cendre.tmTheme` もリンクしているので、それらが外れない。19-22 行目の走査対象に `~/.gitmessage` と `~/.gitignore` が無い）:

```zsh
# Remove every symlink under the scan roots whose target points into the
# repo's home/ tree — including dangling links. Real files and dirs
# (app runtime state) are never touched.

print -r -- "Removing symlinks pointing into $root/home ..."

local -a scan_roots=(
  "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.zshrc" "$HOME/.gitconfig"
  "$HOME/.hammerspoon" "$HOME/.config"
  "$HOME/.claude" "$HOME/.cursor" "$HOME/.copilot" "$HOME/.agents"
)

local removed=0
local p link target
for p in "${scan_roots[@]}"; do
  [[ -e $p || -L $p ]] || continue
  while IFS= read -r link; do
    target=$(readlink "$link")
    [[ $target = /* ]] || target="${link:h}/$target"
    target=${target:a}
    if [[ $target == "$root/home" || $target == "$root/home/"* ]]; then
      print -r -- "unlink: $link -> $target"
      rm "$link"
      removed=$(( removed + 1 ))
    fi
  done < <(find "$p" -maxdepth 6 -type l 2>/dev/null)
done
```

`install:65-74`（72 行目の URL は古い Linuxbrew のもの。今は現行インストーラへ転送するだけのスタブを返す）:

```bash
	# Linux: Homebrew for `mise run install-apps` (script/linux/Brewfile).
	# macOS: nix-homebrew installs it on `mise run switch` (nix/homebrew.nix).
	if [ "$uname_s" = 'Linux' ]; then
		echo ""
		if type brew >/dev/null 2>&1; then
			echo "brew is installed";
		else
			sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
		fi
	fi
```

`install` のインデントはタブ。

守る規約:

- コードにコメントは基本書かない。書くのは、マジックナンバーの根拠と、コードから読み取れない回避策の理由だけ。
- Linux / Windows では、実行時に書き込みのあるディレクトリをまるごとリンクしない。ファイル単位でエントリを書く（`~/.config/lazygit` がその例）。
- 差分は最小にする。無関係な整形をしない。

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| 整合性チェック | `mise run check` | 最終行が `check: OK`、exit 0 |
| zsh 構文 | `zsh -n home/.zshrc` | 出力なし、exit 0 |
| shellcheck | `shellcheck -S warning install` | 出力なし、exit 0 |

`mise run check` は Plan 001 で作ったタスク。無ければ STOP（Plan 001 が未完了）。

## Scope

In scope（変更してよいのはこれだけ）:

- `home/.zshrc`
- `home/.zshenv`
- `mise.linux.toml`
- `script/linux/clean.zsh`
- `home/.config/lazygit/config.yml`
- `install`

Out of scope（関係がありそうでも触らない）:

- `home/.gitconfig` — `credential.helper = osxkeychain` が Linux にもリンクされるが、macOS と共有のファイルで、直し方に判断が要る。この計画では触らない（Maintenance notes 参照）。
- `nix/` 以下すべて — macOS の設定。Linux の修正で触る理由が無い。
- `mise.windows.toml`、`script/win/`、`home-win/` — Windows は別の計画（004、005）。
- `script/linux/clean.zsh` の `prune_dirs`（42-66 行目）— 古い項目が残っているが、存在しないディレクトリは無視されるだけで害が無い。
- `home/.zshrc` のほかの節（Playdate、Keka など macOS 向けの残り）。

## Git workflow

- Branch: `advisor/002-repair-linux-path`
- コミットは Conventional Commits。例: `fix(nvim): stop dimming dotfiles in neo-tree`。説明は英語の小文字命令形で 72 文字以内。
- 論理単位ごとにコミットする。例: `fix(zsh): guard git-wt init on machines without it`、`fix(linux): link lazygit commit helper`、`fix(clean): remove links into extras and git files`
- push しない。PR も作らない。

## Steps

### Step 1: `home/.zshrc` の git-wt の節をガードする

`eval "$(git wt --init zsh)"` から `gd() { ... }` の閉じ括弧まで（抜粋の 112-135 行目）を、`if command -v git-wt >/dev/null 2>&1; then` と `fi` で囲む。中身は 4 スペース下げる（starship の節と同じ書き方）。節の見出しコメント 2 行（110-111 行目）は `if` の外に残す。関数の中身は変えない。

仕上がりの形:

```zsh
# --- git-wt (git worktree manager) --------
# https://github.com/k1LoW/git-wt?tab=readme-ov-file
if command -v git-wt >/dev/null 2>&1; then
    eval "$(git wt --init zsh)"

    wt() {
      ...
    }
    ...
    gd() {
      ...
    }
fi
```

Verify: `zsh -n home/.zshrc` → 出力なし、exit 0。続けて `grep -n 'command -v git-wt' home/.zshrc` → 1 行出る。

### Step 2: `home/.zshenv` を macOS 側に揃える

1. 44 行目の値の末尾に `opencode` を足す: `"python python3 pip npm pnpm yarn claude opencode"`
2. 50 行目 `# Used by .zshrc to skip interactive-only sheldon plugins (enhancd).` を削除する。

Verify: `zsh -n home/.zshenv` → exit 0。`grep -c enhancd home/.zshenv` → `0`。`grep -c 'claude opencode"' home/.zshenv` → `1`。

### Step 3: `mise.linux.toml` に lazygit のスクリプトを足し、古いコメントを消す

1. `"~/.config/lazygit/config.yml" = ...` の行の直後に足す。

```toml
"~/.config/lazygit/generate-commit-msg.sh" = { source = "home/.config/lazygit/generate-commit-msg.sh", mode = "symlink" }
```

2. `"~/.cursor/hooks.json" = ...` の直前にある 4 行のコメント（`# Claude Code plugins are declared, not vendored:` で始まり `# (theme, marketplaces it adds) land in the repo as real changes.` で終わる）を削除する。`"~/.cursor/hooks.json"` の行そのものは残す。

Verify: `mise run check` → `check: OK`。`grep -c 'generate-commit-msg.sh' mise.linux.toml` → `1`。`grep -c 'Claude Code plugins are declared' mise.linux.toml` → `0`。

### Step 4: `home/.config/lazygit/config.yml` の古いコメントを消す

28 行目 `# The script is linked via mise.macos.toml.` を削除する。ほかの行は変えない。

Verify: `grep -c 'mise.macos.toml' home/.config/lazygit/config.yml` → `0`

### Step 5: `script/linux/clean.zsh` の取りこぼしを直す

1. 12-14 行目のコメントの `repo's home/ tree` を `repo` に変える（「リポジトリ全体」を指すように）。
2. 16 行目を `print -r -- "Removing symlinks pointing into $root ..."` にする。
3. `scan_roots` の 1 行目に `"$HOME/.gitmessage" "$HOME/.gitignore"` を足す。行が長くなるので、次の形にする。

```zsh
local -a scan_roots=(
  "$HOME/.zshenv" "$HOME/.zprofile" "$HOME/.zshrc"
  "$HOME/.gitconfig" "$HOME/.gitmessage" "$HOME/.gitignore"
  "$HOME/.hammerspoon" "$HOME/.config"
  "$HOME/.claude" "$HOME/.cursor" "$HOME/.copilot" "$HOME/.agents"
)
```

4. 32 行目の条件を、リポジトリ全体に広げる。

```zsh
    if [[ $target == "$root" || $target == "$root/"* ]]; then
```

`"$root/"*` の末尾のスラッシュは必ず残す。無いと `dotfiles-wt` のような隣のディレクトリまで一致する。

Verify: 次のテストを実行する（一時ディレクトリを `$HOME` に見立てるので、本物のホームには触れない）。

```bash
t=$(mktemp -d) && mkdir -p "$t/.config/delta" \
  && ln -s "$PWD/home/.gitmessage" "$t/.gitmessage" \
  && ln -s "$PWD/extras/delta/cendre.gitconfig" "$t/.config/delta/cendre.gitconfig" \
  && ln -s /etc/hosts "$t/.config/foreign" \
  && HOME="$t" zsh script/linux/clean.zsh \
  && ls -A "$t" "$t/.config"
```

期待する出力: `unlink:` の行が 2 つ（`.gitmessage` と `cendre.gitconfig`）、`Done (2 symlink(s) removed).`、そして `ls` の結果に `foreign` が残り、`.gitmessage` が無い。終わったら `rm -rf "$t"` で消す。

### Step 6: `install` の Homebrew の URL を現行のものにする

72 行目を次に置き換える（インデントはタブ 3 つのまま）。

```bash
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify: `shellcheck -S warning install` → 出力なし。`bash -n install` → exit 0。`grep -c Linuxbrew install` → `0`。

### Step 7: 全体を確認する

Verify: `mise run check` → 最終行 `check: OK`、exit 0

## Test plan

テストフレームワークは無い。検証は次の 3 つで行う。

- `mise run check`（zsh の構文、shellcheck、リンク元の存在）。
- Step 5 の一時ディレクトリを使った `clean.zsh` の動作テスト。リポジトリ内へのリンクだけが外れ、外部へのリンクが残ることを確かめる。
- Linux 実機での確認は、この計画ではできない。完了報告に「Linux 実機は未確認」と書く。

## Done criteria

すべて満たすこと。

- [ ] `mise run check` が exit 0 で、最終行が `check: OK`
- [ ] `grep -c 'command -v git-wt' home/.zshrc` が `1`
- [ ] `grep -c 'generate-commit-msg.sh' mise.linux.toml` が `1`
- [ ] Step 5 のテストが期待どおり（2 件を unlink、`foreign` が残る）
- [ ] `grep -c Linuxbrew install` が `0`
- [ ] `git diff --stat 6e8371d -- nix home/.gitconfig mise.windows.toml script/win home-win` が空
- [ ] `git status --short` に出るのが In scope のファイルだけ（`home/.config/cloudflare/` は元からある未追跡ディレクトリなので無視する）
- [ ] `plans/README.md` の Status を更新した

## STOP conditions

次のどれかに当てはまったら、止まって報告する。

- `mise run check` というタスクが無い（Plan 001 が未完了）。
- 「Current state」の抜粋と現物が食い違っている（Plan 001 による `mise.linux.toml` の変更を除く）。
- Step 5 のテストで、`foreign`（リポジトリ外へのリンク）が消える。条件式が広すぎる。
- 修正に `home/.gitconfig` か `nix/` の変更が必要だと感じる。
- 同じ Verify が、妥当な修正を試しても 2 回失敗する。

## Maintenance notes

- `home/.zshrc` は `nix/home-manager/tools/*.nix` の zsh 設定を手で写したもの。macOS 側でツールの関数を変えたら、Linux 側にも反映が要る（例: `tools/git-wt.nix` の `wtt` は `.zshrc` に無い）。
- 見送ったこと（判断が要る）: `home/.gitconfig:37-38` の `credential.helper = osxkeychain`。Linux では存在しないヘルパーなので、HTTPS 認証のたびに「`credential-osxkeychain` is not a git command」という警告が出る。動作は続く。直すなら、macOS だけで読まれる別ファイルに分けて include する方法がある。
- 見送ったこと: `script/linux/clean.zsh` の `prune_dirs` の整理。害が無いので残した。
- レビューで見てほしい点: Step 5 の条件式の末尾スラッシュと、Step 1 で関数の中身が変わっていないこと（インデントだけの差分になる）。
