# Session

- **session_id:** `dogfood-luffy-session`
- **source:** `file`
- **project:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **timestamp:** ``

## Transcript / notes

# Luffy dogfood — F25 pin SoT

## OPERATIONS
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
3. Optional variable: `LUFFY_MODEL` (default in scripts: `openai/gpt-5-mini`)
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
- **Per-PR cooldown (F19):** default 900s after a *successful* Luffy comment — skip paid run (rocket reaction). Override `vars.LUFFY_COOLDOWN_SECONDS` (`0`/`off` disables). Bypass: `@luffy review force` or workflow_dispatch
- **Cost visibility (F21):** each successful review footer includes estimated OpenRouter cost + token/API counts from `hermes-usage.json`; the Actions job summary has a matching **Luffy cost / usage** section (no artifact download required)
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

Secrets (`sk-or-…`, `[REDACTED] common `ghp_`/`github_pat_` tokens) are redacted in **posted review bodies** (`normalize-review.py`, F18) and again before trace packaging / hub payload.

```bash
# Download latest trace for a run
gh run download <run-id> -R owner/repo -n luffy-trace-pr1-run<run-id>
```

## F8 Prebaked Hermes runner (faster CI startup)

Cold Hermes install is the expensive part of job startup (~2 minutes locally). Mitigation:

1. **Actions cache** (default): pin-keyed restore of `~/.local` + `~/.hermes` (F2/F14/F7).
2. **Prebaked image** (optional): build with workflow **Build Luffy Hermes runner** or `./scripts/build-luffy-runner-image.sh`. Image sets `LUFFY_HERMES_PREBAKED=1`. On runners that already have Hermes, export the same env so install is skipped.
3. **Benchmark:** `./scripts/benchmark-hermes-startup.sh` → `docs/benchmarks/hermes-startup-latest.md`.


## ROI-FIXES
# High-ROI minimal fixes (triage)

Evidence from live e2e (Odoo monorepo + hub memory):

| Symptom | Observed |
|---------|----------|
| Monorepo checkout | ~3.5 min for full Odoo PR head (`fetch-depth: 0`) |
| Hermes cold install | ~1–2 min every job |
| Actions cache | `cache write denied` despite `actions: write` |
| Hub memory | Written after run, **not loaded into** next review |
| UX | Only 👀 reaction; no done/fail signal |

## Ranked list

| Rank | ID | Fix | Effort | ROI | Status |
|------|-----|-----|--------|-----|--------|
| 1 | **F1** | PR head `fetch-depth: 1` + **sparse-checkout of changed paths only** | S | 🔥 Huge time on monorepos | **Shipped** (e2e: sparse cone 1 path on Odoo) |
| 2 | **F2** | **Cache Hermes install** (`~/.local` + `~/.hermes` bin) | S | 🔥 Cuts cold install | **Shipped** (cache step; warm on 2nd run) |
| 3 | **F3** | **Preload hub `MEMORY.md`** into `HERMES_HOME` before review | S | 🔥 Real memory-backed reviews | **Shipped** (e2e: `HUB_MEMORY=preloaded` 1126B) |
| 4 | **F4** | Drop broken hermes-home Actions cache (hub is SoT) / soft-fail | XS | Removes noise, simpler | **Shipped** |
| 5 | **F5** | ✅ / ❌ reactions on trigger comment | XS | Clear UX | **Shipped** (`+1`/`-1`) |
| 6 | **F6** | Cap hub clone depth=1 (already ~20) → 1 | XS | Small | **Shipped** |
| 7 | **F11** | Author association allowlist (default OWNER/MEMBER/COLLABORATOR/CONTRIBUTOR; override via `vars.LUFFY_ALLOWED_ASSOCIATIONS`) | XS | 🔥 Cost control | **Shipped** |
| 8 | **F12** | Replace previous Luffy comment (delete prior `<!-- luffy-review pr=N` before post) | XS | 🔥 Less PR noise | **Shipped** |
| 9 | **F13** | Fix sparse path `grep -c \|\| echo 0` → empty PR path count was `0\\n0`, forcing full monorepo clone | XS | 🔥 Correct sparse path | **Shipped** |
| 10 | **F14** | Hermes cache: stable key `v3`, save **only on miss** (drop per-run_id thrash) | XS | 🔥 Cache hits + GH cache quota | **Shipped** |
| 11 | **F15** | Config error `pipeline_rc=1` (was 0 → false ✅ reaction) | XS | Honest UX | **Shipped** |
| 12 | **F16** | Association deny → 😕 reaction (no OpenRouter spend) | XS | Visible deny | **Shipped** |
| 13 | **F17** | Drop dead `RUNNER_TEMP` Hermes tree copy after cold install | XS | Faster cold path | **Shipped** |
| 14 | **F18** | Redact secrets in **posted** review (`normalize-review.py` choke-point) | XS | 🔥 Trust — no keys on PR comments | **Shipped** |
| 15 | **F7** | Pin Hermes install (`scripts/hermes-pin.sh` + `LUFFY_HERMES_COMMIT` + cache key `v4-<pin>`) | S | 🔥 Repro CI | **Shipped** |
| 16 | **F19** | Per-PR re-trigger cooldown (`scripts/cooldown-check.sh`, default 900s) | S | 🔥 Cost/abuse | **Shipped** |
| 17 | **F20** | `scripts/install-luffy.sh` copy pack to target repo | S | 🔥 Adoption | **Shipped** |
| 18 | **F8** | Prebaked Hermes runner image + startup benchmark | M | 🔥 Fast CI startup | **Shipped** (docker/ + build workflow + benchmark script) |
| 19 | **F21** | Surface OpenRouter cost/tokens on PR comment + job summary | XS | 🔥 Cost visibility | **Shipped** (`usage-summary.py`) |
| 20 | **F10** | Reusable `workflow_call` + thin hub caller | M | 🔥 Multi-repo DX | **Shipped** (`luffy-review-reusable.yml`, `--caller`) |
| 21 | **F22** | Verdict-aware done signal (reaction + commit status + job summary) | XS | 🔥 Trust UX — REQUEST CHANGES no longer looks like ✅ | **Shipped** (`parse-verdict.py`, `report-verdict.sh`) |
| 22 | **F23** | Formal GitHub PR Review event from verdict (Reviews panel) | XS | 🔥 Trust UX — APPROVE/REQUEST_CHANGES/COMMENT as real PR reviews | **Shipped** (`review_event` + `report-verdict.sh`) |
| 23 | **F24** | Dismiss prior Luffy PR reviews on re-run (Reviews hygiene) | XS | 🔥 Trust UX — re-@luffy no longer stacks APPROVE/REQUEST_CHANGES | **Shipped** (`dismiss-prior-pr-reviews.sh`) |
| 24 | **F25** | Hermes pin single source of truth (no workflow hardcoded SHA) | XS | 🔥 Ops/repro — bump pin in one place | **Shipped** (workflows call `hermes-pin.sh default`) |
| 25 | F9 | Inline GitHub review comments (line-level) | L | Product | Later |

### Sprint 1 (shipped)

**F1–F6** wall-clock + memory quality.

### Sprint 2 (shipped)

**F11–F12** cost control + comment hygiene.

### Sprint 3 (shipped)

**F13–F17** correctness + cache + reaction honesty.

### Sprint 4 (shipped)

**F18** secret redaction on normalize → PR comment path (aligned with trace/hub scrub patterns).

### Sprint 5 (shipped)

**F7** pin Hermes via `LUFFY_HERMES_COMMIT` (default known-good SHA in `scripts/hermes-pin.sh` + workflow env); install uses `install.sh --skip-setup --commit … --force-commit`; Actions cache key `luffy-hermes-bin-*-v4-<pin>`; set var to `latest`/`main` to float. Trace includes `hermes-pin.txt`.

### Sprint 6 (shipped)

**F19** per-PR re-trigger cooldown: after a *successful* Luffy PR comment, further `@luffy review` within `LUFFY_COOLDOWN_SECONDS` (default **900**) skips Hermes/OpenRouter (rocket reaction + job summary). Failures do not start the window. Bypass: `@luffy review force`, `workflow_dispatch`, or set cooldown to `0`/`off`.

### Sprint 7 (shipped)

**F8** prebaked Hermes runner: `docker/luffy-runner/Dockerfile` + `scripts/build-luffy-runner-image.sh` + GHCR publish workflow; optional `vars.LUFFY_RUNNER_IMAGE` as job `container`; `ensure_hermes` short-circuits on `LUFFY_HERMES_PREBAKED=1` or `~/.hermes-pin`; startup benchmark under `docs/benchmarks/`.

### Sprint 8 (shipped)

**F20** one-command install: `scripts/install-luffy.sh /path/to/target-repo` copies `agent/`, runtime `scripts/`, and `luffy-pr-review.yml`; optional `--with-hub-ingest` / `--with-runner-build`; stamp `.luffy-install-stamp`.

### Sprint 9 (shipped)

**F21** cost/usage visibility: `scripts/usage-summary.py` appends a `*Cost / usage: …*` line to the posted review from `hermes-usage.json` and writes a job-summary section (model, estimated USD, tokens, API calls, stage timings). Soft no-op when usage is missing.

### Sprint 10 (shipped)

**F10** reusable packaging: `luffy-review-reusable.yml` holds the full review job (`workflow_call` + `luffy_repository` / `luffy_ref` inputs). Thin `luffy-pr-review.yml` triggers and calls it. `install-luffy.sh --caller` installs only `pack/luffy-pr-review-caller.yml` pointing at hub `@main` (no agent/scripts copy — free upgrades). Default pack mode still copies agent/scripts + both workflow files for self-contained targets.

### Sprint 11 (shipped)

**F22** verdict-aware done signal: parse `**Verdict:**` from the posted review → trigger-comment reaction (`+1` / `-1` / `eyes`) and PR-head commit status `luffy/review` (`success` / `failure` / `error`). Pipeline failures stay `error`+`-1`. Job summary gets a **Luffy verdict (F22)** section. Opt-out: `vars.LUFFY_COMMIT_STATUS=0`. Required-status checks can require context `luffy/review`.

### Sprint 12 (shipped)

**F23** formal PR Review: same verdict map emits `review_event` (`APPROVE` / `REQUEST_CHANGES` / `COMMENT`) and `report-verdict.sh` posts a short GitHub Pull Request Review so the Reviews panel matches the reaction/status. Full Markdown stays on the issue comment (F12). Pipeline failures use `COMMENT` (not REQUEST_CHANGES). APPROVE soft-falls back to COMMENT when GitHub rejects self/bot approve. Opt-out: `vars.LUFFY_PR_REVIEW=0`.

### Sprint 13 (shipped)

**F24** dismiss prior Luffy PR reviews: before posting a new F23 review, `dismiss-prior-pr-reviews.sh` finds bodies with `<!-- luffy-pr-review pr=N` and dismisses `APPROVED` / `CHANGES_REQUESTED` (GitHub cannot dismiss `COMMENTED`). Shares `LUFFY_REPLACE_PREVIOUS` with F12 (0 = leave history). Soft-fail; fixture-testable via `LUFFY_PR_REVIEWS_FIXTURE`.

### Sprint 14 (shipped)

**F25** Hermes pin single source of truth: remove hardcoded `DEFAULT_HERMES_COMMIT` from workflow `env:` fallbacks. Empty/unset `vars.LUFFY_HERMES_COMMIT` → after pack checkout, write pin from `scripts/hermes-pin.sh default` into `$GITHUB_ENV`. Explicit `latest`/`main`/`floating` still float. Same for `build-luffy-runner.yml`. Bump pin only in `hermes-pin.sh` (Dockerfile ARG may lag for standalone builds).

### readme-kit (shipped)

YAML config (preferred) + JSON parity; `yaml` npm dep; dead hand-rolled parser removed.

## DEV
# DEV — engineering knowledge

> How this repository is built.

## Architecture

- Luffy is a gated GitHub Actions control plane, not a chat bot: `@luffy review this pr` → gate + per-PR concurrency → dual checkout → restore Hermes memory → assemble context → `hermes -z` → normalize → PR comment → distill memory → cache/artifacts.
- Orchestration is deterministic shell (`scripts/run-luffy-review.sh` composes stages and records timings); only the inner review step is LLM-driven, so every run leaves reproducible artifacts.
- Stage → script map: assemble-context.sh (gh pr meta + diff + prompt, no LLM), run-hermes-review.sh (Hermes one-shot over `WORKSPACE_ROOT`; F7 pin via hermes-pin.sh), normalize-review.py (contract/fences/size/HTML marker + secret redact), usage-summary.py (F21 cost footer + job summary from hermes-usage.json), parse-verdict.py + report-verdict.sh (F22 reaction/status + F23 formal PR review + F24 dismiss-prior), distill-memory.sh, post-review-comment.sh, save-trace.sh, publish-run-to-hub.sh, hub-ingest-run.py.
- **F20/F10 install:** `scripts/install-luffy.sh` is the adoption entrypoint. Default **pack** mode copies `agent/`, runtime scripts, thin `luffy-pr-review.yml`, and `luffy-review-reusable.yml`. **`--caller`** installs only the hub-managed thin workflow from `pack/luffy-pr-review-caller.yml` (no agent/scripts). Optional `--with-hub-ingest` / `--with-runner-build` (pack mode). Stamp `.luffy-install-stamp` records `mode=pack|caller` + source SHA.
- Dual workspace separates trust domains: `luffy/` holds SOUL + prompts + scripts (from pack default branch or hub checkout), `workspace/` holds only the PR head, `.luffy-hermes-home/` holds Hermes config + growing memory.
- **F10 packaging split:** the whole review job lives in `.github/workflows/luffy-review-reusable.yml` (`on: workflow_call`, inputs `luffy_repository` / `luffy_ref`); `luffy-pr-review.yml` is a thin trigger-only caller that owns `issue_comment` / `workflow_dispatch`, concurrency and permissions, then `uses:` the reusable job.

## Design decisions

- **F8 prebaked runner:** `ensure_hermes` short-circuits when `LUFFY_HERMES_PREBAKED=1` or `/root/.hermes-pin`/`$HOME/.hermes-pin` exists and `hermes` is on PATH (image from `docker/luffy-runner/`). Workflow optional `container: vars.LUFFY_RUNNER_IMAGE`; Hermes Actions cache is skipped when prebaked is detected.
- Hermes install is pinned for repro (F7/F25): `scripts/hermes-pin.sh` is the **single source of truth** for `DEFAULT_HERMES_COMMIT`. Workflows pass through `vars.LUFFY_HERMES_COMMIT` only; when empty, **Resolve Hermes pin (F25)** writes `hermes-pin.sh default` into `$GITHUB_ENV` (empty GHA var must not float). Explicit `latest`/`main`/`floating` still float. `install.sh` args via `install-args`; cache key suffix `v4-<12-char-pin>`.
- Re-runs replace prior Luffy comments by deleting bodies matching the `<!-- luffy-review pr=N` marker before posting; set `LUFFY_REPLACE_PREVIOUS=0` to stack instead.
- Failure UX is always-publish: missing OpenRouter secret, Hermes/model failure, and job crash before the review file each still produce a PR comment (failure stub / low-confidence COMMENT verdict) rather than a silent red X.

- The review step is agentic, not a single completion: Hermes runs with `LUFFY_TOOLSETS` (default `terminal`) so the reviewer can inspect files under `WORKSPACE_ROOT` beyond the assembled diff, and `capture-hermes-loop.py` records the tool loop.
- Observability is forced on at the env level (`HERMES_TUI_TOOL_PROGRESS=verbose`, `PYTHONUNBUFFERED=1`) so agent/tool activity is recoverable from logs even for a run that later fails.
- `HERMES_HOME` is seeded per run but `MEMORY.md` is explicitly preserved through seeding — the home directory is disposable, the memory file is not.

- The installer copies **itself** into the target pack (`install-luffy.sh` is in `RUNTIME_SCRIPTS`), so an installed repo can re-run the install/update from its own tree; executable bits are preserved per-file (`[[ -x "$from" ]] && chmod +x`).
- Installing the pack into the Luffy source tree itself (`SRC == DEST`) is refused unless `--force`, explicitly to avoid half-copies over the canonical tree.

- **F22/F23/F24 verdict signal** is a post-post decoration: `scripts/parse-verdict.py` reads `**Verdict:**` and maps APPROVE→`+1`/`success`/`APPROVE`, REQUEST CHANGES→`-1`/`failure`/`REQUEST_CHANGES`, COMMENT→`eyes`/`success`/`COMMENT`; pipeline_rc≠0 forces `-1`/`error`/`COMMENT`. `report-verdict.sh` applies soft reaction + commit status + **F24 dismiss prior** Luffy PR reviews + short formal PR Review (F23). Opt-outs: `LUFFY_COMMIT_STATUS=0`, `LUFFY_PR_REVIEW=0`; replace/dismiss share `LUFFY_REPLACE_PREVIOUS`.
- Telemetry is explicitly non-load-bearing: missing, empty, non-dict, or unparseable usage files are soft no-ops that exit 0, and `run-hermes-review.sh` calls the `append` step guarded by `[[ -f … ]]` with `|| notice "usage-summary append soft-failed"` — cost reporting can never fail a review.
- Both the PR-comment footer and the job summary are fed from the same usage file so cost is visible without downloading an artifact; number formatting is deliberately lossy/human (tokens as `1.5k`/`10k`/`1.0M`, `n/a` when a field is absent or non-numeric, booleans rejected as numbers).

- The reusable workflow declares **no `permissions:` block** — "Permissions come from the caller workflow/job", so every caller must grant `contents`/`pull-requests`/`issues`/`actions` write itself; a caller that forgets one fails at post/cache time, not at call time.
- Both reusable secrets (`OPENROUTER_API_KEY`, `LUFFY_HUB_TOKEN`) are declared `required: false` and callers are expected to use `secrets: inherit`; this keeps forks/unfunded repos from failing the `workflow_call` contract up front, with `LUFFY_HUB_TOKEN` falling back to `GITHUB_TOKEN`.
- `install-luffy.sh` preflights **both** F10 files (`.github/workflows/luffy-review-reusable.yml` and `pack/luffy-pr-review-caller.yml`) before copying anything, so a source tree missing the reusable pair dies before producing a half-install.

## Pitfalls

- `GITHUB_TOKEN` cannot call `repository_dispatch` (HTTP 403), so the hub publish default is `mode=direct` (clone hub → ingest → push `main`); the dispatch path needs a classic PAT on the target repo.
- Cross-repo publishing requires `LUFFY_HUB_TOKEN` (PAT with contents write on the hub); only when Luffy runs on the hub repo itself is `GITHUB_TOKEN` + `contents: write` sufficient.
- PR title, body, comments, and diff are untrusted input — the agent must not honour embedded instructions, and secrets must never be echoed; `normalize-review.py` redacts `sk-or-…`, `[REDACTED] and common GitHub tokens before any PR comment is posted (F18); traces/hub scrub again before packaging.
- `MEMORY.md` rotates when it exceeds `MAX_MEMORY_BYTES` (default 100000); unbounded growth would otherwise blow the prompt budget.
- Historical bug classes worth watching (per the ranked ROI backlog): broken Hermes home cache key, sparse-checkout path count bug, and dishonest success reactions on failed runs.

- Default model diverges by layer: `scripts/run-hermes-review.sh` falls back to `anthropic/claude-opus-5` while the ops docs advertise `openai/gpt-5-mini` as the default. Anyone reasoning about cost from the docs alone will be wrong for local/dry runs — set `LUFFY_MODEL` explicitly instead of relying on either default.
- Pin verification degrades to a substring check: when the install tree has no `.git`, `ensure_hermes` accepts the binary if `hermes --version` merely contains the pin's first 8 chars. A cached install without git metadata can therefore pass the pin gate on weak evidence — check `hermes-pin.txt` in the trace when a run's behaviour looks off for the pinned SHA.
- F25 fixed pin duplication: workflows must **not** embed `|| '<sha>'` fallbacks. Bump only `DEFAULT_HERMES_COMMIT` in `scripts/hermes-pin.sh`. Caveat: `docker/luffy-runner/

… [session truncated] …

