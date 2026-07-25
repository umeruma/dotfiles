# docs

Documentation site for [dot.umeru.ma](https://dot.umeru.ma), built with
[Nimbus](https://nimbus-docs.com) (Astro) and deployed to Cloudflare Workers.

## Develop

```bash
mise run dev   # or: bun run dev
```

Open http://localhost:4321.

## Content

- `src/pages/index.astro` — the landing page at `/` (hero, install one-liner,
  and cards linking into the docs).
- `src/content/docs/*.{md,mdx}` — documentation pages. The sidebar is derived
  from frontmatter (`sidebar.order`, `sidebar.group.label`).
- `astro.config.ts` — site config via `defineNimbusConfig` (`site`, `title`,
  `github`) and the `copyInstallScripts` integration that copies the repo-root
  `install` / `install-win` scripts into `public/` so they are served at
  `/install` and `/install-win`.
- `public/_headers` — Cloudflare asset headers (immutable `/_astro/*`,
  plain-text installers).

Nimbus ships OG images, `/llms.txt`, `/llms-full.txt`, per-page `.md`/`.mdx`
twins, `robots.txt`, sitemap, and Pagefind search out of the box — see
`src/pages/`. `AGENT.md` documents the layout and authoring rules.

## Build & deploy

```bash
bun run build       # astro build → dist/
bun run preview:cf  # local Cloudflare Workers preview (wrangler dev)
bun run deploy      # astro check && astro build && wrangler deploy
```

The Worker is named `dotfiles` (`wrangler.jsonc`), which is bound to
`dot.umeru.ma`.
