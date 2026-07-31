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
| 25 | **F26** | Align default model docs + code (`anthropic/claude-opus-5` SoT) | XS | 🔥 Trust/cost — ops docs no longer understate spend | **Shipped** (`DEFAULT_LUFFY_MODEL`) |
| 26 | **F27** | Auto banner when PR diff was size-truncated | XS | 🔥 Trust — incomplete context always visible on PR | **Shipped** (`normalize-review --diff-truncated`) |
| 27 | **F28** | Repo-local `.luffy/` memory (primary); hub publish opt-in only | S | 🔥 Product memory lives on the target; no hub required | **Shipped** (`publish-run-local.sh`, ingest layout=local, preload local-first) |
| 28 | F9 | Inline GitHub review comments (line-level) | L | Product | Later |

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

### Sprint 15 (shipped)

**F26** default model alignment: `DEFAULT_LUFFY_MODEL=anthropic/claude-opus-5` in `run-hermes-review.sh` is SoT; OPERATIONS/USAGE/.env.example no longer claim `gpt-5-mini` as the script default. Workflow leaves empty `vars.LUFFY_MODEL` unset so the script default applies (no second hardcoded fallback). Effective model → `.luffy-out/luffy-model.txt`.

### Sprint 16 (shipped)

**F27** diff-truncation trust banner: when `assemble-context` sets `DIFF_TRUNCATED=true` (PR diff > `MAX_DIFF_BYTES`), `normalize-review.py --diff-truncated` injects a ⚠️ callout before `**Verdict:**` so the posted comment always shows incomplete context even if the model forgets. Job summary gets a **Luffy diff truncation (F27)** section.

### Sprint 17 (shipped)

**F28** repo-local `.luffy/` memory: target repo is SoT for `MEMORY.md` + slim `runs/{trace}/`. Default `LUFFY_MEMORY_MODE=local` (hub off). Preload local-first via contents API; hub only if `both|hub` or `LUFFY_HUB_PUBLISH=1`. Install seeds `.luffy/MEMORY.md`. Scripts: `publish-run-local.sh`, `hub-ingest-run.py` layout=local, updated `preload-hub-memory.sh` / `publish-run-to-hub.sh`.

### readme-kit (shipped)

YAML config (preferred) + JSON parity; `yaml` npm dep; dead hand-rolled parser removed.
