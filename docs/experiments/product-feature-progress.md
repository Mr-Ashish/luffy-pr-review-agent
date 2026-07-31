# Product feature progress

**Updated:** 2026-07-31 (F55 feature toggles)  
**Loop:** 019fb948dbe8 orchestrator

## SHIPPED

| ID | Feature | Type | Notes |
|----|---------|------|-------|
| F44 | Normalize chat chrome | agent_quality | shipped |
| F45 | Tool-turns gate | agent_quality | shipped |
| F46 | Soul context scan | agent_quality | shipped |
| F48 | Soul detect scope | agent_quality | shipped |
| F49 | Soft reprompt | agent_quality | shipped |
| F50 | Severity calibration | agent_quality | shipped |
| F51 | Tool depth | agent_quality | shipped |
| F52 | Multi-lens | product | PR #2 merged |
| F53 | Linked issue context | product | PR #3 merged |
| F54 | Fix-it prompt per inline comment | product | PR #4 merged |
| F55 | Feature toggle system | product | **this fire** — registry + file + CLI |

## IN_PROGRESS

| ID | Feature | Notes |
|----|---------|-------|
| — | Review lens recipes / named packs | multi-lens base in F52; recipes backlog |
| — | Live e2e issue-ctx + fixit quality | measure Actionability/Inline after F54 |
| — | Toggle migration (remaining scripts) | F55 core shipped; gradual consumer adopt |

## LEFT (priority product backlog)

1. ~~FEATURE TOGGLE SYSTEM (unified registry)~~ → **F55**
2. ~~FIX-IT PROMPT PER INLINE COMMENT~~ → **F54**
3. REVIEW LENS RECIPES + NAMED PROMPT PACKS
4. REVIEW LENSES multi-dim (extend F52)
5. PR DESCRIPTION FILLER
6. LINKED ISSUE CONTEXT — extend/test live (F53 shipped)
7. MERMAID ARCHITECTURE in PR comments
8. INCREMENTAL REVIEW
9. REPLY ON THREAD
10. TESTPLAN GENERATION
11. FP RESOLVE + MEMORY UPDATE
12. SELF-LEARNING + federated memory
13. AGENT TOOLS eval under /tmp
14. HERMES best practices → Luffy product
15. Multi-PR odoo e2e + multi-dim benchmark

## Counts

- **features_built_count:** 12 (F44–F55)
- **types_built:** agent_quality, product (actionability, multi-lens, issue-ctx, fixit, toggles)
- **left_count:** 12 (items 3–15; 1–2 done)
- **progress_pct:** ~53% of 15-item product backlog (8 product-ish of 15 ≈ 53)
- **eta:** 5–9 more productive fires for top remaining (recipes, filler, mermaid, incremental, federated)
- **active_worktrees:** f55-feature-toggles
- **federated_memory_note:** still deferred; registry now has `hub_publish`/`local_publish` keys for gated compound learning

## Status line

`features_built_count=12 types_built=agent_quality,product left_count=12 progress_pct=53 eta=5-9fires active_worktrees=1 federated_memory_note=keys_registered_deferred`
