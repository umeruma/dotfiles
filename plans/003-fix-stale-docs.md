# Plan 003: 実態と食い違っているドキュメントを直す

> Executor instructions: この計画を上から順に実行する。各ステップの Verify を実行し、
> 期待どおりの結果を確認してから次へ進む。「STOP conditions」に当てはまったら、
> 自分で工夫せずに止まって報告する。完了したら `plans/README.md` の該当行の
> Status を更新する（レビュアーから「索引は自分が管理する」と言われた場合を除く）。
>
> Drift check（最初に実行）:
> `git diff --stat 6e8371d..HEAD -- README.md AGENTS.md docs/AGENT.md docs/src/content/docs mise.windows.toml home-win/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`
> `AGENTS.md` は Plan 001 で「Quality Gates」節（18-22 行目付近）が変わっているはず。
> それ以外の変更が出たら「Current state」の抜粋と現物を見比べ、食い違っていれば STOP。

## Status

- Priority: P2
- Effort: S
- Risk: LOW
- Depends on: plans/001-add-check-task.md（`AGENTS.md` を同じく編集するので、後に実行する）
- Category: docs
- Planned at: commit `6e8371d`, 2026-11-11

## Why this matters

macOS を Nix に移し、ドキュメントサイトを Fumadocs から Nimbus（Astro）に替えたあと、いくつかの記述が古いまま残っている。存在しないタスクやショートカットを案内していたり、エージェント向けの手順書が無いファイル（`meta.json`）や違うパッケージマネージャ（pnpm）を指示していたりする。人もエージェントもこれを読んで作業するので、誤った手順を踏む原因になる。

直すのは、事実として間違っている箇所だけ。文章の言い回しは変えない。

## Current state

確認済みの事実（これがドキュメントの正解）:

- macOS に `install-apps` タスクは無い。`mise.macos.toml` にあるタスクは `switch` だけで、アプリは `mise run switch` で入る。`install-apps` は `mise.linux.toml` と `mise.windows.toml` にある。
- nvim を開くシェル関数は、どの OS でも `n`。`nv` は存在しない。
  - macOS: `nix/home-manager/tools/neovim.nix:19` に `n() { nvim "''${@:-.}"; }`
  - Linux: `home/.zshrc:172` に `n() { nvim "${@:-.}"; }`
  - Windows: `home-win/Documents/PowerShell/Microsoft.PowerShell_profile.ps1:45` に `function n { ... }`
- lazygit の `A`（AI でコミットメッセージを作る）が使う生成器は OS で違う。
  - macOS / Linux: `home/.config/lazygit/generate-commit-msg.sh` が、既定で `claude -p --model haiku` を呼ぶ。環境変数 `LAZYGIT_AI_CMD` で差し替えられる。`commit.template`（`~/.gitmessage`）が読めることが条件。
  - Windows: `home-win/.config/lazygit/generate-commit-msg.ps1` が `cursor-agent`（`composer-2.5-fast`）を呼ぶ。
- `nix/home-manager/tools/keka.nix` の実物は次のとおり。GUI アプリは `home.packages` ではなく `my.apps` に書く（`nix/home-manager/default.nix:18-22` の定義: 「nixpkgs GUI apps; nix-darwin copies them to /Applications/Nix Apps」）。Homebrew の formula 用に `my.brews` もある（`default.nix:27-31`）。

```nix
{ pkgs, ... }:
{
  my.apps = [ pkgs.keka ];

  programs.zsh.shellAliases.keka = "${pkgs.keka}/Applications/Keka.app/Contents/MacOS/Keka --cli";
}
```

