---
name: dev-server
description: "Use when starting the dev server with mise run dev in the current git worktree. Prefer inferring the target path from the active file or recent worktree context so the user does not need to remember the worktree path every time. Use for: devサーバー起動, worktreeでdev, person-newでdev, feature branchでdev確認, 現在のworktreeでdev, mise run dev in worktree."
argument-hint: "[optional: branch name or worktree name]"
---

# Dev Server in Worktree

worktree 環境で `mise run dev` を正しく起動するワークフロー。

## 目的

毎回 worktree のパスを手で指定しなくてよいようにする。
また、同じ worktree ですでに VS Code terminal 上の dev server が起動しているなら、
新しい terminal を増やさず **既存 terminal を再利用する**。
基本方針は以下。

1. まず **現在編集中のファイルのパス** から worktree を推定する
2. 同じ worktree の dev server が既存 terminal で動いていないか確認する
3. それで決まらない場合だけ **直近の作業コンテキスト** や引数の branch 名を使う
4. 最後に `git wt --json` で対応する path を確認する

つまり、ユーザーが `/dev-server person-new` と言わなくても、
「今 `/.git/wt/person-new/` 配下のファイルを触っている」ならその worktree を使う。

## 注意事項

`run_in_terminal` の `isBackground=true` はツールが `cd` を省略し、常にワークスペースルートから起動する。そのため **worktree での起動には必ず `isBackground=false` を使う**。

ただし、**同じ worktree の既存 terminal で `mise run dev` がすでに起動中なら、新しい terminal を作らない**。
見えている terminal だけでなく、直近にエージェントが起動した hidden terminal も再利用候補とする。

サーバーが起動するとエージェントはブロックされるが、ユーザーが確認後に Ctrl+C で停止すれば自動的に再開するため問題ない。

また、wt コマンドで node_modulesはコピーされないため、worktree での起動前にルートで一度 `bun install` を実行しておく必要がある。

## Procedure

### 1. 作業中の worktree パスを特定する

優先順位は次のとおり。

1. **アクティブファイルの絶対パス**
	- 例: `/repo/.git/wt/person-new/src/...` なら worktree は `/repo/.git/wt/person-new`
2. **直近の作業コンテキスト**
	- 直前にその worktree で build / dev / edit をしていれば、その path を使う
3. **スキル引数**
	- branch 名や worktree 名が渡されている場合はそれを使う
4. **`git wt --json`**
	- 上記で曖昧なら一覧から path を特定する

```sh
git wt --json
```

現在編集中のファイルパスか、直近の作業コンテキストから対象の worktree ディレクトリを特定する。
例: `/path/to/repo/.git/wt/<branch-name>/`

アクティブファイルが worktree 配下にあるなら、**原則としてその path をそのまま使う**。

### 2. 既存 terminal の再利用を優先する

対象 worktree path が決まったら、**新しく起動する前に** VS Code 上の既存 terminal を確認する。

優先順位は次のとおり。

1. **同じ worktree path で起動済みの persistent terminal**
	- 直前に `cd <same-worktree> && mise run dev` を実行している terminal があればそれを使う
	- その terminal の出力を確認し、サーバーが待受中なら **新規起動しない**
2. **VS Code 上で見えている terminal の作業ディレクトリ / 最終コマンド**
	- cwd が同じ worktree、かつ `mise run dev` や `astro dev` が動いていれば再利用する
3. **上記に一致しない場合のみ、新規 terminal で起動する**

判定ルール:

- `cwd == <worktree-path>` または `cd <worktree-path> && mise run dev` の履歴がある
- 出力に `astro ... ready` や `watching for file changes` がある
- その場合は「既存サーバーを利用中」とみなし、新しい terminal を増やさない

### 3. 必要な場合だけ `isBackground=false` でサーバーを起動する

```sh
cd <worktree-path> && mise run dev
```

ユーザーが確認を終えて Ctrl+C でサーバーを停止すると、エージェントは次のステップへ進む。

## 実行テンプレート

最終的にやることはこれだけ。

```sh
cd <active-or-resolved-worktree-path> && mise run dev
```

ただし、同じ worktree の既存 terminal がすでに生きているなら、
**起動ではなく既存 terminal の参照を優先する**。
