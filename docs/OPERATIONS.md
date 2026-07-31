# Luffy operations

## Required setup

1. Install onto the **default branch** of a GitHub repo:
   ```bash
   # Hub-managed (F10, recommended for multi-repo): thin workflow only
   ./scripts/install-luffy.sh --caller /path/to/target-repo

   # Self-contained pack (agent + scripts + reusable workflow on the target)
   ./scripts/install-luffy.sh /path/to/target-repo
   # optional: --force, --with-hub-ingest, --with-runner-build
   ```
2. Repository secret: `OPENROUTER_API_KEY`
3. Optional variable: `LUFFY_MODEL` (default in scripts: `anthropic/claude-opus-5` — F26; set e.g. `openai/gpt-5-mini` to cut cost)
4. Optional variable: `LUFFY_HERMES_COMMIT` — pin Hermes to a git SHA (default from `scripts/hermes-pin.sh` only — F25); set `latest` or `main` to float on install.sh tip
5. On a PR, comment: `@luffy review this pr`

## High-ROI fixes

See [ROI-FIXES.md](ROI-FIXES.md) for the ranked backlog.

- **Sprint 1 (F1–F6):** shallow+sparse checkout, Hermes install cache, hub memory preload, drop broken home cache, reactions, shallow hub clone  
- **Sprint 2 (F11–F12):** author association allowlist, replace previous Luffy PR comment  
- **Sprint 3 (F13–F17):** sparse count bugfix, stable Hermes cache key, honest fail reaction, deny 😕, drop dead install copy  
- **Sprint 4 (F18):** secret redaction on posted review body  
- **Sprint 5 (F7):** pin Hermes install via `LUFFY_HERMES_COMMIT` + `scripts/hermes-pin.sh` (cache key v4)
- **Sprint 6 (F19):** per-PR re-trigger cooldown after successful review
- **Sprint 7 (F8):** prebaked Hermes runner image (`docker/luffy-runner/`, `vars.LUFFY_RUNNER_IMAGE`)
- **Sprint 8 (F20):** `scripts/install-luffy.sh` one-command pack install into target repos
- **Sprint 9 (F21):** cost/usage line on PR comments + job summary from `hermes-usage.json`
- **Sprint 10 (F10):** reusable `workflow_call` job + `install-luffy.sh --caller` hub-managed thin install
- **Sprint 11 (F22):** verdict-aware reaction + commit status `luffy/review` + job-summary verdict section
- **Sprint 12 (F23):** formal GitHub PR Review event from verdict (Reviews panel); opt-out `vars.LUFFY_PR_REVIEW=0`
- **Sprint 13 (F24):** dismiss prior Luffy PR reviews on re-run (APPROVED/CHANGES_REQUESTED); shares `LUFFY_REPLACE_PREVIOUS`
- **Sprint 14 (F25):** Hermes pin single source of truth — bump only `scripts/hermes-pin.sh`; workflows resolve empty var via `default`
- **Sprint 15 (F26):** default model SoT `anthropic/claude-opus-5` in `run-hermes-review.sh`; docs/.env.example aligned; cheaper via `vars.LUFFY_MODEL`
- **Sprint 16 (F27):** posted review gets a ⚠️ banner when the assembled PR diff was size-truncated (`MAX_DIFF_BYTES`)
- **Sprint 17 (F28):** repo-local `.luffy/` memory is the default SoT; hub publish is opt-in
- **Sprint 18 (F29):** soft max cost budget via `vars.LUFFY_MAX_COST_USD` (footer + job summary + warning; never fails the run)
- **Sprint 19 (F30):** memory health job summary + loud local-publish failure; README local-first
- **Sprint 20 (F31):** every run auto-writes `run-bundle.json` for the Run Console (artifact + job summary); soft-fail
- **Sprint 21 (F32):** `trigger-review.sh` + Modal bit4 enqueue/webhook + Run Console Run tab (spawn-only doorbell)
- **Sprint 22 (F33):** webhook HMAC + bearer auth on Modal doorbell (`webhook_auth.py`)
- **Sprint 23 (F9):** path-anchored inline PR comments on first changed line (`post-inline-comments.py`)
- **Sprint 24 (F34):** Modal webhook fail-closed by default (`LUFFY_WEBHOOK_ALLOW_OPEN=1` for dev)
- **Sprint 25 (F9b):** inline comments prefer `path:LINE` when that line is a changed `+` line
- **Sprint 26 (F35):** PR comment ops footer with Actions run link + run-bundle tip
- **Sprint 27 (F36):** Hermes wall-clock timeout (default 1500s; kill hung loops)
- **Sprint 28 (F37):** Verdict → PR labels (`luffy:approve` / `request-changes` / `comment` / `error`)
- **Sprint 29 (F38):** Path-glob free skip (opt-in docs-only / filtered PRs — no OpenRouter)
- **Sprint 30 (F9c):** GitHub apply-suggestion blocks from `### Code suggestions`
- **Sprint 31 (F39):** Modal host parity (path-skip + report-verdict on bit 3)
- **Sprint 32 (F40):** Ops signals in run-bundle + Run Console overview
- **Sprint 33 (F41):** Hermes max_turns iteration budget (default 40) + loop metrics in run-bundle
- **Sprint 34 (F42):** Auto model tier by PR size (`LUFFY_MODEL_TIER=auto` → cheap for tiny/docs)
- **Sprint 35 (F43):** Hard preflight spend estimate before Hermes (force_cheap / refuse)

