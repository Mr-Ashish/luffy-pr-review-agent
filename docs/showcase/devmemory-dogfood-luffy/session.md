# Session

- **session_id:** `dogfood-luffy-session`
- **source:** `file`
- **project:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **timestamp:** ``

## Transcript / notes

# Dogfood session — Luffy F41 Hermes max_turns (2026-07-31)

## Product change
Shipped F41: Hermes agent iteration budget for Luffy PR reviews.

Problem: Hermes defaults to 500 tool-calling turns. A thrashing agentic review can burn OpenRouter spend even under the F36 wall-clock timeout (1500s).

Solution:
- scripts/max_turns.py resolve/detect (default 40; 0/off disables)
- agent/config.yaml agent.max_turns: 40
- run-hermes-review.sh passes --max-turns, rewrites HERMES_HOME config, writes hermes-max-turns.env, detects "Iteration budget exhausted"
- pack-run-for-ui.py emits signals.max_turns_hit + loop metrics (tool_call_turns, message_count, step_count, max_turns)
- Run Console Overview Ops signals + Agent loop panel; Loop tab measures
- Workflow vars.LUFFY_MAX_TURNS, Modal LUFFY_MAX_TURNS default 40, install pack includes max_turns.py

Hermes inspiration: agent.max_turns / --max-turns / HERMES_MAX_ITERATIONS from NousResearch/hermes-agent conversation loop.

Complements F36 (time kill) and F29 (soft $ after finish).

## Verify
- pytest 204 passed
- bash -n run-hermes-review.sh
- ui/review-console npm run pack-fixture && npm run build green
- SHA 50c4712 pushed to origin/main

## Knowledge to extract
- Default max_turns product SoT is 40 in max_turns.py + agent/config.yaml
- Detection patterns: Iteration budget exhausted, max_iterations_reached, Reached maximum iterations
- run-bundle.loop is the structured surface for operators
- Living list: docs/experiments/hermes-inspired-roi.md

