# Repository context

- **root:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **assembled_at:** 2026-07-31T17:28:16Z

## git status

```
M USAGE.md
 M agent/DEV.md
 M docs/showcase/devmemory-dogfood-luffy/README.md
 M docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.json
 M docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.md
 M docs/showcase/devmemory-dogfood-luffy/agent-loop/agent.log
 M docs/showcase/devmemory-dogfood-luffy/agent-loop/usage.json
 M docs/showcase/devmemory-dogfood-luffy/apply.json
 M docs/showcase/devmemory-dogfood-luffy/extract.raw.md
 M docs/showcase/devmemory-dogfood-luffy/hermes-usage.json
 M docs/showcase/devmemory-dogfood-luffy/meta.env
 M docs/showcase/devmemory-dogfood-luffy/preview.diff
 M docs/showcase/devmemory-dogfood-luffy/preview.json
 M docs/showcase/devmemory-dogfood-luffy/prompt.md
 M docs/showcase/devmemory-dogfood-luffy/repo-context.md
 M docs/showcase/devmemory-dogfood-luffy/session.md
 M docs/showcase/devmemory-dogfood-luffy/summary.md
 M docs/showcase/devmemory-dogfood-luffy/timings.json
 M docs/showcase/devmemory-dogfood-luffy/units.json
?? .luffy-out-e2e-pr2-f44/
?? .luffy-out-e2e-pr2-f49/
?? .luffy-out-e2e-pr2-h16/
?? .luffy-out-e2e-pr4-f49/
?? .luffy-out-e2e-pr4-h16/
?? .luffy-out-e2e-pr5-f49/
?? .luffy-out-e2e-pr6-f49/
```

## recent log

```
d27b477 feat(review): F51 tool-depth nudge after F49 (H26)
0a201f0 docs(e2e): H24 score odoo#6 F49 mini 34/50 (tools 0→1 shallow)
f67a963 docs(e2e): H23 corpus #6 odoo#279777 street_split → Mr-Ashish/odoo#6
e9bb515 dogfood: F50 severity calibration knowledge + showcase
b075a74 F50/H20: severity calibration for missing-test self-reports
```

## tree (sample)

```
DEV.md
README.generated.md
README.md
USAGE.md
demo/__init__.py
demo/hello.py
ui/DEV.md
ui/review-console/DESIGN.md
ui/review-console/DEV.md
ui/review-console/PRODUCT.md
ui/review-console/README.md
ui/review-console/index.html
ui/review-console/package-lock.json
ui/review-console/package.json
ui/review-console/tsconfig.json
ui/review-console/tsconfig.tsbuildinfo
ui/review-console/vite.config.ts
ui/review-console/src/App.tsx
ui/review-console/src/main.tsx
ui/review-console/src/parse.ts
ui/review-console/src/styles.css
ui/review-console/src/types.ts
ui/review-console/src/vite-env.d.ts
readme-kit/DEV.md
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
docker/luffy-runner/DEV.md
docker/luffy-runner/Dockerfile
docker/luffy-runner/README.md
docker/luffy-runner/USAGE.md
memory/DEV.md
memory/README.md
memory/index.json
memory/repos/Mr-Ashish--odoo/MEMORY.md
memory/repos/Mr-Ashish--odoo/latest.json
memory/repos/Mr-Ashish--luffy-pr-review-agent/MEMORY.md
memory/repos/Mr-Ashish--luffy-pr-review-agent/latest.json
modal_app/DEV.md
modal_app/USAGE.md
modal_app/__init__.py
modal_app/app.py
tests/test_apply_verdict_labels.py
tests/test_cooldown_check.py
tests/test_default_model.py
tests/test_dismiss_prior_pr_reviews.py
tests/test_gate_helpers.py
tests/test_hermes_pin.py
tests/test_hub_ingest.py
tests/test_install_luffy.py
tests/test_local_memory.py
tests/test_max_turns.py
tests/test_memory_health.py
tests/test_modal_parity.py
tests/test_model_tier.py
tests/test_normalize_review.py
tests/test_ops_footer.py
tests/test_pack_run_for_ui.py
tests/test_parse_verdict.py
tests/test_path_skip_check.py
tests/test_post_inline_comments.py
tests/test_preflight_cost.py
tests/test_review_to_openui.py
tests/test_run_with_timeout.py
tests/test_severity_calibration.py
tests/test_soul_context_scan.py
tests/test_tool_turns_gate.py
tests/test_trigger_review.py
tests/test_usage_summary.py
tests/test_webhook_auth.py
pack/DEV.md
pack/README.md
pack/luffy-pr-review-caller.yml
agent/DEV.md
agent/MEMORY.seed.md
agent/SOUL.md
agent/config.yaml
agent/review-prompt.md
docs/ARCHITECTURE.md
docs/MODAL.md
docs/OPENUI-INTEGRATION.md
docs/OPERATIONS.md
docs/README-BRANDING-ECOSYSTEM.md
docs/README-KIT-MVP.md
docs/ROI-FIXES.md
docs/experiments/2026-07-31-f31-run-bundle.md
docs/experiments/2026-07-31-f32-trigger.md
docs/experiments/2026-07-31-f33-webhook-auth.md
docs/experiments/2026-07-31-f34-webhook-fail-closed.md
docs/experiments/2026-07-31-f35-ops-footer.md
docs/experiments/2026-07-31-f36-review-timeout.md
docs/experiments/2026-07-31-f37-verdict-labels.md
docs/experiments/2026-07-31-f38-path-skip.md
docs/experiments/2026-07-31-f39-modal-parity.md
docs/experiments/2026-07-31-f40-ops-signals.md
docs/experiments/2026-07-31-f41-max-turns.md
docs/experiments/2026-07-31-f42-model-tier.md
docs/experiments/2026-07-31-f43-preflight-cost.md
docs/experiments/2026-07-31-f44-normalize-chat-chrome.md
docs/experiments/2026-07-31-f45-tool-turns-gate.md
docs/experiments/2026-07-31-f46-soul-context-scan.md
docs/experiments/2026-07-31-f48-soul-detect-scope.md
docs/experiments/2026-07-31-f49-soft-reprompt.md
docs/experiments/2026-07-31-f50-severity-calibration.md
docs/experiments/2026-07-31-f51-tool-depth.md
docs/experiments/2026-07-31-f9-inline-comments.md
docs/experiments/2026-07-31-f9b-precise-anchors.md
docs/experiments/2026-07-31-f9c-suggestions.md
docs/experiments/2026-07-31-roi-fire.md
docs/experiments/f28-repo-local-memory.md
docs/experiments/hermes-inspired-roi.md
docs/experiments/loop-idle-streak.txt
docs/experiments/loop-no-work-streak.md
docs/experiments/odoo-e2e-benchmark.md
docs/experiments/odoo-e2e-learn.md
docs/blog/building-luffy-agentic-pr-review.md
docs/benchmarks/hermes-startup-latest.json
docs/benchmarks/hermes-startup-latest.md
docs/benchmarks/local-memory-ingest-latest.md
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
docs/showcase/openui-luffy/README.md
docs/showcase/openui-luffy/review-modal-e2e.openui
docs/showcase/openui-luffy/review.openui
scripts/apply-verdict-labels.py
scripts/assemble-context.sh
scripts/association-allowed.sh
scripts/benchmark-hermes-startup.sh
scripts/build-hub-payload.py
scripts/build-luffy-runner-image.sh
scripts/capture-hermes-loop.py
scripts/cooldown-check.sh
scripts/dismiss-prior-pr-reviews.sh
scripts/distill-memory.sh
scripts/hermes-pin.sh
scripts/hub-ingest-run.py
scripts/install-luffy.sh
scripts/max_turns.py
scripts/memory-health.sh
scripts/modal_parity.py
scripts/model_tier.py
scripts/normalize-review.py
scripts/ops_footer.py
scripts/pack-run-for-ui.py
scripts/parse-verdict.py
scripts/path-skip-check.py
scripts/post-inline-comments.py
scripts/post-review-comment.sh
scripts/preflight_cost.py
scripts/preload-hub-memory.sh
scripts/publish-run-local.sh
scripts/publish-run-to-hub.sh
scripts/report-verdict.sh
scripts/review-local.sh
scripts/review-to-openui.py
scripts/run-hermes-review.sh
scripts/run-luffy-review.sh
```

## git diff

