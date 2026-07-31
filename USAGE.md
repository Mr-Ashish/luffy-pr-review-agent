# USAGE — operational knowledge

> How to work with this repository.

## Run console

- **F31 auto-pack:** every review writes `.luffy-out/run-bundle.json` (and `traces/<id>/run-bundle.json`) — download the `luffy-out` or `luffy-trace` Actions artifact and load it in the console. Soft-fail only.
- Manual pack (showcase / older runs): `python3 scripts/pack-run-for-ui.py --dir path/to/run-or-showcase -o run-bundle.json` (`--host gha|modal|local`, `--memory-health path`, `--also path`, `--soft`).
- UI: `cd ui/review-console && npm install && npm run pack-fixture && npm run dev` → http://localhost:5177 → **Load bundle** for any `run-bundle.json`.
- Tabs: Overview, **Run** (F32 trigger), PR, Result, Findings, Diff, Trace, Agent loop, Cost, Memory, Artifacts, Raw review
- Optional OpenUI Lang: `python3 scripts/review-to-openui.py --review review.md -o out.openui`
- Design: Impeccable (`/tmp/impeccable`) · `ui/review-console/PRODUCT.md` + `DESIGN.md`

## Trigger a review (F32)

```bash
./scripts/trigger-review.sh print  owner/repo 123          # commands only
./scripts/trigger-review.sh local  owner/repo 123 --model openai/gpt-4.1-mini
./scripts/trigger-review.sh modal  owner/repo 123 --cheap --no-post
modal run modal_app/app.py --bit 4 --repo owner/repo --pr 123   # dry enqueue plan
```

Run Console **Run** tab copies the same commands + sample webhook JSON. Modal webhook (after `modal deploy`) accepts `{repo,pr,model,post_comment}` or GitHub `@luffy review` issue_comment on a PR — spawns only.

### Ops footer / deep-link (F35)

```bash
# Preview line (needs GITHUB_REPOSITORY + GITHUB_RUN_ID in env for the Actions link)
GITHUB_REPOSITORY=owner/repo GITHUB_RUN_ID=123 python3 scripts/ops_footer.py line
# Inject into a review before post
python3 scripts/ops_footer.py append --review .luffy-out/review-3.md
```

Optional hosted console: `LUFFY_CONSOLE_URL=https://…`. Opt-out: `LUFFY_OPS_FOOTER=0`.

### Inline comments (F9 / F9b)

```bash
# Plan only (no API) — JSON includes line_hint + anchor (exact|nearest|first)
python3 scripts/post-inline-comments.py plan \
  --review docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/review.md \
  --diff docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/pr.diff

# Post (needs gh auth + head SHA)
python3 scripts/post-inline-comments.py post \
  --review review.md --diff pr.diff --repo owner/name --pr 3 --commit "$HEAD_SHA"
```

Key findings File column may use `` `path:LINE` `` when LINE is a new line from the diff (F9b). Opt-out: `vars.LUFFY_INLINE_COMMENTS=0`. Severity/max: `LUFFY_INLINE_SEVERITY`, `LUFFY_INLINE_MAX`.

### Webhook auth (F33/F34)

```bash
# Sign a body like GitHub would (fixture / curl)
python3 scripts/webhook_auth.py sign --secret "$LUFFY_WEBHOOK_SECRET" --body payload.json
# Authorize
python3 scripts/webhook_auth.py authorize --secret "$LUFFY_WEBHOOK_SECRET" --body payload.json \
  --header "X-Hub-Signature-256: sha256=…"
# Dev open (not for production)
python3 scripts/webhook_auth.py authorize --allow-open --body payload.json
```

Set `LUFFY_WEBHOOK_SECRET` (GitHub) and/or `LUFFY_WEBHOOK_TOKEN` (Bearer) on the Modal function env. **F34:** neither → denied (fail-closed). Local smoke only: `LUFFY_WEBHOOK_ALLOW_OPEN=1`.
## Common commands

- Install Luffy into another repo (self-contained pack): `./scripts/install-luffy.sh /path/to/target-repo` (`--force` overwrite; `--dry-run` preview).
- Hub-managed thin install (F10, no agent/scripts copy): `./scripts/install-luffy.sh --caller /path/to/target-repo`.
- Build prebaked Hermes runner image: `./scripts/build-luffy-runner-image.sh` (optional `PUSH=1`).
- Benchmark Hermes startup paths: `SKIP_COLD=1 ./scripts/benchmark-hermes-startup.sh` → `docs/benchmarks/`.

```bash
devmemory extract --fixture sample-auth-module --apply
```

- Inspect the effective Hermes pin locally without network: `scripts/hermes-pin.sh resolve` (empty output = floating), `scripts/hermes-pin.sh default` (baked-in known-good SHA — **F25 single source of truth** for CI when `vars.LUFFY_HERMES_COMMIT` is unset), `scripts/hermes-pin.sh install-args` (exact `install.sh` args), `scripts/hermes-pin.sh cache-suffix` (Actions cache key suffix).
- Check whether an installed tree satisfies the pin: `scripts/hermes-pin.sh matches <git-head-sha>` — exit 0 means acceptable (short/full SHA prefixes both count).
- Per-run pin actually used is recorded at `.luffy-out/hermes-pin.txt` and shipped in the trace artifact — read it before blaming the model for a behaviour change.

