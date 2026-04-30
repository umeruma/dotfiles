---
name: wt
description: "git wt（k1LoW/git-wt）を使ってgit worktreeを作成・切り替え・削除するワークフロー。Use when: worktreeで並行作業する, ブランチを切り替える, feature branch per task, worktree管理, 並列タスク実行, git worktree list/add/remove。エージェントが複数ブランチを横断して自律的にタスクを実行する場合にも使用する。"
argument-hint: "<branch|worktree|path> | list | delete"
---

# git-wt ワークフロー

`git wt`（[k1LoW/git-wt](https://github.com/k1LoW/git-wt)）は `git worktree` をシンプルに扱うための Git サブコマンド。

## When to Use

- 「ブランチ X で実装して」と依頼されたとき
- 複数ブランチ・タスクを 並行して 進めるとき
- 現在の作業を捨てずに別ブランチを覗きたいとき
- worktree の一覧確認・クリーンアップをするとき

---

## コマンドリファレンス

```sh
# 一覧表示
git wt                            # 全 worktree を表示
git wt --json                     # JSON 形式で表示

# 切り替え / 作成（ブランチ・worktree がなければ自動作成）
git wt <branch>                   # ブランチ名で切り替え
git wt <worktree-folder-name>     # .git/wt/ 内のフォルダ名で切り替え
git wt <path>                     # 絶対 / 相対パスで切り替え

# 削除（safe: デフォルトブランチは保護される）
git wt -d <branch|path>           # worktree + ブランチを削除
git wt -D <branch|path>           # 強制削除
```

## 即実行ルール

- ユーザーが `/wt <branch|worktree|path>` のように対象を明示したら、一覧確認や存在確認を先に挟まず `git wt <target>` を最優先で実行する
- `git wt <target>` は既存 worktree への切り替えと、未作成時の新規作成を兼ねる前提で扱う
- 一覧確認のための `git wt` は、対象が曖昧なとき、削除候補を見たいとき、または `git wt <target>` が失敗したときだけ行う
- エージェントは「まず一覧を見る」より「まず切り替えを試す」を基本動作にする

---

## エージェント向けワークフロー

機能ブランチに閉じたタスクを実行するときの推奨手順：

1. 切り替え / 作成 — 対象が明示されているなら、まず `git wt <branch>` で対象ブランチへ移動（なければ自動作成）
2. 現在地確認 — 必要な場合にだけ `git wt` で worktree 一覧を確認
3. 作業 — コード変更・テスト・コミットをその worktree で実施
4. 別タスクへ — `git wt <other-branch>` で別 worktree へ切り替え（現在の変更は保持）
5. 完了後クリーンアップ — マージ済みなら `git wt -d <branch>` で削除

> ポイント: `git wt` は worktree 間の `cd` を自動で行う（Shell Integration が必要。後述）。  
> エージェントが `run_in_terminal` でコマンドを実行する場合は、パスを明示的に変更するか `--nocd` でパスを取得してから `cd` すること。
- worktree を閉じる前に、対象ブランチは non-fast-forward merge で取り込むことを推奨（`git merge --no-ff <branch>`）

---

## 推奨設定

### zsh Shell Integration セットアップ

`~/.zshrc` に追加することで、`git wt <branch>` が worktree へ自動 `cd` できるようになる。

```sh
eval "$(git wt --init zsh)"
```

> `--nocd` を付けると `cd` なし・補完のみになる:  
> `eval "$(git wt --init zsh --nocd)"`

### 新規 worktree 作成時に依存をインストール（hook 例）

```sh
# Node.js プロジェクト
git config --add wt.hook "bun install"

# Go プロジェクト
git config --add wt.hook "go mod download"
```

### .gitignore ファイルを新 worktree にコピー

```sh
git config wt.copyignored true  # .env など全て
# または特定ファイルのみ
git config --add wt.copy ".env"
git config --add wt.copy ".vscode/"
```

---

## レシピ

### fzf でインタラクティブ選択（zsh/bash）

```sh
cd $(git wt | fzf --header-lines=1 | awk '{if ($1 == "*") print $2; else print $1}')
```

### tmux: 新 worktree を新ウィンドウで開く

```sh
git config wt.nocd create
git config --add wt.hook 'tmux neww -c "$PWD" -n "$(basename -s .git `git remote get-url origin`):$(git branch --show-current)"'
```

### 削除前にリモートブランチも消す

```sh
git config --add wt.deletehook "git push origin --delete $(git branch --show-current)"
```
