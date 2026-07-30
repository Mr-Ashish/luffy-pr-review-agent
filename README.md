<p align="center">
  <img src="assets/luffy-mark.png" alt="Luffy mark" width="128" height="128" />
</p>

<h1 align="center">Luffy — PR Review Agent</h1>

<p align="center">
  <img src="assets/twemoji-pirate-flag.png" alt="" width="28" height="28" />
  <strong>Comment-triggered PR reviews</strong> via
  <a href="https://github.com/nousresearch/hermes-agent">Hermes Agent</a>
  + <a href="https://openrouter.ai">OpenRouter</a>
  <img src="assets/twemoji-ship.png" alt="" width="28" height="28" />
</p>

<p align="center">
  <a href="https://github.com/Mr-Ashish/luffy-pr-review-agent/actions/workflows/luffy-pr-review.yml"><img alt="Luffy workflow" src="https://img.shields.io/github/actions/workflow/status/Mr-Ashish/luffy-pr-review-agent/luffy-pr-review.yml?label=Luffy%20PR%20Review&logo=github" /></a>
  <a href="https://github.com/Mr-Ashish/luffy-pr-review-agent/actions/workflows/ingest-luffy-run.yml"><img alt="Hub ingest" src="https://img.shields.io/github/actions/workflow/status/Mr-Ashish/luffy-pr-review-agent/ingest-luffy-run.yml?label=Hub%20memory&logo=github" /></a>
  <img alt="License" src="https://img.shields.io/badge/license-MIT-FF6B2C?logo=open-source-initiative&logoColor=white" />
</p>

Comment **`@luffy review this pr`** on a pull request → GitHub Actions runs Hermes + OpenRouter → Markdown review lands on the PR → **central hub memory** grows under [`memory/repos/`](memory/repos/).

## Flow

```text
@luffy review this pr
        │
        ▼
GitHub Actions (target repo)
  · dual workspace: luffy/ + PR head
  · Hermes one-shot + OpenRouter
  · normalize Markdown contract
  · post PR comment
  · upload run trace artifact
        │
        ▼
Hub publish (direct push / optional dispatch)
        │
        ▼
Mr-Ashish/luffy-pr-review-agent
  memory/repos/{owner}--{repo}/MEMORY.md
  memory/repos/{owner}--{repo}/runs/{trace_id}/
```

## Trigger

```text
@luffy review this pr
@luffy review
```

Also: **Actions → Luffy PR Review → Run workflow** (manual PR number).

## Setup (target repo)

1. Copy `agent/`, `scripts/`, and `.github/workflows/luffy-pr-review.yml` onto the **default branch**.
2. Secrets:
   - `OPENROUTER_API_KEY` — model calls  
   - `LUFFY_HUB_TOKEN` — PAT that can push to this hub (for central memory)
3. Optional variables: `LUFFY_MODEL`, `LUFFY_HUB_REPO`, `LUFFY_HUB_MODE`
4. Comment on a PR: `@luffy review this pr`

## Local dry-run

```bash
# .env has OPENROUTER_API_KEY (gitignored)
./scripts/review-local.sh owner/repo 123
POST_COMMENT=1 ./scripts/review-local.sh owner/repo 123
```

## Traces

Each run packages a redacted trace:

```text
.luffy-out/traces/pr{N}-run{id}-a{attempt}/
  meta.json  prompt.md  context.md  pr.diff
  review.raw.md  review.md  hermes.stderr  timings.json
```

Artifacts:

| Name | Retention |
|------|-----------|
| `luffy-trace-pr{N}-run{id}` | 90 days |
| `luffy-out-pr{N}-run{id}` | 14 days |

```bash
gh run download <run-id> -R owner/repo -n luffy-trace-pr1-run<run-id>
```

## Central hub memory

After each run, the target publishes into **this** repo:

```text
memory/repos/{owner}--{repo}/
  MEMORY.md
  latest.json
  runs/{trace_id}/meta.json|review.md|summary.md
```

See [memory/README.md](memory/README.md) and [docs/OPERATIONS.md](docs/OPERATIONS.md).

## Brand

| Asset | Path |
|-------|------|
| Mark (SVG) | [`assets/luffy-mark.svg`](assets/luffy-mark.svg) |
| Mark (PNG) | [`assets/luffy-mark.png`](assets/luffy-mark.png) |
| Favicon | [`assets/favicon.png`](assets/favicon.png) |
| Twemoji accents | [`assets/twemoji-*.png`](assets/) (CC-BY 4.0 Twitter) |

## Docs

- [Architecture](docs/ARCHITECTURE.md)
- [Operations](docs/OPERATIONS.md)

## Layout

```text
agent/          SOUL, prompts, Hermes config, memory seed
scripts/        assemble → hermes → normalize → distill → hub publish
memory/         central per-repo MEMORY (hub)
assets/         brand mark + favicon
.github/workflows/
  luffy-pr-review.yml
  ingest-luffy-run.yml
```

## v1 limits

- PR **comment** reviews (not inline threads yet)
- Large diffs truncated (`MAX_DIFF_BYTES`)
- Hermes installed on the runner (Docker pin later)

---

<p align="center">
  <img src="assets/twemoji-anchor.png" width="24" height="24" alt="" />
  <em>Luffy · Hermes Agent · OpenRouter · memory-backed review</em>
</p>
