# Task

Extract **durable repository knowledge** from the development session below.
You already have enough context below — **do not explore the filesystem**.
Respond with **only** the JSON object (fence optional).

## Output contract (mandatory)

```json
{
  "summary": "1-3 sentences: what durable knowledge was found",
  "session_ids": ["file-dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": "src/auth",
      "action": "merge",
      "section": "Design decisions",
      "content": "- Bullet one\n- Bullet two",
      "evidence": ["short quote"],
      "confidence": "high"
    }
  ]
}
```

### Field rules
- `kind`: `"dev"` (architecture/decisions/patterns/pitfalls) or `"usage"` (commands/setup/debug)
- `path`: **must be one of the existing directories listed below** (or `"."`). Never invent paths.
  Prefer code modules under `src/`. **Never** use `tests/`, `docs/`, `fixtures/`, `assets/`, or `scripts/` as knowledge homes.
- `section`: **must** be one of:
  - DEV: `Architecture` | `Design decisions` | `Patterns` | `Pitfalls`
  - USAGE: `Setup` | `Common commands` | `Debugging` | `Troubleshooting`
- `content`: markdown bullets only; concrete and non-duplicative of existing knowledge
- `confidence`: `high` | `medium` | `low`
- Prefer 1–6 units. When both design and commands appear, emit **both** kinds.
- **No secrets**. Never copy tokens, keys, or `.env` values.
- **Anti-restate (R6):** If the session only restates claims already listed in the
  claim index / existing knowledge, return `"units": []`. Prefer empty over paraphrase.

## Session
- **id:** `file-dogfood-luffy-session`
- **source:** `file`

### Transcript

We built and operate Luffy, a comment-triggered PR review agent (Hermes + OpenRouter + hub memory).

Durable knowledge for this repository follows from the architecture and operations below.
Key decisions and workflows to preserve in DEV.md / USAGE.md colocated with the control plane (agent/, scripts/, memory/, .github/).

# Source: docs/ARCHITECTURE.md

# Luffy architecture

## One sentence

Luffy is a gated GitHub Actions control plane that assembles a bounded PR context, runs Hermes Agent + OpenRouter with a growing `MEMORY.md`, validates Markdown against a fixed contract, and always publishes the result as a PR comment.

## Flow

```text
@luffy review this pr
    → gate + concurrency
    → dual checkout (luffy/ + workspace/)
    → restore HERMES_HOME memory
    → assemble-context → hermes -z → normalize → PR comment
    → distill MEMORY.md → cache + artifacts
```

## Stages

| Stage | Script | Responsibility |
|-------|--------|----------------|
| Assemble | `scripts/assemble-context.sh` | `gh pr` meta + diff + prompt (no LLM) |
| Review | `scripts/run-hermes-review.sh` | Hermes one-shot on `WORKSPACE_ROOT` |
| Normalize | `scripts/normalize-review.py` | Contract, fences, size, HTML marker |
| Distill | `scripts/distill-memory.sh` | Append structured memory block |
| Post | `scripts/post-review-comment.sh` | Delete prior `<!-- luffy-review pr=N` comments, then `gh pr comment` |
| Orchestrate | `scripts/run-luffy-review.sh` | Compose stages + timings |
| Trace | `scripts/save-trace.sh` | Redacted per-run package → Actions artifact |
| Hub publish | `scripts/publish-run-to-hub.sh` | `repository_dispatch` → hub |
| Hub ingest | `scripts/hub-ingest-run.py` | Commit `memory/repos/{slug}/…` on hub |

## Dual workspace

| Path | Contents |
|------|----------|
| `luffy/` | Agent SOUL, prompts, scripts (from default branch) |
| `workspace/` | PR head only (code under review) |
| `.luffy-hermes-home/` | Hermes config + growing memory (cached) |

## Memory layers

1. **L0** — single-run Hermes home  
2. **L1** — Actions cache of `.luffy-hermes-home`  
3. **L2** — workflow artifacts (debug + memory snapshots)  
4. **Distill** — explicit append after each review  

## Security

- PR body/diff treated as untrusted data  
- Least-privilege token permissions  
- Secrets only via env / Hermes `.env` (mode 0600)  
- No formal GitHub “request changes” review API in v1 (comment only)  

