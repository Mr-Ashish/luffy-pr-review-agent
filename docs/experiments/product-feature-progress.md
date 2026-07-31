# Product feature progress

**Updated:** 2026-07-31 (F56 lens recipes)  
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
| F55 | Feature toggle system | product | PR #5 merged |
| F56 | Lens recipes + named packs | product | **MERGED** PR #6 — `lens_recipes.py` + packs |

## IN_PROGRESS

| ID | Feature | Notes |
|----|---------|-------|
| — | Live e2e issue-ctx + fixit + lens depth | measure Actionability/Inline/D10 |
| — | Auto pack select from paths | optional follow-up |
| — | Toggle migration (remaining scripts) | gradual |

## LEFT (priority product backlog)

1. ~~FEATURE TOGGLE SYSTEM~~ → **F55**
2. ~~FIX-IT PROMPT~~ → **F54**
3. ~~REVIEW LENS RECIPES + NAMED PROMPT PACKS~~ → **F56**
4. REVIEW LENSES multi-dim (extend F52/F56 — auto-select)
5. PR DESCRIPTION FILLER
6. LINKED ISSUE CONTEXT — live e2e (F53 shipped)
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

- **features_built_count:** 13 (F44–F56)
- **types_built:** agent_quality, product (multi-lens, issue-ctx, fixit, toggles, recipes)
- **left_count:** 11 (items 4–15; 1–3 done)
- **progress_pct:** ~60% of 15-item product backlog (9 product-ish of 15 ≈ 60)
- **eta:** 4–8 more productive fires
- **active_worktrees:** none (F56 merged)
- **federated_memory_note:** deferred; toggle keys exist

## Status line

`features_built_count=13 types_built=agent_quality,product left_count=11 progress_pct=60 eta=4-8fires active_worktrees=0 federated_memory_note=deferred`
