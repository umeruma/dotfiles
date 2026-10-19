# TODO

- [ ] herdr の prefix バインドを考え直す（既定は tmux 由来の `ctrl+b`。nvim のページアップと衝突する、IME オン時に通るかも要確認）
- [ ] markdownlint をルール単位で戻すか決める（今は `lua/plugins/markdown.lua` で全部切っている）

## Nix: Homebrew

Nix（nix-darwin + home-manager）移行の残り作業。

- [ ] 気が向いたら仕分け（宣言する / 消す / 手で入れたまま）。`cleanup` は `"none"` のまま（decisions.md）
  - cask → `my.casks`、formula → nixpkgs か `my.brews`、App Store → `my.masApps`
  - 2026-10-19 に2回仕分け済み。残り:
    - cask: aerospace, dropshare, firefox, google-chrome, pairpods, postman, teamviewer
    - formula: age, aicommit2, carthage, container, deno, difftastic, git-filter-repo, hugo, k1low/tap/mo, mactop, static-web-server, subversion
    - App Store: 1Password for Safari, Raycast Companion, Windows App

## Nix: Raycast

- [ ] nixpkgs の版が cask に追いついたら、`home.packages` に戻すか検討する
  - nixpkgs 2.7.3.0 < cask 2.8.2.0 で、古い版は移行済みデータを開けなかった
  - 自己更新するアプリなので、cask のままが妥当かもしれない
  - 確認: `nix eval --raw --inputs-from . 'nixpkgs#raycast.version'`
