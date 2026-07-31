# Repository context

- **root:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **assembled_at:** 2026-07-31T12:25:36Z

## git status

```
(clean)
```

## recent log

```
ff1096a feat(ops): prebaked Hermes runner image + optional container (F8)
3c7d39b docs(knowledge): dogfood F19 cooldown patterns into DEV/USAGE + showcase
e015fd2 feat(cost): per-PR re-trigger cooldown after successful review (F19)
5b836d5 docs(knowledge): dogfood F7 Hermes pin into DEV/USAGE + showcase
34841d9 feat(ops): pin Hermes install for reproducible CI (F7)
```

## tree (sample)

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
docker/luffy-runner/Dockerfile
docker/luffy-runner/README.md
memory/DEV.md
memory/README.md
memory/index.json
memory/repos/Mr-Ashish--odoo/MEMORY.md
memory/repos/Mr-Ashish--odoo/latest.json
memory/repos/Mr-Ashish--luffy-pr-review-agent/MEMORY.md
memory/repos/Mr-Ashish--luffy-pr-review-agent/latest.json
tests/test_cooldown_check.py
tests/test_gate_helpers.py
tests/test_hermes_pin.py
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
docs/benchmarks/hermes-startup-latest.json
docs/benchmarks/hermes-startup-latest.md
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
scripts/benchmark-hermes-startup.sh
scripts/build-hub-payload.py
scripts/build-luffy-runner-image.sh
scripts/capture-hermes-loop.py
scripts/cooldown-check.sh
scripts/distill-memory.sh
scripts/hermes-pin.sh
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

## git diff

```
(no unstaged/uncommitted diff)
```

## existing knowledge files

