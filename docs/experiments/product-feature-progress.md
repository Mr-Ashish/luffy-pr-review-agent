# Product feature progress

**Updated:** 2026-08-01 (F62 FP resolve + memory)  
**Loop:** continuous product backlog

## SHIPPED

| ID | Feature | Type | Notes |
|----|---------|------|-------|
| F44–F59 | Agent quality + product suite | agent_quality, product | through incremental |
| F60 | Reply on thread | product | MERGED PR #10 |
| F61 | Testplan generation | product, agent_quality | MERGED PR #11 |
| F62 | FP resolve + memory update | product, memory | **SHIPPING** — `fp_resolve_memory.py` |

## IN_PROGRESS

| ID | Feature | Notes |
|----|---------|-------|
| — | Live milvus multi-feature e2e | re-score after F62 for D1/D8 |
| F63 | Self-learn + federated memory | design; hub deferred |

## LEFT

12. SELF-LEARN + FEDERATED MEMORY  
13. Deeper lens packs Go/C++/milvus  
14. Agent tools from research  
15. Hermes best practices as Luffy-native  

## Counts

- **features_built_count:** 19 (F44–F62)
- **types_built:** agent_quality, product, memory
- **left_count:** 4
- **progress_pct:** ~93%
- **eta:** 2 fires
- **active_worktrees:** f62-fp-resolve-memory
- **federated_memory_note:** F62 local FP patterns; hub still deferred
- **agent_design_note:** F62 pure regex I/O + MEMORY merge; prompt judgment only
- **meta_loop_note:** F62 closes named product gap from milvus D1/D8
- **milvus_corpus:** 3

## Status line

`features_built_count=19 types_built=agent_quality,product,memory left_count=4 progress_pct=93 eta=2fires active_worktrees=1 federated_memory_note=local_fp milvus_corpus=3`
