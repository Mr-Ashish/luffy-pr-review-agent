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
| #2 bloom 50M (F49 mini re-prompt) | 3 | 4 | 3 | 4 | 3 | 3 | 5 | 4 | 4 | 4 | **37** | Soft e2e-suggestion only; multi-lang covered |
| #3 Azure broker (F49 mini re-prompt) | 3 | 4 | 3 | 4 | 3 | 5 | 5 | 4 | 4 | 4 | **39** | Security walkthrough strong; empty Key findings |

### Evidence

- **#1 F49 mini:** Soft re-prompt recovered `tool_turns` **0→24** (sessions `20260731_235241_feea70` → `20260731_235256_01b7f6`); F45 skipped; **COMMENT 75** · ~$0.071 · 25 API · total **104s** (hermes 99s); F46 soul clean; F57 mermaid 6-file internal group; multi-lens default all ok/n/a; F53 cross-link to milvus-io#51991 in assemble; local memory publish to Mr-Ashish/milvus@master; no path:LINE key findings; soft negative-test suggestion + mock-type nit; chip path tool-reprompt-ok; score **36/50**.

### Cross-harness note

Milvus #1 first-run **36/50** ≈ odoo #2 F49 (36) / #5 F49 (37) on mini — F49 transfer holds; domain shift Go/WAL did not break gates.

- **#2 F49 mini:** Soft re-prompt recovered `tool_turns` **0→36** (sessions `20260731_235714_56bd07` → `20260731_235729_160d87`); **APPROVE 85** · ~$0.103 · 37 API · **113s**; **MEMORY_SOURCE=local** (preloaded #1 notes); F57 mermaid **5 groups** (client/config/docs/internal/pkg); multi-lens ok; e2e-at-limit test suggestion only; no path:LINE findings; score **37/50** (+1 vs #1 via D8).

Milvus #2 **37/50** slightly above #1; memory compound + multi-module mermaid.

- **#3 F49 mini:** Soft re-prompt recovered `tool_turns` **0→10** (sessions `20260801_000121_833521` → `20260801_000138_88d5da`); **APPROVE 95** high · ~$0.023 · 11 API · **63s**; MEMORY local ~5kB; security audit cites validation/URI/mutual exclusion; F57 2 groups pkg/internal; score **39/50** (best milvus so far on cost+security narrative).

### Corpus summary (n=3)

| PR | Total | Tools | Cost | Lat | Memory | Verdict |
|----|------:|------:|-----:|----:|--------|---------|
| #1 insert parse | 36 | 0→24 | $0.07 | 104s | seed→local | COMMENT 75 |
| #2 bloom 50M | 37 | 0→36 | $0.10 | 113s | local | APPROVE 85 |
| #3 Azure broker | 39 | 0→10 | $0.02 | 63s | local | APPROVE 95 |

**Mean:** ~37.3/50. F49 recovery 100%. Gap: D1/D3/D5 soft findings + inline anchors.
