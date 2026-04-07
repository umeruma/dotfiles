---
name: commit
description: "Use when the user runs /commit or asks to create a git commit automatically from current changes following this repository conventions."
---

# /commit

このスキルは、現在の変更からコミット規則に沿ったコミットを自動で作成する。

## コミット規則

1. 英語で書く
2. Conventional Commits の形式に従う: `<type>(<scope>): <description>`

### タイプ一覧

| タイプ       | 使うタイミング                                       |
| :----------- | :--------------------------------------------------- |
| `feat`       | 新機能の追加                                         |
| `fix`        | バグ修正                                             |
| `docs`       | ドキュメントのみの変更                               |
| `style`      | フォーマット修正など（ロジック変更なし）             |
| `refactor`   | バグ修正でも機能追加でもないコード変更               |
| `perf`       | パフォーマンス改善                                   |
| `test`       | テストの追加・更新                                   |
| `chore`      | ビルド、依存関係更新、ツール設定変更                 |
| `ci`         | CI/CD 設定の変更                                     |

### ルール

- description は命令形で書く（"add"、"added" や "adds" は使わない）。
- description は 72 文字以内に収める。
- 関連する Issue がある場合はフッターに記載する: `Fixes #123`

### 例

```
feat(layout): add responsive header component
fix(store): resolve hydration mismatch in AppStore
docs: add PostCSS usage guide to README
chore(deps): update astro to v6.1.0
refactor(animations): extract easing constants to separate file
```

## Workflow

1. `git status --short` で変更を確認。
2. `git diff --staged` と `git diff` を見て要約を作る。
3. 上記コミット規則に沿うコミットタイトルを1つ決める。
4. ステージされていない変更があれば `git add -A`。
5. `git commit -m "<title>"` を実行。
6. 実行結果（コミットハッシュとタイトル）を返す。

## Fallback

- 変更がない場合はコミットしないで「No changes to commit」を返す。
- 規則に適合しない場合は、修正した候補タイトルを提示してから実行する。
