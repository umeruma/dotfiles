---
name: wt-slots
description: "課題管理ツール（Notion / GitHub Issues など）の未着手タスクを、固定スロットの worktree + 固定ポート dev サーバーで並列に実装し、ユーザー確認を挟んでマージまで回すオーケストレーション。Use when: タスクリストをまとめて実装する, オーケストレーションしながら対応, タスクごとにworktreeを切ってサーバーで確認してOKならマージ, 複数タスクを並列で進める, Notionの実装未着手を消化する。単発タスクには使わない（git-wt / dev-server で足りる）。"
argument-hint: "[タスク一覧の URL やタスク名]"
---

# wt-slots（worktree スロット並列オーケストレーション）

複数タスクを「1 タスク = 1 ブランチ = 1 worktree」で並列実装し、**スロットごとの dev サーバーでユーザーが確認 → OK が出たものだけマージ**する進め方。

エージェント（Task/Agent tool）に実装を委譲し、自分はオーケストレーターとして確認とマージに専念する。

## When to Use

- 課題管理ツールの未着手タスクを、まとめて消化するとき
- 「タスクごとに worktree を切って、サーバーで確認して、OK ならマージ」と言われたとき
- 3 件以上のタスクが独立していて、並列に進める価値があるとき

単発タスクなら使わない。[git-wt] と [dev-server] で足りる。

---

## 一度だけの準備

### 1. worktree の置き場（重要）

**`.git/` 配下に worktree を置くと Vite が動かない。** Vite の `server.fs.deny` 既定に `**/.git/**` が含まれるため、`git wt` の既定 basedir（`.git/wt/`）だと全アセットが `outside of Vite serving allow list` になる。

```sh
git config wt.basedir ".wt"          # repo 直下。launch.json の cwd はプロジェクト内限定なので repo 外も不可
echo ".wt/" >> .git/info/exclude     # コミットせず無視
```

### 2. 依存の自動インストール

```sh
git config --add wt.hook "mise x -- bun install"
```

hook のシェルは mise の shims を見ないので、**素の `bun` / `npm` は使えない**。`mise x --` を必ず挟む。
node_modules は worktree ごとに持たせる（`node_modules/.vite` を共有すると並走 dev が落ちる）。

### 3. スロットの dev サーバー（`.claude/launch.json`）

並列数ぶんのスロットを固定ポートで用意する。3 スロット（4321/4322/4323）が扱いやすい。

```json
{
  "name": "slot-1",
  "runtimeExecutable": "mise",
  "runtimeArgs": ["run", "_dev", "--", "--port", "4321"],
  "cwd": ".wt/slot-1",
  "port": 4321
}
```

- `cwd` は**プロジェクトルートからの相対パス**（外は拒否される）
- `mise run <task> -- <args>` でタスクに引数を渡せる
- `preview_start {name: "slot-1"}` でそのスロットの worktree からサーバーが立つ

---

## 進め方

### タスクの割り当て

**同じページ・同じコンポーネントを触るタスクは同じスロットで直列**、別ページのものを並列にする。コンフリクトはこれでほぼ避けられる。

どうしても同じファイルを触る 2 件を並列にするなら、**担当範囲を明示的に分ける**（例: 一方は演出の TSX、他方はレイアウト CSS）とマージが通る。

ブランチは常に**マージ後の最新**から切る。

### 1 タスクのループ

```
1. 作成    git wt -b feat/<slug> slot-N
2. 実装    Agent に委譲（background）。完了通知を待つ
3. 起動    preview_start {name: "slot-N"}
4. 自己確認 read_console_messages / preview_logs / javascript_tool で計測
5. ユーザー確認  URL と見どころを提示して待つ
6a. OK  → preview_stop → git merge --no-ff feat/<slug> → git wt -d feat/<slug> → 次へ
6b. NG  → 自分で直すか、Agent に追加指示 → HMR で反映 → 4 へ
```

### 確認依頼の出し方

**表で出す。列は slot / タスクのリンク / ブランチ / URL / 見どころ。**
タスクのリンクは必須。ユーザーはその場で課題管理ツールのステータスを更新するため。

エージェントの報告のうち、**判断が分かれた点と「デザインにない部分をどう解釈したか」は必ず伝える**。そこが差し戻しの起点になる。

---

## エージェントへの委譲テンプレ

```
worktree: <絶対パス>（すべてのコマンドは cd してから実行。他の worktree やメインツリーには触らない）
ブランチ: feat/<slug>（作成済み、node_modules インストール済み）
タスク: <URL>
  - 本文を読む。スクリーンショットは curl で scratchpad に落として実際に見る
  - Figma リンクがあれば Figma MCP（get_design_context / get_screenshot）で実寸を取る
やること: このタスクだけを実装。最小差分。既存パターンを踏襲
禁止: push / 課題管理ツールへの書き込み / 他タスクの先回り / astro build（dev と Vite キャッシュが衝突する）
確認: <型チェックコマンド> が通ること
コミット: conventional commit（英語）
報告: 変更ファイル / 確認 URL と見どころ（PC・SP、数値付き）/ 判断に迷った点 / チェック結果
```

**並列タスクが同じファイルを触る場合は、担当範囲の線引きをテンプレに書く。**

---

## 落とし穴

| 症状 | 原因 / 対処 |
|---|---|
| dev で全アセットが 403 / `outside of Vite serving allow list` | worktree が `.git/` 配下。`wt.basedir` を `.wt` に |
| `cwd must be a relative path within the project root` | launch.json の `cwd` が repo 外。repo 内に置く |
| wt.hook が `command not found` | mise の shims が無い。`mise x -- <cmd>` に |
| 日本語の行アニメーションが CSS の折り返しとズレる | SplitText の既定は空白区切り。和文境界の `wordDelimiter` を渡す |
| デザインと折り返しが違う | 明示的な `<br>` を足す前に、まず **letter-spacing と本文幅**を疑う。過去のコミットで値が変わっていることがある |
| 「見た目が揃わない」 | box は揃っていても字面がズレている。フォントのサイドベアリングを計測して `text-indent` で寄せる |
| マージ後に別ページが壊れる | 共通コンポーネントの変更。**共有先のページも必ず回帰確認する**（報告にも書かせる） |

## 課題管理ツールへの書き込み

**ステータス変更・コメント追加は勝手にしない。** ユーザーが自分で管理していることが多い。
本文への追記が要る場合も、冒頭に `実装メモ：` として最小限にとどめ、明示的に頼まれたときだけ行う。

## 終わったら

- `git wt` で残 worktree がないことを確認
- 最後に 1 回フルビルドを通す（レビュー中は dev と衝突するので走らせない）
- push はユーザーの判断。勝手にしない

[git-wt]: ../git-wt/SKILL.md
[dev-server]: ../dev-server/SKILL.md
