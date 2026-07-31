# Repository context

- **root:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **assembled_at:** 2026-07-31T12:07:41Z

## git status

```
M .gitignore
?? DEV.md
?? USAGE.md
```

## recent log

```
dea239c brand: use Three.js orbital core as README hero artifact
6a938b1 feat(brand): Three.js square artifact gallery (not banners)
0b578c4 fix(readme-kit): repair package.json; link brand options in docs
8d24dec feat(brand): 8 code-generated hero banner options for review
0c9b861 docs: technical blog on building Luffy (anti-slop edit)
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
memory/README.md
memory/index.json
memory/repos/Mr-Ashish--odoo/MEMORY.md
memory/repos/Mr-Ashish--odoo/latest.json
memory/repos/Mr-Ashish--luffy-pr-review-agent/MEMORY.md
memory/repos/Mr-Ashish--luffy-pr-review-agent/latest.json
tests/test_gate_helpers.py
tests/test_hub_ingest.py
tests/test_normalize_review.py
agent/MEMORY.seed.md
agent/SOUL.md
agent/config.yaml
agent/review-prompt.md
docs/ARCHITECTURE.md
docs/OPERATIONS.md
docs/README-BRANDING-ECOSYSTEM.md
docs/README-KIT-MVP.md
docs/ROI-FIXES.md
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

## git diff

```
diff --git a/.gitignore b/.gitignore
index ac1d802..2b06407 100644
--- a/.gitignore
+++ b/.gitignore
@@ -12,3 +12,4 @@ node_modules/
 .pytest_cache/
 # local brand experiments (examples/luffy/branding is committed as demo)
 /branding/
+.devmemory/
```

## existing knowledge files

### DEV.md

# DEV — engineering knowledge

> How this repository is built.

## Architecture

_(seeded by devmemory init)_


### USAGE.md

# USAGE — operational knowledge

> How to work with this repository.

## Common commands

```bash
devmemory extract --fixture sample-auth-module --apply
```


