import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { encryptStudyData } from "./encrypt-data.mjs";

const root = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.resolve(root, process.argv[2] || "private_site");
const password = process.env.STUDY_WIKI_PASSWORD;

if (!password) {
  console.error("STUDY_WIKI_PASSWORD is required.");
  process.exit(1);
}

fs.rmSync(outDir, { recursive: true, force: true });
fs.mkdirSync(outDir, { recursive: true });

const files = [
  ["private_index.html", "index.html"],
  ["styles.css", "styles.css"],
  ["app.js", "app.js"],
  ["private-loader.js", "private-loader.js"]
];

for (const [source, destination] of files) {
  fs.copyFileSync(path.join(root, source), path.join(outDir, destination));
}

encryptStudyData({ root, outDir, password });
console.log(`Private encrypted site was built at ${outDir}`);