- `docs/` に `meta.json` は 1 つも無い（Fumadocs 時代のもの）。サイドバーの順序は、各ページの frontmatter の `sidebar.order` で決まる。
- ドキュメントのページには `.md` と `.mdx` の両方がある（`decisions.md`、`lean-zsh.md`、`setup-hard/*.md` は `.md`）。
- `docs/` のパッケージマネージャは bun（`docs/package.json` の `"packageManager": "bun@1.3.14"`、`bun.lock`）。pnpm は使っていない。
- macOS は mise の `[dotfiles]` を読まない。`home/` のファイルは、macOS では home-manager がリンクする。
- macOS の Brewfile はもう無い（Nix に移した）。残っているのは `script/linux/Brewfile` だけ。
- Windows の `mise run install-apps` は `script/win/install-apps.ps1` を実行し、`mise bootstrap packages apply` のあとに Cursor CLI と herdr のインストーラも走らせる。

直す箇所の現状:

`README.md:11`:

```markdown
This clones to `~/Codes/dotfiles`, installs mise if needed, then runs `mise bootstrap` (packages, login shell, deploy). Optional GUI/CLI apps: `mise run install-apps`.
```

`docs/src/content/docs/editor-stack.mdx:65-69`:

````markdown
```bash
herdr / hr   # Windows のみ。セッションを起動 / attach（prefix は ctrl+b、ヘルプは prefix+?）
nvim / nv    # LazyVim（リーダーキーは space）。`nv +100 file.rs` もそのまま通る
lazygit / lg # Git TUI（Files で A = Cursor AI コミットメッセージ）
```
````

`docs/src/content/docs/editor-stack.mdx:73`:

```markdown
`nv` / `lg` は `~/.zshrc`（Windows は PowerShell プロファイル）の薄いシェル関数。`hr` は PowerShell プロファイルだけにある。
```

`docs/src/content/docs/editor-stack.mdx:75`（1 行の長い段落。直す部分だけ抜粋）:

- 冒頭: ``lazygit の `A` は **staged の diff だけ** を `cursor-agent`（`composer-2.5-fast`）に渡す。``
- 末尾近く: ``要: `cursor-agent login`（または `CURSOR_API_KEY`）と stage 済み。ヘルパー本体は macOS が `generate-commit-msg.sh`、Windows が `generate-commit-msg.ps1`（`mise.windows.toml` が `%LOCALAPPDATA%\lazygit` にリンク）。``

`docs/src/content/docs/windows.mdx:97`（直す部分だけ抜粋）: ``macOS の Brewfile と同じく **opt-in**``

`docs/src/content/docs/windows.mdx:114`（直す部分だけ抜粋）: ``ショートカットは PowerShell プロファイルの `nv` / `lg` / `hr`（`nv` は組み込みエイリアス `New-Variable` を外してから定義）。``

`docs/src/content/docs/windows.mdx:235-238`:

```markdown
| Directory   | Used on        | Tool        |
|------------|----------------|-------------|
| `home/`    | macOS, Linux（一部は Windows でも） | mise `[dotfiles]` |
| `home-win/`| Windows        | mise `[dotfiles]` |
```

`docs/src/content/docs/nix.mdx:38-40`:

```markdown
1. **nixpkgs**: `home.packages`。探すときは `nix search nixpkgs <name>`。
2. **ほかの flake**: `flake.nix` の `inputs` に足す（例: `crit.nix`）。
3. **Homebrew cask**: `my.casks`。nixpkgs にないもの、ドライバやシステム拡張を入れるもの、自己更新でデータを移行するもの（Raycast）。
```

`docs/src/content/docs/nix.mdx:46-54`:

````markdown
```nix
# nix/home-manager/tools/keka.nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.keka ];

  programs.zsh.shellAliases.keka = "${pkgs.keka}/Applications/Keka.app/Contents/MacOS/Keka --cli";
}
```
````

`docs/src/content/docs/mise-bootstrap.mdx:76`（直す部分だけ抜粋）: ``` `mise run install-apps`（= `mise bootstrap packages apply`）でのみ適用する ```

`mise.windows.toml:2`:

```toml
# Applied by `mise run install-apps` (= `mise bootstrap packages apply`).
```

`AGENTS.md:50-52`:

```markdown
- `.miserc.toml` sets `auto_env = true` so `mise.linux.toml` / `mise.macos.toml` load
- Documentation is managed as MDX in `docs/src/content/docs` and published on the site
- Navigation is auto-completed by `meta.json` (usually just add a page)
```

