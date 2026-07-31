# Session

- **session_id:** `dogfood-luffy-session`
- **source:** `file`
- **project:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **timestamp:** ``

## Transcript / notes

# Dogfood session — F49 soft re-prompt (H15)

## What shipped
- F49/H15: when first hermes -z has tool_turns=0 on multi-file code PR, soft re-prompt once with tool-nudge suffix before F45 fail-closed.
- CLI: tool_turns_gate.py reprompt-decide / reprompt-write
- Env: LUFFY_TOOL_TURNS_REPROMPT (default on)
- Artifacts: tool-turns-reprompt.env, review-*.attempt1.raw.md, agent-loop-attempt1/
- Pack chips: tool-reprompt / tool-reprompt-ok
- Evidence prior: odoo e2e #2 and #4 both mini tool_turns=0 after F47/F48

## Lessons
- F45 honesty gate alone does not recover D1; recovery needs a second agentic pass.
- Soft re-prompt doubles cheap-path spend when it fires — intentional.
- If F49 still yields tool_turns=0, next is H18 hard tool nudge.

## Verify
- pytest test_tool_turns_gate + test_pack_run_for_ui: 36 passed
- bash -n run-hermes-review.sh ok
- Pushed main e153394