## Packaging (future)

Reusable `workflow_call` so app repos only need a thin caller.

# Source: docs/OPERATIONS.md

# Luffy operations

## Required setup

1. Put this project (or at least `agent/`, `scripts/`, `.github/workflows/luffy-pr-review.yml`) on the **default branch** of a GitHub repo.
2. Repository secret: `OPENROUTER_API_KEY`
3. Optional variable: `LUFFY_MODEL` (default in scripts: `openai/gpt-5-mini`)
4. On a PR, comment: `@luffy review this pr`

## High-ROI fixes

See [ROI-FIXES.md](ROI-FIXES.md) for the ranked backlog.

- **Sprint 1 (F1–F6):** shallow+sparse checkout, Hermes install cache, hub memory preload, drop broken home cache, reactions, shallow hub clone  
- **Sprint 2 (F11–F12):** author association allowlist, replace previous Luffy PR comment  
- **Sprint 3 (F13–F17):** sparse count bugfix, stable Hermes cache key, honest fail reaction, deny 😕, drop dead install copy

## Central hub memory (cross-repo)

All target repos publish each run to the hub:

**Hub:** `Mr-Ashish/luffy-pr-review-agent`  
**Path:** `memory/repos/{owner}--{repo}/`

### Flow

```text
Target Luffy run finishes
  → build-hub-payload.py (redacted, size-capped)
  → publish-run-to-hub.sh
       default mode=direct:
         clone hub → hub-ingest-run.py → commit memory/ → push main
       optional mode=dispatch:
         repository_dispatch luffy-run → Ingest Luffy Run workflow
```

> **Note:** `GITHUB_TOKEN` cannot call `repository_dispatch` (HTTP 403).  
> Default **direct** push works with `contents: write` on the hub (self-review) or a PAT on target repos.

### Target repo secrets / vars

| Name | Required | Purpose |
|------|----------|---------|
| `LUFFY_HUB_TOKEN` | yes (cross-repo) | PAT with contents write on the hub repo |
| `LUFFY_HUB_REPO` | no | Default `Mr-Ashish/luffy-pr-review-agent` |
| `LUFFY_HUB_MODE` | no | `direct` (default), `dispatch`, or `both` |
| `LUFFY_HUB_PUBLISH` | no | Set `0` to disable |

When Luffy runs **on the hub repo itself**, `GITHUB_TOKEN` + `contents: write` is enough for direct ingest.

### Hub workflow (optional dispatch path)

- File: `.github/workflows/ingest-luffy-run.yml`
- Trigger: `repository_dispatch` type `luffy-run` (needs classic PAT from target)
- Permission: `contents: write`

## Manual dispatch

Actions → **Luffy PR Review** → Run workflow → enter PR number.

## Local dry-run

```bash
cd pr-review-agent
# .env with OPENROUTER_API_KEY
./scripts/review-local.sh owner/repo 123
POST_COMMENT=1 ./scripts/review-local.sh owner/repo 123
```

Requires: `gh` authenticated, network for Hermes install + OpenRouter.

## Failure UX

| Failure | What users see |
|---------|----------------|
| Missing OpenRouter secret | PR comment explaining config error |
| Hermes/model failure | PR comment with low-confidence COMMENT verdict |
| Job crash before review file | Always-post step writes failure stub + comments |

## Cost controls

- Explicit comment trigger only (no auto on every push)
- **Author association allowlist** (default `OWNER,MEMBER,COLLABORATOR,CONTRIBUTOR`) — override with repo variable `LUFFY_ALLOWED_ASSOCIATIONS` (comma list; empty = no gate)
- Concurrency cancel-in-progress per PR
- Diff size cap (`MAX_DIFF_BYTES`, default 400000)
- Job timeout 45 minutes
- Re-runs **replace** prior Luffy comments on the same PR (marker `<!-- luffy-review pr=N`); set `LUFFY_REPLACE_PREVIOUS=0` to stack

## Memory

- Path: `.luffy-hermes-home/memories/MEMORY.md`
- Grows via `distill-memory.sh` after each review
- Rotates when exceeding `MAX_MEMORY_BYTES` (default 100000)
- Gitignored; restored via Actions cache

## Debug

