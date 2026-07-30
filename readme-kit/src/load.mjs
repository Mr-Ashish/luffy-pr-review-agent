import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const KIT_ROOT = path.resolve(__dirname, "..");

export function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

export function loadConfig(configPath) {
  const abs = path.resolve(configPath);
  if (!fs.existsSync(abs)) {
    throw new Error(`Config not found: ${abs}`);
  }
  const raw = fs.readFileSync(abs, "utf8");
  let config;
  if (abs.endsWith(".json")) {
    config = JSON.parse(raw);
  } else {
    // Minimal YAML: allow JSON-in-YAML file or require JSON for MVP
    throw new Error("MVP supports .json configs only (YAML in next slice). Use readme.config.json");
  }
  config.__path = abs;
  config.__dir = path.dirname(abs);
  return config;
}

export function loadTheme(themeId) {
  const p = path.join(KIT_ROOT, "themes", `${themeId}.json`);
  if (!fs.existsSync(p)) {
    throw new Error(`Unknown theme: ${themeId} (expected ${p})`);
  }
  return loadJson(p);
}

export function loadPack(packId) {
  const p = path.join(KIT_ROOT, "packs", packId, "pack.json");
  if (!fs.existsSync(p)) {
    throw new Error(`Unknown pack: ${packId} (expected ${p})`);
  }
  return loadJson(p);
}

export function resolveMaybeFile(baseDir, value) {
  if (value == null) return null;
  if (typeof value !== "string") return value;
  if (value.includes("\n")) return value; // inline
  const candidate = path.resolve(baseDir, value);
  if (fs.existsSync(candidate) && fs.statSync(candidate).isFile()) {
    return fs.readFileSync(candidate, "utf8");
  }
  return value;
}
