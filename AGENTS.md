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
5. Update documentation (add details to `docs/content/docs`, use README as an entry point)
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
- Use GNU Stow for symlink deployment
- Before deploy, read `/.deploy_subdir` and create required directories with `mkdir -p`
- Use `README.md` as an entry point; put detailed steps/background in `docs/`
- Follow existing style (frontmatter, naming, hierarchy) when creating files

## Commit Messages (Optional, Recommended)
- Follow Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`, etc.
- One change per commit (keep changes small)

## How to Request (Human → Agent)
- State what you want to do and where (e.g., "Add AGENTS.md", "Add to docs")
- Indicate consistency with existing implementation (e.g., use stow, use justfile recipes)
- Specify output language (Japanese/English) and location (README or docs)

## Repository-Specific Knowledge
- Main operations are summarized in the root `justfile`
- Documentation is managed as MDX in `docs/content/docs` and published on the site
- Navigation is auto-completed by `meta.json` (usually just add a page)

## References
- GNU Stow: https://www.gnu.org/software/stow/
- just: https://github.com/casey/just
- sheldon: https://github.com/rossmacarthur/sheldon