`docs/AGENT.md` の pnpm の記述（60、61、64、65、66、68、87 行目）。例:

```markdown
| UI from registry | `pnpm exec nimbus-docs add <slug>`. Register in `src/components.ts` if used in MDX. |
...
- **Search** — `data-pagefind-body` is on the docs main wrapper; after `pnpm build`, `dist/pagefind/` exists with ≥1 indexed page.
```

`home-win/Documents/PowerShell/Microsoft.PowerShell_profile.ps1:44-45`（44 行目のコメントは、やめた方式の名残）:

```powershell
# nv = New-Variable is a built-in PowerShell alias; drop it for LazyVim parity with zsh.
function n { if ($args.Count) { nvim @args } else { nvim . } }
```

守る規約:

- ドキュメントサイトのページは、見出しが英語、本文が日本語。簡潔に書く。
- Markdown で太字を増やさない（既存の太字はそのまま。新しく足さない）。
- コードにコメントは基本書かない。古いコメントは、書き直さずに消す。
- `README.md`、`AGENTS.md`、`docs/AGENT.md` は英語のファイル。英語のまま直す。

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| docs の型チェックと lint | `cd docs && mise run check` | `0 errors` と `lint clean`、exit 0 |
| 整合性チェック | `mise run check` | 最終行が `check: OK`、exit 0 |

どちらも Plan 001 で作ったタスク。`cd docs && mise run check` が無ければ、代わりに `cd docs && bun run typecheck && bun run lint:docs` を使う。

## Suggested executor toolkit

- 日本語の文を書き換えるときは、使えるなら `natural-japanese` スキルを使う。ただし書き換えるのは下の各ステップで指定した語句だけで、周りの文は変えない。

## Scope

In scope（変更してよいのはこれだけ）:

- `README.md`
- `AGENTS.md`（50-52 行目付近の 3 行だけ）
- `docs/AGENT.md`
- `docs/src/content/docs/editor-stack.mdx`
- `docs/src/content/docs/windows.mdx`
- `docs/src/content/docs/nix.mdx`
- `docs/src/content/docs/mise-bootstrap.mdx`
- `mise.windows.toml`（2 行目のコメントだけ）
- `home-win/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`（44 行目のコメントだけ）

Out of scope（関係がありそうでも触らない）:

- `docs/README.md` — `mise run dev` の記述は、Plan 001 でタスクを足したので正しい。
- `docs/src/content/docs/overview.mdx` — `dottrack` は macOS にも定義がある（`nix/home-manager/tools/mise.nix:11`）。記述は正しい。
- `docs/src/content/docs/decisions.md` — 削除したものの記録。古いパスが出てくるのは意図どおり。
- `AGENTS.md` の末尾にある `<skills_system>` ブロック — 別ツール（openskills）が管理している。
- `AGENTS.md` の「Quality Gates」節 — Plan 001 が書き換えた。
- 設定ファイルやスクリプトの挙動。この計画はドキュメントとコメントだけを直す。

## Git workflow

- Branch: `advisor/003-fix-stale-docs`
- コミットしない。このリポジトリでは、日本語ドキュメントの変更は持ち主が読み直してからコミットする決まりになっている。変更は未コミットのまま残し、完了報告に変更ファイルの一覧を書く。
- push しない。PR も作らない。

## Steps

### Step 1: `README.md` の `install-apps` の案内を OS 別にする

11 行目の末尾の文 ``Optional GUI/CLI apps: `mise run install-apps`.`` を、次に置き換える。

```markdown
Apps: on macOS they are installed by `mise run switch` (run at the end of bootstrap); on Linux, optionally run `mise run install-apps`.
```

Verify: `grep -c 'on Linux, optionally run' README.md` → `1`

### Step 2: `editor-stack.mdx` の `nv` と lazygit の説明を直す

