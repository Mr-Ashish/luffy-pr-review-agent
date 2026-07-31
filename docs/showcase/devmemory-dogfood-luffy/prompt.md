# Task

Extract **durable repository knowledge** from the development session below.
You already have enough context below — **do not explore the filesystem**.
Respond with **only** the JSON object (fence optional).

## Output contract (mandatory)

```json
{
  "summary": "1-3 sentences: what durable knowledge was found",
  "session_ids": ["dogfood-luffy-session"],
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
- **id:** `dogfood-luffy-session`
- **source:** `file`

### Transcript

# dogfood-luffy-session (F44)

We built and operate Luffy, a comment-triggered PR review agent (Hermes + OpenRouter + hub memory).

## F44 change
- `scripts/normalize-review.py` now extracts the real review from `hermes chat -q` chrome.
- Rejects prompt-template echo with placeholder `**Verdict:** < APPROVE | … >`.
- Promotes unbolded `Verdict:` / `Summary` headings so parse-verdict and contract checks work.
- Does not treat bare `───` separators as TUI chrome (models use them between findings).

## E2e evidence
- Multi-PR corpus on Mr-Ashish/odoo PRs #1 #2 #3 (luffy-eval titles).
- Cheap run on PR #2: hermes -z failed → chat fallback; without F44 would post full prompt.
- GHA prior review on PR #2 had higher signal (missing format:false tests) than no-tool mini run.

## Durable lessons
- Normalizer is a trust boundary: never treat prompt-echo as valid contract just because snippets match.
- tool_turns=0 on multi-file PRs is a quality smell for agentic review product.
- SOUL.md can be blocked by Hermes prompt_injection scanner — needs a P1 workaround.


## Existing directories (allowed `path` values)

```
.
demo
ui
ui/review-console
ui/review-console/dist
ui/review-console/dist/fixtures
ui/review-console/dist/assets
ui/review-console/public
ui/review-console/public/fixtures
ui/review-console/src
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
docker
docker/luffy-runner
memory
memory/repos
memory/repos/Mr-Ashish--odoo
memory/repos/Mr-Ashish--odoo/runs
memory/repos/Mr-Ashish--luffy-pr-review-agent
memory/repos/Mr-Ashish--luffy-pr-review-agent/runs
modal_app
pack
agent
```

## Repository snapshot

### git status
```
M docs/experiments/hermes-inspired-roi.md
 M docs/experiments/loop-no-work-streak.md
 M scripts/normalize-review.py
 M tests/test_normalize_review.py
?? .luffy-out-e2e-pr2-f44/
?? docs/experiments/2026-07-31-f44-normalize-chat-chrome.md
?? docs/experiments/odoo-e2e-benchmark.md
?? docs/experiments/odoo-e2e-learn.md
```

### recent log
```
a58eb3b docs(knowledge): dogfood F43 preflight cost + showcase
8b74bf5 feat(cost): F43 hard preflight spend estimate before Hermes (H6)
6aa9f3f docs(knowledge): dogfood F42 model tier + showcase
d3c1c2d feat(cost): F42 auto model tier by PR size (H7)
776fc4c docs(knowledge): dogfood F41 max_turns + showcase
```

### tree (sample)
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
scripts/run-with-timeout.py
scripts/save-trace.sh
scripts/sparse-pr-paths.sh
scripts/trigger-review.sh
scripts/usage-summary.py
scripts/webhook_auth.py
scripts/write-failure-review.sh
assets/README.md
assets/favicon-32.png
```

