---
name: dev-crit
description: >-
  Start (or reuse) the local mise/astro dev server, then open a live-page design
  review with crit against that URL. Use when the user asks to 起動してcrit,
  デザインレビュー, review the live design, crit the running site, or wants
  visual/UI feedback on the current worktree before or instead of a git-diff review.
argument-hint: "[optional: path|/ or page URL path]"
---

# Dev + Crit (live design review)

dev サーバーを用意してから、**ライブURL** を `crit` に渡してデザイン全般をレビューする。
コード差分レビュー（引数なしの `crit`）ではない。

## 前提

- 起動手順は **dev-server** スキルに従う（worktree 推定・既存 terminal 再利用・`mise run dev`）
- レビューループ（Finish Review 待ち・コメント対応・次ラウンド）は **crit** スキルに従う
- このスキルの仕事は「サーバー準備 → URL 確定 → `crit <url>` 起動」の橋渡し

## Crit レビュー中の検証ルール（必須）

レビューセッションが生きている間（`crit` daemon / Finish Review 待ち中）は、**検証に `build` を使わない**。

- **禁止:** `npm run build` / `bun run build` / `astro build` / `mise run build` など、dev と並走しうる production build
- **使う:** 起動中の live URL と HMR。編集後は Crit の proxy（または `Local:` の URL）をリロードして確認する
- **理由:** `astro build` と `astro dev` が同時に Vite の dep キャッシュ（`node_modules/.vite`）を触ると、dev が落ちて Crit が `{"error":"upstream unreachable"}` になる

コメント対応中も同様。型チェックやビルド確認が必要なら **Finish Review 後**、または別ターミナルで dev を止めてから行う。

`upstream unreachable` が出たときは、先に `Local:` の URL へ curl / ブラウザで upstream の生死を確認し、落ちていれば `mise run dev` を再起動してから Crit をリロードする。build で「直したつもり」にしない。

## Trailing slash（crit は slash を落とす）

crit は渡された URL を正規化し、**エントリ URL の trailing slash を落として** upstream を叩く
（`http://…/sessions/` を渡しても `/sessions` を probe する）。
`trailingSlash: 'always'` のプロジェクトでは dev サーバーが `/sessions` を 404 にするため、
起動時に `upstream returned 404` が出て live モードが空振りする。

crit 側の挙動は変えられないので、**deep URL を渡す前に no-slash 形が解決するか確認する**:

```sh
curl -s -o /dev/null -w '%{http_code}\n' 'http://localhost:3333/sessions'
```

- `200` / `301` → そのまま `crit <deep-url>` で良い
- `404` → 2 択
  1. dev サーバー側で no-slash → slash の 301 を返す（本番の Apache と同じ挙動。
     Astro なら `astro.config.mjs` の `vite.plugins` に serve 限定 middleware を足し、
     内部 middleware の後ろではなく `server.middlewares.stack.unshift()` で先頭に差し込む。
     単に `use()` すると Astro のリクエストハンドラの後ろに並び 404 を書き換えられない）
  2. プロジェクト設定を触らないなら **origin ルートを渡して**（`http://localhost:3333/?stab=true`）
     アプリ内リンクで目的ページへ遷移してもらう。Swup サイトでは `#swup` 外のストアが保持されるので
     `?stab=true` などのクエリは初回ロードで効かせれば遷移後も維持される

## Procedure

### 1. worktree と既存サーバーを解決する

dev-server と同じ優先順位で対象 path を決める。

1. アクティブファイルの絶対パス
2. 直近の作業コンテキスト
3. 引数の branch / worktree 名
4. `git wt --json`

同じ worktree で `mise run dev` / `astro dev` がすでに待受中なら **新規起動しない**。

待受判定の目安:

- 出力に `Local:` / `Network:` / `ready` / `watching for file changes`
- または cwd がその worktree で Astro が listen 中

未起動なら background で起動し、ready になるまで待つ:

```sh
cd <worktree-path> && mise run dev
```

### 2. レビュー URL を決める

優先順位:

1. ユーザーが絶対 URL を渡した → そのまま使う
2. ターミナル出力の `Local: http://...`（なければ `Network:`）
3. プロジェクト設定の port（例: Astro `server.port`。toradfes-2026 は `3333`）→ `http://localhost:<port>/`
4. それでも不明なら `http://localhost:4321/`（Astro デフォルト）を試し、接続できなければユーザーに確認

スキル引数がパスだけのとき（例: `/sessions/`）は、上記ベース URL に結合する。

trailing slash はプロジェクト設定に合わせる（toradfes-2026 は `trailingSlash: 'always'`）。

### 3. crit をライブモードで起動する

```sh
crit <resolved-url>
```

- **必ず URL を渡す**（裸の `crit` にしない）
- background で起動し、stdout の daemon URL をユーザーに伝える:

> **Crit is open at http://localhost:\<port\>. Leave inline comments, then click Finish Review.**

- Finish Review まで待つ。先走ってコメントを読まない。

### 4. コメント対応と次ラウンド

crit スキルの Step 3〜5 と同じ:

1. stdout / `approved` を確認
2. 未解決コメントを修正し、`crit comment --reply-to ...` で返信（勝手に `--resolve` しない）
3. 修正の確認は **live / HMR のみ**（上記「Crit レビュー中の検証ルール」）。`build` は走らせない
4. 必要なら再度 `crit <resolved-url>` で次ラウンド
5. コメント 0 件で finish → 承認済みとして終了

複数返信は一括:

```sh
echo '[
  {"reply_to": "c_a1b2c3", "body": "Fixed"},
  {"reply_to": "c_d4e5f6", "body": "Adjusted spacing"}
]' | crit comment --json --author 'Claude Code'
```

## 使い分け

| やりたいこと | 使うもの |
|-------------|---------|
| 見た目・レイアウトを広く見る | **このスキル** → `crit <url>` |
| ブランチのコード差分だけ | crit スキル → `crit` |
| サーバー起動だけ | dev-server スキル |

## 注意

- Crit レビュー中は **build 禁止**（live / HMR で確認）。詳細は「Crit レビュー中の検証ルール」
- Swup 管理サイトでは素の `history.replaceState(null, ...)` を入れない（プロジェクト AGENTS.md）
- CSS 変更時はプロジェクトの style guide / Cursor CSS ルールに従う
- コミットはユーザーが頼んだときだけ。このスキルではコミットしない
