# TODO

- [ ] markdownlint をルール単位で戻すか決める（今は `lua/plugins/markdown.lua` で全部切っている）

## improve の計画（2026-11-11）

`plans/README.md` が索引。計画 5 件は実行して main にマージ済み（`e329c9e`〜`a0d49b2` の 9 コミット、未 push）。

- [ ] push する
- [ ] 日本語を見直す
  - 003 で書き換えた docs: `editor-stack.mdx`、`windows.mdx`、`nix.mdx`、`mise-bootstrap.mdx`
  - `plans/README.md`（索引）
- [ ] 実機で確かめる
  - Windows: lazygit の `A`（004）、`mise run clean`（005）
  - Linux: シェルの起動、lazygit の `A`、`mise run clean`（002）
- [ ] 計画にしなかった指摘を判断する（詳細は `plans/README.md`）
  - `install-win`: `mise trust` を呼んでいない。Developer Mode が無効でも先へ進む
  - `home/.gitconfig` の `credential.helper = osxkeychain` が Linux にもリンクされる
  - Windows: `install-apps.ps1` の `$LASTEXITCODE` 判定、`theme.ps1` のバックアップ、mise の最低バージョン
  - `home-win/.gitconfig` に `core.excludesfile` と `init.defaultBranch` が無い
  - `script/linux/clean.zsh` が実行時に `p=...` を 1 行出す（`local p` が環境にある同名の変数を表示する。害は無い）
- [ ] 方向性の提案を検討する: スキル一覧の自動導出、Linux の zsh の一本化、GitHub Actions で `mise run check`

## Nix: Homebrew

Nix（nix-darwin + home-manager）移行の残り作業。

- [ ] 気が向いたら仕分け（宣言する / 消す / 手で入れたまま）。`cleanup` は `"none"` のまま（decisions.md）
  - cask → `my.casks`、formula → nixpkgs か `my.brews`、App Store → `my.masApps`
  - 2026-10-19 に2回仕分け済み。2026-11-11 時点の残り:
    - cask: aerospace, dockdoor-pro, dropshare, firefox, google-chrome, hex, kero, pairpods, postman, teamviewer
    - formula: age, aicommit2, carthage, container, deno, difftastic, git-filter-repo, hugo, k1low/tap/mo, mactop, static-web-server, subversion
    - App Store: 1Password for Safari, iMovie, Lens, MenubarX, Raycast Companion, Windows App
  - dockdoor-pro は使うのをやめた（decisions.md）のに入ったまま。`brew uninstall --cask dockdoor-pro` で消す

## Nix: Raycast

- [ ] nixpkgs の版が cask に追いついたら、`home.packages` に戻すか検討する
  - 2026-11-11 時点で nixpkgs 2.7.3.0 < cask 2.11.1.0。古い版は移行済みデータを開けなかった
  - 自己更新するアプリなので、cask のままが妥当かもしれない
  - 確認: `nix eval --raw --inputs-from . 'nixpkgs#raycast.version'`
