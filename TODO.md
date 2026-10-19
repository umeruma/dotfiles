# TODO

- [ ] herdr の prefix バインドを考え直す（既定は tmux 由来の `ctrl+b`。nvim のページアップと衝突する、IME オン時に通るかも要確認）
- [ ] markdownlint をルール単位で戻すか決める（今は `lua/plugins/markdown.lua` で全部切っている）

## Nix: Homebrew

Nix（nix-darwin + home-manager）移行の残り作業。

- [ ] Brewfile 外で入れたアプリ（cask / formula / App Store）を、移さずそのまま宣言する
  - cask → `my.casks`、formula → `homebrew.brews`、App Store → `my.masApps`
  - 2026-10-19 に一部を仕分け済み（消す / 宣言する）。残りは宣言していない cask（google-chrome、orca、kero など）、formula 全部、App Store の一部
- [ ] 全部宣言したら `nix/homebrew.nix` の `cleanup` を `"uninstall"` にする
  - 先に `brew bundle cleanup --file=<生成された Brewfile>` で、何も消えないことを確かめる
  - `homebrew.nix` のコメントにある `macos/Brewfile` はもうないので、そのとき直す
- [ ] 気が向いたら仕分け（nixpkgs へ移す / 消す）
  - 使用記録なし: pairpods, postman, teamviewer
  - 不要そう: carthage
  - App Store: Folder Quick Look, iPreview

## Nix: Raycast

- [ ] nixpkgs の版が cask に追いついたら、`home.packages` に戻すか検討する
  - nixpkgs 2.7.3.0 < cask 2.8.2.0 で、古い版は移行済みデータを開けなかった
  - 自己更新するアプリなので、cask のままが妥当かもしれない
  - 確認: `nix eval --raw --inputs-from . nixpkgs#raycast.version`

## Nix: 自己更新するアプリ

- [ ] Cursor / VS Code / Zed / Slack / Discord が、データ移行や自己更新で壊れないか

## Nix: Docs

- [ ] `mise-bootstrap.mdx` を macOS の新しい流れ（Nix インストール → `mise run switch`）に合わせる
- [ ] Nix の使い方ページを足す（ツールファイルの足し方、switch、更新）
- [ ] `AGENTS.md` の sheldon / Brewfile の記述を直す
