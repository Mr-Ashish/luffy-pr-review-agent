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

## High-level architecture

```mermaid
flowchart TB
  subgraph Humans
    Dev["Developer"]
  end

  subgraph TargetRepo["Target repo (e.g. Mr-Ashish/odoo)"]
    PR["Pull request"]
    Comment["@luffy review this pr"]
    GHA["GitHub Actions\nluffy-pr-review.yml"]
    Scripts["scripts/\nassemble · hermes · normalize\ndistill · save-trace · hub publish"]
    AgentCfg["agent/\nSOUL · config · prompts"]
    Artifacts["Actions artifacts\ntrace 90d · out 14d"]
  end

  subgraph LLM["Inference"]
    Hermes["Hermes Agent\n(-z one-shot)"]
    OR["OpenRouter\nopenai/gpt-5-mini"]
  end

  subgraph Hub["Hub: Mr-Ashish/luffy-pr-review-agent"]
    Memory["memory/repos/{owner}--{repo}/\nMEMORY.md · runs/{trace_id}/"]
  end

  Dev --> Comment
  Comment --> PR
  PR --> GHA
  GHA --> Scripts
  GHA --> AgentCfg
  Scripts --> Hermes
  Hermes --> OR
  OR --> Hermes
  Scripts --> Artifacts
  Scripts --> Memory
  Scripts --> PR
```

**Pieces**

| Layer | Responsibility |
|--------|----------------|
| **Target repo** | Workflow install, secrets, PR comment trigger, runs the job |
| **Luffy scripts** | Context assembly, Hermes invoke, normalize, distill, hub publish |
| **Hermes + OpenRouter** | Model review of the PR |
| **Hub repo** | Durable per-repo memory + run summaries |
| **Artifacts** | Redacted per-run traces for audit |

## E2E flow

```mermaid
sequenceDiagram
  autonumber
  actor Dev as Developer
  participant PR as Target PR
  participant GHA as GitHub Actions
  participant Hub as Luffy hub
  participant Hermes as Hermes Agent
  participant OR as OpenRouter

  Dev->>PR: Comment "@luffy review this pr"
  PR->>GHA: issue_comment event

  Note over GHA: Gate + concurrency + 👀 reaction
  GHA->>GHA: Checkout luffy/ (agent + scripts)
  GHA->>GHA: Sparse shallow checkout of PR head
  GHA->>Hub: Preload MEMORY.md for this repo
  Hub-->>GHA: Prior review notes (if any)

  GHA->>GHA: assemble-context (pr.json, diff, prompt)
  GHA->>Hermes: hermes -z + SOUL + memory + prompt
  Hermes->>OR: chat/completions (gpt-5-mini)
  OR-->>Hermes: review Markdown
  Hermes-->>GHA: review.raw.md

  GHA->>GHA: normalize-review.py → review.md
  GHA->>GHA: distill local MEMORY + save-trace
  GHA->>Hub: publish-run-to-hub (direct push)
  Note over Hub: memory/repos/.../MEMORY.md<br/>runs/{trace_id}/meta+review+summary
  GHA->>PR: gh pr comment (review.md)
  GHA->>GHA: Upload luffy-trace + luffy-out artifacts
  GHA->>PR: React +1 / -1 on trigger
```

**Pipeline stages** (orchestrator)

```mermaid
flowchart LR
  A[preload_hub_memory] --> B[assemble]
  B --> C[hermes -z]
  C --> D[normalize]
  D --> E[distill]
  E --> F[save_trace]
  F --> G[publish_hub]
  G --> H[PR comment + artifacts]
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
