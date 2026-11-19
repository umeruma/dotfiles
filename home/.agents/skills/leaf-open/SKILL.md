---
name: leaf-open
description: "Use when showing the user a markdown file you just wrote or updated (a plan, report, notes, a README draft) inside Rex: open it in leaf in a floating Rex pane instead of only printing its path. Also use when the user asks to view an md/pdf/epub in leaf. Use for: 計画を見せる, leafで開いて, mdを開いて, plan review, レポートを見せる."
---

# leaf で md を見せる

新しく書いた・直した md（計画、レポート、メモなど）をユーザーに見せるときは、Rex のフローティングペインで leaf を開く。leaf で選んだ行へのコメント（ctrl+enter / Enter）は `LEAF_AGENT_PANE` のペインに送られる。指定しないと別のエージェントのペインに届くことがあるので、必ず自分のペイン（`$REX_BLOCK`）を渡す。

## Rex の中（`$REX_BLOCK` があり、`rex` と `leaf` が PATH にある）

zsh の `leaf` 関数は経由しない。エージェントの Bash には TTY が無く、関数が素の `leaf` を呼んでしまい、`failed to initialize terminal` で落ちる。`rex split` を直接呼ぶ。

```sh
rex split -s "$REX_SESSION" -b "$REX_BLOCK" --split=below -c "$PWD" --label leaf -- \
  sh -c '"$1" api call -s "$REX_SESSION" session.float_block \
      "{\"block_id\":\"$REX_BLOCK\",\"bounds\":[0.05,0.05,0.9,0.9]}" >/dev/null 2>&1 ||
      "$1" zoom --on >/dev/null 2>&1 || true
    shift; exec "$@"' \
  sh "$(command -v rex)" env "LEAF_AGENT_PANE=$REX_BLOCK" "$(command -v leaf)" <絶対パス>
```

- `--wait` は付けない。付けると leaf を閉じるまでエージェントが止まる
- 開いたら「leaf で開いた」とだけ伝え、中身の要点は返答にも短く書く

## Rex の外

開かずに、ファイルの絶対パスを伝える。
