---
title: Decisions
description: やめたもの・見送ったものと、その理由
sidebar:
  order: 8
---

試したけれどやめたもの、検討したけれど見送ったものを残す。消したものにはコメントを書く場所がないので、ここに書く。同じ提案を繰り返さないための記録。

今あるものの理由はそのファイルのコメントに、エージェント向けのルールは [AGENTS.md](https://github.com/umeruma/dotfiles/blob/main/AGENTS.md) に書く。

## Packages

- **Brewfile → `[bootstrap.packages]`（見送り）**: `brew bundle add` / `brew bundle cleanup` で追加・追跡するワークフローを残したかったので見送った。その後、macOS の Brewfile 自体を Nix に移したので、この案はもうない。
- **Brewfile → flake + nix-homebrew（macOS）**: Brewfile ではアプリと zsh の設定が別のファイルにあり、アプリを消しても alias や設定が残っていた。Nix ではツールごとのファイル（`nix/home-manager/tools/*.nix`）に、パッケージや cask と、zsh の alias・関数・設定を一緒に書ける。ファイルを消せば全部一緒に消える。nixpkgs にないアプリやドライバは nix-homebrew 経由の Homebrew で入れ、cask も各ツールのファイルの `my.casks` で宣言する。（[805e05a](https://github.com/umeruma/dotfiles/commit/805e05a)）
- **Homebrew の `cleanup = "uninstall"`（見送り）**: 宣言から消したアプリを switch で消せるが、宣言していないアプリも全部消える。dotfiles に入れずに手で入れるアプリもあるので、`"none"` のままにする。宣言から外したアプリは `brew uninstall` で消す。
- **`Brewfile.lock.json`**: Homebrew 7 から読み書きされなくなったので削除。（[3327221](https://github.com/umeruma/dotfiles/commit/3327221)）
- **herdr / Herdr（macOS・Linux）**: Rex で同じことができるので外した。Windows には Rex がないので、herdr を残している。
- **Brewfile の mise**: mise は bootstrap の途中で `curl https://mise.run | sh` で入れるので、Brewfile からは外した。（[e3e71b1](https://github.com/umeruma/dotfiles/commit/e3e71b1)）
- **`win/apps.winget`（winget DSC）**: mise 2026.9.3 で winget が `[bootstrap.packages]` に対応したので、`mise.windows.toml` に移した。Brewfile と同じく opt-in。（[5f1e66c](https://github.com/umeruma/dotfiles/commit/5f1e66c)）
- **Nix で必須アプリとその他のアプリを分ける（見送り）**: Nix 以前は、bootstrap で必須のものだけ入れ、ほかは `install-apps` で入れていた。いまは Mac が1台なので、`mise run switch` で全部入れている。必須のものだけで立ち上げたい Mac が出てきたら分ける。分け方は、GUI アプリの `tools/*.nix` を `extras/` などに移し、`darwinConfigurations` を2つ定義する（必須だけの `AME-core` と全部入りの `AME`）。`install-apps` は core から全部入りへ切り替えるコマンドとして残せる。

## Apps

- **DockDoor Pro**: Dock のカスタマイズに飽きた。ウィンドウ切り替えは AltTab で足りるので、cask をコメントアウトした。
- **Bartender**: ディスプレイを繋ぎ直したときなどに、メニューバーのアイコンが消えることがあったのでやめた。
- **Slack を nixpkgs・cask から入れる**: App Store（`my.masApps`）から入れる。直接配布版は、常駐プロセスで自分のアップデートを管理しようとしてくる。cask も同じ直接配布版なので、cask では入れない。
- **Raycast を nixpkgs から入れる**: cask に戻した。Raycast は自己更新し、そのたびにデータを新しい形式へ移行する。nixpkgs の版（2.7.3.0）は cask（2.8.2.0）より古く、移行済みのデータを開けなかった。（[b28c562](https://github.com/umeruma/dotfiles/commit/b28c562)）
- **AltTab を nixpkgs から入れる**: cask にした。nixpkgs 版はソースからビルドされ、ad-hoc 署名になる。そのため画面収録の権限を何度許可しても定着せず、起動のたびにダイアログが出た。
- **Elgato Wave XLR / Wave Link**: 使うのをやめ、オーディオインターフェースを常駐アプリが不要な Zoom AMS-22 に替えた。Wave XLR は PC スイッチャーで切り替えると、色設定がおかしくなったり音量がリセットされたりした。Wave Link は OS 側で入出力を切り替えたうえで、Wave Link 上でも出力を切り替える必要があり、二度手間だった。（[3327221](https://github.com/umeruma/dotfiles/commit/3327221)）

## Deploy

- **GNU Stow**: mise の `[dotfiles]` に置き換え。リンクするものを allowlist で宣言する。（[96fcef0](https://github.com/umeruma/dotfiles/commit/96fcef0)）
- **PSDotFiles（Windows）**: `[dotfiles]` が Windows の symlink を扱えるようになったので置き換え。Developer Mode がないと mise は symlink ではなくコピーするので、Developer Mode が必須になった。（[5f1e66c](https://github.com/umeruma/dotfiles/commit/5f1e66c)）
- **`macos/defaults.sh`**: `mise.macos.toml` の `[bootstrap.macos.defaults]` に移した。（[6507146](https://github.com/umeruma/dotfiles/commit/6507146)）
- **ランタイムに書き込むディレクトリのまるごと symlink（Linux / Windows）**: 禁止。lazygit・micro・herdr などはファイル単位でリンクする。過去に移行で dangling symlink が11本出たため。macOS は `~/.config` をまるごと `home/.config` にリンクし、状態ファイルは `home/.config/.gitignore` で除外する方式に変えた（babarot/dotfiles と同じ）。hammerspoon は `~/.config` の外なので、今もファイル単位。
- **`~/.claude/settings.json` の追跡**: やめた。中身のほとんどは Orca・herdr・tldraw の hook や statusLine で、各ツールが自分で書き込む。プラグイン（crit、ponytail）も、ツールのドキュメントどおりに入れただけだった。追跡していると、ツールが書き換えるたびに差分が出るうえ、`/model` の `model` を外す filter と pre-commit も要った。
- **`mise run deploy`**: 削除。macOS のリンクは home-manager に移り、switch が古いリンクも消すようになった。Linux / Windows は `mise dotfiles apply`（`mise bootstrap` の手順3でも走る）を直接使い、エントリを消したときだけ `mise run clean` を先に実行する。git の hooksPath と filter は、clone ごとに `git config` する代わりに `repo.gitconfig` を `~/.gitconfig` の `includeIf` で読む。
- **`mise.dotfiles.toml` / `mise.unix.toml`**: 削除。mise は設定ファイルを足し合わせるだけで、Mac だけエントリを外すことができない。Mac に `[dotfiles]` が見えると、`mise bootstrap` が home-manager と同じ場所にリンクを張ってぶつかる。共通エントリは `mise.linux.toml` と `mise.windows.toml` に1回ずつ書く。
- **`home/.config/.gitignore` を Nix で生成する**: 採用。各ツールのファイルに `my.configIgnore = [ "gh" ];` のように書き、`dotfiles.nix` の activation で集めて書き出す。ツールのファイルを消すと ignore も一緒に消えるので、1ファイル1ライフサイクルに合う。
  - `home.file` で作ると Nix store へのシンボリックリンクになるが、git（2.32 以降）は作業ツリー内のシンボリックリンクの `.gitignore` を読まない。なので実ファイルとして書き出し、git でも管理する。手で編集しても switch で上書きされる。
  - `.git/info/exclude` に書く方法は選ばない。clone 直後は ignore が効かず、認証情報が untracked として見えてしまう。
  - home-manager の `programs.git.ignores` は使わない。グローバルな ignore（`~/.config/git/ignore`）なので、手書きの `.gitconfig` の `excludesfile` と競合し、生成物が repo 内の `home/.config/git/` にできる。ツールごとの値が集まるのはモジュールシステムのリスト連結の働きなので、自前のオプションで同じことができる。
  - tools にファイルがないアプリ（emacs、flutter など）の分は `dotfiles.nix` にまとめる。

## Tasks

- **Makefile → Just → mise tasks**: Just を経由して、最終的に mise に一本化。ツールとタスクの入口が `mise` 1つになる。（[c3c91a6](https://github.com/umeruma/dotfiles/commit/c3c91a6)、[3771669](https://github.com/umeruma/dotfiles/commit/3771669)、[6b460ef](https://github.com/umeruma/dotfiles/commit/6b460ef)）
- **`mise run help`**: 削除。中身は `mise tasks` を呼ぶだけだった。
- **`mise run install-fonts`（macOS）**: `nix/home-manager/tools/fonts.nix` に移した。Moralerspace は nixpkgs から全系統を取ってくる。Windows は今もこのタスクで入れる。

## Shell

- **zplug → zinit → sheldon**: zplugなどは結局開発者も使わなくなったツールだったはず。sheldon が設定も素直に書けて安定していそうだと判断。（[5fa2b95](https://github.com/umeruma/dotfiles/commit/5fa2b95)、[71e6510](https://github.com/umeruma/dotfiles/commit/71e6510)）
- **sheldon → home-manager（macOS）**: `programs.zsh` に移した。理由は Brewfile と同じで、ツールのファイルにパッケージと zsh の設定を一緒に書けるから。プラグイン（k など）は flake の input でコミットを固定する。Linux は今も `home/.zshrc` と sheldon。（[9e3f331](https://github.com/umeruma/dotfiles/commit/9e3f331)）
- **enhancd → zoxide**: enhancd はリリースが3年前で止まっている。zoxide は `zoxide init zsh --cmd cd` で `cd` をそのまま置き換えられる。enhancd で使っていた「引数なし `cd` で履歴から fzy 選択」だけは `cdi` を fzy 版にして残した。enhancd 専用だった sheldon の `interactive` プロファイル分岐も一緒に消した。
- **pure → starship**: zsh と PowerShell で同じプロンプト設定（`home/.config/starship.toml`）を使うため。設定は omarchy の `config/starship.toml` を元に、Nerd Font なしでも出る記号に替えた。
- **omarchy の `ga` / `gd`（worktree 作成・削除）の移植（見送り）**: omarchy 版は `../repo--branch` に作る独自配置で git-wt と衝突する。同名の `ga` / `gd` は git-wt の薄いラッパーにした。

## Editor

- **Doom Emacs**: LazyVim に移行。Doom Emacs は初回のコンパイルが遅かった。Emacs には独自の操作体系もあり、すでに使っている lazygit などのツールとの相性を考えると自分には LazyVim の方が合っていた。（[635f5d9](https://github.com/umeruma/dotfiles/commit/635f5d9)）
- **nvim の Chalice アイコン → 記号表示**: Chalice は私用領域（U+E000〜E011）のグリフで、Ghostty の `font-codepoint-map` で ChaliceIcons フォントに割り当てて表示していた。この割り当てができない端末（Rex、Windows Terminal）では出ない。分類（`home/.config/nvim/file-icons.toml`）は Chalice のまま残し、各分類を2文字幅の記号（`{}` `>_` など）で出す形にして全 OS で揃えた。フォントと割り当て設定は消した。

## Docs

- **Fumadocs（Next.js / OpenNext）**: Nimbus（Astro）に移行。OG 画像・`/llms.txt`・検索・sitemap が標準で付くので、自前の仕組みを消せた。（[8e0325e](https://github.com/umeruma/dotfiles/commit/8e0325e)）