### claim index (do not restate these claims)
- [DEV.md#Architecture] @luffy action assemble cacheartifact checkout comment concurrency context
- [DEV.md#Architecture] artifact compos deterministic every inner llm-driven orchestr record
- [DEV.md#Architecture] assemble-contextsh contractfencessizehtml distill-memorysh hermes-pinsh hub-ingest-runpy marker normalize-reviewpy one-shot
- [DEV.md#Architecture] branch config default domain luffy luffy-hermes-home memory prompt
- [DEV.md#Design decisions] 400000 45-minute 900s @luffy allowlist author-associ bypas cancel-in-progres
- [DEV.md#Design decisions] action cache container detect dockerluffy-runner ensureherm exist image
- [DEV.md#Design decisions] --commit --force-commit --skip-setup action cache default float install
- [DEV.md#Design decisions] comment delet luffy luffy-review luffyreplaceprevious=0 marker match prior
- [DEV.md#Design decisions] always-publish comment crash failure hermesmodel low-confidence openrouter produce
- [DEV.md#Design decisions] agentic assembl beyond capture-hermes-looppy completion default inspect luffytoolset
- [DEV.md#Design decisions] activity agenttool hermestuitoolprogress=verbose later level observability pythonunbuffered=1 recoverable
- [DEV.md#Design decisions] directory disposable explicitly hermeshome memory memorymd preserv through
- [DEV.md#Pitfalls] 403 cannot classic clone default dispatch githubtoken ingest
- [DEV.md#Pitfalls] content cross-repo githubtoken itself luffy luffyhubtoken publish requir
- [DEV.md#Pitfalls] again agent comment common embedd f18 github honour
- [DEV.md#Pitfalls] 100000 budget default exceed growth maxmemorybyt memorymd otherwise
- [DEV.md#Pitfalls] backlog broken cache class count dishonest historical sparse-checkout
- [DEV.md#Pitfalls] advertise alone anthropicclaude-opus-5 anyone default diverg either explicitly
- [DEV.md#Pitfalls] --version accept behaviour binary check contain degrad ensureherm
- [DEV.md#Pitfalls] <sha> default defaulthermescommit duplicat fallback hardcod overrid script
- [DEV.md#Pitfalls] --paginate array assum buffer concatenat consumer cooldown-checksh extend
- [DEV.md#Pitfalls] disabl error guard luffycooldownsecond non-integer reason=disabledinvalid remov silently
- [DEV.md#Pitfalls] age=0 bypass clamp clock comment cooldown maximis newer
- [DEV.md#Patterns] apikey-style assignment choke-point driven generic ghpousr… githubpat… helper
- [DEV.md#Patterns] 
… [claim index truncated; do not restate] …

### knowledge excerpts
### DEV.md

## Architecture
- Luffy is a gated GitHub Actions control plane, not a chat bot: `@luffy review this pr` → gate + per-PR concurrency → dual checkout → restore Hermes memory → assemble context → `hermes -z` → normalize → PR comment → distill memory → cache/artifacts.
- Orchestration is deterministic shell (`scripts/run-luffy-review.sh` composes stages and records timings); only the inner review step is LLM-driven, so every run leaves reproducible artifacts.
- Stage → script map: assemble-context.sh (gh pr meta + diff + prompt, no LLM), run-hermes-review.sh (Hermes one-shot over `WORKSPACE_ROOT`; F7 pin via hermes-pin.sh), normalize-review.py (contract/fences/size/HTML marker + secret redact), distill-memory.sh, post-review-comment.sh, save-trace.sh, publish-run-to-hub.sh, hub-ingest-run.py.
- Dual workspace separates trust domains: `luffy/` holds SOUL + prompts + scripts from the default branch, `workspace/` holds only the PR head, `.luffy-hermes-home/` holds Hermes config + growing memory.

## Design decisions
- Cost/abuse controls are layered: **F19 per-PR cooldown** (`scripts/cooldown-check.sh`, default 900s after a *successful* Luffy comment; failure stubs do not start the window; `@luffy review force` / `workflow_dispatch` / `LUFFY_COOLDOWN_SECONDS=0` bypass), author-association allowlist (default `OWNER,MEMBER,COLLABORATOR,CONTRIBUTOR`, override with repo var `LUFFY_ALLOWED_ASSOCIATIONS`, empty disables the gate), concurrency cancel-in-progress per PR, `MAX_DIFF_BYTES` (default 400000) diff cap, and a 45-minute job timeout.
- **F8 prebaked runner:** `ensure_hermes` sho
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

## Common commands
- Build prebaked Hermes runner image: `./scripts/build-luffy-runner-image.sh` (optional `PUSH=1`).
- Benchmark Hermes startup paths: `SKIP_COLD=1 ./scripts/benchmark-hermes-startup.sh` → `docs/benchmarks/`.
- Inspect the effective Hermes pin locally without network: `scripts/hermes-pin.sh resolve` (empty output = floating), `scripts/hermes-pin.sh default` (baked-in known-good SHA), `scripts/hermes-pin.sh install-args` (exact `install.sh` args), `scripts/hermes-pin.sh cache-suffix` (Actions cache key suffix).
- Check whether an installed tree satisfies the pin: `scripts/hermes-pin.sh matches <git-head-sha>` — exit 0 means acceptable (short/full SHA prefixes both count).

## Setup
- Install on each target repo by copying `agent/`, `scripts/`, and `.github/workflows/luffy-pr-review.yml` onto that repo's **default branch** (workflow only runs from default branch).
- Required secret: `OPENROUTER_API_KEY`. For cross-repo hub memory also add `LUFFY_HUB_TOKEN` (PAT with contents write on the hub).
- Optional repo variables: `LUFFY_MODEL` (script default `openai/gpt-5-mini`; showcase runs used `anthropic/claude-opus-5`), `LUFFY_HERMES_COMMIT` (pin Hermes SHA; default in `scripts/hermes-pin.sh`; `latest`/`main` = floating tip), `LUFFY_COOLDOWN_SECONDS` (default 900; `0`/`off` disables re-trigger cooldown), `LUFFY_RUNNER_IMAGE` (optional prebaked Hermes container image, F8), `LUFFY_HUB_REPO`, `LUFFY_HUB_MODE`, `LUFFY_ALLOWED_ASSOCIATIONS`, `LUFFY_REPLACE_PREVIOUS`, `MAX_DIFF_BYTES`, `MAX_MEMORY_BYTES`.
- Trigger a review by commenting `@luffy review this pr` (or `@l
… [truncated; do not restate] …

