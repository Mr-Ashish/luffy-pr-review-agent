# Session

- **session_id:** `dogfood-luffy-session`
- **source:** `file`
- **project:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **timestamp:** ``

## Transcript / notes

# Luffy dogfood session (F43)

## Latest feature F43
Hard preflight spend estimate before Hermes (H6).
scripts/preflight_cost.py estimate/decide; shares LUFFY_MAX_COST_USD with F29.
Default action force_cheap; refuse writes COMMENT stub and skips Hermes.
Evidence: preflight-cost.env, pack chips preflight-cheap / preflight-refuse.

## Architecture
# Luffy architecture

## One sentence

Luffy is a gated GitHub Actions control plane that assembles a bounded PR context, runs Hermes Agent + OpenRouter with a growing `MEMORY.md`, validates Markdown against a fixed contract, and always publishes the result as a PR comment.

## Flow

```text
@luffy review this pr
    → gate + concurrency + cooldown (F19)
    → sparse path list → path-glob free skip (F38, opt-in)
    → dual checkout (luffy/ + workspace/)
    → preload MEMORY (.luffy/ first, hub opt-in)
    → assemble-context → hermes -z (F36 timeout) → normalize → PR comment
    → verdict signals (F22/F23/F9/F37) → distill MEMORY.md → save-trace
    → publish slim pack → target .luffy/ (default)
    → hub memory only if LUFFY_MEMORY_MODE=hub|both or LUFFY_HUB_PUBLISH=1
```

## Stages

| Stage | Script | Responsibility |
|-------|--------|----------------|
| Assemble | `scripts/assemble-context.sh` | `gh pr` meta + diff + prompt (no LLM) |
| Review | `scripts/run-hermes-review.sh` + `run-with-timeout.py` | Hermes one-shot on `WORKSPACE_ROOT`; F36 wall-clock kill (default 1500s) |
| Normalize | `scripts/normalize-review.py` | Contract, fences, size, HTML marker, secret redact |
| Cost UX | `scripts/usage-summary.py` | Append cost/tokens footer + job-summary from `hermes-usage.json` (F21) |
| Verdict signal | `scripts/parse-verdict.py` + `report-verdict.sh` | Map verdict → reaction + commit status `luffy/review` + job summary (F22) + F23 PR review + F9 inline + F37 PR labels |
| Inline notes | `scripts/post-inline-comments.py` | Path-anchored findings (F9/F9b) + Code suggestions → ```suggestion``` apply blocks (F9c) |
| Distill | `scripts/distill-memory.sh` | Append structured memory block |
| Post | `scripts/post-review-comment.sh` | Delete prior `<!-- luffy-review pr=N` comments, then `gh pr comment` |
| Orchestrate | `scripts/run-luffy-review.sh` | Compose stages + timings |
| Trace | `scripts/save-trace.sh` | Redacted per-run package → Actions artifact (fat; not committed) |
| Local memory | `scripts/publish-run-local.sh` + `hub-ingest-run.py` layout=local | Commit target `.luffy/` slim pack (F28 default) |
| Hub publish | `scripts/publish-run-to-hub.sh` | Opt-in hub clone/ingest or `repository_dispatch` |
| Hub ingest | `scripts/hub-ingest-run.py` | Hub: `memory/repos/{slug}/…`; local: `.luffy/` |

## Dual workspace

| Path | Contents |
|------|----------|
| `luffy/` | Agent SOUL, prompts, scripts (from default branch) |
| `workspace/` | PR head only (code under review) |
| `.luffy-hermes-home/` | Hermes config + growing memory (cached) |
| target `.luffy/` | **Repo-local** MEMORY + slim run history (committed; F28 SoT) |

## Memory layers (F28)

1. **L0** — single-run Hermes home  
2. **L1** — preload from target **`.luffy/MEMORY.md`** (default branch via API; sparse PR workspace is not enough)  
3. **L2** — Actions artifacts (fat traces + debug; 14–90 day expiry OK)  
4. **L3** — opt-in hub `memory/repos/{slug}/` when `LUFFY_MEMORY_MODE=hub|both` or `LUFFY_HUB_PUBLISH=1`  
5. **Distill** — explicit append after each review (then local publish)  

Layout under the target repo:

```text
.luffy/
  MEMORY.md

## Operations F43
## Preflight cost (F43)

Hard OpenRouter spend estimate **before** Hermes. Uses the same `LUFFY_MAX_COST_USD`
as F29, but gates *start* of the agent loop (F29 only annotates after).

| Var | Default | Meaning |
|-----|---------|---------|
| `LUFFY_MAX_COST_USD` | unset | Enables hard preflight when set |
| `LUFFY_PREFLIGHT_COST` | `auto` | `hard` when budget set; `off` / `estimate` |
| `LUFFY_PREFLIGHT_ACTION` | `force_cheap` | or `refuse` / `warn` |

```bash
python3 scripts/preflight_cost.py decide --model anthropic/claude-opus-5 --diff-bytes 200000
```

Evidence: `preflight-cost.env`, job-summary, Run Console chips.

## Modal host parity (F39)

## Scripts inventory
apply-verdict-labels.py
build-hub-payload.py
capture-hermes-loop.py
hub-ingest-run.py
max_turns.py
modal_parity.py
model_tier.py
normalize-review.py
ops_footer.py
pack-run-for-ui.py
parse-verdict.py
path-skip-check.py
post-inline-comments.py
preflight_cost.py
review-to-openui.py
run-with-timeout.py
usage-summary.py
webhook_auth.py

## ROI next
| H3 | Skill-file evolution (GEPA/DSPy) for review-prompt / SOUL | L | Quality over time; needs eval harness + spend | backlog |
| H4 | Context compressor / history budget for huge monorepos | M | Cuts tokens after F27 truncation | backlog |
| H5 | Session/search memory over past PR traces (FTS5 pattern) | M | Better repo memory than append-only distill | backlog |
| H8 | Subagent fan-out for multi-file PRs | L | Parallel review streams; Modal cost + complexity | backlog |
| H9 | Trajectory packaging for offline eval datasets | M | Quality regressions measurable | backlog (capture-hermes-loop partial) |
| H10 | Soft skill nudge mid-loop (“prefer fewer tools”) | M | Hermes skill nudge pattern; needs hermes hooks | backlog |

