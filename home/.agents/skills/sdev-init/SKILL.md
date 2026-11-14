---
name: sdev-init
description: "Use when introducing azu/sdev (spec-driven development toolkit) into the current project: install the pinned launcher or a mise tool entry, set the document languages, and point AGENTS.md at `sdev help`. Use for: sdev入れて, sdev導入, SDDを始めたい, spec駆動にしたい, sdev init."
argument-hint: "[optional: mise | bin] [optional: languages, e.g. ja or en+ja]"
---

# sdev init

[azu/sdev](https://github.com/azu/sdev) を今のプロジェクトに入れる。sdev は Product / Requirements / Design の書き方ガイドとテンプレートを CLI で出し、エージェントは `AGENTS.md` の指示から `sdev help` を読む。

手順の正は sdev の README と `docs/engineering/guidelines/releasing.md`。ここと食い違ったら、そちらに従う。

## 1. 確認する

- プロジェクトのルートにいること（`git rev-parse --show-toplevel`）
- `bin/sdev`・`sdev.toml`・mise.toml の `github:azu/sdev` がすでにあれば、導入済みなので中止して伝える
- 他人のリポジトリやチームのリポジトリなら、ファイルを足してよいか先に聞く

## 2. 入れ方と言語を決める

引数で決まっていなければ、まとめて1回で聞く。

- 入れ方
  - `bin`（既定）: `bin/sdev` ランチャーをコミットする。mise がない人や CI でも動く
  - `mise`: プロジェクトが mise.toml を使っているときの候補。`bin/sdev` と `sdev init` は不要
- 言語: 既定言語と翻訳言語（例: `ja` だけ、`en` + `ja`）

## 3. 入れる

### bin

```sh
curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/azu/sdev/main/install.sh | sh -s -- --init
```

`bin/sdev`・`AGENTS.md`（既存の内容は残る）・`sdev.toml`・`.gitignore` ができる。`sdev.toml` の `language` と `translations` を手順 2 の言語に書き換える。

### mise

releasing.md の「Install with mise」の `[tools."github:azu/sdev"]` と platforms を mise.toml に足す。version は `gh release view -R azu/sdev --json tagName` の最新にする。

```sh
mise trust
mise lock --platform macos-arm64,macos-x64,linux-arm64,linux-x64,windows-x64
mise install --locked
mise exec -- sdev help
```

`sdev.toml` を手で作り、`language` と `translations` を書く。`AGENTS.md` に、仕様や実装に取りかかる前に `mise exec -- sdev help` を読んで該当ガイドを選ぶよう1段落足す。

## 4. 終える

- `./bin/sdev help`（mise なら `mise exec -- sdev help`）が動くことを確かめる
- 既存コードがあるプロジェクトなら、仕様は `sdev help brownfield` から始めると伝える
- コミットはしない。追加・変更したファイルを一覧で伝える
