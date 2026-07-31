```json
{
  "summary": "Session shipped F49/H15 soft re-prompt: when the first `hermes -z` pass ends with tool_turns=0 on a multi-file code PR, the orchestrator re-prompts once with a tool-nudge suffix before the F45 fail-closed gate. Durable new knowledge is the escalation rationale (F45 alone cannot recover a zero-tool review), the intentional cost trade-off, the env kill switch, and the new console chip pair.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Design decisions",
      "content": "- **F49/H15 soft re-prompt** sits *between* detection and enforcement: on a multi-file code PR whose first `hermes -z` pass reports `tool_turns=0`, the orchestrator re-prompts Hermes once with a tool-nudge prompt suffix and only then applies the F45 fail-closed gate. Rationale from dogfooding: the F45 honesty gate alone can flag a zero-tool review but cannot recover a D1-grade one — recovery requires a second *agentic* pass, not a stricter verdict.\n- Escalation ladder is explicit and ordered: F45 (detect + fail closed) → F49/H15 (soft re-prompt once) → H18 (hard tool nudge, only if F49 runs still land on `tool_turns=0`). Do not skip straight to a hard nudge while F49 is still recovering runs.\n- The re-prompt is a single attempt guarded by env `LUFFY_TOOL_TURNS_REPROMPT` (default **on**), with the decision and the rewritten prompt split into two CLI verbs on `tool_turns_gate.py` (`reprompt-decide` / `reprompt-write`) so the decision is testable without spending a second Hermes pass.\n- Attempt 1 is preserved rather than overwritten: `review-*.attempt1.raw.md`, `agent-loop-attempt1/`, and `tool-turns-reprompt.env` are emitted so a run bundle shows both passes and why the second happened."
    ,
      "evidence": [
        "when first hermes -z has tool_turns=0 on multi-file code PR, soft re-prompt once with tool-nudge suffix before F45 fail-closed",
        "F45 honesty gate alone does not recover D1; recovery needs a second agentic pass.",
        "If F49 still yields tool_turns=0, next is H18 hard tool nudge.",
        "Env: LUFFY_TOOL_TURNS_REPROMPT (default on)"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- When F49 fires it **doubles cheap-path Hermes spend** for that PR (two full review passes). This is an accepted trade-off, not a bug — but it means cost-per-review dashboards will show bimodal spend on multi-file code PRs, and disabling the recovery is a knob (`LUFFY_TOOL_TURNS_REPROMPT=0`) rather than a code change.\n- Zero-tool reviews were observed *after* F47/F48 landed (odoo e2e corpus #2 and #4 both had mini `tool_turns=0`), so prompt/scoping fixes upstream of the loop do not by themselves make the agent use tools — treat `tool_turns=0` as a recurring residual condition to gate on, not a solved one."
    ,
      "evidence": [
        "Soft re-prompt doubles cheap-path spend when it fires — intentional.",
        "Evidence prior: odoo e2e #2 and #4 both mini tool_turns=0 after F47/F48"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": "ui",
      "action": "merge",
      "section": "Design decisions",
      "content": "- **F49 adds a chip pair** to the pack signals, not a single flag: `tool-reprompt` (a soft re-prompt was attempted) and `tool-reprompt-ok` (the second pass actually produced tool turns). Both are filled from `tool-turns-reprompt.env`, so the console can distinguish \"we retried\" from \"the retry worked\" without opening the raw logs — a run showing `tool-reprompt` without `tool-reprompt-ok` is the H18 escalation signal."
    ,
      "evidence": [
        "Pack chips: tool-reprompt / tool-reprompt-ok",
        "Artifacts: tool-turns-reprompt.env"
      ],
      "confidence": "medium"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Debugging",
      "content": "- Regression surface for the re-prompt path is two suites plus a shell syntax check: `pytest tests/test_tool_turns_gate.py tests/test_pack_run_for_ui.py` (36 passed at F49) and `bash -n scripts/run-hermes-review.sh`. Run both after any change to the gate verbs or the pack signal shape — the gate tests cover `reprompt-decide`/`reprompt-write`, the pack tests cover the chip plumbing."
    ,
      "evidence": [
        "pytest test_tool_turns_gate + test_pack_run_for_ui: 36 passed",
        "bash -n run-hermes-review.sh ok"
      ],
      "confidence": "high"
    }
  ]
}
```
