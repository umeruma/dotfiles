---
description: "Global personal preferences for all projects"
applyTo: "**"
---

- 返答は常に日本語で行う
- 不明瞭な指示は質問して明確にする

## 作業

- Webプロジェクトの実行/ビルドは `mise run ...` を正として扱う
- git worktree の指定がない限り、基本は現在の作業ツリーで進める
- 現在の作業ツリーが main なら、その main 上で作業を続行する
- 別 worktree が必要なケースだけ、必要性を確認または提案する

## コード設計

- 関心の分離を保つ
- 状態とロジックを分離する
- 可読性と保守性を重視する
- コントラクト層（API/型）を厳密に定義し、実装層は再生成可能に保つ