## Ops signals in Run Console (F40/F41/F42)

Every auto-pack (`run-bundle.json`) includes a `signals` object:

| Flag | Source |
|------|--------|
| `timeout` | `hermes-timeout.env` / F36 review text |
| `path_skip` | `ops-signals.env` / F38 stub text |
| `over_budget` | review OVER BUDGET / F29 |
| `diff_truncated` | `meta.env` DIFF_TRUNCATED / F27 |
| `max_turns_hit` | `hermes-max-turns.env` / F41 iteration budget |
| `model_tier` / `model-cheap` | `model-tier.env` / F42 auto tier |
| `preflight_refuse` / `preflight-cheap` | `preflight-cost.env` / F43 |
| `tool_turns_gate` / `tool-turns-gate` | `tool-turns-gate.env` / F45 zero-tool fail-closed |

Also `loop` metrics: `tool_call_turns`, `message_count`, `step_count`, `max_turns`.

Console: header chips + Overview **Ops signals** + **Agent loop (F41)** panel.

## Hermes max turns (F41)

Cap Hermes tool-calling iterations (Hermes default **500** is far too high for CI).

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_MAX_TURNS` | `40` | Cap; `0`/`off` = unlimited Hermes default |

```bash
python3 scripts/max_turns.py resolve
python3 scripts/max_turns.py detect .luffy-out/hermes-*.stderr
```

Wired in `run-hermes-review.sh` (`--max-turns` + `agent.config` rewrite + detect).
Evidence: `hermes-max-turns.env`, job-summary **Luffy max turns (F41)**.

## Auto model tier (F42)

Opt-in cheap model for tiny / docs-only PRs (keeps Opus for large code PRs).

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_MODEL_TIER` | `off` | `auto` / `cheap` / `full` / `off` |
| `LUFFY_MODEL_CHEAP` | `openai/gpt-4.1-mini` | Cheap-tier OpenRouter id |
| `LUFFY_MODEL_FULL` | `anthropic/claude-opus-5` (or `LUFFY_MODEL`) | Full-tier model |
| `LUFFY_TIER_MAX_BYTES` | `12000` | Tiny-diff threshold |
| `LUFFY_TIER_MAX_FILES` | `3` | Tiny file-count threshold |

```bash
LUFFY_MODEL_TIER=auto python3 scripts/model_tier.py select --path README.md --diff-bytes 500
# → model=openai/gpt-4.1-mini tier=cheap reason=docs_only
```

Wired in `run-hermes-review.sh` after assemble meta. Evidence: `model-tier.env`,
`luffy-model.txt`, job-summary **Luffy model tier (F42)**, run-bundle `signals.model_tier*`.


## Preflight cost (F43)

Hard OpenRouter spend estimate **before** Hermes. Uses the same `LUFFY_MAX_COST_USD`
as F29, but gates *start* of the agent loop (F29 only annotates after).

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_MAX_COST_USD` | unset | Enables hard preflight when set |
| `LUFFY_PREFLIGHT_COST` | `auto` | `hard` when budget set; `off` / `estimate` |
| `LUFFY_PREFLIGHT_ACTION` | `force_cheap` | or `refuse` / `warn` |

```bash
python3 scripts/preflight_cost.py decide --model anthropic/claude-opus-5 --diff-bytes 200000
```

Evidence: `preflight-cost.env`, job-summary, Run Console chips.

## Tool-turns fail-closed (F45 / H12)

Zero Hermes tool turns on multi-file **code** PRs cannot leave **APPROVE** standing
(odoo e2e #2 mini false green). Docs-only and single-file PRs are exempt.

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_TOOL_TURNS_GATE` | `1` | `0`/`off` disables |
| `LUFFY_TOOL_TURNS_MIN_FILES` | `2` | multi-file threshold |
| `LUFFY_TOOL_TURNS_GATE_VERDICTS` | `APPROVE` | rewritten to COMMENT |

```bash
python3 scripts/tool_turns_gate.py decide --tool-turns 0 --file-count 4 --path a.js --path b.js
```

Wired post-normalize in `run-hermes-review.sh`. Evidence: `tool-turns-gate.env`,
job-summary **Luffy tool-turns gate (F45)**, chip `tool-turns-gate`.

