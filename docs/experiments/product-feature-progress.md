# Product feature progress

**Updated:** 2026-07-31 (F60 reply-on-thread)  
**Loop:** 019fb948dbe8 orchestrator

## SHIPPED

| ID | Feature | Type | Notes |
|----|---------|------|-------|
| F44–F59 | Agent quality + product suite | agent_quality, product | through incremental |
| F60 | Reply on thread | product | **this PR** — `reply_on_thread.py` + F9 split |

## IN_PROGRESS

| ID | Feature | Notes |
|----|---------|-------|
| — | Live milvus multi-feature e2e | corpus 3; mean ~37 |
| F61 | Testplan generation | next |

## LEFT

10. TESTPLAN GENERATION  
11–15. FP, federated, tools eval, hermes, multi-PR e2e polish  

## Counts

- **features_built_count:** 17 (F44–F60)
- **types_built:** agent_quality, product
- **left_count:** 6
- **progress_pct:** ~85%
- **eta:** 2–4 fires
- **active_worktrees:** f60-reply-on-thread
- **federated_memory_note:** local milvus compounds; hub deferred
- **agent_design_note:** F60 pure code I/O + match; prompt untouched
- **meta_loop_note:** corpus≥3 → product F60
- **milvus_corpus:** 3

## Status line

`features_built_count=17 types_built=agent_quality,product left_count=6 progress_pct=85 eta=2-4fires active_worktrees=1 federated_memory_note=local_x3 milvus_corpus=3`
