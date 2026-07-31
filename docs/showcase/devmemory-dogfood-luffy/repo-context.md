# Repository context

- **root:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **assembled_at:** 2026-07-31T12:15:33Z

## git status

```
(clean)
```

## recent log

```
34841d9 feat(ops): pin Hermes install for reproducible CI (F7)
fc672e8 feat(security): redact secrets in posted PR reviews (F18)
0cfa72c Add colocated DEV/USAGE from devmemory dogfood on Luffy
dea239c brand: use Three.js orbital core as README hero artifact
6a938b1 feat(brand): Three.js square artifact gallery (not banners)
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
memory/DEV.md
memory/README.md
memory/index.json
memory/repos/Mr-Ashish--odoo/MEMORY.md
memory/repos/Mr-Ashish--odoo/latest.json
memory/repos/Mr-Ashish--luffy-pr-review-agent/MEMORY.md
memory/repos/Mr-Ashish--luffy-pr-review-agent/latest.json
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
- [DEV.md#Design decisions] 400000 45-minute allowlist author-associ cancel-in-progres concurrency control costabuse
- [DEV.md#Design decisions] --commit --force-commit --skip-setup action cache default float install
- [DEV.md#Design decisions] comment delet luffy luffy-review luffyreplaceprevious=0 marker match prior
- [DEV.md#Design decisions] always-publish comment crash failure hermesmodel low-confidence openrouter produce
- [DEV.md#Pitfalls] 403 cannot classic clone default dispatch githubtoken ingest
- [DEV.md#Pitfalls] content cross-repo githubtoken itself luffy luffyhubtoken publish requir
- [DEV.md#Pitfalls] again agent comment common embedd f18 github honour
- [DEV.md#Pitfalls] 100000 budget default exceed growth maxmemorybyt memorymd otherwise
- [DEV.md#Pitfalls] backlog broken cache class count dishonest historical sparse-checkout
- [DEV.md#Patterns] apikey-style assignment choke-point driven generic ghpousr… githubpat… helper
- [DEV.md#Patterns] adding again agent cannot contract-failure ensurecontract fallback normalize-reviewpy
- [DEV.md#Patterns] acros added apart comment drift duplicated-but-align intentionally normalize-reviewpy
- [DEV.md#Patterns] agentsoulmd delegat enforc guarantee intent mechanically model never
- [DEV.md#Patterns] absent assert assertion both-sid broken-output fallback githubtokenredact includ
- [memory/DEV.md#Architecture] central doubl every flatten history ingest latestjson memorymd
- [memory/DEV.md#Architecture] build-hub-payloadpy commit default direct hub-ingest-runpy luffy-run memory optional
- [memory/DEV.md#Architecture] cross-repo cross-run hermeshome memory per-job preload preload-hub-memorysh review
- [memory/DEV.md#Architecture] behaviour default direct|dispatch|both disable env-configurable luffyhubmode luffyhubpublish=0 luffyhubrepo
- [agent/DEV.md#Design decisions] added agentsoulmd already chang contract explicitly import invent
- [agent/DEV.md#Design decisions] approve attempt ig
… [claim index truncated; do not restate] …

### knowledge excerpts
### DEV.md

## Architecture
- Luffy is a gated GitHub Actions control plane, not a chat bot: `@luffy review this pr` → gate + per-PR concurrency → dual checkout → restore Hermes memory → assemble context → `hermes -z` → normalize → PR comment → distill memory → cache/artifacts.
- Orchestration is deterministic shell (`scripts/run-luffy-review.sh` composes stages and records timings); only the inner review step is LLM-driven, so every run leaves reproducible artifacts.
- Stage → script map: assemble-context.sh (gh pr meta + diff + prompt, no LLM), run-hermes-review.sh (Hermes one-shot over `WORKSPACE_ROOT`; F7 pin via hermes-pin.sh), normalize-review.py (contract/fences/size/HTML marker + secret redact), distill-memory.sh, post-review-comment.sh, save-trace.sh, publish-run-to-hub.sh, hub-ingest-run.py.
- Dual workspace separates trust domains: `luffy/` holds SOUL + prompts + scripts from the default branch, `workspace/` holds only the PR head, `.luffy-hermes-home/` holds Hermes config + growing memory.

## Design decisions
- Cost/abuse controls are layered: author-association allowlist (default `OWNER,MEMBER,COLLABORATOR,CONTRIBUTOR`, override with repo var `LUFFY_ALLOWED_ASSOCIATIONS`, empty disables the gate), concurrency cancel-in-progress per PR, `MAX_DIFF_BYTES` (default 400000) diff cap, and a 45-minute job timeout.
- Hermes install is pinned for repro (F7): `scripts/hermes-pin.sh` resolves `LUFFY_HERMES_COMMIT` (default known-good SHA; `latest`/`main`/`floating`/empty = float), emits `install.sh` args (`--skip-setup --commit … --force-commit`), and supplies the Actions cache key 
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
- Optional repo variables: `LUFFY_MODEL` (script default `openai/gpt-5-mini`; showcase runs used `anthropic/claude-opus-5`), `LUFFY_HERMES_COMMIT` (pin Hermes SHA; default in `scripts/hermes-pin.sh`; `latest`/`main` = floating tip), `LUFFY_HUB_REPO`, `LUFFY_HUB_MODE`, `LUFFY_ALLOWED_ASSOCIATIONS`, `LUFFY_REPLACE_PREVIOUS`, `MAX_DIFF_BYTES`, `MAX_MEMORY_BYTES`.
- Trigger a review by commenting `@luffy review this pr` (or `@luffy review`) on the PR.

## Debugging
- Local dry-run (needs authenticated `gh`, network, and `.env` with `OPENROUTER_API_KEY`): `./scripts/review-local.sh owner/repo 123`; add `POST_COMMENT=1` to actually comment on the PR.
- Two artifacts per run: `luffy-out-pr<N>-run<id>` (full `.luffy-out/` + memory snapshot, 14 days) and `luffy-trace-pr<N>-run<id>` (structured redacted trace, 90 days).
- Fetch a trace with `gh run download <run-id> -R owner/repo -n luffy-trace-pr<N>-run<run-id>`.
- Trace layout under `traces/pr{N}-run{RUN_ID}-a{ATTEMPT}/`: `meta.json`, `trace.json`, `prompt.md`, `context.md`, `pr.json`/`pr.diff`, `review.raw.md` (Hermes stdout) vs `review.md` (posted body), `hermes.stderr`, `timings.json`, `memory-before.md`/`memory-after.md` — diff raw vs normalized to isolate contract violations, and before/after memory to veri
… [truncated; do not restate] …

