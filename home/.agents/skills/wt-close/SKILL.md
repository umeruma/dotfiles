---
name: wt-close
description: "Use when finishing work in a git-wt worktree: stop the servers, daemons and background tasks running from it, check it is safe to delete, then delete the worktree and close its Rex tab via `wtt close` with a [Y/n] prompt. Use for: wt閉じる, worktree片付け, 作業終わったのでworktree削除, タブ閉じて, wtt close, wt-close."
argument-hint: "[optional: worktree path or branch; defaults to the session's worktree]"
---

# Close Worktree

git-wt の worktree での作業を終えるときに、後始末をしてから **worktree の削除と Rex タブのクローズ** を行う。

最後の削除とクローズは、シェル関数 `wtt close`（dotfiles `nix/home-manager/tools/git-wt.nix`）に任せる。
`wtt close` は `[Y/n]` で確認し（Enter = Yes）、`gd`（安全な `git wt -d`）が成功したときだけタブを閉じる。

## 前提

- 対象はリンクされた worktree。メインチェックアウトでは使わない
- プロジェクトの種類（Web / CLI / ライブラリなど）は問わない
- Rex 上で動いていること（`$REX_BLOCK` がある）。ない場合は手順 4 の代わりに、ユーザーに `wtt close` か `gd` を手で実行してもらう

## Procedure

### 1. 対象を決める

1. 引数の path / branch
2. セッションの作業ディレクトリ（primary working directory）

`git rev-parse --path-format=absolute --git-dir` と `--git-common-dir` が同じならメインチェックアウトなので中止する。

既定ブランチ（以下 `<default>`）は `git symbolic-ref --short refs/remotes/origin/HEAD`（`origin/` を外す）で取る。取れなければ、メインチェックアウトのブランチを使う。

### 2. 消してよい状態か確認する

対象 worktree で次を確認し、結果をユーザーに伝える。

| 確認 | コマンド | 該当したら |
|------|---------|-----------|
| 未コミットの変更 | `git status --porcelain` | **中止**して内容を伝える（`git wt -d` も止まる） |
| `<default>` に未マージ | `git merge-base --is-ancestor HEAD <default>` が失敗 | 続行してよいが「ブランチは残る」と伝える |
| 未 push | upstream があれば `git log --oneline @{u}..` | 続行してよいが件数を伝える |

### 3. この worktree で動いているものを止める

タブを閉じても止まらないもの（バックグラウンドで常駐するサーバーやデーモン）があるので、先に止める。
止めずに削除すると、`wt.remover trash` の場合はプロセスが `~/.Trash/<name>` を cwd にしたまま残り続ける。

1. **自分が起動したもの**: このセッションで起動したバックグラウンドタスクを止める（Claude Code なら TaskStop）
2. **自前の停止コマンドがあるもの**: 起動時の出力やツールのヘルプに停止方法があれば、それで止める（例: `<tool> stop`、`docker compose down`）。
   pid ファイルやロックを片付けてくれるので kill より安全
3. **残りを cwd で探す**: 対象 worktree 配下を cwd に持つプロセスを洗い出す

```sh
WT=<worktree の絶対パス>
for p in $(pgrep -u "$(id -u)" .); do
  lsof -a -p "$p" -d cwd -Fn 2>/dev/null | grep -q "^n$WT" && echo "$p $(ps -o command= -p "$p" | cut -c1-100)"
done
```

洗い出したものの扱い:

- サーバー・ウォッチャー・デーモン（ポートを LISTEN している、`dev` / `watch` / `serve` などで起動されたもの）→ kill してよい
- ユーザーのシェル、エディタ、lazygit などの対話ツール、自分自身（このセッション）→ **触らない**。タブを閉じれば一緒に終わる
- 判断がつかないもの → 一覧をユーザーに見せて確認する

他の worktree やメインチェックアウトのプロセスには触らない。

### 4. 削除とクローズ（最後の 1 手）

まず手順 2・3 の結果を報告する。報告し終えてから、**最後のツール呼び出し**として自分のタブを分割し、そこで `wtt close` を実行する。

```sh
rex split -b "$REX_BLOCK" -c "<worktree の絶対パス>" --split=below -- zsh -ic 'wtt close'
```

- `zsh -ic` は必須。split のコマンドはログインシェル環境で動き、`.zshrc` で入る `rex` の PATH と `wtt` 関数がないため
- 自分のブロック（`$REX_BLOCK`）に `rex send` しない。Claude の入力欄に文字が入るだけになる
- 新しいペインにフォーカスが移る。ユーザーが Enter を押すと worktree が消え、**このセッションごとタブが閉じる**
- `n` と答えればペインが消えるだけで何も起きない

呼び出した後は「Enter で worktree を削除してタブを閉じます」と 1 行だけ伝えて終える。

## 注意

- コミット・push・マージはこのスキルではしない。必要なら手順 2 の結果を見てユーザーに確認する
- `git wt -d` が未コミットの変更で止まった場合、タブは開いたまま残る
