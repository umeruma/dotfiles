# Plan 004: Windows の lazygit コミットメッセージ生成に、改行を保った diff を渡す

> Executor instructions: この計画を上から順に実行する。各ステップの Verify を実行し、
> 期待どおりの結果を確認してから次へ進む。「STOP conditions」に当てはまったら、
> 自分で工夫せずに止まって報告する。完了したら `plans/README.md` の該当行の
> Status を更新する（レビュアーから「索引は自分が管理する」と言われた場合を除く）。
>
> Drift check（最初に実行）:
> `git diff --stat 6e8371d..HEAD -- home-win/.config/lazygit/generate-commit-msg.ps1`
> 変更が出たら「Current state」の抜粋と現物を見比べ、食い違っていれば STOP。

## Status

- Priority: P2
- Effort: S
- Risk: LOW
- Depends on: none
- Category: bug
- Planned at: commit `6e8371d`, 2026-11-11

## Why this matters

Windows の lazygit で `A` を押すと、ステージ済みの diff を AI（cursor-agent）に渡してコミットメッセージを作る。ところが、PowerShell は外部コマンドの出力を「行ごとの配列」として受け取るので、いまのスクリプトでは次の 2 つが起きている。

- diff が 1 行に潰れて AI に渡る（配列を文字列に埋め込むと、空白でつながる）。
- 24000 文字で切り詰める処理が効かない（`.Length` が文字数ではなく行数になる）。大きな diff は Windows のコマンドライン長の上限を超え、起動に失敗する。

計画作成時に、macOS 上の PowerShell 7.6 で再現を確認した。3 行のファイルをステージすると、AI に渡るプロンプトの末尾が `diff --git a/a.txt b/a.txt new file mode 100644 ... +one +two +three` という 1 行になる。

## Current state

関係するファイル:

- `home-win/.config/lazygit/generate-commit-msg.ps1` — Windows 用のコミットメッセージ生成スクリプト。lazygit の `A` から呼ばれる。
- `home/.config/lazygit/generate-commit-msg.sh` — macOS / Linux 用の同等のスクリプト。こちらは正しく動いている。読むだけ。

`home-win/.config/lazygit/generate-commit-msg.ps1:26-30`（直す箇所）:

```powershell
$stat = git diff --cached --stat
$diff = git diff --cached
if ($diff.Length -gt 24000) {
  $diff = $diff.Substring(0, 24000) + "`n`n[staged diff truncated]"
}
```

同ファイル `45-50` 行目（`$stat` と `$diff` をヒアストリングに埋め込んでいる。ここは変えない）:

```powershell
staged --stat:
$stat

staged diff:
$diff
"@
```

同ファイル `54-55` 行目（プロンプトを最後の引数として渡している。ここも変えない）:

```powershell
  $rawOut = & $agent.Source -p --mode ask --output-format text --trust `
    --model composer-2.5-fast -- $prompt 2>$errFile
```

同じ内容の bash 版（`home/.config/lazygit/generate-commit-msg.sh:42-47`）。目指す挙動はこれと同じ:

```bash
STAT=$(git diff --cached --stat)
DIFF=$(git diff --cached)
if [ "${#DIFF}" -gt 24000 ]; then
  DIFF=${DIFF:0:24000} # not `| head -c`: SIGPIPE + pipefail exits 141
  DIFF+=$'\n\n[staged diff truncated]'
fi
```

スクリプトの流れ（テストの理解に必要な分）:

1. `cursor-agent`（無ければ `agent`）というコマンドを PATH から探す。
2. ステージ済みの変更が無ければ、エラーで終わる。
3. プロンプトを組み立てて、エージェントに渡す。
4. 出力から Conventional Commits 形式の行を取り出し、`.git/LAZYGIT_PENDING_COMMIT` に書く。
5. 環境変数 `NVIM` が無ければ、「Commit message written. Press c to open the commit panel.」と表示して exit 1 で終わる（lazygit がポップアップに出すための、正常な終わり方）。

守る規約:

- コードにコメントは基本書かない。書くのは、コードから読み取れない回避策の理由だけ。
- 差分は最小にする。無関係な整形をしない。

## Commands you will need

macOS には PowerShell が入っていないので、Nix から一時的に実行する（リポジトリには何も書き込まれない）。

| Purpose | Command | Expected on success |
|---|---|---|
| PowerShell の起動確認 | `nix run --inputs-from . nixpkgs#powershell -- -NoProfile -Command '$PSVersionTable.PSVersion.Major'` | `7` |
| 動作テスト | 下の「Test plan」のスクリプト | 「Test plan」に書いた出力 |

初回の `nix run` は、PowerShell のダウンロードに数十秒かかる。

## Scope

In scope（変更してよいのはこれだけ）:

- `home-win/.config/lazygit/generate-commit-msg.ps1`（26-30 行目だけ）

Out of scope（関係がありそうでも触らない）:

- `home/.config/lazygit/generate-commit-msg.sh` — 正しく動いている。
- プロンプトを引数ではなく標準入力で渡す変更 — cursor-agent 側の対応を Windows 実機で確かめる必要がある。この計画ではやらない。
- 生成器を `claude` に替える変更 — 持ち主の判断が要る。
- スクリプトのほかの部分（出力の解析、nvim への `c` の注入）。
- テスト用のファイルをリポジトリに足すこと。テストは一時ディレクトリだけで行う。

## Git workflow

