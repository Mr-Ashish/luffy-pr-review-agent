# Milvus multi-PR e2e learn log

Target fork: [Mr-Ashish/milvus](https://github.com/Mr-Ashish/milvus) (upstream milvus-io/milvus).  
Local clone: `/Users/ashishmishra/Documents/experiments/milvus` (blob:none shallow).  
Luffy SoT: this repo only. **LIVE e2e harness = milvus only** (odoo retired for loop).

## Corpus (luffy-eval PRs)

| PR | Title | Upstream | Files | +/− | Status |
|----|-------|----------|------|-----|--------|
| [#1](https://github.com/Mr-Ashish/milvus/pull/1) | luffy-eval: #51991 skip insert body parsing without functions | milvus-io#51991 | 6 Go | +104/−37 | OPEN — first live mini F49 **36/50** |

Corpus size: **1** open eval PR (need ≥2–3).

### Port method

Exact upstream parent/head SHAs (not tip-of-master apply):

- base `113c236` → branch `luffy-eval/51991-base`
- head `cbb3f66` → branch `luffy-eval/51991-head`
- `gh pr create --base …-base --head …-head`

`git apply` of `gh pr diff` onto fork `master` **failed** (master tip diverged). Prefer SHA port for milvus.

## Runs

| When | PR | Run id | Model | Host | Notes |
|------|----|--------|-------|------|-------|
| **2026-07-31** | **#1** | **local / pr1-runlocal-a1** (`.luffy-out-e2e-milvus-pr1`) | **openai/gpt-4.1-mini** | local | F49: tool_turns **0→24**; F45 skipped; COMMENT 75; ~$0.071 · 25 API · 104s total (hermes 99s); F46 soul clean; mermaid F57; multi-lens default; local `.luffy` publish to milvus@master; score **36/50** |

Artifacts: `.luffy-out-e2e-milvus-pr1/`.

## Introspect (first milvus fire)

1. **Corpus cold-start:** fork existed; local clone missing → shallow `blob:none` clone ~158MB workable.
2. **Port strategy:** monorepo tip-apply fails; exact parent/head branches preserve 6-file eval delta (fair Signal/Coverage).
3. **F49 transfer:** same zero-tool first pass on mini as odoo; re-prompt recovered tools 0→24 on Go write-path — product gates work off odoo domain.
4. **Finding depth still soft:** COMMENT/75 with empty Key findings + robustness suggestion; multi-lens all-ok may under-stress skip-parse edge cases (schema race, partial functions).
5. **Memory:** first run seed-only → local publish ok; hub skipped; compounds next milvus runs once MEMORY.md present.
6. **Next:** grow corpus to 2–3 (e.g. #51962 bloom / #52076 proxy JSON); product F60 reply-on-thread or testplan; optional POST_COMMENT=1 dogfood.

## Idle streak

Progress this fire → reset to **0**.
