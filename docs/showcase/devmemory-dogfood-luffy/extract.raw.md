```json
{
  "summary": "The session is mostly benchmark bookkeeping (per-PR scores, run ids, cost) which is ephemeral, but it does confirm one durable empirical pattern: on live odoo PR reviews the first Hermes attempt lands with zero tool turns, and the F49 soft reprompt reliably recovers a real agentic loop so the F45 fail-closed gate ends up skipped.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": "agent",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- Zero tool turns on attempt 1 is the norm, not an anomaly, on live upstream-port PRs: repeated e2e runs (odoo#2, #4, #5) all recorded `tool_turns=0` before the F49 soft reprompt, which then recovered a real agentic loop (0→23, 0→9, 0→8). Treat a `tool_turns=0` first attempt as expected and check whether `LUFFY_TOOL_TURNS_REPROMPT=1` was set before suspecting a prompt/toolset regression.\n- Because the reprompt succeeds, the F45 tool-turns gate reports *skipped* rather than pass/fail on these runs — a skipped F45 plus `soul_blocked=0` is the healthy signature, so do not read \"gate skipped\" as \"gate not wired up\".",
      "evidence": [
        "tool_turns recovered 0→8 via LUFFY_TOOL_TURNS_REPROMPT=1; F45 gate skipped; soul_blocked=0",
        "docs(e2e): H19 F49 re-score odoo#4 — tools 0→9, 31→38/50",
        "docs: F49 live #2 e2e — tool_turns 0→23, score 36/50"
      ],
      "confidence": "medium"
    }
  ]
}
```