- Explicit-flag form of the installer (equivalent to the positional target): `./scripts/install-luffy.sh --dest /path/to/target-repo [--source /path/to/luffy] [--dry-run|--force]`.
- Hub-only extra: `--with-hub-ingest` additionally copies `.github/workflows/ingest-luffy-run.yml` (install this on the hub repo, not on app repos).
- Image-building extra: `--with-runner-build` copies `build-luffy-runner.yml`, `docker/luffy-runner/{Dockerfile,README.md}`, plus `scripts/build-luffy-runner-image.sh` and `scripts/benchmark-hermes-startup.sh`, which are otherwise excluded from target packs.

- F21/F29 cost/usage CLI: `python3 scripts/usage-summary.py footer --usage <hermes-usage.json>` (print line); `… append --usage … --review review.md` (inject into posted body); `… step-summary --usage … --timings timings.json` (Actions job summary Markdown); `… budget --usage … --max-usd 1.00` (F29 kv: `over_budget=`). Soft max also via env `LUFFY_MAX_COST_USD`. All modes exit 0 with no/minimal output when the usage file is missing or empty.
- F27 truncation banner: `python3 scripts/normalize-review.py -i raw.md -o out.md --pr N --diff-truncated` injects a ⚠️ callout when the assembled PR diff was capped (`MAX_DIFF_BYTES`; set via env / repo var).

- Regenerate the Hermes startup comparison: `./scripts/benchmark-hermes-startup.sh` writes `docs/benchmarks/hermes-startup-latest.md` (cold Hermes install measured at ~1–2 min, which is what the cache/prebaked-image paths are traded against).

## Setup

- Install on each target repo's **default branch** (workflow only runs from default branch):
  - **Pack:** `./scripts/install-luffy.sh /path/to/target-repo` — `agent/`, runtime `scripts/`, thin caller + local reusable.
- Required secret: `OPENROUTER_API_KEY`.
- **Memory (F28):** each target repo owns review memory under **`.luffy/`** (committed slim pack: `MEMORY.md` + `runs/{trace}/`). Install seeds `.luffy/MEMORY.md`. Fat debug traces stay Actions artifacts only.
- Optional hub memory: set repo var `LUFFY_MEMORY_MODE=both` or `hub`, and/or `LUFFY_HUB_PUBLISH=1`, plus secret `LUFFY_HUB_TOKEN` (PAT with contents write on the hub). Default mode is `local` (hub off).
- Optional repo variables: `LUFFY_MODEL` (script default `anthropic/claude-opus-5` — F26 SoT in `run-hermes-review.sh`; override e.g. `openai/gpt-5-mini` for cheaper runs), `LUFFY_HERMES_COMMIT` (pin Hermes SHA; default in `scripts/hermes-pin.sh`; `latest`/`main` = floating tip), `LUFFY_COOLDOWN_SECONDS` (default 900; `0`/`off` disables re-trigger cooldown), `LUFFY_RUNNER_IMAGE` (optional prebaked Hermes container image, F8), `LUFFY_MAX_COST_USD` (F29 soft budget USD; `0`/`off`/unset disables), `LUFFY_MEMORY_MODE` (`local`|`hub`|`both`), `LUFFY_MEMORY_PATH` (default `.luffy`), `LUFFY_HUB_REPO`, `LUFFY_HUB_MODE`, `LUFFY_HUB_PUBLISH`, `LUFFY_ALLOWED_ASSOCIATIONS`, `LUFFY_REPLACE_PREVIOUS`, `MAX_DIFF_BYTES`, `MAX_MEMORY_BYTES`.
- Trigger a review by commenting `@luffy review this pr` (or `@luffy review`) on the PR.

### Repo-local memory commands

```bash
# Offline: write slim pack under a checkout's .luffy/
export CLIENT_PAYLOAD_FILE=path/to/client_payload.json
export LUFFY_INGEST_LAYOUT=local LUFFY_MEMORY_ROOT=/path/to/target
python3 scripts/hub-ingest-run.py

# Preload preference dry-run (needs network/API or curl stub): local path first
REPO=owner/name HERMES_HOME=/tmp/hh LUFFY_MEMORY_MODE=local bash scripts/preload-hub-memory.sh
```

## Debugging

- Local dry-run (needs authenticated `gh`, network, and `.env` with `OPENROUTER_API_KEY`): `./scripts/review-local.sh owner/repo 123`; add `POST_COMMENT=1` to actually comment on the PR.
- Two artifacts per run: `luffy-out-pr<N>-run<id>` (full `.luffy-out/` + memory snapshot, 14 days) and `luffy-trace-pr<N>-run<id>` (structured redacted trace, 90 days).
- Fetch a trace with `gh run download <run-id> -R owner/repo -n luffy-trace-pr<N>-run<run-id>`.
- Trace layout under `traces/pr{N}-run{RUN_ID}-a{ATTEMPT}/`: `meta.json`, `trace.json`, `prompt.md`, `context.md`, `pr.json`/`pr.diff`, `review.raw.md` (Hermes stdout) vs `review.md` (posted body), `hermes.stderr`, `timings.json`, `memory-before.md`/`memory-after.md` — diff raw vs normalized to isolate contract violations, and before/after memory to verify distill.
- `scripts/capture-hermes-loop.py` turns a run into a step-by-step agent-loop dump (API calls, tool turns, messages, token/cost estimates) as in `docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/`.