- Branch: `advisor/004-fix-windows-commit-helper`
- コミットは Conventional Commits。例（`git log` より）: `fix(nvim): stop dimming dotfiles in neo-tree`。説明は英語の小文字命令形で 72 文字以内。
- この計画のコミット例: `fix(lazygit): keep newlines in the staged diff on windows`
- push しない。PR も作らない。

## Steps

### Step 1: 修正前の挙動を再現する

「Test plan」のスクリプトを、修正前のコードに対して実行する。

Verify: 出力に `lines with +two alone: 0` が出る（バグが再現している）。`0` 以外が出たら STOP（すでに直っているか、環境が違う）。

### Step 2: 出力を 1 つの文字列として受け取る

`home-win/.config/lazygit/generate-commit-msg.ps1` の 26-27 行目を、次に置き換える。28-30 行目（切り詰め）は変えない。

```powershell
$stat = (git diff --cached --stat | Out-String).TrimEnd()
$diff = (git diff --cached | Out-String).TrimEnd()
```

`Out-String` は行を改行でつないで 1 つの文字列にする。これで、続く `.Length` は文字数になり、`.Substring` も文字列に対して働く。

Verify: `sed -n 26,30p home-win/.config/lazygit/generate-commit-msg.ps1` → 上の 2 行に続いて、変更していない `if ($diff.Length -gt 24000) {` からの 3 行が出る。

### Step 3: 修正後の挙動を確かめる

「Test plan」のスクリプトをもう一度実行する。

Verify: 出力に `lines with +two alone: 1` と `truncated marker: 1` が出る。

## Test plan

このリポジトリにテストフレームワークは無い。偽の `cursor-agent`（渡されたプロンプトをファイルに書き出すだけのシェルスクリプト）を一時ディレクトリに置き、実際のスクリプトを PowerShell で動かして確かめる。リポジトリには何も足さない。

次のスクリプトを、リポジトリのルートで実行する。

```bash
REPO=$PWD
T=$(mktemp -d)
mkdir -p "$T/bin" "$T/small" "$T/big"
cat > "$T/bin/cursor-agent" <<'EOF'
#!/bin/sh
for a in "$@"; do last=$a; done
printf '%s' "$last" > "$CAPTURE"
echo "fix(test): capture prompt"
EOF
chmod +x "$T/bin/cursor-agent"

run() {
  ( cd "$1" && env -u NVIM CAPTURE="$2" PATH="$T/bin:$PATH" \
      nix run --inputs-from "$REPO" nixpkgs#powershell -- -NoProfile \
      -File "$REPO/home-win/.config/lazygit/generate-commit-msg.ps1" ) >/dev/null 2>&1 || true
}

( cd "$T/small" && git init -q . && printf 'one\ntwo\nthree\n' > a.txt && git add a.txt )
run "$T/small" "$T/small.txt"
echo "lines with +two alone: $(grep -c '^+two$' "$T/small.txt")"

( cd "$T/big" && git init -q . && seq 1 9000 > b.txt && git add b.txt )
run "$T/big" "$T/big.txt"
echo "truncated marker: $(grep -c '^\[staged diff truncated\]$' "$T/big.txt")"
echo "big prompt chars: $(wc -c < "$T/big.txt" | tr -d ' ')"

rm -rf "$T"
```

期待する出力:

| 項目 | 修正前 | 修正後 |
|---|---|---|
| `lines with +two alone` | `0` | `1` |
| `truncated marker` | `0`（プロンプトのファイルができず、grep がエラーを出すこともある） | `1` |
| `big prompt chars` | 不定 | 24000 より大きく 26000 より小さい |

スクリプトが exit 1 で終わるのは正常（「Press c ...」を lazygit に表示させるため）。だから `run` は終了コードを無視している。

## Done criteria

すべて満たすこと。

- [ ] 「Test plan」のスクリプトが `lines with +two alone: 1` を出す
- [ ] 「Test plan」のスクリプトが `truncated marker: 1` を出す
- [ ] `big prompt chars` が 24000 より大きく 26000 より小さい
- [ ] `git diff --stat` に出るのが `home-win/.config/lazygit/generate-commit-msg.ps1` だけで、変更が 2 行の置き換えに収まっている
- [ ] `git status --short` に、テスト用のファイルが残っていない（`home/.config/cloudflare/` は元からある未追跡ディレクトリなので無視する）
- [ ] `plans/README.md` の Status を更新した

## STOP conditions

次のどれかに当てはまったら、止まって報告する。

- 26-30 行目が「Current state」の抜粋と違う。
- Step 1 で `lines with +two alone: 0` にならない（修正前なのにバグが再現しない）。
- `nix run --inputs-from . nixpkgs#powershell` が動かない（Nix が無い、ネットワークに出られない）。静的な確認だけで完了にしない。
- 修正後も `truncated marker` が `1` にならない。
- 同じ Verify が、妥当な修正を試しても 2 回失敗する。

## Maintenance notes

- テストは macOS 上の PowerShell で行っている。Windows 実機との違いは、改行コードが CRLF になりうる点。`Out-String` は行を環境の改行でつなぐので、Windows では CRLF になるが、AI に渡すテキストとしては問題ない。Windows 実機で `A` を一度試すとよい。
- 見送ったこと: プロンプトを標準入力で渡す変更。切り詰めが効くようになったので、プロンプトは 26000 文字未満に収まり、Windows のコマンドライン長の上限（32767 文字）を超えない。stat の部分が極端に長い（数千ファイルを一度にステージする）ときだけ上限に近づく。
- bash 版（`generate-commit-msg.sh`）と PowerShell 版は別々に手で保守している。片方のプロンプトを変えたら、もう片方も合わせる。
