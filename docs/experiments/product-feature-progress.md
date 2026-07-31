# Product feature progress

**Updated:** 2026-07-31 (F54 fix-it prompts)  
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
| F54 | Fix-it prompt per inline comment | product | this fire — `LUFFY_FIXIT_PROMPTS` |

## IN_PROGRESS

| ID | Feature | Notes |
|----|---------|-------|
| — | Feature toggle system (unified) | env toggles exist; OpenFeature-style registry still open |
| — | Review lens recipes / named packs | multi-lens base in F52; recipes backlog |
| — | Live e2e issue-ctx + fixit quality | measure Actionability/Inline after F54 merge |

## LEFT (priority product backlog)

1. FEATURE TOGGLE SYSTEM (unified registry)
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

- **features_built_count:** 11 (F44–F54, skipping F47 numbering gap if any)
- **types_built:** agent_quality, product (actionability, multi-lens, issue-ctx, fixit)
- **left_count:** 13 (items 1,3–15 above; item 2 done)
- **progress_pct:** ~46% of 15-item product backlog (7 product-ish of 15 if counting F52–F54 + partials ≈ 46)
- **eta:** 6–10 more productive fires for top-5 remaining (toggles, recipes, filler, mermaid, incremental)
- **active_worktrees:** f54-fixit-prompts
- **federated_memory_note:** not started this fire; `.luffy` local + hub publish paths exist from prior work; FP outcomes / shared learning still gated

## Status line

`features_built_count=11 types_built=agent_quality,product left_count=13 progress_pct=46 eta=6-10fires active_worktrees=1 federated_memory_note=deferred`
