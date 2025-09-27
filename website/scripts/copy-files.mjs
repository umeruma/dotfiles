import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(__dirname, "..");
const repoRoot = path.resolve(websiteRoot, "..");

const src = path.join(repoRoot, "install");
const dest = path.join(websiteRoot, "public", "install");

/**
 * Copy install script to website public directory
 */
fs.mkdirSync(path.dirname(dest), { recursive: true });
if (!fs.existsSync(src)) {
  console.error("install not found:", src);
  process.exit(1);
}
fs.copyFileSync(src, dest);

console.log("copied:", src, "->", dest);

/**
 * Copy README.md to website src/content/docs/index.md
 */
const srcReadme = path.join(repoRoot, "README.md");
const destReadme = path.join(websiteRoot, "src/content/docs", "index.md");

fs.mkdirSync(path.dirname(destReadme), { recursive: true });
if (!fs.existsSync(srcReadme)) {
  console.error("README.md not found:", srcReadme);
  process.exit(1);
}
fs.copyFileSync(srcReadme, destReadme);

console.log("copied:", srcReadme, "->", destReadme);