1. 67 行目: `nvim / nv    #` を `nvim / n     #` に、`` `nv +100 file.rs` `` を `` `n +100 file.rs` `` にする（`#` の桁位置を上下の行と揃える）。
2. 68 行目: `A = Cursor AI コミットメッセージ` を `A = AI コミットメッセージ` にする。
3. 73 行目: 冒頭の `` `nv` / `lg` `` を `` `n` / `lg` `` にする。
4. 75 行目の冒頭の文を、次に置き換える。

```markdown
lazygit の `A` は **staged の diff だけ** を AI に渡す。macOS / Linux は `claude -p --model haiku`（`LAZYGIT_AI_CMD` で差し替え可）、Windows は `cursor-agent`（`composer-2.5-fast`）。
```

5. 75 行目の ``要: `cursor-agent login`（または `CURSOR_API_KEY`）と stage 済み。`` を、次に置き換える。

```markdown
要: stage 済みであること。macOS / Linux は `claude` と `commit.template`（`~/.gitmessage`）、Windows は `cursor-agent login`（または `CURSOR_API_KEY`）。
```

6. 75 行目の ``ヘルパー本体は macOS が `generate-commit-msg.sh` `` の `macOS が` を `macOS / Linux が` にする。

75 行目のそれ以外の文（`loadingText`、`LAZYGIT_PENDING_COMMIT`、`$NVIM` の説明）は変えない。

Verify: `grep -c '`nv`\|/ nv ' docs/src/content/docs/editor-stack.mdx` → `0`。`grep -c 'LAZYGIT_AI_CMD' docs/src/content/docs/editor-stack.mdx` → `1`。

### Step 3: `windows.mdx` の 3 か所を直す

1. 97 行目: `macOS の Brewfile と同じく` を `Linux の Brewfile と同じく` にする。
2. 114 行目: ``ショートカットは PowerShell プロファイルの `nv` / `lg` / `hr`（`nv` は組み込みエイリアス `New-Variable` を外してから定義）。`` を ``ショートカットは PowerShell プロファイルの `n` / `lg` / `hr`。`` にする。
3. 237 行目の表の行を、次に置き換える。

```markdown
| `home/`    | macOS, Linux（一部は Windows でも） | macOS は home-manager、Linux / Windows は mise `[dotfiles]` |
```

Verify: `grep -c 'New-Variable\|macOS の Brewfile' docs/src/content/docs/windows.mdx` → `0`。`grep -c 'macOS は home-manager' docs/src/content/docs/windows.mdx` → `1`。

### Step 4: `nix.mdx` の入れ方の一覧と keka の例を直す

1. 38 行目を、次に置き換える。

```markdown
1. **nixpkgs**: CLI は `home.packages`、GUI アプリは `my.apps`（`/Applications/Nix Apps` に入る）。探すときは `nix search nixpkgs <name>`。
```

2. 40 行目の `` `my.casks`。 `` の直後に `formula は `my.brews`。` を足す。仕上がり:

```markdown
3. **Homebrew cask**: `my.casks`。formula は `my.brews`。nixpkgs にないもの、ドライバやシステム拡張を入れるもの、自己更新でデータを移行するもの（Raycast）。
```

3. 50 行目（コードブロックの中）の `home.packages = [ pkgs.keka ];` を `my.apps = [ pkgs.keka ];` にする。

Verify: `grep -c 'my.apps' docs/src/content/docs/nix.mdx` → `2`。`grep -c 'my.brews' docs/src/content/docs/nix.mdx` → `1`。`grep -c 'home.packages = \[ pkgs.keka \]' docs/src/content/docs/nix.mdx` → `0`。

### Step 5: Windows の `install-apps` の説明を揃える

1. `docs/src/content/docs/mise-bootstrap.mdx:76`: ``（= `mise bootstrap packages apply`）`` を ``（`mise bootstrap packages apply` と Cursor CLI / herdr のインストーラ）`` にする。
2. `mise.windows.toml:2` を、次に置き換える。

```toml
# Applied by `mise run install-apps` (`mise bootstrap packages apply`, then the Cursor CLI and herdr installers).
```

Verify: `grep -c '(= `mise bootstrap packages apply`)\|（= `mise bootstrap packages apply`）' docs/src/content/docs/mise-bootstrap.mdx mise.windows.toml` → どちらのファイルも `0`。

