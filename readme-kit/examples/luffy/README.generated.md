<p align="center">
  <img src="assets/luffy-mark.svg" alt="Luffy" width="128" />
</p>

# Luffy

**Comment-triggered PR review agent**

Hermes Agent + OpenRouter + growing hub memory + redacted run traces.

[![PR Review](https://img.shields.io/github/actions/workflow/status/Mr-Ashish/luffy-pr-review-agent/luffy-pr-review.yml?branch=main&style=for-the-badge&label=PR%20Review&logo=githubactions&logoColor=white)](https://github.com/Mr-Ashish/luffy-pr-review-agent/actions/workflows/luffy-pr-review.yml)
[![Hub memory](https://img.shields.io/github/actions/workflow/status/Mr-Ashish/luffy-pr-review-agent/ingest-luffy-run.yml?branch=main&style=for-the-badge&label=Hub%20memory&logo=githubactions&logoColor=white)](https://github.com/Mr-Ashish/luffy-pr-review-agent/actions/workflows/ingest-luffy-run.yml)
![trigger](https://img.shields.io/badge/trigger-%40luffy%20review%20this%20pr-FF6B2C?style=for-the-badge&logo=github&logoColor=white)
![model](https://img.shields.io/badge/model-openai%2Fgpt-5-mini-0B0F19?style=for-the-badge&logo=openai&logoColor=white)
![provider](https://img.shields.io/badge/provider-OpenRouter-C41E3A?style=for-the-badge)
[![Last commit](https://img.shields.io/github/last-commit/Mr-Ashish/luffy-pr-review-agent/main?style=for-the-badge&logo=git&logoColor=white&color=0B0F19)](https://github.com/Mr-Ashish/luffy-pr-review-agent/commits/main)
![License](https://img.shields.io/badge/license-MIT-FFD166?style=for-the-badge&labelColor=0B0F19&logo=open-source-initiative&logoColor=FFD166)

## Why it exists

Most AI PR bots are stateless chat on a diff. Luffy is a review control plane: explicit trigger, bounded context (sparse checkout + capped diff), Hermes via OpenRouter, durable hub memory so the next review on the same repo is smarter, and redacted traces as Actions artifacts for audit.

## Trigger

```text
@luffy review this pr
@luffy review
```

Also: **Actions → Luffy PR Review → Run workflow** (PR number).

## High-level architecture

```mermaid
flowchart TB
  subgraph Humans
    Dev["Developer"]
  end

  subgraph TargetRepo["Target repo"]
    PR["Pull request"]
    Comment["@luffy review this pr"]
    GHA["GitHub Actions"]
    Scripts["Luffy scripts"]
  end

  subgraph LLM["Inference"]
    Hermes["Hermes Agent"]
    OR["OpenRouter"]
  end

  subgraph Hub["Hub repo"]
    Memory["memory/repos/..."]
  end

  Dev --> Comment --> PR --> GHA
  GHA --> Scripts
  Scripts --> Hermes --> OR
  Scripts --> Memory
  Scripts --> PR
```

Install Luffy on each **target** repo; this hub stores memory under `memory/repos/`.

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

  Dev->>PR: @luffy review this pr
  PR->>GHA: issue_comment
  GHA->>Hub: preload MEMORY.md
  Hub-->>GHA: prior notes
  GHA->>GHA: assemble prompt + diff
  GHA->>Hermes: hermes -z
  Hermes->>OR: completions
  OR-->>Hermes: review markdown
  Hermes-->>GHA: final text
  GHA->>Hub: publish memory + run
  GHA->>PR: review comment + artifacts
```

**Pipeline stages**

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

## Setup (target repo)

1. Copy `agent/`, `scripts/`, and `.github/workflows/luffy-pr-review.yml` onto the **default branch**
2. Add secret `OPENROUTER_API_KEY`
3. Add secret `LUFFY_HUB_TOKEN` (PAT that can push to this hub)
4. Optional vars: `LUFFY_MODEL`, `LUFFY_HUB_REPO`, `LUFFY_HUB_MODE`
5. Comment on a PR: `@luffy review this pr`

## Local dry-run

```bash
# .env has OPENROUTER_API_KEY (gitignored)
./scripts/review-local.sh owner/repo 123
POST_COMMENT=1 ./scripts/review-local.sh owner/repo 123
```

## Traces

Each run packages a redacted trace and uploads Actions artifacts.

```text
.luffy-out/traces/pr{N}-run{id}-a{attempt}/
  meta.json  prompt.md  context.md  pr.diff
  review.raw.md  review.md  hermes.stderr  timings.json
```

```bash
gh run download <run-id> -R owner/repo -n luffy-trace-pr1-run<run-id>
```

## Central hub memory

After each run, the target publishes into **this** hub repo so memory grows across reviews.

```text
memory/repos/{owner}--{repo}/
  MEMORY.md
  latest.json
  runs/{trace_id}/meta.json|review.md|summary.md
```

## Layout

```text
agent/          SOUL, prompts, Hermes config
scripts/        assemble → hermes → normalize → hub
memory/         central per-repo MEMORY (hub)
readme-kit/     compile README from theme + pack + config
assets/         brand mark + favicon
.github/workflows/
```

## Docs

- [Architecture](docs/ARCHITECTURE.md)
- [Operations](docs/OPERATIONS.md)
- [ROI fixes](docs/ROI-FIXES.md)
- [README branding ecosystem](docs/README-BRANDING-ECOSYSTEM.md)
- [readme-kit MVP](docs/README-KIT-MVP.md)

## Limits (v1)

- PR comment reviews only (not inline threads yet)
- Diffs truncated at MAX_DIFF_BYTES
- Default OpenRouter model is paid (openai/gpt-5-mini)
- Install on each target repo — not a global bot for arbitrary public repos
- Hermes tool-loop traces not fully exported yet (final review + outer pipeline are)

---

*Luffy · Hermes Agent · OpenRouter · memory-backed review · generated by readme-kit*