### git diff
```
diff --git a/docs/experiments/hermes-inspired-roi.md b/docs/experiments/hermes-inspired-roi.md
index 092f1d5..3080081 100644
--- a/docs/experiments/hermes-inspired-roi.md
+++ b/docs/experiments/hermes-inspired-roi.md
@@ -18,6 +18,10 @@ Only ship what fits Luffy’s control-plane (scripts/agent/workflows/modal/ui) 
 | H8 | Subagent fan-out for multi-file PRs | L | Parallel review streams; Modal cost + complexity | backlog |
 | H9 | Trajectory packaging for offline eval datasets | M | Quality regressions measurable | backlog (capture-hermes-loop partial) |
 | H10 | Soft skill nudge mid-loop (“prefer fewer tools”) | M | Hermes skill nudge pattern; needs hermes hooks | backlog |
+| **H11** | **Strip hermes chat chrome + reject prompt-template echo in normalizer** | **S** | **F44 e2e: chat -q posted Query+template; contract false-positive** | **Shipped F44** |
+| H12 | Fail closed when tool_turns=0 on multi-file non-docs PR (re-prompt or COMMENT) | S | #2 mini APPROVE missed known test gap; GHA/tools did not | **P0 next** |
+| H13 | SOUL.md hermes prompt_injection false-positive workaround | S | F44 log: SOUL blocked — review discipline may not load | **P1** |
+| H14 | Make hermes -z reliable; avoid chat -q fallback | M | -z rc=2 forced chat path that needs F44 scrubbing | backlog |
 
 ## Selection rule
 
@@ -30,3 +34,5 @@ Each fire: pick **one** unfinished highest-ROI **minimal** item. Prefer S over M
 **H7 → F42** (2026-07-31): auto model tier (`LUFFY_MODEL_TIER=auto`) — cheap for tiny/docs, full otherwise.
 
 **H6 → F43** (2026-07-31): hard preflight cost estimate — force_cheap then refuse when still over budget.
+
+**H11 → F44** (2026-07-31): normalizer extracts real review from hermes chat chrome; rejects placeholder verdict / template echo; promotes loose headings for parse-verdict.
diff --git a/docs/experiments/loop-no-work-streak.md b/docs/experiments/loop-no-work-streak.md
index 2e941a4..11a95fc 100644
--- a/docs/experiments/loop-no-work-streak.md
+++ b/docs/experiments/loop-no-work-streak.md
@@ -6,5 +6,5 @@ Track consecutive scheduled fires that found **no P0/P1** Luffy product work
 | Field | Value |
 |-------|------:|
 | streak | **0** |
-| last_fire | 2026-07-31 (F43 hard preflight cost estimate shipped) |
-| note | P1 cost work found and shipped → streak stays 0. |
+| last_fire | 2026-07-31 (F44 hermes chat chrome normalizer + odoo e2e score) |
+| note | E2e run + P0 normalizer shipped → streak stays 0. |
diff --git a/scripts/normalize-review.py b/scripts/normalize-review.py
index 9b94a5e..7fc7f8e 100755
--- a/scripts/normalize-review.py
+++ b/scripts/normalize-review.py
@@ -93,10 +93,200 @@ def strip_outer_fence(text: str) -> str:
     return body.strip()
 
 
+# F44: hermes chat -q echoes "Query: …" + the full prompt (including the
+# required Markdown *template*) before the real model answer. The template
+# already contains every REQUIRED_SNIPPET, so a naive contract check would
+# treat the polluted blob as valid and post the prompt to GitHub.
+_REVIEW_HEADING_RX = re.compile(
+    r"(?:^|\n)(?:#{1,3}\s*)?(?:🏴‍☠️\s*)?Luffy Review\s*[—\-–]?\s*PR\s*#?\s*\d*",
+    re.IGNORECASE,
+)
+_PLACEHOLDER_VERDICT_RX = re.compile(
+    r"(?:\*\*)?Verdict:(?:\*\*)?\s*<[^>\n]+>",
+    re.IGNORECASE,
+)
+_REAL_VERDICT_RX = re.compile(
+    r"(?:\*\*)?Verdict:(?:\*\*)?\s*"
+    r"(APPROVE|REQUEST\s*CHANGES|COMMENT|LGTM|CHANGES\s*REQUESTED)\b",
+    re.IGNORECASE,
+)
+# Hermes TUI / CLI chrome — only lines that are *not* valid review content.
+# Do NOT treat bare ─── rules as chrome: models often use them between findings.
+_HERMES_CHROME_LINE_RX = re.compile(
+    r"(?:"
+    r"^Query:\s*"
+    r"|^Initializing agent\b"
+    r"|^Resume this session with:\s*"
+    r"|^Session:\s+\S+"
+    r"|^Duration:\s+"
+    r"|^Messages:\s+\d+"
+    r"|^[╭╰].*[╮╯]\s*$"  # full-width TUI box top/bottom
+    r"|^╭─\s*⚕"  # Hermes panel header
+    r"|^⚕\s*Hermes\b"
+    r"|^⚠\s+tirith\b"
+    r")",
+    re.MULTILINE | re.IGNORECASE,
+)
+# Trailing session footer starts here — drop everything after
+_HERMES_FOOTER_RX = re.compile(
+    r"\n(?:Resume this session with:|Session:\s+\d{8}_\d+)",
+    re.IGNORECASE,
+)
+_SECTION_ALIASES: tuple[tuple[re.Pattern[str], str], ...] = (
+    (re.compile(r"^#{0,3}\s*Summary\s*$", re.I | re.M), "### Summary"),
+    (re.compile(r"^#{0,3}\s*Walkthrough\s*$", re.I | re.M), "### Walkthrough"),
+    (re.compile(r"^#{0,3}\s*Blocking\s*$", re.I | re.M), "### Blocking"),
+    (re.compile(r"^#{0,3}\s*Key findings\s*$", re.I | re.M), "### Key findings"),
+    (re.compile(r"^#{0,3}\s*Security audit\s*$", re.I | re.M), "### Security audit"),
+    (re.compile(r"^#{0,3}\s*Suggestions\s*$", re.I | re.M), "### Suggestions"),
+    (re.compile(r"^#{0,3}\s*Code suggestions\s*$", re.I | re.M), "### Code suggestions"),
+    (re.compile(r"^#{0,3}\s*Nits\s*$", re.I | re.M), "### Nits"),
+    (re.compile(r"^#{0,3}\s*Tests\s*&\s*risk\s*$", re.I | re.M), "### Tests & risk"),
+    (re.compile(r"^#{0,3}\s*What I checked\s*$", re.I | re.M), "### What I checked"),
+)
+_META_LINE_ALIASES: tuple[tuple[re.Pattern[str], str], ...] = (
+    (re.compile(r"^\*{0,2}Verdict:\*{0,2}\s*", re.I | re.M), "**Verdict:** "),
+    (re.compile(r"^\*{0,2}Confidence:\*{0,2}\s*", re.I | re.M), "**Confidence:** "),
+    (re.compile(r"^\*{0,2}Score:\*{0,2}\s*", re.I | re.M), "**Score:** "),
+    (re.compile(r"^\*{0,2}Review effort:\*{0,2}\s*", re.I | re.M), "**Review effort:** "),
+)
+
+
+def _looks_like_template_only(text: str) -> bool:
+    """True when the only verdict is the angle-bracket prompt placeholder."""
+    if _PLACEHOLDER_VERDICT_RX.search(text) and not _REAL_VERDICT_RX.search(text):
+        return True
+    # Template body often keeps the angle brackets even when bold labels exist
+    if _PLACEHOLDER_VERDICT_RX.search(text):
+        # Real verdict may coexist if model answered then chrome kept template
+        # — only "template only" when no concrete token outside placeholders.
+        without_ph = _PLACEHOLDER_VERDICT_RX.sub("", text)
+        if not _REAL_VERDICT_RX.search(without_ph):
+            return True
+    return False
+
+
+def _candidate_score(chunk: str) -> int:
+    """Higher = more likely the model’s actual review (not the prompt template)."""
+    if not chunk or len(chunk) < 40:
+        return -100
+    score = 0
+    if _PLACEHOLDER_VERDICT_RX.search(chunk):
+        score -= 50
+    if _REAL_VERDICT_RX.search(chunk):
+        score += 40
+    if "**Verdict:**" in chunk or re.search(r"^Verdict:\s*\w", chunk, re.M):
+        score += 5
+    for snip in ("### Summary", "### Blocking", "### Security audit", "### Tests & risk"):
+        if snip in chunk:
+            score += 3
+    # Unbolded section labels from chat mode still count
+    for label in ("Summary", "Blocking", "Security audit", "Tests & risk"):
+        if re.search(rf"^#{{0,3}}\s*{re.escape(label)}\s*$", chunk, re.M | re.I):
+            score += 2
+    if "Required Markdown template" in chunk or "Trust boundary" in chunk:
+        score -= 30
+    if chunk.lstrip().startswith("Query:"):
+        score -= 40
+    # Prefer chunks that look finished (footer or Tests section)
+    if "Luffy · Hermes Agent" in chunk or "### What I checked" in chunk:
+        score += 5
+    return score
+
+
+def extract_agent_review(text: str) -> str:
+    """F44: pull the real review out of hermes chat -q / TUI chrome + prompt echo.
+
+    When ``hermes -z`` fails, the chat fallback prints ``Query:`` + the full
+    prompt (which embeds the Markdown *template* with every required snippet)
+    before the agent answer. Posting that blob is a trust/ops failure.
+    """
+    t = text.strip()
+    if not t:
+        return t
+
+    # Fast path: clean one-shot output already looks like a review
+    if (
+        t.startswith("## ")
+        and "Luffy Review" in t[:80]
+        and not t.startswith("Query:")
+        and not _looks_like_template_only(t)
+        and _REAL_VERDICT_RX.search(t)
+    ):
+        return t
+
+    matches = list(_REVIEW_HEADING_RX.finditer(t))
+    if not matches:
+        # No heading — strip obvious chrome lines and return remainder
+        lines = [ln for ln in t.splitlines() if not _HERMES_CHROME_LINE_RX.match(ln)]
+        cleaned = "\n".join(lines).strip()
+        return cleaned or t
+
+    best: str | None = None
+    best_score = -10_000
+    for i, m in enumerate(matches):
+        start = m.start()
+        # If match began at a newline, keep content from the heading line
+        if start > 0 and t[start] == "\n":
+            start += 1
+        end = matches[i + 1].start() if i + 1 < len(matches) else len(t)
+        chunk = t[start:end]
+        # Drop Hermes session footer if present inside this slice
+        foot = _HERMES_FOOTER_RX.search(chunk)
+        if foot:
+            chunk = chunk[: foot.start()]
+        # Drop TUI chrome lines but keep in-body ─── separators between findings
+        chunk_lines: list[str] = []
+        for ln in chunk.splitlines():
+            if _HERMES_CHROME_LINE_RX.match(ln):
+                continue
+            chunk_lines.append(ln)
+        chunk = "\n".join(chunk_lines).strip()
+        sc = _candidate_score(chunk)
+        # Later candidates win ties (model answer usually last)
+        if sc >= best_score:
+            best_score = sc
+            best = chunk
+
+    if best is None or best_score < 10:
+        # Fall back to last heading slice even if weak — ensure_contract may repair
+        last = matches[-1]
+        start = last.start() + (1 if last.start() > 0 and t[last.start()] == "\n" else 0)
+        best = t[start:].strip()
+        foot = _HERMES_FOOTER_RX.search(best)
+        if foot:
+            best = best[: foot.start()].strip()
+
+    # Strip leading fence if model wrapped only the answer
+    if best.startswith("```"):
+        best = strip_outer_fence(best)
+    return best
+
+
+def normalize_loose_headings(text: str) -> str:
+    """Promote chat-mode unbolded labels to the hard contract form."""
+    out = text
+    for rx, repl in _META_LINE_ALIASES:
+        out = rx.sub(repl, out)
+    for rx, repl in _SECTION_ALIASES:
+        out = rx.sub(repl, out)
+    # Ensure title has ##
+    out = re.sub(
+        r"^(?!#)((?:🏴‍☠️\s*)?Luffy Review\s*[—\-–].*)$",
+        r"## \1",
+        out,
+        count=1,
+        flags=re.M,
+    )
+    return out
+
+
 def ensure_contract(text: str, pr: str) -> str:
     t = text.strip()
