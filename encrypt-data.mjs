import crypto from "node:crypto";
import fs from "node:fs";
import vm from "node:vm";
import path from "node:path";
import { pathToFileURL } from "node:url";

export function encryptStudyData({ root, outDir, password }) {
  if (!root || !outDir || !password) {
    throw new Error("root, outDir, and password are required.");
  }

  const dataPath = path.join(root, "data.js");
  const dataCode = fs.readFileSync(dataPath, "utf8");
  const context = { window: {} };
  vm.runInNewContext(dataCode, context, { filename: dataPath });
  const json = JSON.stringify(context.window.STUDY_WIKI_DATA);

  const salt = crypto.randomBytes(16);
  const iv = crypto.randomBytes(12);
  const iterations = 210000;
  const key = crypto.pbkdf2Sync(password, salt, iterations, 32, "sha256");
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);
  const encrypted = Buffer.concat([cipher.update(json, "utf8"), cipher.final()]);
  const tag = cipher.getAuthTag();
  const ciphertext = Buffer.concat([encrypted, tag]);

  const payload = {
    version: 1,
    algorithm: "PBKDF2-SHA256-AES-256-GCM",
    iterations,
    salt: salt.toString("base64"),
    iv: iv.toString("base64"),
    ciphertext: ciphertext.toString("base64")
  };

  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(
    path.join(outDir, "encrypted-data.js"),
    `window.ENCRYPTED_STUDY_WIKI_DATA = ${JSON.stringify(payload, null, 2)};\n`
  );
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    encryptStudyData({
      root: process.argv[2],
      outDir: process.argv[3],
      password: process.env.STUDY_WIKI_PASSWORD
    });
  } catch (error) {
    console.error("Usage: STUDY_WIKI_PASSWORD=... node encrypt-data.mjs <root> <outDir>");
    console.error(error.message);
    process.exit(1);
  }
}
