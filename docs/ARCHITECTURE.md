# Luffy architecture

## One sentence

Luffy is a gated GitHub Actions control plane that assembles a bounded PR context, runs Hermes Agent + OpenRouter with a growing `MEMORY.md`, validates Markdown against a fixed contract, and always publishes the result as a PR comment.

## Flow

```text
@luffy review this pr
    → gate + concurrency
    → dual checkout (luffy/ + workspace/)
    → restore HERMES_HOME memory
    → assemble-context → hermes -z → normalize → PR comment
    → distill MEMORY.md → cache + artifacts
```

## Stages

| Stage | Script | Responsibility |
|-------|--------|----------------|
| Assemble | `scripts/assemble-context.sh` | `gh pr` meta + diff + prompt (no LLM) |
| Review | `scripts/run-hermes-review.sh` | Hermes one-shot on `WORKSPACE_ROOT` |
| Normalize | `scripts/normalize-review.py` | Contract, fences, size, HTML marker, secret redact |
| Cost UX | `scripts/usage-summary.py` | Append cost/tokens footer + job-summary from `hermes-usage.json` (F21) |
| Verdict signal | `scripts/parse-verdict.py` + `report-verdict.sh` | Map verdict → reaction + commit status `luffy/review` + job summary (F22) |
| Distill | `scripts/distill-memory.sh` | Append structured memory block |
| Post | `scripts/post-review-comment.sh` | Delete prior `<!-- luffy-review pr=N` comments, then `gh pr comment` |
| Orchestrate | `scripts/run-luffy-review.sh` | Compose stages + timings |
| Trace | `scripts/save-trace.sh` | Redacted per-run package → Actions artifact |
| Hub publish | `scripts/publish-run-to-hub.sh` | `repository_dispatch` → hub |
| Hub ingest | `scripts/hub-ingest-run.py` | Commit `memory/repos/{slug}/…` on hub |

## Dual workspace

| Path | Contents |
|------|----------|
| `luffy/` | Agent SOUL, prompts, scripts (from default branch) |
| `workspace/` | PR head only (code under review) |
| `.luffy-hermes-home/` | Hermes config + growing memory (cached) |

## Memory layers

1. **L0** — single-run Hermes home  
2. **L1** — Actions cache of `.luffy-hermes-home`  
3. **L2** — workflow artifacts (debug + memory snapshots)  
4. **Distill** — explicit append after each review  

## Security

- PR body/diff treated as untrusted data  
- Least-privilege token permissions  
- Secrets only via env / Hermes `.env` (mode 0600)  
- No formal GitHub “request changes” review API in v1 (comment only)  

## Packaging (F10)

| Mode | What lives on the target | Runtime source |
|------|--------------------------|----------------|
| **Caller** (`install-luffy.sh --caller`) | Thin `.github/workflows/luffy-pr-review.yml` only | Hub `agent/`+`scripts/` via `luffy-review-reusable.yml@main` |
| **Pack** (default install) | `agent/`, runtime `scripts/`, thin caller + local copy of reusable | Target default branch |

Hub implementation file: `.github/workflows/luffy-review-reusable.yml` (`on: workflow_call`, inputs `luffy_repository` + `luffy_ref`).
