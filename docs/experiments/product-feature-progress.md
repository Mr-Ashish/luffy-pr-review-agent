# Product feature progress

**Updated:** 2026-08-01 (F61 testplan generation)  
**Loop:** 019fb948dbe8 orchestrator

## SHIPPED

| ID | Feature | Type | Notes |
|----|---------|------|-------|
| F44–F59 | Agent quality + product suite | agent_quality, product | through incremental |
| F60 | Reply on thread | product | MERGED PR #10 |
| F61 | Testplan generation | product, agent_quality | shipping — deterministic suggested test plan |

## IN_PROGRESS

| ID | Feature | Notes |
|----|---------|-------|
| — | Live milvus multi-feature e2e | corpus 3; mean ~37; re-score after F61 |

## LEFT

11. FP RESOLVE + MEMORY UPDATE  
12. SELF-LEARN + FEDERATED MEMORY  
13. Deeper lens packs Go/C++/milvus  
14. Agent tools from research  
15. Hermes best practices as Luffy-native  

## Counts

- **features_built_count:** 18 (F44–F61)
- **types_built:** agent_quality, product
- **left_count:** 5
- **progress_pct:** ~90%
- **eta:** 2–3 fires
- **active_worktrees:** f61-testplan (this fire)
- **federated_memory_note:** local milvus compounds; hub deferred
- **agent_design_note:** F61 pure code I/O + heuristics; prompt judgment only
- **meta_loop_note:** corpus≥3 → product F61 from D3 gap
- **milvus_corpus:** 3

## Status line

`features_built_count=18 types_built=agent_quality,product left_count=5 progress_pct=90 eta=2-3fires active_worktrees=1 federated_memory_note=local_x3 milvus_corpus=3`