## Modal host parity (F39)

`modal_app` `review_pr` (bit 3) now mirrors GHA cost/trust gates:

| Gate | Behaviour on Modal |
|------|--------------------|
| F38 path-skip | Before clone; env `LUFFY_SKIP_PATH_GLOBS`; force `LUFFY_SKIP_PATHS_FORCE=1` |
| F36 timeout | `LUFFY_REVIEW_TIMEOUT_SECONDS` (default 1500) |
| F41 max_turns | `LUFFY_MAX_TURNS` (default 40; `0`/`off` disables) |
| F22–F37 / F9 | `report-verdict.sh` after review (status, PR review, inline, labels) |

Offline helper: `python3 scripts/modal_parity.py path-skip …`. App version `0.6.0-f39`.

## Apply-suggestion blocks (F9c)

When the review includes `### Code suggestions` with a ```diff``` fence, Luffy posts
inline comments containing a GitHub ```suggestion``` block so authors can **Apply**
in the Files changed UI.

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_INLINE_SUGGESTIONS` | `1` | `0` disables F9c (findings F9/F9b still run) |
| `LUFFY_SUGGESTION_MAX` | `3` | Max suggestion comments per run |

Mapping: suggestion `-` lines must match a contiguous run of PR `+` lines (same
file). Multi-line → `start_line`/`line` on RIGHT. Soft-fail with F9.

```bash
python3 scripts/post-inline-comments.py plan \
  --review review.md --diff pr.diff   # JSON: suggestions count + kind=suggestion
```

## Path-glob free skip (F38)

Skip paid review when **every** changed file matches skip globs (docs/changelog PRs).

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_SKIP_PATH_GLOBS` | empty (off) | `docs` = built-in docs preset; or comma globs e.g. `*.md,docs/**` |

Force paid run: `@luffy review force` or `workflow_dispatch`. Fail-open on script errors.

```bash
python3 scripts/path-skip-check.py --path README.md --path docs/a.md --globs docs  # exit 2 skip
python3 scripts/path-skip-check.py --path src/x.py --path README.md --globs docs   # exit 0 allow
```

## Verdict PR labels (F37)

After each run Luffy applies **one** managed label on the PR (creates labels if missing)
and removes the other managed labels from a prior run:

| Verdict / state | Label |
|-----------------|-------|
| APPROVE | `luffy:approve` |
| REQUEST CHANGES | `luffy:request-changes` |
| COMMENT | `luffy:comment` |
| Pipeline fail / UNKNOWN | `luffy:error` |

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_PR_LABELS` | `1` | `0`/`off` disables |
| `LUFFY_LABEL_PREFIX` | `luffy` | Prefix before `:` |

```bash
python3 scripts/apply-verdict-labels.py plan --verdict REQUEST_CHANGES
python3 scripts/apply-verdict-labels.py apply --repo owner/name --pr 3 \
  --verdict APPROVE --pipeline-ok true
```

Needs `issues: write` (already on the workflow). Soft-fail only.

## Review timeout (F36)

Hung Hermes/OpenRouter loops are killed after a wall-clock limit so spend cannot
run until the full GHA job cap (90m).

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_REVIEW_TIMEOUT_SECONDS` | `1500` | Wall seconds for `hermes -z` (and chat fallback). `0`/`off` disables |

On timeout: exit 124, partial model output discarded, chat fallback **skipped**
(would double spend), posted review is an honest COMMENT failure stub, job
summary section **Luffy review timeout (F36)**. Trace: `hermes-timeout.env`,
`hermes-timeout-seconds.txt`.

```bash
python3 scripts/run-with-timeout.py resolve          # effective seconds
python3 scripts/run-with-timeout.py --seconds 2 -- sleep 10   # exits 124
```

## Ops footer (F35)

Posted review gets an italic ops line (after cost footer when present):

```text
*Ops (F35): [workflow run](…) · artifact `run-bundle.json` → `ui/review-console` Load bundle*
```

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_OPS_FOOTER` | `1` | `0` disables |
| `LUFFY_CONSOLE_URL` | empty | Optional hosted Run Console base URL |

## Inline comments (F9 / F9b / F9c)

After the formal F23 review, Luffy may post a second COMMENT review with **inline** notes. Anchors (F9b):

1. `` `path:LINE` `` / line hint from the finding when LINE is a changed `+` line → **exact**
2. else nearest changed line on that file → **nearest**
3. else first added line → **first** (F9)

**F9c:** also posts apply-suggestion blocks from `### Code suggestions` (see section above).

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_INLINE_COMMENTS` | `1` | `0`/`off` disables all inline (findings + suggestions) |
| `LUFFY_INLINE_SEVERITY` | `critical,high,blocking` | Comma list; `all` = no filter |
| `LUFFY_INLINE_MAX` | `6` | Cap finding notes per run |
| `LUFFY_INLINE_SUGGESTIONS` | `1` | F9c apply blocks |
| `LUFFY_SUGGESTION_MAX` | `3` | Cap suggestion notes per run |

Offline plan: `python3 scripts/post-inline-comments.py plan --review review.md --diff pr.diff` (see `anchor` / `line_hint` / `kind` in JSON).

## Repo-local memory (F28 default)

Each target repo owns review memory under **`.luffy/`** on its default branch:

```text
.luffy/
  MEMORY.md
  runs/{trace_id}/meta.json|review.md|summary.md
