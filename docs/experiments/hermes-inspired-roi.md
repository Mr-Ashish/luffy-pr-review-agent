# Hermes-inspired ROI list (living)

Ideas scanned from read-only clones:
- `/tmp/hermes-agent` (NousResearch/hermes-agent)
- `/tmp/hermes-agent-self-evolution`

Only ship what fits Luffy’s control-plane (scripts/agent/workflows/modal/ui) — do **not** fork Hermes into this repo.

| ID | Idea | Effort | Why ROI for Luffy PR ops | Status |
|----|------|--------|--------------------------|--------|
| H1 | Cap `agent.max_turns` / `--max-turns` (Hermes default 500) | S | Stops runaway tool loops burning OpenRouter under F36 wall-clock | **Shipped F41** |
| H2 | Surface agent-loop metrics (tool turns, messages) in run-bundle | S | Operators see thrash without opening agent-loop.md | **Shipped F41** (with H1) |
| H3 | Skill-file evolution (GEPA/DSPy) for review-prompt / SOUL | L | Quality over time; needs eval harness + spend | backlog |
| H4 | Context compressor / history budget for huge monorepos | M | Cuts tokens after F27 truncation | backlog |
| H5 | Session/search memory over past PR traces (FTS5 pattern) | M | Better repo memory than append-only distill | backlog |
| H6 | Hard preflight spend estimate before Hermes | S | Refuse/force cheap model when diff huge + budget tight | **Shipped F43** |
| H7 | Auto model tier by PR size (cheap first) | S | Cost without quality loss on docs/tiny PRs | **Shipped F42** |
| H8 | Subagent fan-out for multi-file PRs | L | Parallel review streams; Modal cost + complexity | backlog |
| H9 | Trajectory packaging for offline eval datasets | M | Quality regressions measurable | backlog (capture-hermes-loop partial) |
| H10 | Soft skill nudge mid-loop (“prefer fewer tools”) | M | Hermes skill nudge pattern; needs hermes hooks | backlog |

## Selection rule

Each fire: pick **one** unfinished highest-ROI **minimal** item. Prefer S over M/L. Prefer cost/trust/ops over docs.

## Last pick

**H1+H2 → F41** (2026-07-31): wire Hermes iteration budget default 40 + loop metrics in pack/UI.

**H7 → F42** (2026-07-31): auto model tier (`LUFFY_MODEL_TIER=auto`) — cheap for tiny/docs, full otherwise.

**H6 → F43** (2026-07-31): hard preflight cost estimate — force_cheap then refuse when still over budget.