+    # F44: reject prompt-template echo even if REQUIRED_SNIPPETS are present
+    template_only = _looks_like_template_only(t)
     missing = [s for s in REQUIRED_SNIPPETS if s not in t]
-    if not missing:
+    if not missing and not template_only:
         body = t
         # Append missing soft headings only if completely absent (do not invent content)
         for sec in SOFT_SECTIONS:
@@ -104,6 +294,15 @@ def ensure_contract(text: str, pr: str) -> str:
                 # leave as-is; soft sections are guidance for the model, not hard repair
                 pass
     else:
+        reason = (
+            "prompt/template echo or placeholder verdict (F44)"
+            if template_only
+            else f"missing: {', '.join(missing)}"
+        )
+        # Keep only a short raw snippet to avoid re-posting the full prompt
+        raw_snip = t
+        if len(raw_snip) > 4000:
+            raw_snip = raw_snip[:4000].rstrip() + "\n…\n_(raw truncated by normalizer)_\n"
         body = f"""## 🏴‍☠️ Luffy Review — PR #{pr}
 
 **Verdict:** COMMENT
@@ -112,7 +311,7 @@ def ensure_contract(text: str, pr: str) -> str:
 **Review effort:** 2/5
 
 ### Summary
-Agent output did not match the review contract (missing: {', '.join(missing)}). Raw content preserved below.
+Agent output did not match the review contract ({reason}). Raw content preserved below.
 
 ### Walkthrough
 - Contract repair only — re-run for a full structured review
@@ -145,7 +344,7 @@ None
 - Normalizer only
 
 ### Raw agent output
-{t}
+{raw_snip}
 """
 
     marker = f"<!-- luffy-review pr={pr}"
