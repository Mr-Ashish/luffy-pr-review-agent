# Product feature progress

**Updated:** 2026-08-01 (F63 domain packs + auto-select)  
**Loop:** continuous product backlog

## SHIPPED

| ID | Feature | Type | Notes |
|----|---------|------|-------|
| F44–F61 | Agent quality + product suite | agent_quality, product | through testplan |
| F62 | FP resolve + memory update | product, memory | MERGED PR #12 |
| F63 | Domain packs milvus/go/cpp + auto | product, agent_quality | **SHIPPING** — path_globs + `LUFFY_LENS_PACK=auto` |

## IN_PROGRESS

| ID | Feature | Notes |
|----|---------|-------|
| — | Live milvus multi-feature e2e | re-score with milvus pack + F62 |
| F64 | Self-learn + federated memory | hub deferred; local FP compounds via F62 |

## LEFT

14. SELF-LEARN + FEDERATED MEMORY (F64)  
15. Agent tools from research  
16. Hermes best practices as Luffy-native  
17. Modal as default prod live e2e  

## Counts

- **features_built_count:** 20 (F44–F63)
- **types_built:** agent_quality, product, memory
- **left_count:** 4
- **progress_pct:** ~93%
- **eta:** 2 fires
- **active_worktrees:** f63-domain-packs
- **federated_memory_note:** F62 local FP; hub deferred
- **agent_design_note:** F63 pack JSON + glob scoring; prompt judgment only
- **meta_loop_note:** deeper packs from milvus thin-pack gap
- **milvus_corpus:** 3

## Status line

`features_built_count=20 types_built=agent_quality,product,memory left_count=4 progress_pct=93 eta=2fires active_worktrees=1 federated_memory_note=local_fp milvus_corpus=3`