### Step 6: `AGENTS.md` の 3 行を直す

50-52 行目付近の 3 行を、次に置き換える（Plan 001 で行番号がずれている可能性があるので、文面で探す）。

```markdown
- `.miserc.toml` sets `auto_env = true` so `mise.linux.toml` / `mise.macos.toml` / `mise.windows.toml` load
- Documentation is managed as Markdown / MDX in `docs/src/content/docs` and published on the site
- Sidebar order comes from each page's frontmatter (`sidebar.order`); usually just add a page
```

Verify: `grep -c 'meta.json' AGENTS.md` → `0`。`grep -c 'sidebar.order' AGENTS.md` → `1`。

### Step 7: `docs/AGENT.md` の pnpm を bun にする

1. `pnpm exec nimbus-docs` を、すべて `bunx nimbus-docs` に置き換える（6 か所: 60、61、64、65、66、68 行目）。
2. 87 行目の `` `pnpm build` `` を `` `bun run build` `` にする。

Verify: `grep -c pnpm docs/AGENT.md` → `0`。`grep -c 'bunx nimbus-docs' docs/AGENT.md` → `6`。

### Step 8: PowerShell プロファイルの古いコメントを消す

`home-win/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` の 44 行目 `# nv = New-Variable is a built-in PowerShell alias; drop it for LazyVim parity with zsh.` を削除する。45 行目の `function n ...` は変えない。

Verify: `grep -c 'New-Variable' home-win/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` → `0`。`grep -c '^function n ' home-win/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` → `1`。

### Step 9: docs のチェックを通す

Verify: `cd docs && mise run check` → `0 errors` を含む行と `lint clean` を含む行、exit 0。続けてリポジトリのルートで `mise run check` → `check: OK`。

## Test plan

ドキュメントの修正なので、新しいテストは無い。検証は各ステップの grep と、Step 9 の docs チェック（frontmatter と内部リンクの検査を含む）で行う。

## Done criteria

すべて満たすこと。

- [ ] `cd docs && mise run check` が exit 0
- [ ] `mise run check` が exit 0
- [ ] `grep -rn '`nv`' docs/src/content/docs README.md AGENTS.md` が何も返さない
- [ ] `grep -c pnpm docs/AGENT.md` が `0`
- [ ] `grep -c 'meta.json' AGENTS.md` が `0`
- [ ] `git status --short` に出るのが In scope のファイルだけ（`home/.config/cloudflare/` は元からある未追跡ディレクトリなので無視する）
- [ ] 変更をコミットしていない（`git log 6e8371d..HEAD --oneline -- docs README.md AGENTS.md` に、この計画のコミットが無い）
- [ ] `plans/README.md` の Status を更新した

## STOP conditions

次のどれかに当てはまったら、止まって報告する。

- 「Current state」の抜粋と現物が食い違っている（Plan 001 による `AGENTS.md` の変更を除く）。
- 「確認済みの事実」が現物と違う。たとえば `nv` という関数がどこかに定義されている、`docs/` に `meta.json` がある、など。
- `cd docs && mise run check` が、この計画で触っていないページのエラーで落ちる。
- 指定した語句以外の文を書き換えたくなった。
- 同じ Verify が、妥当な修正を試しても 2 回失敗する。

## Maintenance notes

- ツールの入れ方やショートカットを変えたら、`editor-stack.mdx`、`windows.mdx`、`nix.mdx` の該当箇所も直す。今回の食い違いは、すべて「コードだけ変えてドキュメントを直さなかった」ことが原因だった。
- 見送ったこと: `docs/AGENT.md:30` の「`wrangler.jsonc` at the project root」。`docs/` を基準にすれば正しいので、そのままにした。
- 見送ったこと: `docs/AGENT.md` のファイル構成図の更新。Nimbus のひな形の文章で、実害が小さい。
- レビューで見てほしい点: 日本語の言い回し（Step 2 と Step 4 の差し替え文）。