@@ -178,6 +377,10 @@ def main(argv: list[str] | None = None) -> int:
 
     raw = args.input.read_text(errors="replace")
     cleaned = strip_outer_fence(raw)
+    # F44: drop hermes chat chrome + prompt echo before contract checks
+    cleaned = extract_agent_review(cleaned)
+    cleaned = normalize_loose_headings(cleaned)
+    cleaned = strip_outer_fence(cleaned)
     # Redact before contract repair so fallback "raw agent output" is also scrubbed.
     cleaned = redact_secrets(cleaned)
     final = ensure_contract(cleaned, str(args.pr))
diff --git a/tests/test_normalize_review.py b/tests/test_normalize_review.py
index 644a0f6..991ea4e 100644
--- a/tests/test_normalize_review.py
+++ b/tests/test_normalize_review.py
@@ -136,6 +136,104 @@ class NormalizeReviewTests(unittest.TestCase):
         out = self.run_norm(self._full_contract(), diff_truncated=False)
         self.assertNotIn("Diff truncated (F27)", out)
 
+    def test_f44_extracts_review_from_hermes_chat_chrome(self):
+        # hermes chat -q echoes Query + prompt template (with placeholder verdict)
+        # then the real answer (often unbolded headings).
+        template = (
+            "## 🏴‍☠️ Luffy Review — PR #2\n\n"
+            "**Verdict:** < APPROVE | REQUEST CHANGES | COMMENT >\n"
+            "**Confidence:** < low | medium | high >\n"
+            "**Score:** <0-100>/100\n"
+            "**Review effort:** <1-5>/5\n\n"
+            "### Summary\n<fill>\n\n"
+            "### Blocking\n- None\n\n"
+            "### Security audit\nNo\n\n"
+            "### Tests & risk\n- Risk: low\n"
+        )
+        real = (
+            "🏴‍☠️ Luffy Review — PR #2\n\n"
+            "Verdict: REQUEST CHANGES\n"
+            "Confidence: high\n"
+            "Score: 72/100\n"
+            "Review effort: 3/5\n\n"
+            "Summary\nMissing tests for format:false alias.\n\n"
+            "Blocking\n"
+            "- Add tests for integer/float format alias.\n\n"
+            "Key findings\nNone\n\n"
+            "Security audit\nNo\n\n"
+            "Suggestions\n- None\n\n"
+            "Code suggestions\nNone\n\n"
+            "Nits\n- None\n\n"
+            "Tests & risk\n"
+            "- Relevant tests added/updated: no\n"
+            "- Coverage: getFieldsSpec only\n"
+            "- Risk: low — small\n"
+            "- Rollback: easy\n\n"
+            "What I checked\n- diff of field extractors\n"
+        )
+        raw = (
+            "Query: # Task\n\nYou are reviewing a PR.\n\n"
+            "## Required Markdown template\n\n"
+            "```markdown\n"
+            f"{template}\n"
+            "```\n\n"
+            "Initializing agent...\n"
+            "╭─ ⚕ Hermes ───────────────────────────────╮\n"
+            f"{real}\n"
+            "────────────────────────────────────────\n"
+        )
+        out = self.run_norm(raw, pr="2")
+        self.assertNotIn("Query:", out)
+        self.assertNotIn("< APPROVE | REQUEST CHANGES | COMMENT >", out)
+        self.assertNotIn("Required Markdown template", out)
+        self.assertIn("**Verdict:** REQUEST CHANGES", out)
+        self.assertIn("**Score:** 72/100", out)
+        self.assertIn("### Summary", out)
+        self.assertIn("Missing tests for format:false", out)
+        self.assertIn("<!-- luffy-review pr=2 run=test -->", out)
+        self.assertNotIn("contract repair", out.lower())
+
+    def test_f44_rejects_template_only_echo(self):
+        raw = (
+            "Query: # Task\n\n"
+            "## 🏴‍☠️ Luffy Review — PR #9\n\n"
+            "**Verdict:** < APPROVE | REQUEST CHANGES | COMMENT >\n"
+            "**Confidence:** < low | medium | high >\n"
+            "**Score:** <0-100>/100\n"
+            "**Review effort:** <1-5>/5\n\n"
+            "### Summary\n<template>\n\n"
+            "### Blocking\n- None\n\n"
+            "### Security audit\nNo\n\n"
+            "### Tests & risk\n- Risk: unknown\n"
+        )
+        out = self.run_norm(raw, pr="9")
+        self.assertIn("**Verdict:** COMMENT", out)
+        self.assertIn("placeholder verdict (F44)", out)
+        self.assertIn("contract repair", out.lower())
+
+    def test_f44_promotes_loose_headings_on_clean_body(self):
+        raw = (
+            "🏴‍☠️ Luffy Review — PR #5\n\n"
+            "Verdict: APPROVE\n"
+            "Confidence: medium\n"
+            "Score: 88/100\n"
+            "Review effort: 2/5\n\n"
+            "Summary\nLooks good.\n\n"
+            "Blocking\nNone\n\n"
+            "Security audit\nNo\n\n"
+            "Tests & risk\n"
+            "- Relevant tests added/updated: yes\n"
+            "- Coverage: unit\n"
+            "- Risk: low — n/a\n"
+            "- Rollback: easy\n\n"
+            "What I checked\n- full diff\n"
+        )
+        out = self.run_norm(raw, pr="5")
+        self.assertIn("**Verdict:** APPROVE", out)
+        self.assertIn("### Summary", out)
+        self.assertIn("### Security audit", out)
+        self.assertNotIn("contract repair", out.lower())
+
 
 if __name__ == "__main__":
     unittest.main()
