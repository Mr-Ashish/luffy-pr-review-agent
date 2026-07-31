```json
{
  "summary": "The F51 session's durable content is mostly already merged into agent/DEV.md and USAGE.md by the prior devmemory run; two bullets were dropped in that merge and remain unrecorded: the three-surface sync contract for tool-depth wording, and the shallow-read evidence that 0→1 tool recovery is not real inspection.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": "agent",
      "action": "merge",
      "section": "Design decisions",
      "content": "- **F51/H26 tool depth** is not a new gate — it is prompt wording that must stay in sync across three surfaces: `build_reprompt_suffix` (the F49 soft re-prompt suffix), the **Workspace** section of `agent/review-prompt.md`, and the **Scope** section of `agent/SOUL.md`. Editing only one leaves a re-prompted attempt with depth guidance the first attempt never saw (or vice versa), so treat the three as a single contract.\n- It shifts the objective from *whether* the reviewer used tools (F45/F49) to *how deeply* it looked, which is why it ships as prompt text plus an assertion in the existing tool-turns suite rather than a new post-review gate script.",
      "evidence": [
        "Fix: build_reprompt_suffix + review-prompt Workspace + SOUL Scope require diff hunks / rg + line-range on changed symbols; forbid head-only large-file reads",
        "F51: tool-depth nudge after F49 soft re-prompt (H26)"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": "agent",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- A non-zero `tool_turns` after the F49 re-prompt is not evidence of real inspection: on odoo eval PR #6 the recovered attempt went 0→**1** tool call and spent it on `head -80` of a large `misc.py`, never reaching the changed `street_split` code around **L1925** — score 34/50 with depth dimension **D8=2**. When judging a re-prompted run, check *which lines* were read, not the `tool-turns-*` counters.",
      "evidence": [
        "Evidence: odoo eval #6 F49 recovered 0→1 tools but only `head -80` on large misc.py; never read street_split ~L1925; score 34/50 D8=2"
      ],
      "confidence": "high"
    }
  ]
}
```
