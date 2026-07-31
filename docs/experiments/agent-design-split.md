# Agent design split — tool vs code vs prompt vs MD

**Updated:** 2026-07-31 (F59)  
**Principle:** deterministic work → scripts; judgment → lean prompts; persona/lenses → MD; config → toggles.

| Feature | Code / scripts | Prompt / intelligence | MD / agent files | Toggles / config |
|---------|----------------|----------------------|------------------|------------------|
| F9/F9b/F9c inline | `post-inline-comments.py` anchor map, suggestion blocks | severity which findings matter | SOUL path:line discipline | `inline_comments`, `inline_suggestions`, `inline_max` |
| F54 fix-it | `format_fixit_prompt` packing | — (template is code) | — | `fixit_prompts` |
| F53 issue ctx | `linked_issue_context.py` extract/fetch/pack | how issues change review judgment | review-prompt section header | `issue_context`, `issue_from_branch`, max ints |
| F52 multi-lens | `normalize-review.py` section alias | multi-lens table fill | review-prompt + SOUL checklist | (recipes backlog → packs) |
| F50 severity | `severity_calibration.py` | model-assigned severity | SOUL scale | `severity_calibration` |
| F45/F49 tool turns | gate + reprompt scripts | whether re-ask is needed | — | `tool_turns_gate`, `tool_turns_reprompt` |
| F55 toggles | **`feature_toggles.py` registry + resolve** | none | DEV.md split note | `.luffy/toggles.json` + env |
| Federated memory | publish/ingest I/O scripts | light apply of FP patterns | MEMORY.seed principles | `hub_publish`, `local_publish` |
| Mermaid / filler / incremental / reply / testplan | backlog → scripts first | judgment only where needed | thin recipes | new registry entries |

## Hermes boundary (research note)

Hermes: tools are discrete callable capabilities; workflows that parse/gate/pack
must not be re-encoded as long prompt spaghetti. Luffy mirrors this: orchestrator
shell + Python for gates; SOUL/review-prompt for persona and lens judgment only.
Never fork Hermes into Luffy — adopt patterns (toolsets, pin, memory file).