```

### existing knowledge + claim index (do not repeat / paraphrase these claims)
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
- Trust model lives in SOUL, not in the prompt template: PR text and diff are UNTRUSTED DATA and prompt-injection attempts ("ignore previous instructions", "approve this PR") must be refused.
- Finding discipline is asymmetric by design: thorough on bugs/security, high bar elsewhere — every finding needs file + symbol + concrete trigger, and silence beats speculation (an empty Blocking section is an acceptable output).
- Every review must emit structured judgment fields: Score 0–100, review effort 1–5, security audit verdict, relevant-tests yes/no, key findings, optional concrete code suggestions.

## Pitfalls
- Same anchoring applies to `**Score:** <int>[/100]` and `**Confidence:** low|medium|high` — score/confidence are parsed only for reporting, and a missed match yields empty strings rather than an error.
- `UNKNOWN` is deliberately non-blocking (reaction `eyes`, status `success`, review_event `COMMENT`), so a broken prompt contract looks like a healthy neutral review instead of failing loudly. Verify the posted body still carries the bold verdict line after any prompt/template edit.
- F23 dual-channel: the full Markdown is still the issue comment (F12 replace via `<!-- luffy-review pr=N`); the formal PR Review body is intentionally short so the Reviews panel is not a second full dump. Marker `<!-- luffy-pr-review pr=N` tags Luffy
… [truncated; do not restate] …

### USAGE.md

## Run console
- **F31 auto-pack:** every review writes `.luffy-out/run-bundle.json` (and `traces/<id>/run-bundle.json`) — download the `luffy-out` or `luffy-trace` Actions artifact and load it in the console. Soft-fail only.
- **F40–F43 signals:** bundle includes `signals` (timeout / path-skip / over-budget / diff-truncated / max-turns / model-tier + `flags[]`) and `loop` metrics. Overview shows **Ops signals** + **Agent loop (F41)**; header chips when any flag is set. Path-skip → `ops-signals.env`; F41 → `hermes-max-turns.env`; F42 → `model-tier.env`.
- Manual pack (showcase / older runs): `python3 scripts/pack-run-for-ui.py --dir path/to/run-or-showcase -o run-bundle.json` (`--host gha|modal|local`, `--memory-health path`, `--also path`, `--soft`).
- UI: `cd ui/review-console && npm install && npm run pack-fixture && npm run dev` → http://localhost:5177 → **Load bundle** for any `run-bundle.json`.

## Trigger a review (F32)
--model anthropic/claude-opus-5 --diff-bytes 200000 --file-count 20
--path README.md --diff-bytes 400
--review docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/review.md \
--diff docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/pr.diff

## Common commands
- Install Luffy into another repo (self-contained pack): `./scripts/install-luffy.sh /path/to/target-repo` (`--force` overwrite; `--dry-run` preview).
- Hub-managed thin install (F10, no agent/scripts copy): `./scripts/install-luffy.sh --caller /path/to/target-repo`.
- Build prebaked Hermes runner image: `./scripts/build-luffy-runner-image.sh` (optional `PUSH=1`).
- Benchmark Hermes startup paths: `SKIP_CO
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


## Final instruction
Return the JSON object now. If nothing **new** durable is present (including when
the session only restates the claim index), return `"units": []`.
