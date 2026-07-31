# Milvus e2e qualitative benchmark

Rubric dims (1–5 each; one-line evidence). Same schema as odoo for cross-harness compare.

| Dim | Name |
|-----|------|
| D1 | Signal quality — true issues vs noise |
| D2 | Coverage — important risk areas hit |
| D3 | Actionability — fixable, concrete |
| D4 | Trust/citations — grounded in diff |
| D5 | Inline precision — line-level correctness |
| D6 | Cost efficiency — model/turns/budget |
| D7 | Latency/ops — finished, traces usable |
| D8 | Memory/context / federated / issue / FP |
| D9 | Severity ranking — priorities sensible |
| D10 | Multi-lens / recipe depth |

## Per-PR scores

| PR | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | Total/50 | Top gap |
|----|----|----|----|----|----|----|----|----|-----|----------|---------|
| #1 skip insert parse (F49 mini re-prompt) | 3 | 4 | 3 | 4 | 3 | 3 | 5 | 3 | 4 | 4 | **36** | Soft findings; empty Key findings; first-run memory seed |

### Evidence

- **#1 F49 mini:** Soft re-prompt recovered `tool_turns` **0→24** (sessions `20260731_235241_feea70` → `20260731_235256_01b7f6`); F45 skipped; **COMMENT 75** · ~$0.071 · 25 API · total **104s** (hermes 99s); F46 soul clean; F57 mermaid 6-file internal group; multi-lens default all ok/n/a; F53 cross-link to milvus-io#51991 in assemble; local memory publish to Mr-Ashish/milvus@master; no path:LINE key findings; soft negative-test suggestion + mock-type nit; chip path tool-reprompt-ok; score **36/50**.

### Cross-harness note

Milvus #1 first-run **36/50** ≈ odoo #2 F49 (36) / #5 F49 (37) on mini — F49 transfer holds; domain shift Go/WAL did not break gates.
