import { cpSync, mkdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { defineConfig } from "astro/config";
import icon from "astro-icon";
import tailwindcss from "@tailwindcss/vite";
import nimbus, { defineConfig as defineNimbusConfig } from "@cloudflare/nimbus-docs";
import { tableScroll } from "@cloudflare/nimbus-docs/markdown";

// The curl/irm installers are the repo-root `install` / `install-win` scripts.
// They must be served verbatim at /install and /install-win (referenced from
// the docs and from the outside world), so copy them into `public/` before
// dev and build. They stay gitignored under public/ — the repo root is the
// single source of truth.
function copyInstallScripts() {
  return {
    name: "copy-install-scripts",
    hooks: {
      "astro:config:setup": () => {
        const publicDir = fileURLToPath(new URL("./public/", import.meta.url));
        mkdirSync(publicDir, { recursive: true });
        for (const name of ["install", "install-win"]) {
          cpSync(
            fileURLToPath(new URL(`../${name}`, import.meta.url)),
            `${publicDir}${name}`,
          );
        }
      },
    },
  };
}

const nimbusConfig = defineNimbusConfig({
  // Canonical origin (no trailing slash). Drives canonical URLs, absolute OG
  // image URLs, robots.txt, sitemap, and the links in /llms.txt.
  site: "https://dot.umeru.ma",
  // Used for <title>, the home H1, the header brand, and OG cards.
  title: "dotfiles",
  description: "umeruma's dotfiles — install and deploy on macOS, Linux, and Windows.",
  locale: "en",
  github: "https://github.com/umeruma/dotfiles",
  socialImageAlt: "dotfiles documentation preview",
});

export default defineConfig({
  site: "https://dot.umeru.ma",
  output: "static",
  // Tailwind v4 via its Vite plugin (the integration Astro recommends for
  // Tailwind v4 — replaces the PostCSS plugin, which doesn't build under
  // Astro 7's Vite 8 bundler).
  vite: {
    plugins: [tailwindcss()],
  },
  // Hover-prefetch link targets so full-page navigations feel instant without
  // a client-side router.
  prefetch: {
    prefetchAll: true,
    defaultStrategy: "hover",
  },
  integrations: [
    copyInstallScripts(),
    icon(),
    nimbus(nimbusConfig, {
      // Frontmatter must validate against the content schema, and broken
      // internal links are 404s for readers — enforce both.
      rules: {
        "nimbus/frontmatter-shape": "error",
        "nimbus/internal-link": "error",
      },
      // Wrap wide tables so they scroll instead of overflowing the page
      // (styled by `.nb-table-scroll` in src/styles/prose.css).
      markdown: {
        hastPlugins: [tableScroll()],
      },
    }),
  ],
});
