```json
{
  "summary": "The session yields new durable knowledge from F48/H17: SOUL-block detection and agent.log capture must be scoped to the current invocation via HERMES_LOG_OFFSET (shared HERMES_HOME log history caused a false soul_blocked=1), plus the H16 re-score finding that after F47 the `hermes -z` CLI path is healthy while tool_turns=0 persists as a model-behaviour gap that keeps the F45 gate load-bearing.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Design decisions",
      "content": "- **F48 (H17) log scoping:** `HERMES_LOG_OFFSET` is passed into `scripts/capture-hermes-loop.py` so the packaged `agent.log` is only the byte slice produced by *this* invocation. Capture must honour the offset when set — the run bundle should never carry another run's loop/SOUL evidence.\n- SOUL-block detection is therefore an invocation-scoped signal, not a property of `HERMES_HOME`: never treat the full shared `HERMES_HOME/logs/agent.log` as evidence for the current run.",
      "evidence": [
        "pass HERMES_LOG_OFFSET into capture-hermes-loop; package only this-invocation agent.log slice",
        "Capture must honor HERMES_LOG_OFFSET when set."
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- `HERMES_HOME` is shared across runs, so scanning the whole `agent.log` yields **false `soul_blocked=1`** from stale history — this was observed on a live H16 run whose SOUL preflight was actually clean, and is what F48 fixes. If `soul_blocked` fires, first confirm the evidence came from the current invocation's log slice before treating it as a real SOUL/threat-scanner block.",
      "evidence": [
        "False soul_blocked=1 from stale agent.log → fixed F48.",
        "avoid false soul_blocked from shared HERMES_HOME log history"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": "agent",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- Cheap-model reviews can end with `tool_turns=0`: the model answers single-shot text and stops without ever using the toolset, even when the CLI path is healthy (post-F47 `hermes -z` ran with no invalid-choice error and no chat fallback). SOUL/prompt preflight being clean does **not** imply the agentic loop ran.\n- Consequence: the **F45 tool-turns gate stays required** on multi-file code PRs whenever `tool_turns=0` (gate → `COMMENT` / confidence 55). Live re-score on `Mr-Ashish/odoo#2` with `openai/gpt-4.1-mini` held at 30/50 — the residual gap is tool use, not the CLI invocation.\n- Open follow-ups for the cheap multi-file path: a soft re-prompt (H15) or a hard tool nudge (H18); do not remove the F45 gate before one of those lands.",
      "evidence": [
        "tool_turns=0 still (model single-shot text stop) → F45 gate COMMENT/55",
        "Score 30/50 same as F45; D8a improved slightly (SOUL preflight clean); residual gap is tool use not CLI.",
        "F45 remains required when tool_turns=0 on multi-file code PRs."
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Debugging",
      "content": "- When triaging a `soul_blocked` signal, export `HERMES_LOG_OFFSET` (byte offset of `HERMES_HOME/logs/agent.log` taken *before* launching Hermes) so `scripts/capture-hermes-loop.py` packages only this run's slice; a block reported without an offset is likely stale history.\n- To separate CLI failures from model behaviour on a cheap-model run, read the captured loop metrics: `hermes -z` health shows up as absence of invalid-choice/chat-fallback in the log slice, while `tool_turns=0` in the bundle's `loop` section means the model never entered the agentic loop and the F45 `tool-turns-gate.env` verdict downgrade is expected rather than a bug.",
      "evidence": [
        "hermes -z worked (no invalid choice, no chat fallback).",
        "Never scan full shared HERMES_HOME/logs/agent.log as this-run SOUL evidence."
      ],
      "confidence": "medium"
    }
  ]
}
```
