# Session

- **session_id:** `dogfood-luffy-session`
- **source:** `file`
- **project:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **timestamp:** ``

## Transcript / notes

# Dogfood session — F48 SOUL detect scope (H17) + H16 re-score

## What shipped
- F48/H17: pass HERMES_LOG_OFFSET into capture-hermes-loop; package only this-invocation agent.log slice; avoid false soul_blocked from shared HERMES_HOME log history.
- H16 live mini re-run on Mr-Ashish/odoo#2 with openai/gpt-4.1-mini after F47.

## H16 results
- hermes -z worked (no invalid choice, no chat fallback).
- tool_turns=0 still (model single-shot text stop) → F45 gate COMMENT/55.
- Score 30/50 same as F45; D8a improved slightly (SOUL preflight clean); residual gap is tool use not CLI.
- False soul_blocked=1 from stale agent.log → fixed F48.

## Guardrails
- Never scan full shared HERMES_HOME/logs/agent.log as this-run SOUL evidence.
- Capture must honor HERMES_LOG_OFFSET when set.
- F45 remains required when tool_turns=0 on multi-file code PRs.
- Next: H15 soft re-prompt or H18 hard tool nudge for cheap multi-file path.