- Reproduce a cooldown decision offline (no `gh`, no network): `LUFFY_COOLDOWN_FIXTURE=/tmp/comments.json NOW_EPOCH=1753963200 bash scripts/cooldown-check.sh 1` — fixture is a JSON array of `{created_at, body}` objects; read the `allowed=`/`reason=`/`remaining_s=` lines and the exit code (0 allow, 2 skip, 1 error).

- For deeper digging, `hermes-usage.json` travels with the run package (see `docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/hermes-usage.json` for a captured example alongside `timings.json`).
- If cost/token values render as `n/a`, the usage JSON parsed but the specific field was absent or non-numeric; if the whole line is missing, the usage file itself was missing/empty and every subcommand no-opped.

- Exercise the F27 local ingest offline against any checkout: `CLIENT_PAYLOAD_FILE=path/to/client_payload.json LUFFY_INGEST_LAYOUT=local LUFFY_MEMORY_ROOT=/path/to/target python3 scripts/hub-ingest-run.py` — prints `MEMORY=`, `RUN_DIR=`, `LAYOUT=local` and writes `.luffy-ingest-summary.txt` at the root.
- Check which memory source a run would use: `REPO=owner/name HERMES_HOME=/tmp/hh LUFFY_MEMORY_MODE=local bash scripts/preload-hub-memory.sh` (needs network or a curl stub); the `MEMORY_SOURCE=` line on stdout tells you local vs hub vs seed.

- Inline comments (F9) can be exercised with zero GitHub API calls: set `LUFFY_INLINE_FIXTURE=<path>` and `post-inline-comments.py` writes the review payload JSON to that path instead of calling `gh api` — this is the hook the tests use, and the same trick works for inspecting a real run's intended anchors.
- `LUFFY_INLINE_DIFF` overrides which diff file the anchor resolution reads, so you can replay anchoring against a saved `pr.diff` (e.g. from a showcase trace) without re-assembling context.
- Identify Luffy's inline output by its markers when auditing a PR: each comment body carries `<!-- luffy-inline -->` and the enclosing review body carries `<!-- luffy-inline-review pr=N -->`.

## Troubleshooting

- Confirm which Luffy version a target repo runs: read `.luffy-install-stamp` (`mode=pack|caller`, `source_sha`) and compare with `git -C <luffy-source> rev-parse --short HEAD`. A stale `source_sha` after a re-install means files were skipped — re-run with `--force`. For `mode=caller`, runtime tracks hub `main`, not the stamp alone.
- Installer output is entirely on stderr; capture it with `./scripts/install-luffy.sh /path/to/repo 2>&1 | tee install.log` and grep for `exists (skip` / `WARN missing` before committing the pack.
- Preview exactly what would be written (including the stamp) with `--dry-run`; lines are prefixed `DRY  <from> → <to>`.

- No `luffy/review` status on the PR head: check (1) repo variable `LUFFY_COMMIT_STATUS` is not `0` (that is the documented opt-out), (2) the caller workflow grants `statuses: write`.
- A neutral 👀 reaction plus `success` means the verdict line was parsed as `UNKNOWN` (or the review was a genuine COMMENT); inspect `review.md` in the trace artifact for a line starting with `**Verdict:**` before blaming the status code path.

- To make Luffy gate merges, add `luffy/review` as a required status check — `REQUEST CHANGES` reports `failure` while `APPROVE`/`COMMENT` report `success`, and any pipeline failure (`pipeline_rc != 0`) reports `error` with 👎 regardless of the parsed verdict.

## F22/F23 verdict signals

After each run Luffy derives a **verdict signal** from the posted review body:

| Verdict | Trigger reaction | Commit status `luffy/review` | PR review event (F23) |
|---------|------------------|------------------------------|------------------------|
| APPROVE | `+1` | `success` | `APPROVE` (fallback `COMMENT`) |
| REQUEST CHANGES | `-1` | `failure` | `REQUEST_CHANGES` |
| COMMENT | `eyes` | `success` | `COMMENT` |
| Pipeline failed | `-1` | `error` | `COMMENT` (not REQUEST_CHANGES) |

- CLI: `python3 scripts/parse-verdict.py review.md --pipeline-rc 0` (kv lines; includes `review_event=`)
- Disable commit status: repo var `LUFFY_COMMIT_STATUS=0`
- Disable formal PR review: repo var `LUFFY_PR_REVIEW=0`
- Status context override: `LUFFY_STATUS_CONTEXT` (default `luffy/review`)
- Full Markdown stays on the **issue comment** (F12 replace). F23 posts a short Reviews-panel review with marker `<!-- luffy-pr-review pr=N`.
