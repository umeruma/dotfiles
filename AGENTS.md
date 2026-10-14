# AGENTS.md

This document is a guide for safe and productive collaboration between AI agents (e.g., GitHub Copilot / Copilot Chat) and human maintainers in this repository.

## Purpose
- Make precise, minimal changes to keep the repository stable
- Document important knowledge (policies, structure, rules) for easy sharing
- Consolidate changes in `docs/` rather than in the README

## Recommended Workflow
1. Break down tasks and create a TODO list (small, observable steps)
2. Gather context (search, then read large relevant file sections)
3. Make minimal diffs (avoid unrelated formatting)
4. Run quality gates and report results (Build / Lint / Typecheck / Test)
5. Update documentation (add details to `docs/src/content/docs`, use README as an entry point)
6. Record changes, results, and follow-ups concisely

## Quality Gates (Keep Green)
- Build: Ensure builds and scripts are not broken
- Lint/Typecheck: Pass static analysis
- Tests: All existing tests must PASS; if none, record a small manual check
- Example report: `Build: PASS / Lint: PASS / Tests: N/A`

## Safety and Prohibited Actions
- Avoid leaking secrets (tokens, cookies, environment variables)
- Destructive actions (e.g., `rm -rf ~`, forced push) are forbidden
- Minimize external network calls and document the reason when needed
- Only change global OS/tool settings with explicit consent

## Coding and Structure Guidelines
- Symlinks for `home/` and `home-win/` are declared in `[dotfiles]`, split by OS: `mise.dotfiles.toml` (all), `mise.unix.toml`, `mise.windows.toml`, `mise.macos.toml`; deploy with `mise run deploy` on every OS
- Dirs that receive runtime writes (karabiner, micro, lazygit, hammerspoon) get per-file entries — never whole-dir symlinks
- Fresh Unix setup converges via `mise bootstrap` (see `docs/src/content/docs/mise-bootstrap.mdx`)
- Use `README.md` as an entry point; put detailed steps/background in `docs/`
- Follow existing style (frontmatter, naming, hierarchy) when creating files

## Commit Messages (Optional, Recommended)
- Follow Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`, etc.
- One change per commit (keep changes small)

## How to Request (Human → Agent)
- State what you want to do and where (e.g., "Add AGENTS.md", "Add to docs")
- Indicate consistency with existing implementation (e.g., use `[dotfiles]` entries, use mise tasks)
- Specify output language (Japanese/English) and location (README or docs)

## Repository-Specific Knowledge
- Main operations are mise tasks in root `mise.toml` (`mise tasks` / `mise run …`)
- Machine bootstrap (packages, login shell, deploy) uses `mise bootstrap`
- `.miserc.toml` sets `auto_env = true` so `mise.linux.toml` / `mise.macos.toml` load
- Documentation is managed as MDX in `docs/src/content/docs` and published on the site
- Navigation is auto-completed by `meta.json` (usually just add a page)
- `.githooks/pre-commit` runs gitleaks (from `[tools]` in `mise.toml`) on staged changes; `mise run deploy` sets `core.hooksPath`

## References
- mise: https://mise.jdx.dev/
- mise bootstrap: https://mise.jdx.dev/bootstrap.html
- sheldon: https://github.com/rossmacarthur/sheldon

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: `npx openskills read <skill-name>` (run in your shell)
  - For multiple: `npx openskills read skill-one,skill-two`
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>natural-japanese</name>
<description>仕事の日本語文書を読みやすくわかりやすく書く・直すためのスキル。議事録（文字起こしからの議事録化を含む）、調査レポート・分析レポート、社内ガイド・マニュアル、リサーチメモ・ディスカッションペーパー・企画書・提案書・報告書・メール、スライド構成案といったビジネス文書の作成・校正、「結論から書いて」「論旨を明確に」「見出しを端的に」「専門用語をわかりやすく説明して」といった指示のいずれでも使用する。AI臭さの除去（「AIっぽい」「AI臭い」「機械翻訳っぽい」「不自然」「もっと自然な日本語に」「機械っぽい」「人間っぽくして」「単調」「〜することができる、と言えるだろう、のような言い回し」といった直接・間接・口語の指摘、AIで書いたと言われた/疑われた）、読みにくい・わかりにくい文章の改善依頼（語順がおかしい、一文が長い、何が言いたいか分からない、読点の位置がおかしい等）、note記事やブログ記事・エッセイの新規執筆（任意のテーマをゼロから書く・書き起こす依頼を含む）、既存文章のリライト・推敲、AI臭さの診断・採点（「この文章AIが書いた？」「AI臭さをスコアで出して」「どれくらいAIっぽいか判定して」という書き換えを伴わない依頼）、自分の文体を学ばせたい・プロファイル化したいという要望（過去の文章を読ませて自分らしく書いてほしいという依頼も含む）にも対応する。禁止語の除去、リズムの単調さ・段落構造の均質さ・英語統語の直訳調に加え、語順・読点・一文一義・主語述語の距離といった読みやすさの原則にも対応する。技術文書の章構成やMarkdownフォーマットの整形自体（一文一行化・引用ブロック・脚注記法など）は対象外——それは別スキルの領域であり、本スキルは文章の自然さ・読みやすさ・わかりやすさに特化する。</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