- Download artifact `luffy-out-pr<N>-run<id>` — full `.luffy-out/` + memory snapshot (14 days)
- Download artifact **`luffy-trace-pr<N>-run<id>`** — structured per-run trace (90 days)

### Per-run trace layout

```text
traces/pr{N}-run{RUN_ID}-a{ATTEMPT}/
  meta.json          # identity, status, timings pointer, file hashes
  trace.json         # index
  prompt.md          # agent prompt
  context.md         # PR context
  pr.json / pr.diff  # GitHub PR data
  review.raw.md      # Hermes stdout
  review.md          # normalized posted body
  hermes.stderr      # errors if any
  timings.json       # stage durations
  memory-before.md   # MEMORY.md before review (if any)
  memory-after.md    # MEMORY.md after distill
```

Secrets (`sk-or-…`, `[REDACTED] common `ghp_`/`github_pat_` tokens) are redacted in **posted review bodies** (`normalize-review.py`, F18) and again before trace packaging / hub payload.

```bash
# Download latest trace for a run
gh run download <run-id> -R owner/repo -n luffy-trace-pr1-run<run-id>
```

# Scripts inventory
assemble-context.sh
association-allowed.sh
build-hub-payload.py
capture-hermes-loop.py
distill-memory.sh
hub-ingest-run.py
normalize-review.py
post-review-comment.sh
preload-hub-memory.sh
publish-run-to-hub.sh
review-local.sh
run-hermes-review.sh
run-luffy-review.sh
save-trace.sh
sparse-pr-paths.sh
write-failure-review.sh

# F18 (2026-07-31): Secret redaction on posted PR reviews
normalize-review.py now redacts OpenRouter keys (sk-or-v1-…), [REDACTED], api_key-style assignments, and common GitHub tokens (ghp_/gho_/ghu_/ghs_/ghr_ and github_pat_) before writing the review body that gets posted as a PR comment and later distilled. Patterns align with save-trace.sh and build-hub-payload.py so traces, hub payloads, and live comments share the same scrub policy. Redaction runs both before contract repair (so fallback 'raw agent output' is scrubbed) and after ensure_contract.

# agent/ SOUL trust model still applies; F18 is mechanical enforcement at the post choke-point.


## Existing directories (allowed `path` values)

```
.
demo
readme-kit
readme-kit/bin
readme-kit/packs
readme-kit/packs/ai-agent
readme-kit/examples
readme-kit/examples/luffy
readme-kit/examples/luffy/branding
readme-kit/examples/luffy/diagrams
readme-kit/scripts
readme-kit/themes
readme-kit/src
readme-kit/src/render
readme-kit/src/assets
memory
memory/repos
memory/repos/Mr-Ashish--odoo
memory/repos/Mr-Ashish--odoo/runs
memory/repos/Mr-Ashish--luffy-pr-review-agent
memory/repos/Mr-Ashish--luffy-pr-review-agent/runs
agent
```

## Repository snapshot

### git status
```
M DEV.md
 M docs/OPERATIONS.md
 M docs/ROI-FIXES.md
 M scripts/normalize-review.py
 M tests/test_normalize_review.py
?? docs/experiments/
```

### recent log
```
0cfa72c Add colocated DEV/USAGE from devmemory dogfood on Luffy
dea239c brand: use Three.js orbital core as README hero artifact
6a938b1 feat(brand): Three.js square artifact gallery (not banners)
0b578c4 fix(readme-kit): repair package.json; link brand options in docs
8d24dec feat(brand): 8 code-generated hero banner options for review
```

### tree (sample)
```
DEV.md
README.generated.md
README.md
USAGE.md
demo/__init__.py
demo/hello.py
readme-kit/README.md
readme-kit/package-lock.json
readme-kit/package.json
readme-kit/bin/readme-kit.mjs
readme-kit/packs/ai-agent/pack.json
readme-kit/examples/luffy/README.generated.md
readme-kit/examples/luffy/readme.config.json
readme-kit/examples/luffy/readme.config.yaml
readme-kit/scripts/generate-hero-options.mjs
readme-kit/themes/flame.json
readme-kit/themes/terminal.json
readme-kit/src/build.mjs
readme-kit/src/cli.mjs
readme-kit/src/load.mjs
readme-kit/src/render/badges.mjs
readme-kit/src/render/document.mjs
readme-kit/src/assets/hero-options.mjs
readme-kit/src/assets/hero-svg.mjs
memory/DEV.md
memory/README.md
memory/index.json
memory/repos/Mr-Ashish--odoo/MEMORY.md
memory/repos/Mr-Ashish--odoo/latest.json
memory/repos/Mr-Ashish--luffy-pr-review-agent/MEMORY.md
memory/repos/Mr-Ashish--luffy-pr-review-agent/latest.json
tests/test_gate_helpers.py
tests/test_hub_ingest.py
tests/test_normalize_review.py
agent/DEV.md
agent/MEMORY.seed.md
agent/SOUL.md
agent/config.yaml
agent/review-prompt.md
docs/ARCHITECTURE.md
docs/OPERATIONS.md
docs/README-BRANDING-ECOSYSTEM.md
docs/README-KIT-MVP.md
docs/ROI-FIXES.md
docs/experiments/2026-07-31-roi-fire.md
docs/blog/building-luffy-agentic-pr-review.md
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/README.md
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/context.md
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/e2e-agentic-trace.mmd
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/files.txt
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/hermes-run.log
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/hermes-usage.json
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/hermes.stderr
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/memory-after.md
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/meta.env
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/meta.json
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/pr.diff
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/pr.json
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/prompt.md
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/review.md
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/review.raw.md
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/timings.json
docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/trace.json
docs/showcase/devmemory-dogfood-luffy/README.md
docs/showcase/devmemory-dogfood-luffy/apply.json
docs/showcase/devmemory-dogfood-luffy/extract.raw.md
docs/showcase/devmemory-dogfood-luffy/hermes-usage.json
docs/showcase/devmemory-dogfood-luffy/meta.env
docs/showcase/devmemory-dogfood-luffy/preview.diff
docs/showcase/devmemory-dogfood-luffy/preview.json
docs/showcase/devmemory-dogfood-luffy/prompt.md
docs/showcase/devmemory-dogfood-luffy/repo-context.md
docs/showcase/devmemory-dogfood-luffy/session.md
docs/showcase/devmemory-dogfood-luffy/summary.md
docs/showcase/devmemory-dogfood-luffy/timings.json
docs/showcase/devmemory-dogfood-luffy/units.json
scripts/assemble-context.sh
scripts/association-allowed.sh
scripts/build-hub-payload.py
scripts/capture-hermes-loop.py
scripts/distill-memory.sh
scripts/hub-ingest-run.py
scripts/normalize-review.py
scripts/post-review-comment.sh
scripts/preload-hub-memory.sh
scripts/publish-run-to-hub.sh
scripts/review-local.sh
scripts/run-hermes-review.sh
scripts/run-luffy-review.sh
scripts/save-trace.sh
scripts/sparse-pr-paths.sh
scripts/write-failure-review.sh
assets/README.md
assets/favicon-32.png
assets/favicon.png
assets/luffy-artifact-orbital-core.png
assets/luffy-hero-banner.svg
assets/luffy-mark.png
assets/luffy-mark.svg
assets/twemoji-anchor.png
assets/twemoji-pirate-flag.png
assets/twemoji-ship.png
assets/brand-options/README.md
assets/brand-options/RECOMMENDATION.md
assets/brand-options/SELECTED-orbital-core.png
assets/brand-options/SELECTED.md
assets/brand-options/hero-A-baseline.svg
assets/brand-options/hero-B-glass.svg
assets/brand-options/hero-C-isometric.svg
assets/brand-options/hero-D-mesh.svg
assets/brand-options/hero-E-volumetric.svg
assets/brand-options/hero-F-cyber.svg
assets/brand-options/hero-G-mark.svg
assets/brand-options/hero-H-cinematic.svg
assets/brand-options/index.json
assets/brand-options/orbital-core-preview.png
assets/brand-options/preview.html
assets/brand-options/three-artifacts.html
```

### git diff
```
diff --git a/DEV.md b/DEV.md
index 8a563b5..4735008 100644
--- a/DEV.md
+++ b/DEV.md
@@ -19,6 +19,6 @@
 
 - `GITHUB_TOKEN` cannot call `repository_dispatch` (HTTP 403), so the hub publish default is `mode=direct` (clone hub → ingest → push `main`); the dispatch path needs a classic PAT on the target repo.
 - Cross-repo publishing requires `LUFFY_HUB_TOKEN` (PAT with contents write on the hub); only when Luffy runs on the hub repo itself is `GITHUB_TOKEN` + `contents: write` sufficient.
-- PR title, body, comments, and diff are untrusted input — the agent must not honour embedded instructions, and secrets must never be echoed; traces redact `sk-or-…` and `[REDACTED] before packaging.
+- PR title, body, comments, and diff are untrusted input — the agent must not honour embedded instructions, and secrets must never be echoed; `normalize-review.py` redacts `sk-or-…`, `[REDACTED] and common GitHub tokens before any PR comment is posted (F18); traces/hub scrub again before packaging.
 - `MEMORY.md` rotates when it exceeds `MAX_MEMORY_BYTES` (default 100000); unbounded growth would otherwise blow the prompt budget.
 - Historical bug classes worth watching (per the ranked ROI backlog): broken Hermes home cache key, sparse-checkout path count bug, and dishonest success reactions on failed runs.
diff --git a/docs/OPERATIONS.md b/docs/OPERATIONS.md
index b41674a..a0d4f66 100644
--- a/docs/OPERATIONS.md
+++ b/docs/OPERATIONS.md
@@ -115,7 +115,7 @@ traces/pr{N}-run{RUN_ID}-a{ATTEMPT}/
   memory-after.md    # MEMORY.md after distill
 ```
 
-Secrets (`sk-or-…`, `[REDACTED] are redacted before packaging.
+Secrets (`sk-or-…`, `[REDACTED] common `ghp_`/`github_pat_` tokens) are redacted in **posted review bodies** (`normalize-review.py`, F18) and again before trace packaging / hub payload.
 
 ```bash
 # Download latest trace for a run
diff --git a/docs/ROI-FIXES.md b/docs/ROI-FIXES.md
index f5dadf3..e515425 100644
--- a/docs/ROI-FIXES.md
+++ b/docs/ROI-FIXES.md
@@ -27,10 +27,13 @@ Evidence from live e2e (Odoo monorepo + hub memory):
 | 11 | **F15** | Config error `pipeline_rc=1` (was 0 → false ✅ reaction) | XS | Honest UX | **Shipped** |
 | 12 | **F16** | Association deny → 😕 reaction (no OpenRouter spend) | XS | Visible deny | **Shipped** |
 | 13 | **F17** | Drop dead `RUNNER_TEMP` Hermes tree copy after cold install | XS | Faster cold path | **Shipped** |
-| 14 | F7 | Pin Hermes version string | S | Repro | Later |
-| 15 | F8 | Docker image with Hermes preinstalled | M | Fastest CI | Later |
-| 16 | F9 | Inline GitHub review comments | L | Product | Later |
-| 17 | F10 | Reusable workflow_call packaging | M | Multi-repo DX | Later |
+| 14 | **F18** | Redact secrets in **posted** review (`normalize-review.py` choke-point) | XS | 🔥 Trust — no keys on PR comments | **Shipped** |
+| 15 | F7 | Pin Hermes version string (`--commit` / `LUFFY_HERMES_COMMIT`) | S | Repro | Next |
+| 16 | F19 | Per-PR re-trigger cooldown (skip paid run after recent success) | S | Cost/abuse | Later |
+| 17 | F20 | `scripts/install-luffy.sh` copy pack to target repo | S | Adoption | Later |
+| 18 | F8 | Docker image with Hermes preinstalled | M | Fastest CI | Later |
+| 19 | F9 | Inline GitHub review comments | L | Product | Later |
+| 20 | F10 | Reusable workflow_call packaging | M | Multi-repo DX | Later |
 
 ### Sprint 1 (shipped)
 
@@ -44,6 +47,10 @@ Evidence from live e2e (Odoo monorepo + hub memory):
 
 **F13–F17** correctness + cache + reaction honesty.
 
+### Sprint 4 (shipped)
+
+**F18** secret redaction on normalize → PR comment path (aligned with trace/hub scrub patterns).
+
 ### readme-kit (shipped)
 
 YAML config (preferred) + JSON parity; `yaml` npm dep; dead hand-rolled parser removed.
diff --git a/scripts/normalize-review.py b/scripts/normalize-review.py
index 3c4a35c..1a8f2c3 100755
--- a/scripts/normalize-review.py
+++ b/scripts/normalize-review.py
@@ -30,6 +30,27 @@ SOFT_SECTIONS = (
     "### What I checked",
 )
 
+# F18: scrub secrets before the body hits GitHub PR comments / distill.
+# Keep patterns aligned with scripts/save-trace.sh + build-hub-payload.py.
+_SECRET_PATTERNS: tuple[tuple[re.Pattern[str], str], ...] = (
+    (re.compile(r"sk-or-v1-[A-Za-z0-9_-]{10,}"), "[OPENROUTER_KEY_REDACTED]"),
+    (re.compile(r"([REDACTED] r"\1[REDACTED]"),
+    (
+        re.compile(r"(api[_-]?key[\"']?\s*[:=]\s*[\"']?)([^\"'\s]+)", re.I),
+        r"\1[REDACTED]",
+    ),
+    (re.compile(r"gh[pousr]_[A-Za-z0-9_]{20,}"), "[GITHUB_TOKEN_REDACTED]"),
+    (re.compile(r"github_pat_[A-Za-z0-9_]{20,}"), "[GITHUB_TOKEN_REDACTED]"),
+)
+
+
+def redact_secrets(text: str) -> str:
+    """Remove accidental API keys / tokens from model output before post."""
+    out = text
+    for rx, repl in _SECRET_PATTERNS:
+        out = rx.sub(repl, out)
+    return out
+
 
 def strip_outer_fence(text: str) -> str:
     t = text.strip()
@@ -125,7 +146,10 @@ def main(argv: list[str] | None = None) -> int:
 
     raw = args.input.read_text(errors="replace")
     cleaned = strip_outer_fence(raw)
+    # Redact before contract repair so fallback "raw agent output" is also scrubbed.
+    cleaned = redact_secrets(cleaned)
     final = ensure_contract(cleaned, str(args.pr))
+    final = redact_secrets(final)
     final = final.replace(
         f"<!-- luffy-review pr={args.pr} -->",
         f"<!-- luffy-review pr={args.pr} run={args.run_id} -->",
diff --git a/tests/test_normalize_review.py b/tests/test_normalize_review.py
index 800a12a..1dbacd9 100644
--- a/tests/test_normalize_review.py
+++ b/tests/test_normalize_review.py
@@ -76,6 +76,37 @@ class NormalizeReviewTests(unittest.TestCase):
         self.assertIn("### Security audit", out)
         self.assertIn("looks fine ship it", out)
 
+    def test_redacts_openrouter_key_in_body(self):
+        # F18: posted PR comments must never carry sk-or keys the model echoed.
+        leak = "sk-or-v1-" + ("a" * 40)
+        raw = self._full_contract(summary=f"found key {leak} in logs")
+        out = self.run_norm(raw)
+        self.assertNotIn(leak, out)
+        self.assertIn("[OPENROUTER_KEY_REDACTED]", out)
+        self.assertIn("**Verdict:** APPROVE", out)
+
+    def test_redacts_openrouter_env_assignment(self):
+        raw = self._full_contract(summary="export [REDACTED]
+        out = self.run_norm(raw)
+        self.assertNotIn("sk-secret-value-xyz", out)
+        self.assertIn("[REDACTED] out)
+
+    def test_redacts_github_tokens(self):
+        ghp = "ghp_" + ("B" * 36)
+        pat = "github_pat_" + ("C" * 22)
+        raw = self._full_contract(summary=f"token {ghp} and {pat}")
+        out = self.run_norm(raw)
+        self.assertNotIn(ghp, out)
+        self.assertNotIn(pat, out)
+        self.assertIn("[GITHUB_TOKEN_REDACTED]", out)
+
+    def test_redacts_secrets_in_contract_fallback_raw(self):
+        leak = "sk-or-v1-" + ("d" * 40)
+        out = self.run_norm(f"broken output with {leak}")
+        self.assertNotIn(leak, out)
+        self.assertIn("[OPENROUTER_KEY_REDACTED]", out)
+        self.assertIn("### Raw agent output", out)
+
     def test_truncates_huge(self):
         raw = self._full_contract(summary="x" * 70_000)
         out = self.run_norm(raw)
```

### existing knowledge + claim index (do not repeat / paraphrase these claims)
### claim index (do not restate these claims)
- [DEV.md#Architecture] @luffy action assemble cacheartifact checkout comment concurrency context
- [DEV.md#Architecture] artifact compos deterministic every inner llm-driven orchestr record
- [DEV.md#Architecture] assemble-contextsh contractfencessizehtml distill-memorysh hub-ingest-runpy marker normalize-reviewpy one-shot post-review-commentsh
- [DEV.md#Architecture] branch config default domain luffy luffy-hermes-home memory prompt
- [DEV.md#Design decisions] 400000 45-minute allowlist author-associ cancel-in-progres concurrency control costabuse
- [DEV.md#Design decisions] comment delet luffy luffy-review luffyreplaceprevious=0 marker match prior
- [DEV.md#Design decisions] always-publish comment crash failure hermesmodel low-confidence openrouter produce
- [DEV.md#Pitfalls] 403 cannot classic clone default dispatch githubtoken ingest
- [DEV.md#Pitfalls] content cross-repo githubtoken itself luffy luffyhubtoken publish requir
- [DEV.md#Pitfalls] again agent comment common embedd f18 github honour
- [DEV.md#Pitfalls] 100000 budget default exceed growth maxmemorybyt memorymd otherwise
- [DEV.md#Pitfalls] backlog broken cache class count dishonest historical sparse-checkout
- [memory/DEV.md#Architecture] central doubl every flatten history ingest latestjson memorymd
- [memory/DEV.md#Architecture] build-hub-payloadpy commit default direct hub-ingest-runpy luffy-run memory optional
- [memory/DEV.md#Architecture] cross-repo cross-run hermeshome memory per-job preload preload-hub-memorysh review
- [memory/DEV.md#Architecture] behaviour default direct|dispatch|both disable env-configurable luffyhubmode luffyhubpublish=0 luffyhubrepo
- [agent/DEV.md#Design decisions] added agentsoulmd already chang contract explicitly import invent
- [agent/DEV.md#Design decisions] approve attempt ignore instruc model previou prompt prompt-injection
- [agent/DEV.md#Design decisions] acceptable asymmetric block bugssecurity concrete design discipline elsewhere
- [agent/DEV.md#Design decisions] 0–100 1–5 audit concrete effort every field finding
- [agent/DEV.md#Design decisions] chatter comment contract directly document fence-wrapp markdown normalize-reviewpy
- [USAGE.md#Setup] agent branch default githubworkflowsluffy-pr-reviewyml install script target workflow
- [USAGE.md#Setup] content cross-repo luffyhubtoken memory openrouterapikey requir secret write
- [USAGE.md#Setup] anthr
… [claim index truncated; do not restate] …

### knowledge excerpts
### DEV.md

## Architecture
- Luffy is a gated GitHub Actions control plane, not a chat bot: `@luffy review this pr` → gate + per-PR concurrency → dual checkout → restore Hermes memory → assemble context → `hermes -z` → normalize → PR comment → distill memory → cache/artifacts.
- Orchestration is deterministic shell (`scripts/run-luffy-review.sh` composes stages and records timings); only the inner review step is LLM-driven, so every run leaves reproducible artifacts.
- Stage → script map: assemble-context.sh (gh pr meta + diff + prompt, no LLM), run-hermes-review.sh (Hermes one-shot over `WORKSPACE_ROOT`), normalize-review.py (contract/fences/size/HTML marker), distill-memory.sh, post-review-comment.sh, save-trace.sh, publish-run-to-hub.sh, hub-ingest-run.py.
- Dual workspace separates trust domains: `luffy/` holds SOUL + prompts + scripts from the default branch, `workspace/` holds only the PR head, `.luffy-hermes-home/` holds Hermes config + growing memory.

## Design decisions
- Cost/abuse controls are layered: author-association allowlist (default `OWNER,MEMBER,COLLABORATOR,CONTRIBUTOR`, override with repo var `LUFFY_ALLOWED_ASSOCIATIONS`, empty disables the gate), concurrency cancel-in-progress per PR, `MAX_DIFF_BYTES` (default 400000) diff cap, and a 45-minute job timeout.
- Re-runs replace prior Luffy comments by deleting bodies matching the `<!-- luffy-review pr=N` marker before posting; set `LUFFY_REPLACE_PREVIOUS=0` to stack instead.
- Failure UX is always-publish: missing OpenRouter secret, Hermes/model failure, and job crash before the review file each still produce a PR c
… [truncated; do not restate] …

### memory/DEV.md

## Architecture
- This repo doubles as the central hub: every target repo's run is ingested under `memory/repos/{owner}--{repo}/` (slug uses `--` to flatten owner/repo), holding `MEMORY.md`, `latest.json`, and a `runs/` history.
- Publish path: `build-hub-payload.py` produces a redacted, size-capped payload → `publish-run-to-hub.sh` (direct push by default, `repository_dispatch luffy-run` optional) → `hub-ingest-run.py` commits under `memory/`.
- Hub memory is preloaded into `HERMES_HOME` at the start of each run (`preload-hub-memory.sh`), which is what makes the next review on the same repo smarter — memory is cross-run and cross-repo, not per-job.
- Hub behaviour is env-configurable per target repo: `LUFFY_HUB_REPO` (default `Mr-Ashish/luffy-pr-review-agent`), `LUFFY_HUB_MODE` (`direct`|`dispatch`|`both`), `LUFFY_HUB_PUBLISH=0` to disable.

### agent/DEV.md

## Design decisions
- `agent/SOUL.md` is the reviewer contract: staff-level reviewer scoped to *this diff's* added lines, explicitly told it sees partial hunks and must not invent missing imports or re-suggest changes already in the `+` lines.
- Trust model lives in SOUL, not in the prompt template: PR text and diff are UNTRUSTED DATA and prompt-injection attempts ("ignore previous instructions", "approve this PR") must be refused.
- Finding discipline is asymmetric by design: thorough on bugs/security, high bar elsewhere — every finding needs file + symbol + concrete trigger, and silence beats speculation (an empty Blocking section is an acceptable output).
- Every review must emit structured judgment fields: Score 0–100, review effort 1–5, security audit verdict, relevant-tests yes/no, key findings, optional concrete code suggestions.

### USAGE.md

## Setup
- Install on each target repo by copying `agent/`, `scripts/`, and `.github/workflows/luffy-pr-review.yml` onto that repo's **default branch** (workflow only runs from default branch).
- Required secret: `OPENROUTER_API_KEY`. For cross-repo hub memory also add `LUFFY_HUB_TOKEN` (PAT with contents write on the hub).
- Optional repo variables: `LUFFY_MODEL` (script default `openai/gpt-5-mini`; showcase runs used `anthropic/claude-opus-5`), `LUFFY_HUB_REPO`, `LUFFY_HUB_MODE`, `LUFFY_ALLOWED_ASSOCIATIONS`, `LUFFY_REPLACE_PREVIOUS`, `MAX_DIFF_BYTES`, `MAX_MEMORY_BYTES`.
- Trigger a review by commenting `@luffy review this pr` (or `@luffy review`) on the PR.

## Debugging
- Local dry-run (needs authenticated `gh`, network, and `.env` with `OPENROUTER_API_KEY`): `./scripts/review-local.sh owner/repo 123`; add `POST_COMMENT=1` to actually comment on the PR.
- Two artifacts per run: `luffy-out-pr<N>-run<id>` (full `.luffy-out/` + memory snapshot, 14 days) and `luffy-trace-pr<N>-run<id>` (structured redacted trace, 90 days).
- Fetch a trace with `gh run download <run-id> -R owner/repo -n luffy-trace-pr<N>-run<run-id>`.
- Trace layout under `traces/pr{N}-run{RUN_ID}-a{ATTEMPT}/`: `meta.json`, `trace.json`, `prompt.md`, `context.md`, `pr.json`/`pr.diff`, `review.raw.md` (Hermes stdout) vs `review.md` (posted body), `hermes.stderr`, `timings.json`, `memory-before.md`/`memory-after.md` — diff raw vs normalized to isolate contract violations, and before/after memory to verify distill.


## Final instruction
Return the JSON object now. If nothing **new** durable is present (including when
the session only restates the claim index), return `"units": []`.
