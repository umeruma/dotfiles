import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const websiteRoot = path.resolve(__dirname, "..");
const repoRoot = path.resolve(websiteRoot, "..");

const copies = [
  { src: "install", dest: "install" },
  { src: "install-win", dest: "install-win" },
];

for (const { src: srcName, dest: destName } of copies) {
  const src = path.join(repoRoot, srcName);
  const dest = path.join(websiteRoot, "public", destName);

  fs.mkdirSync(path.dirname(dest), { recursive: true });
  if (!fs.existsSync(src)) {
    console.error("not found:", src);
    process.exit(1);
  }
  fs.copyFileSync(src, dest);
  console.log("copied:", src, "->", dest);
}
