<p align="center">
  <img src="assets/luffy-artifact-orbital-core.png" alt="Luffy" width="360" />
</p>

<h1 align="center">Luffy</h1>

<p align="center"><strong>Comment-triggered PR review agent</strong></p>

<p align="center">Hermes Agent + OpenRouter + repo-local <code>.luffy/</code> memory + redacted run traces.</p>

[![PR Review](https://img.shields.io/static/v1?label=PR+Review&message=comment+%C2%B7+Actions&color=2ea44f&style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/Mr-Ashish/luffy-pr-review-agent/actions/workflows/luffy-pr-review.yml)
[![Memory](https://img.shields.io/static/v1?label=memory&message=.luffy+%28local+default%29&color=C41E3A&style=for-the-badge&logo=github&logoColor=white)](docs/ARCHITECTURE.md)
![trigger](https://img.shields.io/static/v1?label=trigger&message=%40luffy+review+this+pr&color=FF6B2C&style=for-the-badge&logo=github&logoColor=white)
![model](https://img.shields.io/static/v1?label=model&message=anthropic%2Fclaude-opus-5&color=0B0F19&style=for-the-badge)
![provider](https://img.shields.io/static/v1?label=provider&message=OpenRouter&color=C41E3A&style=for-the-badge)
[![Last commit](https://img.shields.io/static/v1?label=branch&message=main&color=0B0F19&style=for-the-badge&logo=git&logoColor=white)](https://github.com/Mr-Ashish/luffy-pr-review-agent/commits/main)
![License](https://img.shields.io/static/v1?label=license&message=MIT&color=FFD166&style=for-the-badge&logo=open-source-initiative&logoColor=FFD166&labelColor=0B0F19)

## Why it exists

Most AI PR bots are stateless chat on a diff. Luffy is a review control plane: explicit trigger, bounded context (sparse checkout + capped diff), Hermes via OpenRouter, **durable memory in the target repo under `.luffy/`** (hub is optional), and redacted fat traces as Actions artifacts for audit.

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
    LocalMem[".luffy/ MEMORY + slim runs"]
  end

  subgraph LLM["Inference"]
    Hermes["Hermes Agent"]
    OR["OpenRouter"]
  end

  subgraph OptionalHub["Hub optional"]
    HubMem["memory/repos/…"]
  end

  Dev --> Comment --> PR --> GHA
  GHA --> Scripts
  Scripts --> Hermes --> OR
  Scripts --> LocalMem
  Scripts -.->|opt-in| HubMem
  Scripts --> PR
```

Install Luffy on each **target** repo. **Default memory is repo-local** (`.luffy/` on the target default branch). Central hub ingest is **opt-in** (`LUFFY_MEMORY_MODE=hub|both` or `LUFFY_HUB_PUBLISH=1`).

## E2E flow

```mermaid
sequenceDiagram
  autonumber
  actor Dev as Developer
  participant PR as Target PR
  participant GHA as GitHub Actions
  participant Local as Target .luffy/
  participant Hermes as Hermes Agent
  participant OR as OpenRouter

  Dev->>PR: @luffy review this pr
  PR->>GHA: issue_comment
  GHA->>Local: preload MEMORY.md default branch
  Local-->>GHA: prior notes or seed
  GHA->>GHA: assemble prompt + diff
  GHA->>Hermes: hermes -z
  Hermes->>OR: completions
  OR-->>Hermes: review markdown
  Hermes-->>GHA: final text
  GHA->>PR: review comment + signals
  GHA->>Local: publish slim memory pack
  Note over GHA: fat traces → Actions artifacts only
```

**Pipeline stages**

```mermaid
flowchart LR
  A[preload_memory] --> B[assemble]
  B --> C[hermes -z]
  C --> D[normalize]
  D --> E[distill]
  E --> F[save_trace]
  F --> G[publish_local]
  G --> H[publish_hub opt-in]
  H --> I[PR comment + artifacts]
```

## Agentic loop (example)

End-to-end control plane for one review: comment trigger → Actions gate → orchestrator stages → Hermes multi-turn agentic loop (tools + OpenRouter · Claude Opus 5) → normalize → memory + full step trace → PR comment. Live package: docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/.

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
│   1 preload_memory     ──► .luffy/MEMORY.md → HERMES_HOME     │
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
│   5 distill-memory     ──► append notes (job-local)       │   │
│   6 save-trace         ──► fat artifact (not git)         │   │
│   7 publish-run-local  ──► target .luffy/ slim pack       │   │
│   8 publish-run-to-hub ──► opt-in hub memory/repos/…      │   │
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
    Preload["preload_memory\n.target .luffy/ first"]
    Assemble["assemble-context\nPR meta · diff · prompt · SOUL"]
    Hermes["Hermes Agent · hermes -z"]
    Normalize["normalize-review\ncontract · marker · size cap"]
    Distill["distill-memory\nappend structured notes"]
    Trace["save-trace\nfat artifact"]
    LocalPub["publish-run-local\n.luffy/ slim pack"]
    HubPub["publish-run-to-hub\nopt-in only"]
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

  OR["OpenRouter · anthropic/claude-opus-5"]

  Dev --> Comment --> Gate --> Eyes --> Sparse --> CacheR
  CacheR --> Preload --> Assemble --> Hermes
  Hermes --> Prompt
  Think --> OR
  OR --> Think
  Draft --> Normalize --> Distill --> Trace --> LocalPub --> HubPub
  HubPub --> Post --> React --> Arts --> CacheW
```

Inner loop: Hermes may call tools (read workspace files) before emitting the final Markdown review. Outer loop is deterministic shell orchestration so every run leaves a redacted fat trace under `.luffy-out/traces/` (artifact) and a **slim** durable pack under the target’s **`.luffy/`** (git). Hub `memory/repos/…` is opt-in.

## E2E showcase (live · Opus 5 agentic loop)

Full captured run on [odoo/odoo#271153](https://github.com/odoo/odoo/issues/271153) → [Mr-Ashish/odoo#3](https://github.com/Mr-Ashish/odoo/pull/3).

| | |
|--|--|
| **Actions** | [30574256524](https://github.com/Mr-Ashish/odoo/actions/runs/30574256524) |
| **Session** | `20260730_191954_63f003` |
| **Model** | `anthropic/claude-opus-5` via OpenRouter |
| **Loop** | **10 API calls** · **9 tool-call turns** · **26 messages** · ~251s Hermes |
| **Tokens** | ~195k total (cache-heavy) · est. **$0.59** |
| **Verdict** | REQUEST CHANGES · **Score** 42/100 · effort 4/5 |
| **Package** | [`docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/`](docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/) |

### High-level e2e agentic loop (this trace)

Mermaid below is **not a sketch** — nodes match the live session: outer Actions control plane, then Hermes multi-turn tool loop (read diff → codec repros → call-site grep → surrogatepass vs surrogateescape → final review).

```mermaid
%% Live e2e · Mr-Ashish/odoo#3 · run 30574256524 · anthropic/claude-opus-5
%% Session 20260730_191954_63f003 · 10 API calls · 9 tool-call turns · 26 messages
flowchart TB
  subgraph Outer["Outer control plane · GitHub Actions"]
    T["@luffy review this pr"]
    Gate["Gate · association"]
    Sparse["Sparse checkout · PR head"]
    Pre["preload hub MEMORY"]
    Asm["assemble prompt + diff"]
    Post["PR comment · artifacts · hub memory"]
  end

  subgraph Loop["Hermes agentic loop · real trace"]
    direction TB
    U0["① USER prompt<br/>SOUL + contract + PR #3 meta"]
    A1["② ASSISTANT + tools<br/>cat pr.diff · cat context.md"]
    A2["③ tools · repro<br/>latin-1 café + read xml_utils.py"]
    A3["④ tools · call sites<br/>grep remove_control_characters"]
    A4["⑤ tools · cleanup_xml_node<br/>+ more codec experiments"]
    A5["⑥–⑨ tools · surrogatepass vs<br/>surrogateescape · EDI payload"]
    A6["⑩ tools · callers of cleanup_xml_node<br/>+ final local repro"]
    Out["⑪ FINAL review Markdown<br/>Verdict REQUEST CHANGES · Score 42/100"]
    OR["OpenRouter · anthropic/claude-opus-5"]

    U0 --> A1 --> A2 --> A3 --> A4 --> A5 --> A6 --> Out
    A1 & A2 & A3 & A4 & A5 & A6 <--> OR
  end

  T --> Gate --> Sparse --> Pre --> Asm --> U0
  Out --> Post

  classDef tool fill:#1f2937,stroke:#FF6B2C,color:#fff
  classDef model fill:#0B0F19,stroke:#FFD166,color:#FFD166
  classDef ship fill:#14532d,stroke:#22c55e,color:#fff
  class A1,A2,A3,A4,A5,A6 tool
  class OR,Out model
  class Post ship
```

**What the agent actually did (condensed from the trace)**

| Turn | Kind | What happened |
|------|------|----------------|
| 1 | user | Full Luffy review prompt + PR #3 meta |
| 2 | tools | `cat pr.diff`, `cat context.md` |
| 3 | tools | Latin-1 `café` repro + read `xml_utils.py` |
| 4 | tools | `grep remove_control_characters` call sites |
| 5–8 | tools | More codec / `cleanup_xml_node` experiments |
| 9 | tools | Callers of `cleanup_xml_node` + final repro |
| 10 | assistant | Structured review → REQUEST CHANGES (surrogatepass bug) |

Full step dump (every tool arg + message): [`agent-loop/agent-loop.md`](docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/agent-loop/agent-loop.md) · JSON: [`agent-loop/agent-loop.json`](docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/agent-loop/agent-loop.json)

```bash
gh run download 30574256524 -R Mr-Ashish/odoo -n luffy-trace-pr3-run30574256524
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

## Memory (F28 default = repo-local)

Each target owns durable review memory under **`.luffy/`** on its default branch:

```text
.luffy/
  MEMORY.md
  runs/{trace_id}/meta.json|review.md|summary.md
```

- Preload reads default-branch `.luffy/MEMORY.md` via API (not sparse PR workspace).
- Fat debug packs stay **Actions artifacts** only.
- **Hub** (`memory/repos/{owner}--{repo}/`) is optional: `LUFFY_MEMORY_MODE=hub|both` or `LUFFY_HUB_PUBLISH=1`.
- Job summary **Memory health (F30)** shows preload source + local/hub publish status (warnings if local push fails, e.g. branch protection).

## Layout

```text
agent/          SOUL, prompts, Hermes config
scripts/        assemble → hermes → normalize → local memory → hub opt-in
.luffy/         repo-local MEMORY (target SoT)
memory/         optional hub layout (this product repo)
readme-kit/     compile README from theme + pack + config
assets/         brand mark + favicon
.github/workflows/
```

## OpenUI review console (optional)

Interactive OpenUI rendering of Luffy reviews (not GitHub-native — hosted viewer).

```bash
# Convert a review.md → OpenUI Lang (no LLM)
python3 scripts/review-to-openui.py \
  --review docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/review.md \
  --usage docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/hermes-usage.json \
  --timings docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/timings.json \
  -o docs/showcase/openui-luffy/review.openui

# View in console
cd ui/review-console && npm install && npm run copy-fixture && npm run dev
# http://localhost:5177
```

Plan: [docs/OPENUI-INTEGRATION.md](docs/OPENUI-INTEGRATION.md). OpenUI clone reference: `/tmp/openui`.

## Docs

- [Blog: Building Luffy (agentic PR review)](docs/blog/building-luffy-agentic-pr-review.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Operations](docs/OPERATIONS.md)
- [ROI fixes](docs/ROI-FIXES.md)
- [README branding ecosystem](docs/README-BRANDING-ECOSYSTEM.md)
- [readme-kit MVP](docs/README-KIT-MVP.md)
- [Brand banner options (pick one)](assets/brand-options/README.md)

## Limits (v1)

- PR comment reviews only (not inline threads yet)
- Diffs truncated at MAX_DIFF_BYTES
- Default OpenRouter model is paid (anthropic/claude-opus-5; override with LUFFY_MODEL)
- Install on each target repo — not a global bot for arbitrary public repos
- Hermes tool-loop traces not fully exported yet (final review + outer pipeline are)

---

*Luffy · Hermes Agent · OpenRouter · memory-backed review · generated by readme-kit*