```

- Preload: `preload-hub-memory.sh` loads `.luffy/MEMORY.md` via contents API first (sparse PR workspace is not enough).
- Publish: `publish-run-local.sh` clones default branch → ingest layout=local → commit+push (`contents: write`).
- Fat traces stay Actions artifacts only.
- Vars: `LUFFY_MEMORY_MODE=local|hub|both` (default `local`), `LUFFY_MEMORY_PATH` (default `.luffy`), `LUFFY_HUB_PUBLISH=1` to force hub.

## Central hub memory (opt-in cross-repo)

Hub publish runs only when `LUFFY_MEMORY_MODE=hub|both` or `LUFFY_HUB_PUBLISH=1`.

**Hub:** `Mr-Ashish/luffy-pr-review-agent`  
**Path:** `memory/repos/{owner}--{repo}/`

### Flow

```text
Target Luffy run finishes
  → build-hub-payload.py (redacted, size-capped)
  → publish-run-local.sh  (default: commit target .luffy/)
  → publish-run-to-hub.sh (opt-in)
       mode=direct when enabled:
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
- Diff size cap (`MAX_DIFF_BYTES`, default 400000) — when hit, **F27** injects a visible ⚠️ banner on the posted review + job-summary section
- Job timeout 45 minutes
- Re-runs **replace** prior Luffy comments on the same PR (marker `<!-- luffy-review pr=N`); set `LUFFY_REPLACE_PREVIOUS=0` to stack
- **Per-PR cooldown (F19):** default 900s after a *successful* Luffy comment — skip paid run (rocket reaction). Override `vars.LUFFY_COOLDOWN_SECONDS` (`0`/`off` disables). Bypass: `@luffy review force` or workflow_dispatch
- **Cost visibility (F21):** each successful review footer includes estimated OpenRouter cost + token/API counts from `hermes-usage.json`; the Actions job summary has a matching **Luffy cost / usage** section (no artifact download required)
- **Soft max cost (F29):** set `vars.LUFFY_MAX_COST_USD` (e.g. `1.00`) to get ⚠️ OVER BUDGET on the PR cost line + job-summary budget section + Actions warning when estimated spend exceeds the max. Soft only (does not cancel/fail the review). `0`/`off`/unset disables.
- **Memory health (F30):** job summary table for preload source + local/hub publish. Local push failure (branch protection / token) → `::warning::` without failing the review. Inspect `.luffy-out/memory-health.env`.
- **Formal PR Review (F23):** after the full issue comment, Luffy also submits a short Pull Request Review with event `APPROVE` / `REQUEST_CHANGES` / `COMMENT` so the Reviews panel matches the verdict. Opt-out: `vars.LUFFY_PR_REVIEW=0`. APPROVE may soft-fall back to COMMENT (self-review / org policy).
- **Dismiss prior PR reviews (F24):** before a new F23 review, prior Luffy reviews with marker `<!-- luffy-pr-review pr=N` in state APPROVED/CHANGES_REQUESTED are dismissed (soft). Controlled by `LUFFY_REPLACE_PREVIOUS` (same as comment replace). COMMENTED reviews cannot be dismissed by GitHub and may remain.

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

Secrets (`sk-or-…`, `OPENROUTER_API_KEY=…`, common `ghp_`/`github_pat_` tokens) are redacted in **posted review bodies** (`normalize-review.py`, F18) and again before trace packaging / hub payload.

```bash
# Download latest trace for a run
gh run download <run-id> -R owner/repo -n luffy-trace-pr1-run<run-id>
```

## F8 Prebaked Hermes runner (faster CI startup)

Cold Hermes install is the expensive part of job startup (~2 minutes locally). Mitigation:

1. **Actions cache** (default): pin-keyed restore of `~/.local` + `~/.hermes` (F2/F14/F7).
2. **Prebaked image** (optional): build with workflow **Build Luffy Hermes runner** or `./scripts/build-luffy-runner-image.sh`. Image sets `LUFFY_HERMES_PREBAKED=1`. On runners that already have Hermes, export the same env so install is skipped.
3. **Benchmark:** `./scripts/benchmark-hermes-startup.sh` → `docs/benchmarks/hermes-startup-latest.md`.

