# Product feature progress

**Updated:** 2026-08-01 (F65 federated tenant + F66 Modal prod e2e)  
**Loop:** continuous product backlog

## SHIPPED

| ID | Feature | Type | Notes |
|----|---------|------|-------|
| F44–F61 | Agent quality + product suite | agent_quality, product | through testplan |
| F62 | FP resolve + memory update | product, memory | MERGED PR #12 |
| F63 | Domain packs milvus/go/cpp + auto | product, agent_quality | MERGED PR #14 |
| F64 | Durable fp-rules.json self-learn | product, memory | MERGED PR #15 |
| F65 | Multi-tenant federated hub memory | product, memory | **MERGED** PR #16 |
| F66 | Modal default prod live e2e host | product, ops | **MERGED** PR #16 (`0.7.0-f66`) |

## IN_PROGRESS

| ID | Feature | Notes |
|----|---------|-------|
| — | — | milvus Modal re-score done (mean ~38.3/50) |

## LEFT

16. Agent tools from research (research → eval → adopt) — larger  
17. Hermes best practices as full Luffy-native self-evolution — larger  

## Counts

- **features_built_count:** 23 (F44–F66)
- **types_built:** agent_quality, product, memory, ops
- **left_count:** 2 (large deferred)
- **progress_pct:** ~97%
- **eta:** research/self-evolution fires
- **active_worktrees:** none
- **federated_memory_note:** F65 LUFFY_MEMORY_TENANT → memory/tenants/{t}/repos/{slug}
- **agent_design_note:** F62–F66 pure code I/O; prompt judgment only
- **meta_loop_note:** F65+F66 shipped; Modal milvus corpus re-scored mean 38.3
- **milvus_corpus:** 3 (Modal F66 re-score complete)

## Status line

`features_built_count=23 types_built=agent_quality,product,memory,ops left_count=2 progress_pct=97 eta=large-deferred active_worktrees=0 federated_memory_note=tenant_path milvus_corpus=3 modal_rescore=38.3`
