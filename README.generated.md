<p align="center">
  <img src="assets/luffy-hero-banner.svg" alt="Luffy" width="100%" />
</p>

<h1 align="center">Luffy</h1>

<p align="center"><strong>Comment-triggered PR review agent</strong></p>

<p align="center">Hermes Agent + OpenRouter + growing hub memory + redacted run traces.</p>

[![PR Review](https://img.shields.io/static/v1?label=PR+Review&message=comment+%C2%B7+Actions&color=2ea44f&style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/Mr-Ashish/luffy-pr-review-agent/actions/workflows/luffy-pr-review.yml)
[![Hub memory](https://img.shields.io/static/v1?label=Hub+memory&message=central+ingest&color=C41E3A&style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/Mr-Ashish/luffy-pr-review-agent/actions/workflows/ingest-luffy-run.yml)
![trigger](https://img.shields.io/static/v1?label=trigger&message=%40luffy+review+this+pr&color=FF6B2C&style=for-the-badge&logo=github&logoColor=white)
![model](https://img.shields.io/static/v1?label=model&message=openai%2Fgpt-5-mini&color=0B0F19&style=for-the-badge)
![provider](https://img.shields.io/static/v1?label=provider&message=OpenRouter&color=C41E3A&style=for-the-badge)
[![Last commit](https://img.shields.io/static/v1?label=branch&message=main&color=0B0F19&style=for-the-badge&logo=git&logoColor=white)](https://github.com/Mr-Ashish/luffy-pr-review-agent/commits/main)
![License](https://img.shields.io/static/v1?label=license&message=MIT&color=FFD166&style=for-the-badge&logo=open-source-initiative&logoColor=FFD166&labelColor=0B0F19)

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

## Agentic loop (example)

End-to-end control plane for one review: comment trigger → Actions gate → orchestrator stages → Hermes one-shot agentic loop over OpenRouter → normalize → memory + trace → PR comment. Example from the live Odoo e2e path.

**ASCII (high level)**

```text
@luffy review this pr
        │
        ▼
┌───────────────────────────────────────────────────────────────┐
│  GitHub Actions · luffy-pr-review.yml                         │
│  gate (pattern + association) → 👀 → sparse checkout → cache  │
└────────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
┌───────────────────────────────────────────────────────────────┐
│  Orchestrator · scripts/run-luffy-review.sh                   │
│                                                               │
│   1 preload_hub_memory ──► Hub MEMORY.md → HERMES_HOME        │
│   2 assemble-context   ──► PR meta + diff + prompt + SOUL     │
│   3 hermes -z  ───────────────────────────────────────────┐   │
│        │                                                  │   │
│        │    ┌─ agentic loop (Hermes + OpenRouter) ──────┐ │   │
│        │    │  prompt + memory + workspace               │ │   │
│        │    │       │                                   │ │   │
│        │    │       ▼                                   │ │   │
│        │    │  model reasoning ◄──► tools (read files)  │ │   │
│        │    │       │                                   │ │   │
│        │    │       ▼                                   │ │   │
│        │    │  draft Markdown review                    │ │   │
│        │    └───────────────────────────────────────────┘ │   │
│        ▼                                                  │   │
│   4 normalize-review   ──► contract · marker · cap        │   │
│   5 distill-memory     ──► append notes to MEMORY.md      │   │
│   6 save-trace         ──► redacted .luffy-out/traces/    │   │
│   7 publish-run-to-hub ──► memory/repos/{owner}--{repo}/  │   │
└────────────────────────────┬──────────────────────────────────┘
                             │
                             ▼
┌───────────────────────────────────────────────────────────────┐
│  Ship · PR comment (replace prior) · ✅/❌ · artifacts · cache│
└───────────────────────────────────────────────────────────────┘
```

**Mermaid (full control plane + model loop)**

```mermaid
flowchart TB
  subgraph Trigger["1 · Trigger"]
    Dev["Developer"]
    Comment["@luffy review this pr"]
    Gate["Gate · pattern + association allowlist"]
  end

  subgraph ControlPlane["2 · Control plane · GitHub Actions"]
    Eyes["React 👀"]
    Sparse["Sparse PR head + Luffy agent/scripts"]
    CacheR["Restore Hermes install cache"]
  end

  subgraph Orchestrator["3 · Orchestrator · run-luffy-review.sh"]
    Preload["preload_hub_memory\nHub MEMORY.md → HERMES_HOME"]
    Assemble["assemble-context\nPR meta · diff · prompt · SOUL"]
    Hermes["Hermes Agent · hermes -z"]
    Normalize["normalize-review\ncontract · marker · size cap"]
    Distill["distill-memory\nappend structured notes"]
    Trace["save-trace\nredacted package"]
    HubPub["publish-run-to-hub\nmemory/repos/…"]
  end

  subgraph InnerLoop["4 · Agentic loop · Hermes + OpenRouter"]
    Prompt["Review prompt + workspace + memory"]
    Think["Model reasoning"]
    Tools["Optional tools · read workspace"]
    Draft["Draft Markdown review"]
    Prompt --> Think
    Think --> Tools
    Tools --> Think
    Think --> Draft
  end

  subgraph Output["5 · Ship"]
    Post["Post / replace PR comment"]
    React["React ✅ / ❌"]
    Arts["Upload trace + out artifacts"]
    CacheW["Save Hermes cache on miss"]
  end

  OR["OpenRouter · openai/gpt-5-mini"]

  Dev --> Comment --> Gate --> Eyes --> Sparse --> CacheR
  CacheR --> Preload --> Assemble --> Hermes
  Hermes --> Prompt
  Think --> OR
  OR --> Think
  Draft --> Normalize --> Distill --> Trace --> HubPub
  HubPub --> Post --> React --> Arts --> CacheW
```

Inner loop: Hermes may call tools (read workspace files) before emitting the final Markdown review. Outer loop is deterministic shell orchestration so every run leaves a redacted trace under `.luffy-out/traces/` and hub memory under `memory/repos/`.

## E2E showcase (live)

Real run on a multi-file Odoo core fix ([odoo/odoo#271153](https://github.com/odoo/odoo/issues/271153) → [Mr-Ashish/odoo#3](https://github.com/Mr-Ashish/odoo/pull/3)).

| | |
|--|--|
| **Actions run** | [30572964204](https://github.com/Mr-Ashish/odoo/actions/runs/30572964204) |
| **Verdict** | REQUEST CHANGES · **Score** 88/100 · effort 3/5 |
| **Hermes** | ~130s · model `openai/gpt-5-mini` |
| **Trace** | [`docs/showcase/e2e-odoo-pr3-xml-control-chars/`](docs/showcase/e2e-odoo-pr3-xml-control-chars/) |

Luffy preloaded hub memory, assembled sparse PR context, ran Hermes one-shot, posted a structured review (walkthrough · key findings table · security audit · code suggestion), and uploaded a redacted trace artifact.

```bash
gh run download 30572964204 -R Mr-Ashish/odoo -n luffy-trace-pr3-run30572964204
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

