---
title: Decisions
description: やめたもの・見送ったものと、その理由
sidebar:
  order: 8
---

試したけれどやめたもの、検討したけれど見送ったものを残す。消したものにはコメントを書く場所がないので、ここに書く。同じ提案を繰り返さないための記録。

今あるものの理由はそのファイルのコメントに、エージェント向けのルールは [AGENTS.md](https://github.com/umeruma/dotfiles/blob/main/AGENTS.md) に書く。

## Packages

- **Brewfile → `[bootstrap.packages]`（見送り）**: `brew bundle add` / `brew bundle cleanup` で追加・追跡するワークフローを残したい。TOML に移すとこれがなくなる。詳細は [mise bootstrap](/mise-bootstrap)。
- **`Brewfile.lock.json`**: Homebrew 7 から読み書きされなくなったので削除。（[3327221](https://github.com/umeruma/dotfiles/commit/3327221)）
- **Brewfile の mise**: mise は bootstrap の途中で `curl https://mise.run | sh` で入れるので、Brewfile からは外した。（[e3e71b1](https://github.com/umeruma/dotfiles/commit/e3e71b1)）
- **`win/apps.winget`（winget DSC）**: mise 2026.9.3 で winget が `[bootstrap.packages]` に対応したので、`mise.windows.toml` に移した。Brewfile と同じく opt-in。（[5f1e66c](https://github.com/umeruma/dotfiles/commit/5f1e66c)）

## Apps

- **AltTab**: 使い始めた DockDoor Pro に同じ機能があるので外した。（[51e3a06](https://github.com/umeruma/dotfiles/commit/51e3a06)）
- **Bartender**: 弊害が大きく、使わない方がメリットが多いと判断した。（[c59241f](https://github.com/umeruma/dotfiles/commit/c59241f)）
- **Elgato Wave XLR / Wave Link**: 使うのをやめ、オーディオインターフェースを常駐アプリが不要な Zoom AMS-22 に替えた。Wave XLR は PC スイッチャーで切り替えると、色設定がおかしくなったり音量がリセットされたりした。Wave Link は OS 側で入出力を切り替えたうえで、Wave Link 上でも出力を切り替える必要があり、二度手間だった。（[3327221](https://github.com/umeruma/dotfiles/commit/3327221)）

## Deploy

- **GNU Stow**: mise の `[dotfiles]` に置き換え。リンクするものを allowlist で宣言し、どの OS でも `mise run deploy` 1つで済む。（[96fcef0](https://github.com/umeruma/dotfiles/commit/96fcef0)）
- **PSDotFiles（Windows）**: `[dotfiles]` が Windows の symlink を扱えるようになったので置き換え。Developer Mode がないと mise は symlink ではなくコピーするので、Developer Mode が必須になった。（[5f1e66c](https://github.com/umeruma/dotfiles/commit/5f1e66c)）
- **`macos/defaults.sh`**: `mise.macos.toml` の `[bootstrap.macos.defaults]` に移した。（[6507146](https://github.com/umeruma/dotfiles/commit/6507146)）
- **ランタイムに書き込むディレクトリのまるごと symlink**: 禁止。karabiner・micro・lazygit・hammerspoon などはファイル単位でリンクする。過去に移行で dangling symlink が11本出たため。

## Tasks

- **Makefile → Just → mise tasks**: Just を経由して、最終的に mise に一本化。ツールとタスクの入口が `mise` 1つになる。（[c3c91a6](https://github.com/umeruma/dotfiles/commit/c3c91a6)、[3771669](https://github.com/umeruma/dotfiles/commit/3771669)、[6b460ef](https://github.com/umeruma/dotfiles/commit/6b460ef)）

## Shell

- **zplug → zinit → sheldon**: zplugなどは結局開発者も使わなくなったツールだったはず。sheldon が設定も素直に書けて安定していそうだと判断。（[5fa2b95](https://github.com/umeruma/dotfiles/commit/5fa2b95)、[71e6510](https://github.com/umeruma/dotfiles/commit/71e6510)）

## Editor

- **Doom Emacs**: LazyVim に移行。Doom Emacs は初回のコンパイルが遅かった。Emacs には独自の操作体系もあり、すでに使っている lazygit などのツールとの相性を考えると自分には LazyVim の方が合っていた。（[635f5d9](https://github.com/umeruma/dotfiles/commit/635f5d9)）

## Docs

- **Fumadocs（Next.js / OpenNext）**: Nimbus（Astro）に移行。OG 画像・`/llms.txt`・検索・sitemap が標準で付くので、自前の仕組みを消せた。（[8e0325e](https://github.com/umeruma/dotfiles/commit/8e0325e)）