```
diff --git a/USAGE.md b/USAGE.md
index 10a1fca..2e75fca 100644
--- a/USAGE.md
+++ b/USAGE.md
@@ -329,6 +329,9 @@ REPO=owner/name HERMES_HOME=/tmp/hh LUFFY_MEMORY_MODE=local bash scripts/preload
 - When triaging a `soul_blocked` signal, export `HERMES_LOG_OFFSET` (byte offset of `HERMES_HOME/logs/agent.log` taken *before* launching Hermes) so `scripts/capture-hermes-loop.py` packages only this run's slice; a block reported without an offset is likely stale history.
 - To separate CLI failures from model behaviour on a cheap-model run, read the captured loop metrics: `hermes -z` health shows up as absence of invalid-choice/chat-fallback in the log slice, while `tool_turns=0` in the bundle's `loop` section means the model never entered the agentic loop and the F45 `tool-turns-gate.env` verdict downgrade is expected rather than a bug.
 
+- F51 tool-depth wording is covered by the `tool_depth_h26` case in `tests/test_tool_turns_gate.py` (same suite as F45/F49), so depth guidance is asserted from the gate side rather than in a separate test file.
+- Any edit to `agent/SOUL.md` must also pass the SOUL preflight/context scan (`tests/test_soul_context_scan.py`) — run it alongside the tool-turns suite when changing reviewer scope wording.
+
 ## Troubleshooting
 
 - Confirm which Luffy version a target repo runs: read `.luffy-install-stamp` (`mode=pack|caller`, `source_sha`) and compare with `git -C <luffy-source> rev-parse --short HEAD`. A stale `source_sha` after a re-install means files were skipped — re-run with `--force`. For `mode=caller`, runtime tracks hub `main`, not the stamp alone.
diff --git a/agent/DEV.md b/agent/DEV.md
index 2783af7..bf3f23e 100644
--- a/agent/DEV.md
+++ b/agent/DEV.md
@@ -24,6 +24,8 @@
 - **F47/H14 iteration cap contract:** the `hermes` CLI exposes no `--max-turns` flag, so the cap is applied through Hermes-native channels only — `HERMES_MAX_ITERATIONS=<n>` in the environment and/or `agent.max_turns: <n>` in `$HERMES_HOME/config.yaml`. Never re-add a `--max-turns` argv path to `scripts/run-hermes-review.sh`.
 - Because Hermes argparse treats an unknown leading token as a subcommand, a bare `N` after `-z` is read as a command name, not a value — any future tuning knob must be an env var or config key, not a positional/flag pair on the `hermes -z` line.
 
+- The required depth is concrete, not exhortative: read the diff hunks, then `rg` the changed symbols and read the surrounding **line range** in the changed file. Reading a large file with `head` only is explicitly forbidden, so "I looked at the file" no longer counts as inspection.
+
 ## Pitfalls
 
 - Same anchoring applies to `**Score:** <int>[/100]` and `**Confidence:** low|medium|high` — score/confidence are parsed only for reporting, and a missed match yields empty strings rather than an error.
@@ -43,3 +45,5 @@
 
 - Zero tool turns on attempt 1 is the norm, not an anomaly, on live upstream-port PRs: repeated e2e runs (odoo#2, #4, #5) all recorded `tool_turns=0` before the F49 soft reprompt, which then recovered a real agentic loop (0→23, 0→9, 0→8). Treat a `tool_turns=0` first attempt as expected and check whether `LUFFY_TOOL_TURNS_REPROMPT=1` was set before suspecting a prompt/toolset regression.
 - Because the reprompt succeeds, the F45 tool-turns gate reports *skipped* rather than pass/fail on these runs — a skipped F45 plus `soul_blocked=0` is the healthy signature, so do not read "gate skipped" as "gate not wired up".
+
+- Prompt-only mitigations like F51 need a live re-score to be believed — the shipped commit only proves the wording and tests changed, not that depth improved.
diff --git a/docs/showcase/devmemory-dogfood-luffy/README.md b/docs/showcase/devmemory-dogfood-luffy/README.md
index e19d2b7..bbe7466 100644
--- a/docs/showcase/devmemory-dogfood-luffy/README.md
+++ b/docs/showcase/devmemory-dogfood-luffy/README.md
@@ -1,4 +1,4 @@
-# Showcase · `run-20260731T224118-f42fe6`
+# Showcase · `run-20260731T225742-823739`
 
 Live dogfood run of **devmemory on itself**.
 
@@ -6,7 +6,7 @@ Live dogfood run of **devmemory on itself**.
 |-------|-------|
 | model | `anthropic/claude-opus-5` |
 | hermes_rc | 0 |
-| units | 4 |
+| units | 3 |
 
 ## Files
 
diff --git a/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.json b/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.json
index 2e82088..8f4f1e0 100644
--- a/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.json
+++ b/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.json
@@ -1,33 +1,33 @@
 {
-  "run_id": "run-20260731T224118-f42fe6",
+  "run_id": "run-20260731T225742-823739",
   "model": "anthropic/claude-opus-5",
   "hermes_rc": 0,
-  "units": 4,
-  "summary": "The session shipped F50/H20 severity calibration: a post-review gate (scripts/severity_calibration.py) that upgrades APPROVE\u2192REQUEST CHANGES when the review body self-reports missing/insufficient tests, gated by LUFFY_SEVERITY_CALIBRATION (default on) with a score cap of 69 and a sev-cal pack chip. Offline re-scores of the odoo e2e corpus quantify the effect (#2 36\u219242/50, #5 37\u219240/50, #4 clean no-op).",
+  "units": 3,
+  "summary": "Session shipped F51, a tool-depth nudge layered on top of F49's soft re-prompt: the re-prompt suffix plus the review prompt's Workspace section plus SOUL's Scope section now require the reviewer to read diff hunks and rg/line-range the changed symbols, and forbid head-only reads of large files. Durable knowledge: the three-surface contract for tool-depth wording, the shallow-read failure mode that motivated it, and how to verify it.",
   "usage": {
-    "estimated_cost_usd": 0.27356625,
+    "estimated_cost_usd": 0.2573225,
     "cost_status": "estimated",
     "cost_source": "provider_models_api",
     "input_tokens": 2,
-    "output_tokens": 2318,
+    "output_tokens": 1657,
     "cache_read_tokens": 0,
-    "cache_write_tokens": 34497,
-    "reasoning_tokens": 264,
-    "total_tokens": 36817,
+    "cache_write_tokens": 34542,
+    "reasoning_tokens": 204,
+    "total_tokens": 36201,
     "api_calls": 1,
     "model": "anthropic/claude-opus-5",
     "provider": "openrouter",
-    "session_id": "20260731_224120_31ac74",
+    "session_id": "20260731_225744_1eb754",
     "completed": true,
     "failed": false,
     "service_tier": null
   },
   "timings": {
-    "assemble_s": 0.666,
-    "extract_s": 30.615,
-    "normalize_s": 0.001,
-    "apply_s": 3.919,
-    "total_s": 35.208
+    "assemble_s": 1.332,
+    "extract_s": 23.518,
+    "normalize_s": 0.002,
+    "apply_s": 1.505,
+    "total_s": 26.362
   },
   "messages_meta": {
     "db": "/Users/ashishmishra/Documents/experiments/pr-review-agent/.devmemory/hermes-home/state.db",
diff --git a/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.md b/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.md
index 246880d..182fd81 100644
--- a/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.md
+++ b/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent-loop.md
@@ -1,31 +1,31 @@
-# Agent loop · `run-20260731T224118-f42fe6`
+# Agent loop · `run-20260731T225742-823739`
 
 - **model:** `anthropic/claude-opus-5`
 - **hermes_rc:** 0
-- **units:** 4
-- **at:** 2026-07-31T17:11:54Z
+- **units:** 3
+- **at:** 2026-07-31T17:28:08Z
 
 ## Summary
 
-The session shipped F50/H20 severity calibration: a post-review gate (scripts/severity_calibration.py) that upgrades APPROVE→REQUEST CHANGES when the review body self-reports missing/insufficient tests, gated by LUFFY_SEVERITY_CALIBRATION (default on) with a score cap of 69 and a sev-cal pack chip. Offline re-scores of the odoo e2e corpus quantify the effect (#2 36→42/50, #5 37→40/50, #4 clean no-op).
+Session shipped F51, a tool-depth nudge layered on top of F49's soft re-prompt: the re-prompt suffix plus the review prompt's Workspace section plus SOUL's Scope section now require the reviewer to read diff hunks and rg/line-range the changed symbols, and forbid head-only reads of large files. Durable knowledge: the three-surface contract for tool-depth wording, the shallow-read failure mode that motivated it, and how to verify it.
 
 ## Usage
 
 ```json
 {
-  "estimated_cost_usd": 0.27356625,
+  "estimated_cost_usd": 0.2573225,
   "cost_status": "estimated",
   "cost_source": "provider_models_api",
   "input_tokens": 2,
-  "output_tokens": 2318,
+  "output_tokens": 1657,
   "cache_read_tokens": 0,
-  "cache_write_tokens": 34497,
-  "reasoning_tokens": 264,
-  "total_tokens": 36817,
+  "cache_write_tokens": 34542,
+  "reasoning_tokens": 204,
+  "total_tokens": 36201,
   "api_calls": 1,
   "model": "anthropic/claude-opus-5",
   "provider": "openrouter",
-  "session_id": "20260731_224120_31ac74",
+  "session_id": "20260731_225744_1eb754",
   "completed": true,
   "failed": false,
   "service_tier": null
@@ -36,11 +36,11 @@ The session shipped F50/H20 severity calibration: a post-review gate (scripts/se
 
 ```json
 {
-  "assemble_s": 0.666,
-  "extract_s": 30.615,
-  "normalize_s": 0.001,
-  "apply_s": 3.919,
-  "total_s": 35.208
+  "assemble_s": 1.332,
+  "extract_s": 23.518,
+  "normalize_s": 0.002,
+  "apply_s": 1.505,
+  "total_s": 26.362
 }
 ```
 
diff --git a/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent.log b/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent.log
index 4b6f2dc..2c657e1 100644
--- a/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent.log
+++ b/docs/showcase/devmemory-dogfood-luffy/agent-loop/agent.log
@@ -1,23 +1,23 @@
-2026-07-31 22:41:19,751 INFO hermes_cli.plugins: Plugin 'browser-browser-use' registered browser provider: browser-use
-2026-07-31 22:41:19,751 INFO hermes_cli.plugins: Plugin 'browser-browserbase' registered browser provider: browserbase
-2026-07-31 22:41:19,752 INFO hermes_cli.plugins: Plugin 'browser-firecrawl' registered browser provider: firecrawl
-2026-07-31 22:41:19,815 INFO hermes_cli.plugins: Plugin 'deepinfra' registered image_gen provider: deepinfra
-2026-07-31 22:41:19,815 INFO hermes_cli.plugins: Plugin 'fal' registered image_gen provider: fal
-2026-07-31 22:41:19,816 INFO hermes_cli.plugins: Plugin 'krea' registered image_gen provider: krea
-2026-07-31 22:41:19,816 INFO hermes_cli.plugins: Plugin 'openai' registered image_gen provider: openai
-2026-07-31 22:41:19,816 INFO hermes_cli.plugins: Plugin 'openai-codex' registered image_gen provider: openai-codex
-2026-07-31 22:41:19,817 INFO hermes_cli.plugins: Plugin 'openrouter' registered image_gen provider: openrouter
-2026-07-31 22:41:19,817 INFO hermes_cli.plugins: Plugin 'openrouter' registered image_gen provider: nous
-2026-07-31 22:41:19,817 INFO hermes_cli.plugins: Plugin 'xai' registered image_gen provider: xai
-2026-07-31 22:41:19,822 INFO hermes_cli.plugins: Plugin 'deepinfra' registered video_gen provider: deepinfra
-2026-07-31 22:41:19,822 INFO hermes_cli.plugins: Plugin 'fal' registered video_gen provider: fal
-2026-07-31 22:41:19,823 INFO hermes_cli.plugins: Plugin 'xai' registered video_gen provider: xai
-2026-07-31 22:41:19,824 INFO hermes_cli.plugins: Plugin 'web-brave-free' registered web provider: brave-free
-2026-07-31 22:41:19,824 INFO hermes_cli.plugins: Plugin 'web-ddgs' registered web provider: ddgs
-2026-07-31 22:41:19,825 INFO hermes_cli.plugins: Plugin 'web-exa' registered web provider: exa
-2026-07-31 22:41:19,826 INFO hermes_cli.plugins: Plugin 'web-firecrawl' registered web provider: firecrawl
-2026-07-31 22:41:19,826 INFO hermes_cli.plugins: Plugin 'web-parallel' registered web provider: parallel
-2026-07-31 22:41:19,826 INFO hermes_cli.plugins: Plugin 'web-searxng' registered web provider: searxng
-2026-07-31 22:41:19,827 INFO hermes_cli.plugins: Plugin 'web-tavily' registered web provider: tavily
-2026-07-31 22:41:19,827 INFO hermes_cli.plugins: Plugin 'web-xai' registered web provider: xai
-2026-07-31 22:41:19,841 INFO hermes_cli.plugins: Plugin discovery complete: 54 found, 47 enabled
+2026-07-31 22:57:43,709 INFO hermes_cli.plugins: Plugin 'browser-browser-use' registered browser provider: browser-use
+2026-07-31 22:57:43,709 INFO hermes_cli.plugins: Plugin 'browser-browserbase' registered browser provider: browserbase
+2026-07-31 22:57:43,710 INFO hermes_cli.plugins: Plugin 'browser-firecrawl' registered browser provider: firecrawl
+2026-07-31 22:57:43,776 INFO hermes_cli.plugins: Plugin 'deepinfra' registered image_gen provider: deepinfra
+2026-07-31 22:57:43,776 INFO hermes_cli.plugins: Plugin 'fal' registered image_gen provider: fal
+2026-07-31 22:57:43,777 INFO hermes_cli.plugins: Plugin 'krea' registered image_gen provider: krea
+2026-07-31 22:57:43,777 INFO hermes_cli.plugins: Plugin 'openai' registered image_gen provider: openai
+2026-07-31 22:57:43,777 INFO hermes_cli.plugins: Plugin 'openai-codex' registered image_gen provider: openai-codex
+2026-07-31 22:57:43,778 INFO hermes_cli.plugins: Plugin 'openrouter' registered image_gen provider: openrouter
+2026-07-31 22:57:43,778 INFO hermes_cli.plugins: Plugin 'openrouter' registered image_gen provider: nous
+2026-07-31 22:57:43,778 INFO hermes_cli.plugins: Plugin 'xai' registered image_gen provider: xai
+2026-07-31 22:57:43,783 INFO hermes_cli.plugins: Plugin 'deepinfra' registered video_gen provider: deepinfra
+2026-07-31 22:57:43,783 INFO hermes_cli.plugins: Plugin 'fal' registered video_gen provider: fal
+2026-07-31 22:57:43,784 INFO hermes_cli.plugins: Plugin 'xai' registered video_gen provider: xai
+2026-07-31 22:57:43,785 INFO hermes_cli.plugins: Plugin 'web-brave-free' registered web provider: brave-free
+2026-07-31 22:57:43,785 INFO hermes_cli.plugins: Plugin 'web-ddgs' registered web provider: ddgs
+2026-07-31 22:57:43,786 INFO hermes_cli.plugins: Plugin 'web-exa' registered web provider: exa
+2026-07-31 22:57:43,787 INFO hermes_cli.plugins: Plugin 'web-firecrawl' registered web provider: firecrawl
+2026-07-31 22:57:43,787 INFO hermes_cli.plugins: Plugin 'web-parallel' registered web provider: parallel
+2026-07-31 22:57:43,787 INFO hermes_cli.plugins: Plugin 'web-searxng' registered web provider: searxng
+2026-07-31 22:57:43,788 INFO hermes_cli.plugins: Plugin 'web-tavily' registered web provider: tavily
+2026-07-31 22:57:43,788 INFO hermes_cli.plugins: Plugin 'web-xai' registered web provider: xai
+2026-07-31 22:57:43,803 INFO hermes_cli.plugins: Plugin discovery complete: 54 found, 47 enabled
diff --git a/docs/showcase/devmemory-dogfood-luffy/agent-loop/usage.json b/docs/showcase/devmemory-dogfood-luffy/agent-loop/usage.json
index 8d817f3..16325a5 100644
--- a/docs/showcase/devmemory-dogfood-luffy/agent-loop/usage.json
+++ b/docs/showcase/devmemory-dogfood-luffy/agent-loop/usage.json
@@ -1,17 +1,17 @@
 {
-  "estimated_cost_usd": 0.27356625,
+  "estimated_cost_usd": 0.2573225,
   "cost_status": "estimated",
   "cost_source": "provider_models_api",
   "input_tokens": 2,
-  "output_tokens": 2318,
+  "output_tokens": 1657,
   "cache_read_tokens": 0,
-  "cache_write_tokens": 34497,
-  "reasoning_tokens": 264,
-  "total_tokens": 36817,
+  "cache_write_tokens": 34542,
+  "reasoning_tokens": 204,
+  "total_tokens": 36201,
   "api_calls": 1,
   "model": "anthropic/claude-opus-5",
   "provider": "openrouter",
-  "session_id": "20260731_224120_31ac74",
+  "session_id": "20260731_225744_1eb754",
   "completed": true,
   "failed": false,
   "service_tier": null
diff --git a/docs/showcase/devmemory-dogfood-luffy/apply.json b/docs/showcase/devmemory-dogfood-luffy/apply.json
index 2443911..2bee93f 100644
--- a/docs/showcase/devmemory-dogfood-luffy/apply.json
+++ b/docs/showcase/devmemory-dogfood-luffy/apply.json
@@ -1,29 +1,29 @@
 [
   {
-    "path": "DEV.md",
+    "path": "agent/DEV.md",
     "kind": "dev",
-    "action": "scrub",
+    "action": "merge",
     "section": "Design decisions",
-    "bytes": 29749,
+    "bytes": 6718,
     "applied": true,
-    "unit_path": "."
+    "unit_path": "agent"
   },
   {
-    "path": "USAGE.md",
-    "kind": "usage",
+    "path": "agent/DEV.md",
+    "kind": "dev",
     "action": "merge",
-    "section": "Common commands",
-    "bytes": 27004,
+    "section": "Pitfalls",
+    "bytes": 6881,
     "applied": true,
-    "unit_path": "."
+    "unit_path": "agent"
   },
   {
-    "path": "ui/review-console/DEV.md",
-    "kind": "dev",
+    "path": "USAGE.md",
+    "kind": "usage",
     "action": "merge",
-    "section": "Design decisions",
-    "bytes": 1253,
+    "section": "Debugging",
+    "bytes": 27409,
     "applied": true,
-    "unit_path": "ui/review-console"
+    "unit_path": "."
   }
 ]
diff --git a/docs/showcase/devmemory-dogfood-luffy/extract.raw.md b/docs/showcase/devmemory-dogfood-luffy/extract.raw.md
index f117e74..a992144 100644
--- a/docs/showcase/devmemory-dogfood-luffy/extract.raw.md
+++ b/docs/showcase/devmemory-dogfood-luffy/extract.raw.md
@@ -1,52 +1,39 @@
 ```json
 {
-  "summary": "The session shipped F50/H20 severity calibration: a post-review gate (scripts/severity_calibration.py) that upgrades APPROVE→REQUEST CHANGES when the review body self-reports missing/insufficient tests, gated by LUFFY_SEVERITY_CALIBRATION (default on) with a score cap of 69 and a sev-cal pack chip. Offline re-scores of the odoo e2e corpus quantify the effect (#2 36→42/50, #5 37→40/50, #4 clean no-op).",
+  "summary": "Session shipped F51, a tool-depth nudge layered on top of F49's soft re-prompt: the re-prompt suffix plus the review prompt's Workspace section plus SOUL's Scope section now require the reviewer to read diff hunks and rg/line-range the changed symbols, and forbid head-only reads of large files. Durable knowledge: the three-surface contract for tool-depth wording, the shallow-read failure mode that motivated it, and how to verify it.",
   "session_ids": ["dogfood-luffy-session"],
   "units": [
     {
       "kind": "dev",
-      "path": ".",
+      "path": "agent",
       "action": "merge",
       "section": "Design decisions",
-      "content": "- **F50/H20 severity calibration** (`scripts/severity_calibration.py`) is a post-review gate that corrects verdict/severity mismatch rather than editing the review prose: when the review self-reports test gaps (e.g. a `relevant-tests: false` / missing-test suggestion) it upgrades `APPROVE` → `REQUEST CHANGES` and caps the reported score at **69**, so a self-contradicting APPROVE cannot ship at a high score.\n- Motivating evidence is a real disagreement with human/GHA review on the odoo corpus: e2e PR #2 under F49 emitted `APPROVE 95` while carrying a missing-test suggestion, where the GHA-side review was `REQUEST CHANGES` — the gate exists to close that specific gap, not to lower scores generally.\n- The gate is **on by default** (`LUFFY_SEVERITY_CALIBRATION`) and is designed to be a no-op on clean reviews: re-scoring the corpus offline moved #2 36→42/50 and #5 37→40/50 while #4 (no self-reported gap) was unchanged.",
+      "content": "- **F51 tool depth (H26)** extends F49 from *whether* the model used tools to *how deeply*: it is not a new gate, it is prompt wording added on three surfaces that must stay in sync — `build_reprompt_suffix` (the F49 soft re-prompt suffix), the **Workspace** section of `agent/review-prompt.md`, and the **Scope** section of `agent/SOUL.md`. Edit all three together or a re-prompted attempt gets depth guidance the first attempt lacks.\n- The required depth is concrete, not exhortative: read the diff hunks, then `rg` the changed symbols and read the surrounding **line range** in the changed file. Reading a large file with `head` only is explicitly forbidden, so \"I looked at the file\" no longer counts as inspection.",
       "evidence": [
-        "Gate: scripts/severity_calibration.py upgrades APPROVE→REQUEST CHANGES when review self-reports test gaps",
-        "Evidence: odoo e2e #2 F49 APPROVE 95 with format:false test suggestion vs GHA REQUEST CHANGES",
-        "Env LUFFY_SEVERITY_CALIBRATION default on; score cap 69; pack chip sev-cal"
+        "Fix: build_reprompt_suffix + review-prompt Workspace + SOUL Scope require diff hunks / rg + line-range on changed symbols; forbid head-only large-file reads"
       ],
       "confidence": "high"
     },
-    {
-      "kind": "usage",
-      "path": ".",
-      "action": "merge",
-      "section": "Common commands",
-      "content": "- **F50 severity calibration:** enabled by default; disable per-run with `LUFFY_SEVERITY_CALIBRATION=0`. Regression coverage lives in `tests/test_severity_calibration.py`.\n- The gate can be re-run **offline against an existing run directory** to re-score a past review without new OpenRouter spend — this is how the odoo e2e corpus was re-scored (#2 36→42/50, #5 37→40/50, #4 no-op) after the gate landed.\n- Console/bundle side: a `sev-cal` chip appears in the run bundle `signals` when the gate fired, so an upgraded verdict is visible in the Run Console without reading the review body.",
-      "evidence": [
-        "Env LUFFY_SEVERITY_CALIBRATION default on; score cap 69; pack chip sev-cal",
-        "Offline re-score: #2 36→42/50, #5 37→40/50 (#4 clean no-op)"
-      ],
-      "confidence": "medium"
-    },
     {
       "kind": "dev",
-      "path": "ui/review-console",
+      "path": "agent",
       "action": "merge",
-      "section": "Design decisions",
-      "content": "- **F50 `sev-cal`** joins the pack-signal chip family (path-skip, timeout, over-budget, diff-truncated, max-turns, model-tier, preflight, tool-turns): it means the severity-calibration gate rewrote the verdict to `REQUEST CHANGES` and capped the score at 69, so the displayed verdict/score may differ from what the model emitted — read the chip before trusting the raw review score.",
+      "section": "Pitfalls",
+      "content": "- F49 recovering the tool count from 0→1 is not evidence of a real inspection: on the odoo eval PR #6 the recovered attempt spent its single tool call on `head -80` of a large `misc.py` and never reached the changed `street_split` code around L1925, scoring 34/50 with depth dimension D8=2. When judging a re-prompted run, check *which lines* were read, not the `tool-turns-*` counters.\n- Prompt-only mitigations like F51 need a live re-score to be believed — the shipped commit only proves the wording and tests changed, not that depth improved.",
       "evidence": [
-        "Env LUFFY_SEVERITY_CALIBRATION default on; score cap 69; pack chip sev-cal"
+        "Evidence: odoo eval #6 F49 recovered 0→1 tools but only `head -80` on large misc.py; never read street_split ~L1925; score 34/50 D8=2",
+        "Next: H27 live mini re-score #6 under F51"
       ],
-      "confidence": "medium"
+      "confidence": "high"
     },
     {
-      "kind": "dev",
-      "path": "agent",
+      "kind": "usage",
+      "path": ".",
       "action": "merge",
-      "section": "Pitfalls",
-      "content": "- The reviewer contract's `relevant-tests` field is **load-bearing downstream**, not just reporting: F50 reads a self-reported test gap and overrides an `APPROVE` verdict. A prompt/SOUL edit that drops or renames that field silently disables the severity-calibration upgrade instead of failing loudly.",
+      "section": "Debugging",
+      "content": "- F51 tool-depth wording is covered by the `tool_depth_h26` case in `tests/test_tool_turns_gate.py` (same suite as F45/F49), so depth guidance is asserted from the gate side rather than in a separate test file.\n- Any edit to `agent/SOUL.md` must also pass the SOUL preflight/context scan (`tests/test_soul_context_scan.py`) — run it alongside the tool-turns suite when changing reviewer scope wording.",
       "evidence": [
-        "Gate: scripts/severity_calibration.py upgrades APPROVE→REQUEST CHANGES when review self-reports test gaps"
+        "Tests: test_tool_turns_gate tool_depth_h26; SOUL preflight clean"
       ],
       "confidence": "medium"
     }
diff --git a/docs/showcase/devmemory-dogfood-luffy/hermes-usage.json b/docs/showcase/devmemory-dogfood-luffy/hermes-usage.json
index 8d817f3..16325a5 100644
--- a/docs/showcase/devmemory-dogfood-luffy/hermes-usage.json
+++ b/docs/showcase/devmemory-dogfood-luffy/hermes-usage.json
@@ -1,17 +1,17 @@
 {
-  "estimated_cost_usd": 0.27356625,
+  "estimated_cost_usd": 0.2573225,
   "cost_status": "estimated",
   "cost_source": "provider_models_api",
   "input_tokens": 2,
-  "output_tokens": 2318,
+  "output_tokens": 1657,
   "cache_read_tokens": 0,
-  "cache_write_tokens": 34497,
-  "reasoning_tokens": 264,
-  "total_tokens": 36817,
+  "cache_write_tokens": 34542,
+  "reasoning_tokens": 204,
+  "total_tokens": 36201,
   "api_calls": 1,
   "model": "anthropic/claude-opus-5",
   "provider": "openrouter",
-  "session_id": "20260731_224120_31ac74",
+  "session_id": "20260731_225744_1eb754",
   "completed": true,
   "failed": false,
   "service_tier": null
diff --git a/docs/showcase/devmemory-dogfood-luffy/meta.env b/docs/showcase/devmemory-dogfood-luffy/meta.env
index 67b3f74..d83926a 100644
--- a/docs/showcase/devmemory-dogfood-luffy/meta.env
+++ b/docs/showcase/devmemory-dogfood-luffy/meta.env
@@ -1,5 +1,5 @@
-RUN_ID=run-20260731T224118-f42fe6
+RUN_ID=run-20260731T225742-823739
 SESSION_ID=dogfood-luffy-session
 SESSION_SOURCE=file
 REPO_ROOT=/Users/ashishmishra/Documents/experiments/pr-review-agent
-ASSEMBLED_AT=2026-07-31T17:11:19Z
+ASSEMBLED_AT=2026-07-31T17:27:43Z
diff --git a/docs/showcase/devmemory-dogfood-luffy/preview.diff b/docs/showcase/devmemory-dogfood-luffy/preview.diff
index 12fe805..339478d 100644
--- a/docs/showcase/devmemory-dogfood-luffy/preview.diff
+++ b/docs/showcase/devmemory-dogfood-luffy/preview.diff
@@ -1,38 +1,32 @@
-diff --git a/DEV.md b/DEV.md
---- a/DEV.md
-+++ b/DEV.md
-@@ -125,7 +125,6 @@
- - `hermes -z` is not reliable: an observed `-z` rc=2 on odoo PR #2 forced the `hermes chat -q` path, which is exactly the polluted-output case F44 scrubs. Anything that assumes one-shot mode always wins will regress (tracked as H14).
- - `tool_turns=0` on a multi-file PR is a quality smell for an *agentic* review product, not a cheap win: the no-tool mini run on PR #2 returned APPROVE while an earlier GHA tool-using review caught the real gap (missing `format:false` tests). **F45/H12** fail-closes: `scripts/tool_turns_gate.py` downgrades APPROVE→COMMENT, caps score at 55, injects an F45 banner, writes `tool-turns-gate.env` (chip `tool-turns-gate`). Docs-only / single-file exempt; `LUFFY_TOOL_TURNS_GATE=off` disables.
- - **F49/H15 soft re-prompt:** same eligibility as F45, **once** before fail-closed — re-run `hermes -z` with a tool-nudge suffix (`reprompt-write`). Default on (`LUFFY_TOOL_TURNS_REPROMPT=1`). Evidence: `tool-turns-reprompt.env` + chips `tool-reprompt` / `tool-reprompt-ok`. If tools still 0, F45 still annotates. Doubles cheap-path spend when it fires — intentional recovery cost.
--- **F50/H20 severity calibration:** when the review **self-reports** a test gap under **APPROVE**, `scripts/severity_calibration.py` upgrades to **REQUEST CHANGES**, caps score at 69 (override `LUFFY_SEVERITY_SCORE_CAP`), injects F50 banner, chip `sev-cal`. Default on (`LUFFY_SEVERITY_CALIBRATION=1`). Complements SOUL/prompt rules that missing tests for claimed production fixes are Blocking. Offline: odoo #2 F49 APPROVE 95→RC (GHA parity); #5 tests:no; #4 clean.
- - **F46/H13 SOUL load:** Hermes blocks context files matching threat patterns. Never quote classic injection phrases in `agent/SOUL.md`. Preflight: `scripts/soul_context_scan.py check`; runtime: `soul-context.env` + chip `soul-blocked`.
- 
- - The normalizer is a **trust boundary**, not a formatter: never accept a body as a valid review contract just because expected snippets/headings appear in it — prompt echo contains all of them. Contract checks must assert the placeholder-free form.
-
 diff --git a/USAGE.md b/USAGE.md
 --- a/USAGE.md
 +++ b/USAGE.md
-@@ -270,6 +270,10 @@
- - Self-check the gate before wiring it up (exit code is the answer): `python3 scripts/path-skip-check.py --path README.md --path docs/a.md --globs docs` → exit 2 (skip); `python3 scripts/path-skip-check.py --path src/x.py --path README.md --globs docs` → exit 0 (allow).
- - Batch form for a real PR path list: `python3 scripts/path-skip-check.py --paths-file pr-paths.txt` (paths come from `scripts/sparse-pr-paths.sh`).
+@@ -329,6 +329,9 @@
+ - When triaging a `soul_blocked` signal, export `HERMES_LOG_OFFSET` (byte offset of `HERMES_HOME/logs/agent.log` taken *before* launching Hermes) so `scripts/capture-hermes-loop.py` packages only this run's slice; a block reported without an offset is likely stale history.
+ - To separate CLI failures from model behaviour on a cheap-model run, read the captured loop metrics: `hermes -z` health shows up as absence of invalid-choice/chat-fallback in the log slice, while `tool_turns=0` in the bundle's `loop` section means the model never entered the agentic loop and the F45 `tool-turns-gate.env` verdict downgrade is expected rather than a bug.
  
-+- **F50 severity calibration:** enabled by default; disable per-run with `LUFFY_SEVERITY_CALIBRATION=0`. Regression coverage lives in `tests/test_severity_calibration.py`.
-+- The gate can be re-run **offline against an existing run directory** to re-score a past review without new OpenRouter spend — this is how the odoo e2e corpus was re-scored (#2 36→42/50, #5 37→40/50, #4 no-op) after the gate landed.
-+- Console/bundle side: a `sev-cal` chip appears in the run bundle `signals` when the gate fired, so an upgraded verdict is visible in the Run Console without reading the review body.
++- F51 tool-depth wording is covered by the `tool_depth_h26` case in `tests/test_tool_turns_gate.py` (same suite as F45/F49), so depth guidance is asserted from the gate side rather than in a separate test file.
++- Any edit to `agent/SOUL.md` must also pass the SOUL preflight/context scan (`tests/test_soul_context_scan.py`) — run it alongside the tool-turns suite when changing reviewer scope wording.
 +
- ## Setup
+ ## Troubleshooting
  
- - Install on each target repo's **default branch** (workflow only runs from default branch):
+ - Confirm which Luffy version a target repo runs: read `.luffy-install-stamp` (`mode=pack|caller`, `source_sha`) and compare with `git -C <luffy-source> rev-parse --short HEAD`. A stale `source_sha` after a re-install means files were skipped — re-run with `--force`. For `mode=caller`, runtime tracks hub `main`, not the stamp alone.
 
-diff --git a/ui/review-console/DEV.md b/ui/review-console/DEV.md
---- a/ui/review-console/DEV.md
-+++ b/ui/review-console/DEV.md
-@@ -8,3 +8,7 @@
- - Phase tracker state: Phase 2 (standalone review console shell) is **superseded** by the full Run Console; F40 ("ops signals in console", phase 4d) is done, while **4c live progress streaming remains pending** — treat streaming as the next console workstream, not signals.
+diff --git a/agent/DEV.md b/agent/DEV.md
+--- a/agent/DEV.md
++++ b/agent/DEV.md
+@@ -24,6 +24,8 @@
+ - **F47/H14 iteration cap contract:** the `hermes` CLI exposes no `--max-turns` flag, so the cap is applied through Hermes-native channels only — `HERMES_MAX_ITERATIONS=<n>` in the environment and/or `agent.max_turns: <n>` in `$HERMES_HOME/config.yaml`. Never re-add a `--max-turns` argv path to `scripts/run-hermes-review.sh`.
+ - Because Hermes argparse treats an unknown leading token as a subcommand, a bare `N` after `-z` is read as a command name, not a value — any future tuning knob must be an env var or config key, not a positional/flag pair on the `hermes -z` line.
  
- - Those metrics render in two places: an **Agent loop (F41)** panel in the Overview tab, and measures on the **Loop** tab — i.e. `loop` is a first-class bundle section alongside `signals`, not a sub-field of it.
++- The required depth is concrete, not exhortative: read the diff hunks, then `rg` the changed symbols and read the surrounding **line range** in the changed file. Reading a large file with `head` only is explicitly forbidden, so "I looked at the file" no longer counts as inspection.
 +
-+## Design decisions
+ ## Pitfalls
+ 
+ - Same anchoring applies to `**Score:** <int>[/100]` and `**Confidence:** low|medium|high` — score/confidence are parsed only for reporting, and a missed match yields empty strings rather than an error.
+@@ -43,3 +45,5 @@
+ 
+ - Zero tool turns on attempt 1 is the norm, not an anomaly, on live upstream-port PRs: repeated e2e runs (odoo#2, #4, #5) all recorded `tool_turns=0` before the F49 soft reprompt, which then recovered a real agentic loop (0→23, 0→9, 0→8). Treat a `tool_turns=0` first attempt as expected and check whether `LUFFY_TOOL_TURNS_REPROMPT=1` was set before suspecting a prompt/toolset regression.
+ - Because the reprompt succeeds, the F45 tool-turns gate reports *skipped* rather than pass/fail on these runs — a skipped F45 plus `soul_blocked=0` is the healthy signature, so do not read "gate skipped" as "gate not wired up".
 +
-+- **F50 `sev-cal`** joins the pack-signal chip family (path-skip, timeout, over-budget, diff-truncated, max-turns, model-tier, preflight, tool-turns): it means the severity-calibration gate rewrote the verdict to `REQUEST CHANGES` and capped the score at 69, so the displayed verdict/score may differ from what the model emitted — read the chip before trusting the raw review score.
++- Prompt-only mitigations like F51 need a live re-score to be believed — the shipped commit only proves the wording and tests changed, not that depth improved.
diff --git a/docs/showcase/devmemory-dogfood-luffy/preview.json b/docs/showcase/devmemory-dogfood-luffy/preview.json
index eb0acd2..297697d 100644
--- a/docs/showcase/devmemory-dogfood-luffy/preview.json
+++ b/docs/showcase/devmemory-dogfood-luffy/preview.json
@@ -1,25 +1,19 @@
 {
   "stats": {
-    "files": 3,
-    "lines_added": 8,
-    "lines_removed": 1,
+    "files": 2,
+    "lines_added": 7,
+    "lines_removed": 0,
     "changes": 3
   },
   "files": [
-    {
-      "path": "DEV.md",
-      "is_new": false,
-      "lines_added": 0,
-      "lines_removed": 1
-    },
     {
       "path": "USAGE.md",
       "is_new": false,
-      "lines_added": 4,
+      "lines_added": 3,
       "lines_removed": 0
     },
     {
-      "path": "ui/review-console/DEV.md",
+      "path": "agent/DEV.md",
       "is_new": false,
       "lines_added": 4,
       "lines_removed": 0
diff --git a/docs/showcase/devmemory-dogfood-luffy/prompt.md b/docs/showcase/devmemory-dogfood-luffy/prompt.md
index 4530f59..e25943a 100644
--- a/docs/showcase/devmemory-dogfood-luffy/prompt.md
+++ b/docs/showcase/devmemory-dogfood-luffy/prompt.md
@@ -44,20 +44,22 @@ Respond with **only** the JSON object (fence optional).
 
 ### Transcript
 
-# dogfood-luffy-session
+# Luffy dogfood session — F51 tool depth (H26)
 
-## Session notes (H22)
-- Ran F49 mini e2e on Mr-Ashish/odoo#5 (POS ticket screen, port of odoo#279360).
-- tool_turns recovered 0→8 via LUFFY_TOOL_TURNS_REPROMPT=1; F45 gate skipped; soul_blocked=0.
-- Score 37/50; APPROVE 92; ~$0.028 · 56s; sessions 20260731_223146_62f430 → 20260731_223158_96a569.
-- Corpus fully scored: #1 35, #2 GHA 40 / F49 36, #3 39, #4 F49 38, #5 F49 37.
-- Next highest ROI: H20 severity calibration (missing tests blocking) or H23 sixth upstream PR.
+## Shipped
+- F51: tool-depth nudge after F49 soft re-prompt (H26)
+- Evidence: odoo eval #6 F49 recovered 0→1 tools but only `head -80` on large misc.py; never read street_split ~L1925; score 34/50 D8=2
+- Fix: build_reprompt_suffix + review-prompt Workspace + SOUL Scope require diff hunks / rg + line-range on changed symbols; forbid head-only large-file reads
+- Tests: test_tool_turns_gate tool_depth_h26; SOUL preflight clean
+- SHA: d27b477 on origin/main
 
-## Shipped F50 / H20 severity calibration
-- Gate: scripts/severity_calibration.py upgrades APPROVE→REQUEST CHANGES when review self-reports test gaps
-- Evidence: odoo e2e #2 F49 APPROVE 95 with format:false test suggestion vs GHA REQUEST CHANGES
-- Offline re-score: #2 36→42/50, #5 37→40/50 (#4 clean no-op)
-- Env LUFFY_SEVERITY_CALIBRATION default on; score cap 69; pack chip sev-cal
+## Next
+- H27 live mini re-score #6 under F51
+- H25 source 7th complex odoo/odoo PR
+
+## Ops
+- Corpus: 6 luffy-eval PRs on Mr-Ashish/odoo all scored
+- No .env committed
 
 
 ## Existing directories (allowed `path` values)
@@ -109,15 +111,16 @@ agent
 ?? .luffy-out-e2e-pr4-f49/
 ?? .luffy-out-e2e-pr4-h16/
 ?? .luffy-out-e2e-pr5-f49/
+?? .luffy-out-e2e-pr6-f49/
 ```
 
 ### recent log
 ```
+d27b477 feat(review): F51 tool-depth nudge after F49 (H26)
+0a201f0 docs(e2e): H24 score odoo#6 F49 mini 34/50 (tools 0→1 shallow)
+f67a963 docs(e2e): H23 corpus #6 odoo#279777 street_split → Mr-Ashish/odoo#6
+e9bb515 dogfood: F50 severity calibration knowledge + showcase
 b075a74 F50/H20: severity calibration for missing-test self-reports
-7384ce5 docs(dogfood): H22 pitfalls — F49 0→N tools is healthy signature
-85916aa docs(e2e): H22 score odoo#5 F49 mini — tools 0→8, 37/50
-db992e0 docs(e2e): H21 corpus #5 — port odoo#279360 POS ticket screen
-e666fe0 docs(e2e): H19 F49 re-score odoo#4 — tools 0→9, 31→38/50
 ```
 
 ### tree (sample)
@@ -241,6 +244,7 @@ docs/experiments/2026-07-31-f46-soul-context-scan.md
 docs/experiments/2026-07-31-f48-soul-detect-scope.md
 docs/experiments/2026-07-31-f49-soft-reprompt.md
 docs/experiments/2026-07-31-f50-severity-calibration.md
+docs/experiments/2026-07-31-f51-tool-depth.md
 docs/experiments/2026-07-31-f9-inline-comments.md
 docs/experiments/2026-07-31-f9b-precise-anchors.md
 docs/experiments/2026-07-31-f9c-suggestions.md
@@ -321,7 +325,6 @@ scripts/review-local.sh
 scripts/review-to-openui.py
 scripts/run-hermes-review.sh
 scripts/run-luffy-review.sh
-scripts/run-with-timeout.py
 ```
 
 ### git diff
@@ -386,6 +389,9 @@ scripts/run-with-timeout.py
 - Phase tracker state: Phase 2 (standalone review console shell) is **superseded** by the full Run Console; F40 ("ops signals in console", phase 4d) is done, while **4c live progress streaming remains pending** — treat streaming as the next console workstream, not signals.
 - Those metrics render in two places: an **Agent loop (F41)** panel in the Overview tab, and measures on the **Loop** tab — i.e. `loop` is a first-class bundle section alongside `signals`, not a sub-field of it.
 
+## Design decisions
+- **F50 `sev-cal`** joins the pack-signal chip family (path-skip, timeout, over-budget, diff-truncated, max-turns, model-tier, preflight, tool-turns): it means the severity-calibration gate rewrote the verdict to `REQUEST CHANGES` and capped the score at 69, so the displayed verdict/score may differ from what the model emitted — read the chip before trusting the raw review score.
+
 ### readme-kit/DEV.md
 
 ## Design decisions
diff --git a/docs/showcase/devmemory-dogfood-luffy/repo-context.md b/docs/showcase/devmemory-dogfood-luffy/repo-context.md
index b1ff40b..e711cc8 100644
--- a/docs/showcase/devmemory-dogfood-luffy/repo-context.md
+++ b/docs/showcase/devmemory-dogfood-luffy/repo-context.md
@@ -1,7 +1,7 @@
 # Repository context
 
 - **root:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
-- **assembled_at:** 2026-07-31T17:11:19Z
+- **assembled_at:** 2026-07-31T17:27:43Z
 
 ## git status
 
@@ -12,16 +12,17 @@
 ?? .luffy-out-e2e-pr4-f49/
 ?? .luffy-out-e2e-pr4-h16/
 ?? .luffy-out-e2e-pr5-f49/
+?? .luffy-out-e2e-pr6-f49/
 ```
 
 ## recent log
 
 ```
+d27b477 feat(review): F51 tool-depth nudge after F49 (H26)
+0a201f0 docs(e2e): H24 score odoo#6 F49 mini 34/50 (tools 0→1 shallow)
+f67a963 docs(e2e): H23 corpus #6 odoo#279777 street_split → Mr-Ashish/odoo#6
+e9bb515 dogfood: F50 severity calibration knowledge + showcase
 b075a74 F50/H20: severity calibration for missing-test self-reports
-7384ce5 docs(dogfood): H22 pitfalls — F49 0→N tools is healthy signature
-85916aa docs(e2e): H22 score odoo#5 F49 mini — tools 0→8, 37/50
-db992e0 docs(e2e): H21 corpus #5 — port odoo#279360 POS ticket screen
-e666fe0 docs(e2e): H19 F49 re-score odoo#4 — tools 0→9, 31→38/50
 `

… [diff truncated] …
```

## existing knowledge files

### claim index (do not restate these claims)
- [DEV.md#Architecture] @luffy action assemble cacheartifact checkout comment concurrency context
- [DEV.md#Architecture] artifact compos deterministic every inner llm-driven orchestr record
- [DEV.md#Architecture] anchor assemble-contextsh banner budget console contractfencessizehtml diff-trunc dismiss-prior
- [DEV.md#Architecture] --caller --with-hub-ingest --with-runner-build adoption agent agentscript default entrypoint
- [DEV.md#Architecture] branch checkout config default domain luffy luffy-hermes-home memory
- [DEV.md#Architecture] caller concurrency f10 githubworkflowsluffy-review-reusableyml input issuecomment luffy-pr-reviewyml luffyref
- [DEV.md#Design decisions] action append comment complet console deep-link f35 footer
- [DEV.md#Design decisions] 422 actually added chang comment f9b f9f9b findingsblock
- [DEV.md#Design decisions] authoriz bearerx-luffy-token escape f33f34 f34 fail-clos github hmac-sha256
- [DEV.md#Design decisions] --bit --spawn browser command console default dry-plan enqueue
- [DEV.md#Design decisions] --soft action artifact auto-detect bundle download f31 failur
- [DEV.md#Design decisions] action cache container detect dockerluffy-runner ensureherm exist image
- [DEV.md#Design decisions] comment delet luffy luffy-review luffyreplaceprevious=0 marker match prior
- [DEV.md#Design decisions] always-publish comment crash failure hermesmodel low-confidence openrouter produce
- [DEV.md#Design decisions] agentic assembl beyond capture-hermes-looppy completion default inspect luffytoolset
- [DEV.md#Design decisions] activity agenttool hermestuitoolprogress=verbose later level observability pythonunbuffered=1 recoverable
- [DEV.md#Design decisions] directory disposable explicitly hermeshome memory memorymd preserv through
- [DEV.md#Design decisions] $from chmod executable install install-luffysh installer installupdate itself
- [DEV.md#Design decisions] --force avoid canonical explicitly half-cop install itself luffy
- [DEV.md#Design decisions] append empty explicitly guard never no-op non-dict non-load-bear
- [DEV.md#Design decisions] --max-usd alert already budget estimat exceed f29 footerjob-summary
- [DEV.md#Design decisions] 15k10k10m absent artifact boolean deliberately download field footer
- [DEV.md#Design decisions] block caller contentspull-requestsissuesac declar every forget grant itself
- [DEV.md#Design decisions] contrac
… [claim index truncated; do not restate] …

### knowledge excerpts
### DEV.md

## Architecture
- Luffy is a gated GitHub Actions control plane, not a chat bot: `@luffy review this pr` → gate + per-PR concurrency → dual checkout → restore Hermes memory → assemble context → `hermes -z` → normalize → PR comment → distill memory → cache/artifacts.
- Orchestration is deterministic shell (`scripts/run-luffy-review.sh` composes stages and records timings); only the inner review step is LLM-driven, so every run leaves reproducible artifacts.
- Stage → script map: assemble-context.sh (gh pr meta + diff + prompt, no LLM), run-hermes-review.sh (Hermes one-shot over `WORKSPACE_ROOT`; F7 pin via hermes-pin.sh), normalize-review.py (contract/fences/size/HTML marker + secret redact + F27 diff-truncation banner), usage-summary.py (F21 cost footer/job summary + F29 soft max budget), parse-verdict.py + report-verdict.sh (F22 reaction/status + F23 formal PR review + F24 dismiss-prior + F9 inline), post-inline-comments.py (F9 path anchors), distill-memory.sh, post-review-comment.sh, save-trace.sh, publish-run-local.sh (F28 `.luffy/`), publish-run-to-hub.sh (opt-in), hub-ingest-run.py (hub + local layouts), pack-run-for-ui.py (F31 Run Console `run-bundle.json`, soft).
- **F20/F10 install:** `scripts/install-luffy.sh` is the adoption entrypoint. Default **pack** mode copies `agent/`, runtime scripts, thin `luffy-pr-review.yml`, and `luffy-review-reusable.yml`. **`--caller`** installs only the hub-managed thin workflow from `pack/luffy-pr-review-caller.yml` (no agent/scripts). Optional `--with-hub-ingest` / `--with-runner-build` (pack mode). Stamp `.luffy-install-stamp` rec
… [truncated; do not restate] …

### ui/DEV.md

## Design decisions
- **Run Console** loads a single `run-bundle.json` (F31 pack) — operators never need raw Hermes logs for first triage.
- **Ops signals (F40+)** surface gates as chips + Overview rows: path-skip, timeout, over-budget, diff-truncated, max-turns (F41), model-tier (F42).
- **F42 model tier** chips (`model-cheap` / `model-full`) come from pack `signals` filled by `model-tier.env`; Overview shows mode/tier/reason + effective model id.
- **F43 preflight cost** chips (`preflight-cheap` / `preflight-refuse`) come from `preflight-cost.env` via pack signals — refuse means no Hermes spend; forced-cheap means estimate exceeded budget on the premium model.

## Pitfalls
- Fixture re-pack (`npm run pack-fixture`) must stay green after pack-run signal shape changes or Overview types drift.
- Empty `signals.flags` means either a clean paid run *or* tier mode was `off` — check `signals.model_tier_mode` before assuming auto-tier ran.

### ui/review-console/DEV.md

## Architecture
- The console renders `bundle.signals` in two places: header **chips** (shown only when at least one flag is set) and an **Ops signals (F40)** panel in the Overview tab — so a clean run stays visually quiet and any degraded run is visible without opening a tab.
- Phase tracker state: Phase 2 (standalone review console shell) is **superseded** by the full Run Console; F40 ("ops signals in console", phase 4d) is done, while **4c live progress streaming remains pending** — treat streaming as the next console workstream, not signals.
- Those metrics render in two places: an **Agent loop (F41)** panel in the Overview tab, and measures on the **Loop** tab — i.e. `loop` is a first-class bundle section alongside `signals`, not a sub-field of it.

## Design decisions
- **F50 `sev-cal`** joins the pack-signal chip family (path-skip, timeout, over-budget, diff-truncated, max-turns, model-tier, preflight, tool-turns): it means the severity-calibration gate rewrote the verdict to `REQUEST CHANGES` and capped the score at 69, so the displayed verdict/score may differ from what the model emitted — read the chip before trusting the raw review score.

### readme-kit/DEV.md

## Design decisions
- Config format: YAML is the preferred input with JSON kept at parity (`examples/luffy/` ships both `readme.config.yaml` and `readme.config.json`), so either file shape drives the same build.
- YAML parsing uses the `yaml` npm dependency; the previously hand-rolled parser was deleted rather than kept as a fallback — do not reintroduce a bespoke parser for "zero-dep" reasons.

### docker/luffy-runner/DEV.md

## Design decisions
- The image's job is to satisfy a two-signal contract that CI probes, not to run Luffy itself: it sets `LUFFY_HERMES_PREBAKED=1` and writes the resolved SHA to `/root/.hermes-pin`, and bakes `PATH=/root/.local/bin:/root/.hermes/bin`. `ensure_hermes` short-circuits when either signal is present *and* `hermes` is on PATH, so a broken/renamed marker silently falls back to a cold install instead of failing loudly.
- Base is plain `ubuntu:24.04` plus the minimum Hermes needs (`ca-certificates curl git python3 python3-venv bash build-essential`); Hermes is installed at build time with `install.sh --skip-setup --commit "${HERMES_COMMIT}" --force-commit`, i.e. the same pinned, non-interactive install path CI uses (F7).
- The pin is an `ARG HERMES_COMMIT` with a hardcoded default that must track `scripts/hermes-pin.sh` DEFAULT — `scripts/build-luffy-runner-image.sh` resolves the pin via `scripts/hermes-pin.sh default` (overridable with `HERMES_COMMIT=…`) and passes it as `--build-arg`, so the Dockerfile default only matters for raw `docker build` invocations.
- Tagging is pin-derived, not semver: `ghcr.io/<owner>/luffy-hermes-runner:<first-12-chars-of-pin>` plus `:latest`, which makes the image ref self-documenting about which Hermes commit is inside.

### memory/DEV.md

## Architecture
- This repo doubles as the central hub: every target repo's run is ingested under `memory/repos/{owner}--{repo}/` (slug uses `--` to flatten owner/repo), holding `MEMORY.md`, `latest.json`, and a `runs/` history.
- Publish path: `build-hub-payload.py` produces a redacted, size-capped payload → `publish-run-to-hub.sh` (direct push by default, `repository_dispatch luffy-run` optional) → `hub-ingest-run.py` commits under `memory/`.
- Hub memory is preloaded into `HERMES_HOME` at the start of each run (`preload-hub-memory.sh`), which is what makes the next review on the same repo smarter — memory is cross-run and cross-repo, not per-job.
- Hub behaviour is env-configurable per target repo: `LUFFY_HUB_REPO` (default `Mr-Ashish/luffy-pr-review-agent`), `LUFFY_HUB_MODE` (`direct`|`dispatch`|`both`), `LUFFY_HUB_PUBLISH=0` to disable.

## Pitfalls
- Direct push therefore needs write on the hub: on the hub repo itself `GITHUB_TOKEN` + `contents: write` is sufficient (self-review), but any *other* target repo requires `LUFFY_HUB_TOKEN` (PAT with contents write on the hub) or hub publishing silently degrades.
- Original failure mode this layer exists to fix: hub memory was written after a run but **not loaded into** the next review — the preload step is the load half of the contract, and without it the `memory/` tree is write-only.
- `preload-hub-memory.sh` fetches `.luffy/MEMORY.md` through the **default-branch contents API** (`api.github.com/repos/$REPO/contents/...`), not from the checked-out workspace: the PR checkout is sparse/PR-head, so reading it from disk would
… [truncated; do not restate] …

### modal_app/DEV.md

## Design decisions
- The Modal entrypoint is a first-class host in the F31 Run Console contract: `review_pr` exports `LUFFY_HOST=modal` so `pack-run-for-ui.py` stamps the bundle's host label as `modal` instead of falling through the `GITHUB_ACTIONS`/else auto-detect to `local`.
- `review_pr` also returns the `run_bundle` path in its result, so a Modal caller gets the console bundle handle back directly rather than having to download an Actions artifact (the GHA path's only option).
- F34 deliberately reverses F33's behaviour rather than extending it: F33 allowed unauthenticated requests with a warning when no secret/token was configured; F34 makes that same state `auth=denied` so the production-safe posture is the default and misconfiguration is loud instead of silent.
- The open-mode escape hatch is exposed on three surfaces that must stay in sync: env `LUFFY_WEBHOOK_ALLOW_OPEN=1`, the `allow_open=True` argument on the auth helper, and the `--allow-open` flag on `scripts/webhook_auth.py`. All three exist for dev/self-check only — none is a supported production configuration.

## Architecture
- Bit 4 (F32) splits the enqueue path into four units in `modal_app/app.py`: `parse_enqueue_payload` (normalize an incoming request into repo/pr/model/post_comment), `plan_enqueue` (pure plan, no side effects), `enqueue_review` (the spawn call), and `review_webhook` (the HTTP entrypoint). Parsing/planning are separable from spawning so the parser can be self-checked without any OpenRouter spend.
- `review_webhook` accepts two payload shapes: the simple API `{repo, pr, model, post_comm
… [truncated; do not restate] …

### pack/DEV.md

## Architecture
- `pack/` holds installable templates that are *not* live workflows in this repo: `luffy-pr-review-caller.yml` is the F10 hub-managed thin caller, copied verbatim to `.github/workflows/luffy-pr-review.yml` on the target by `install-luffy.sh --caller`.
- It differs from this repo's own `luffy-pr-review.yml` in exactly one way: `uses:` is the absolute hub ref `Mr-Ashish/luffy-pr-review-agent/.github/workflows/luffy-review-reusable.yml@main` with literal `luffy_repository`/`luffy_ref` values, instead of the local `./.github/workflows/...` path with `github.repository`.
- Triggers, `permissions`, and the `luffy-${{ github.repository }}-<pr>` concurrency group are duplicated in the template because a `workflow_call` job cannot own them — edits to gating must be applied to `pack/luffy-pr-review-caller.yml` as well as the in-repo caller.

## Design decisions
- Pack-mode install now seeds the target's `.luffy/MEMORY.md` (`seed_local_memory()` in `install-luffy.sh`), copying `agent/MEMORY.seed.md` when present and falling back to an inline stub. It honours `--force` (skips an existing file otherwise) and `--dry-run`, and runs before `write_stamp "pack"`.
- `--caller` (hub-managed thin) installs **do not** seed `.luffy/` because no agent/scripts are copied — the installer instead prints a tip to seed `.luffy/MEMORY.md` manually on the default branch (or run pack mode once). A caller repo with no seed simply starts from `MEMORY_SOURCE=seed`.
- Regression coverage lives in `tests/test_install_luffy.py`: pack install asserts both `scripts/publish-run-local.sh` and `.luff
… [truncated; do not restate] …

### agent/DEV.md

## Design decisions
- `agent/SOUL.md` is the reviewer contract: staff-level reviewer scoped to *this diff's* added lines, explicitly told it sees partial hunks and must not invent missing imports or re-suggest changes already in the `+` lines.
- Trust model lives in SOUL, not in the prompt template: PR text and diff are UNTRUSTED DATA; author text that redefines the task or forces a merge verdict must be refused.
- Finding discipline is asymmetric by design: thorough on bugs/security, high bar elsewhere — every finding needs file + symbol + concrete trigger, and silence beats speculation (an empty Blocking section is an acceptable output).
- Every review must emit structured judgment fields: Score 0–100, review effort 1–5, security audit verdict, relevant-tests yes/no, key findings, optional concrete code suggestions.

## Pitfalls
- Same anchoring applies to `**Score:** <int>[/100]` and `**Confidence:** low|medium|high` — score/confidence are parsed only for reporting, and a missed match yields empty strings rather than an error.
- `UNKNOWN` is deliberately non-blocking (reaction `eyes`, status `success`, review_event `COMMENT`), so a broken prompt contract looks like a healthy neutral review instead of failing loudly. Verify the posted body still carries the bold verdict line after any prompt/template edit.
- F23 dual-channel: the full Markdown is still the issue comment (F12 replace via `<!-- luffy-review pr=N`); the formal PR Review body is intentionally short so the Reviews panel is not a second full dump. Marker `<!-- luffy-pr-review pr=N` tags Luffy-owned PR reviews.

… [truncated; do not restate] …

### USAGE.md

## Run console
- **F31 auto-pack:** every review writes `.luffy-out/run-bundle.json` (and `traces/<id>/run-bundle.json`) — download the `luffy-out` or `luffy-trace` Actions artifact and load it in the console. Soft-fail only.
- **F40–F49 signals:** bundle includes `signals` (timeout / path-skip / over-budget / diff-truncated / max-turns / model-tier / preflight / **tool-turns-gate** / **tool-turns-reprompt** + `flags[]`) and `loop` metrics. Overview shows **Ops signals** + **Agent loop (F41)**; header chips when any flag is set. Path-skip → `ops-signals.env`; F41 → `hermes-max-turns.env`; F42 → `model-tier.env`; F45 → `tool-turns-gate.env`; F49 → `tool-turns-reprompt.env`.
- Manual pack (showcase / older runs): `python3 scripts/pack-run-for-ui.py --dir path/to/run-or-showcase -o run-bundle.json` (`--host gha|modal|local`, `--memory-health path`, `--also path`, `--soft`).
- UI: `cd ui/review-console && npm install && npm run pack-fixture && npm run dev` → http://localhost:5177 → **Load bundle** for any `run-bundle.json`.

## Trigger a review (F32)
--model anthropic/claude-opus-5 --diff-bytes 200000 --file-count 20
--path a.js --path b.js --env-out tool-turns-gate.env
**before** F45 fail-closed. Attempt-1 artifacts are kept under
--prompt-in prompt.md --prompt-out prompt-reprompt.md \

## Common commands
- Install Luffy into another repo (self-contained pack): `./scripts/install-luffy.sh /path/to/target-repo` (`--force` overwrite; `--dry-run` preview).
- Hub-managed thin install (F10, no agent/scripts copy): `./scripts/install-luffy.sh --caller /path/to/target-repo`.
- Build 
… [truncated; do not restate] …

### docker/luffy-runner/USAGE.md

## Setup
- Order of operations to adopt the prebaked runner: (1) publish the image (`PUSH=1 ./scripts/build-luffy-runner-image.sh` or the **Build Luffy Hermes runner** workflow), (2) make the GHCR package readable by Actions — public package, or explicitly grant the consuming repo access, (3) set repo variable `LUFFY_RUNNER_IMAGE` to the pin-tagged ref (e.g. `ghcr.io/mr-ashish/luffy-hermes-runner:53559aaf86b8`), (4) re-trigger `@luffy review`.
- The workflow resolves the container as `${{ vars.LUFFY_RUNNER_IMAGE != '' && vars.LUFFY_RUNNER_IMAGE || null }}`, so leaving the variable unset (or empty) is the supported default path: host `ubuntu-latest` + pin-keyed Hermes install cache. There is no separate on/off flag.
- Verify an image locally before wiring it into CI: `docker run --rm ghcr.io/mr-ashish/luffy-hermes-runner:latest hermes --version`.

## Troubleshooting
- A stale `LUFFY_RUNNER_IMAGE` pin is invisible: the prebaked short-circuit returns before any pin comparison, so a container built from an older `HERMES_COMMIT` will run happily against a newer `scripts/hermes-pin.sh` default. Compare the image tag's 12-char pin against `scripts/hermes-pin.sh default` when Hermes behaviour differs between the container path and the host path.
- Self-hosted runners can opt into the same fast path without the image by placing `hermes` on PATH plus a `/root/.hermes-pin` (or `$HOME/.hermes-pin`) marker file.

### modal_app/USAGE.md

## Common commands
- Bit 4 dry enqueue plan (no LLM spend, self-checks the payload parser): `modal run modal_app/app.py --bit 4 --repo Mr-Ashish/odoo --pr 3` → `BIT4_OK`.
- Actually enqueue the worker: append `--spawn` to the same command.
- Publish the webhook: `modal deploy modal_app/app.py`, then POST `{"repo":"Mr-Ashish/odoo","pr":3,"model":"openai/gpt-4.1-mini","post_comment":true}` to the `review_webhook` URL (or forward a GitHub `issue_comment` payload).
- F33/F34 auth: set `LUFFY_WEBHOOK_TOKEN` (`Authorization: Bearer …`) and/or `LUFFY_WEBHOOK_SECRET` (GitHub `X-Hub-Signature-256`). Fail-closed without either unless `LUFFY_WEBHOOK_ALLOW_OPEN=1`. Helper: `python3 scripts/webhook_auth.py sign|authorize [--allow-open]`.

## Debugging
- If a live POST is rejected, reproduce locally first: `python3 scripts/webhook_auth.py sign` to mint an `X-Hub-Signature-256` over the exact raw body, then `python3 scripts/webhook_auth.py authorize` to see which branch fired, rather than guessing from the Modal response.
- Modal profile version `0.6.0-f39` (F39 host parity): path-skip before clone + report-verdict after review. Quote it when comparing behaviour across deployed revisions.
- Path-skip offline: `python3 scripts/modal_parity.py path-skip --path README.md --globs docs` → exit 2 means Modal would skip OpenRouter.
- F41: `LUFFY_MAX_TURNS` (default 40) caps Hermes tool iterations on Modal; set `0`/`off` to disable. App version `0.6.1-f41`.

