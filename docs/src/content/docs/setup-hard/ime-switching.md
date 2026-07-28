---
title: IME Switching
description: US 配列（HHKB）での日本語/英語 IME 切り替えを macOS は Karabiner、Windows は kanata で実現する設定。
sidebar:
  order: 1
---

## 方針

キーボードは [HHKB の US（ANSI）配列](/setup-hard/) を使っているため、JIS 配列の「英数」「かな」キーが物理的に存在しない。そこで両 OS とも **修飾キーの単押し（tap）** に IME 切り替えを割り当てて、同じ操作感に揃えている:

| 操作 | macOS | Windows |
| --- | --- | --- |
| **左 ⌘ / 左 Win 単押し** | 英数（英語入力） | English (US) IME に切り替え |
| **右 ⌘ / 右 Win 単押し** | かな（日本語入力） | 日本語 IME に切り替えてかな ON |
| 長押し・他キーと同時 | 通常の修飾キーとして動作 | 通常の Win キーとして動作 |

トグル（`Win+Space` や `Alt+Shift` の循環切り替え）ではなく **常に特定の言語を直接選択** するので、今どちらの IME か気にせず決め打ちで押せる。

## macOS: Karabiner-Elements

[Karabiner-Elements](https://karabiner-elements.pqrs.org/) の complex modification で ⌘ キーの単押しに `japanese_eisuu` / `japanese_kana` を割り当てている。設定は [`home/.config/karabiner/karabiner.json`](https://github.com/umeruma/dotfiles/blob/main/home/.config/karabiner/karabiner.json)。

自作ルールではなく、公式の [complex modifications ルール集](https://ke-complex-modifications.pqrs.org/#japanese)「For Japanese （日本語環境向けの設定）」からインポートしたテンプレート **「コマンドキーを単体で押したときに、英数・かなキーを送信する。（左コマンドキーは英数、右コマンドキーはかな） (rev 3)」** をそのまま使っている（インポート済みの定義は [`assets/complex_modifications/`](https://github.com/umeruma/dotfiles/blob/main/home/.config/karabiner/assets/complex_modifications/1731064377.json) にある）。挙動は:

- 左 ⌘ 単押し → `japanese_eisuu`（英数）
- 右 ⌘ 単押し → `japanese_kana`（かな）
- 長押し判定は `to_if_held_down_threshold_milliseconds: 100`。`lazy: true` にしているので、他のキーと組み合わせたときは通常の ⌘ として即座に働く

そのほかこのプロファイルでは:

- `caps_lock` → `left_control`
- 特定のキーボード（デバイス ID 指定）で Command / Option の位置を入れ替え
- `virtual_hid_keyboard` は `ansi` を指定（US 配列として扱う）

デプロイは mise の `[dotfiles]` で行うが、Karabiner は `~/.config/karabiner` に実行時の書き込みがあるため **ファイル単位** で symlink している（[How it works](/overview#how-it-works) 参照）。Karabiner-Elements 本体は `mise run install-apps`（Brewfile）でインストール。

## Windows: kanata

Windows には英数・かなキー相当の仕組みがないので、[kanata](https://github.com/jtroo/kanata)（`jtroo.kanata_gui`、winget でインストール）で Win キーの tap-hold を組んでいる。設定は [`home-win/Documents/kanata/kanata.kbd`](https://github.com/umeruma/dotfiles/blob/main/home-win/Documents/kanata/kanata.kbd)。

- **左 Win 単押し** → `Alt+Shift+2` を送信 → English (US) IME に切り替え
- **右 Win 単押し** → `Alt+Shift+1` を送信 → 日本語 IME に切り替え、50ms 待ってから かなキー（scan code 22）を送信して IME を ON
- `tap-hold-press` を使っているので、他のキーが押された瞬間に hold（通常の Win キー）へ確定する。`Win+S` などの組み合わせが誤って IME 切り替えにならず、Karabiner と同じ感覚で使える

Windows 側は IME を直接選択する API がないため、**言語ごとの切り替えホットキー**（`Alt+Shift+1` / `Alt+Shift+2`）を OS 側で一度割り当てておく必要がある。この手順・自動起動（スタートアップ登録）・注意点は [Windows ページの Input language hot keys](/windows/#input-language-hot-keys-required) にまとめてある。

補足: 左 Win を「English (US) IME への切り替え」ではなく「日本語 IME のまま英数（直接入力）にする」動作にしたい場合は、`kanata.kbd` 内の `@lwin-jp` エイリアスに差し替える。

### 制約: IME を自前管理するアプリでは効かない

Blender の Text Editor / Python Console のように IME を自前管理しているアプリでは、この切り替えは効かない（Text Editor は IME 未対応の既知の制限: [#84081](https://projects.blender.org/blender/blender/issues/84081)）。kanata の不具合ではなく手動切り替えでも同じ。外部エディタで書いて貼り付ければ OK。
