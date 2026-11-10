# Implementation Plans

improve スキルが 2026-11-11 に作成（対象コミット `6e8371d`）。下の 5 件はすべて実行済みなので、計画書のファイルは削除した。中身は `git show 48c94e8:plans/<番号>-<名前>.md` で読める（一覧は `git show --stat 48c94e8`）。

## Execution order & status

| Plan | Title | Priority | Effort | Depends on | Status |
|------|-------|----------|--------|------------|--------|
| 001 | `mise run check` で整合性を 1 コマンドで確かめる | P1 | S | — | DONE（main にマージ済み: `e329c9e`、`0ce2890`） |
| 002 | Linux のセットアップ経路を実態に合わせて直す | P1 | S | 001 | DONE（main にマージ済み: `17a753b`、`9d5fccc`、`7a0335f`、`db44781`。Linux 実機は未確認） |
| 003 | 実態と食い違っているドキュメントを直す | P2 | S | 001 | DONE（main にマージ済み: `d0846c1`。日本語の見直しは未了） |
| 004 | Windows の lazygit コミットメッセージ生成に改行を保った diff を渡す | P2 | S | — | DONE（main にマージ済み: `2c3d117`。Windows 実機は未確認） |
| 005 | Windows の `mise run clean` が外すべきリンクだけを漏れなく外す | P2 | S | — | DONE（main にマージ済み: `a0d49b2`。Windows 実機は未確認） |

Status values: TODO | IN PROGRESS | DONE | BLOCKED（理由を 1 行で） | REJECTED（理由を 1 行で。別の形で直った、方針をやめた、など）

## Dependency notes

- 002 は 001 のあと。001 が作る `mise run check` を検証に使う。001 は `mise.linux.toml` の `~/.config/zsh` の行を消し、スキル 2 行を足すので、002 の行番号はその分ずれる。
- 003 は 001 のあと。どちらも `AGENTS.md` を編集する（001 は「Quality Gates」節、003 は「Repository-Specific Knowledge」節の 3 行）。003 は `cd docs && mise run check` も使う。
- 003 は 005 より先に実行すると、`mise.windows.toml` の 2 行目のコメントが変わる。005 は `mise.windows.toml` を読むだけなので、順序はどちらでもよい。
- 004 と 005 は独立している。どちらも macOS 上で Nix から PowerShell を一時実行して検証する。

## 検証コマンド（計画作成時に動作確認済み）

| 対象 | コマンド | 結果 |
|---|---|---|
| Nix の評価 | `nix flake check --no-build` | 成功（約 1 秒） |
| シェルスクリプト | `shellcheck -S warning install script/macos/init.sh .githooks/pre-commit home/.config/lazygit/generate-commit-msg.sh` | 指摘なし |
| zsh の構文 | `zsh -n <file>` | 全ファイル成功 |
| docs | `cd docs && bun run typecheck && bun run lint:docs` | 0 errors、lint clean |
| PowerShell | `nix run --inputs-from . nixpkgs#powershell -- -NoProfile -File <script>` | macOS で実行できる |

## 計画にしなかった指摘

あとで計画にする候補。

- `install-win` の堅牢化: `mise dotfiles apply` の前に `mise trust` を呼んでいない（`install-win:211-215`。Unix 版は `install:108` で呼ぶ）。Developer Mode が無効でも警告だけで先へ進み、リンクではなくコピーを作る（`install-win:233-234`）。`home-win/.config/mise/config.toml` に、Unix 版にある `[settings]`（`trusted_config_paths`、`experimental`）が無い。Windows 実機で確かめてから計画にする。
- Windows の細かい疑い（未検証）: `script/win/install-apps.ps1:16-24` が `.ps1` の呼び出しのあとに `$LASTEXITCODE` を見ている。`script/win/theme.ps1` がバックアップなしで Windows Terminal の `settings.json` を書き直す。`mise.windows.toml:3` が求める mise の最低バージョン（2026.9.3）を、どこも強制していない。
- `home/.config/cloudflare/` が未追跡のまま ignore されていない。追跡しないなら、`nix/home-manager/dotfiles.nix` の `my.configIgnore` に `"cloudflare"` を足して `mise run switch` する。中身は端末の識別子を含む状態ファイルで、認証情報ではない。
- `home/.gitconfig:37-38` の `credential.helper = osxkeychain` が Linux にもリンクされる。Linux では警告が出るだけで動作は続く。macOS と共有のファイルなので、分け方に判断が要る。
- Windows の `home-win/.gitconfig` に `core.excludesfile` と `init.defaultBranch` が無く、`~/.gitignore` もリンクされていない。意図的かどうか未確認。

## 方向性の提案（未着手）

- Claude Code 用スキルの一覧を自動で作る: `nix/home-manager/tools/claude.nix` の手書きリストを、`builtins.readDir` で `home/.agents/skills` から作る。`find-skills` のように除外したいものの扱いを決める必要がある。
- Linux の zsh をツール単位の定義に寄せる: `home/.zshrc` は `nix/home-manager/tools/*.nix` の手書きの写しで、すでにずれている（`wtt` が無い、など）。Linux でも home-manager を単体で使えば一本化できるが、Omarchy が `~/.config` を管理している点とぶつかる。設計の検討から始める規模。
- GitHub Actions で `mise run check` を回す: 001 の後続。Nix の評価が Linux のランナーで足りるかは要確認。

## Findings considered and rejected

- 公開中のインストーラが古い疑い: `https://dot.umeru.ma/install` と `/install-win` を取得してリポジトリと比べ、一致した。問題なし。
- `dottrack` が macOS に無いという指摘: `nix/home-manager/tools/mise.nix:11` に定義がある。誤検知。
- `rex` と `wtt-close` のスキルが Windows に無い: Windows には Rex が無いので正しい（`decisions.md`）。001 のチェックは、この 2 つを Windows では除外する。
- `irm ... | iex` や `curl ... | sh` でインストーラを実行する方式: このリポジトリの決まった導入方法。指摘にしない。
- `docs/public/_headers` にハードニング用のヘッダが無い: 静的なドキュメントサイトで、効果が小さい。
- `docs/package.json` の `canvaskit-wasm` が直接は使われていない: `astro-og-canvas` の依存で、意図的に固定している可能性がある。効果が小さい。
- `docs/nimbus.json` が記録するテンプレートの版（0.6.3）と、入っているパッケージ（0.8.x）の差: 実害が確認できない。Nimbus を上げるときに見る。
- `AGENTS.md` 末尾の openskills のブロック: 別ツールが管理している。Copilot など、スキルを自前で読めないエージェント向けの可能性がある。
- `home/.config/nvim/lua/plugins/example.lua`: LazyVim のひな形で、冒頭で空を返すので読み込まれない。害が無い。

## 監査していない範囲

- nvim の Lua 設定、Hammerspoon、Karabiner、kanata の中身。
- `docs/src/components/` のベンダー由来のコンポーネント（約 77 ファイル）。
- Windows と Linux の実機での動作。どちらもコードを読んだうえでの判断で、Windows の 2 件（004、005）だけは macOS 上の PowerShell で再現を確認した。
