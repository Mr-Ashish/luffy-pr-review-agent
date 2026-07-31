# Repository context

- **root:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **assembled_at:** 2026-07-31T16:35:02Z

## git status

```
?? .luffy-out-e2e-pr2-f44/
?? .luffy-out-e2e-pr2-h16/
```

## recent log

```
cd03a57 F48: scope SOUL detect + agent.log capture to this invocation (H17)
eaee0da knowledge: dogfood F47 hermes -z argv / max-turns contract
9b99910 F47: fix hermes -z reliability (H14) — drop invalid --max-turns CLI flag
b305fac docs(dogfood): F46 SOUL context scan knowledge + showcase
b92deb3 fix(F46): keep SOUL.md loadable under Hermes threat scanner (H13)
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
scripts/soul_context_scan.py
scripts/sparse-pr-paths.sh
```

## git diff

```
(no unstaged/uncommitted diff)
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
- **F40–F45 signals:** bundle includes `signals` (timeout / path-skip / over-budget / diff-truncated / max-turns / model-tier / preflight / **tool-turns-gate** + `flags[]`) and `loop` metrics. Overview shows **Ops signals** + **Agent loop (F41)**; header chips when any flag is set. Path-skip → `ops-signals.env`; F41 → `hermes-max-turns.env`; F42 → `model-tier.env`; F45 → `tool-turns-gate.env`.
- Manual pack (showcase / older runs): `python3 scripts/pack-run-for-ui.py --dir path/to/run-or-showcase -o run-bundle.json` (`--host gha|modal|local`, `--memory-health path`, `--also path`, `--soft`).
- UI: `cd ui/review-console && npm install && npm run pack-fixture && npm run dev` → http://localhost:5177 → **Load bundle** for any `run-bundle.json`.

## Trigger a review (F32)
--model anthropic/claude-opus-5 --diff-bytes 200000 --file-count 20
--path a.js --path b.js --env-out tool-turns-gate.env
--path README.md --diff-bytes 400
--review docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/review.md \

## Common commands
- Install Luffy into another repo (self-contained pack): `./scripts/install-luffy.sh /path/to/target-repo` (`--force` overwrite; `--dry-run` preview).
- Hub-managed thin install (F10, no agent/scripts copy): `./scripts/install-luffy.sh --caller /path/to/target-repo`.
- Build prebaked Hermes runner image: `./scripts/build-luffy-runner-image.sh` (option
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

