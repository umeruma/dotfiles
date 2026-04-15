---
name: dev-server
description: "Use when starting the dev server (mise run dev) in the current git worktree. Use for: devサーバー起動, worktreeでdev, ブランチのdev確認, mise run dev in worktree, feature branchで動作確認."
argument-hint: "[worktree branch name]"
---

# Dev Server in Worktree

worktree 環境で `mise run dev` を正しく起動するワークフロー。

## 注意事項

`run_in_terminal` の `isBackground=true` はツールが `cd` を省略し、常にワークスペースルートから起動する。そのため **worktree での起動には必ず `isBackground=false` を使う**。

サーバーが起動するとエージェントはブロックされるが、ユーザーが確認後に Ctrl+C で停止すれば自動的に再開するため問題ない。

また、wt コマンドで node_modulesはコピーされないため、worktree での起動前にルートで一度 `bun install` を実行しておく必要がある。

## Procedure

### 1. 作業中の worktree パスを特定する

```sh
git wt --json
```

現在編集中のファイルパスか、直近の作業コンテキストから対象の worktree ディレクトリを特定する。
例: `/path/to/repo/.wt/<branch-name>/`

### 2. `isBackground=false` でサーバーを起動する

```sh
cd <worktree-path> && mise run dev
```

ユーザーが確認を終えて Ctrl+C でサーバーを停止すると、エージェントは次のステップへ進む。
