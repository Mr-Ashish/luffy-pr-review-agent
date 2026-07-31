# Odoo e2e qualitative benchmark

Rubric dims (1–5 each; one-line evidence). Recursive: dim ≤2 gets sub-dims.

| Dim | Name |
|-----|------|
| D1 | Signal quality — true issues vs noise |
| D2 | Coverage — important risk areas hit |
| D3 | Actionability — fixable, concrete |
| D4 | Trust/citations — grounded in diff |
| D5 | Inline precision — line-level correctness |
| D6 | Cost efficiency — model/turns/budget |
| D7 | Latency/ops — finished, traces usable |
| D8 | Memory/context use — repo/memory leveraged |
| D9 | Severity ranking — priorities sensible |
| D10 | vs PR-Agent/Hermes-style expectations |

## Per-PR scores

| PR | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | Total/50 | Top gap |
|----|----|----|----|----|----|----|----|----|----|-----|----------|---------|
| #1 turnstile (GHA) | 4 | 3 | 4 | 4 | 3 | 4 | 4 | 2 | 4 | 3 | **35** | D8 memory thin |
| #2 web fields (GHA) | 5 | 4 | 5 | 4 | 3 | 4 | 4 | 2 | 5 | 4 | **40** | D8; D5 soft lines |
| #2 web fields (F44 mini local) | 2 | 3 | 2 | 3 | 2 | 5 | 3 | 1 | 2 | 2 | **25** | D1/D3/D8 no tools + SOUL block |
| #2 web fields (F45 gate on F44) | 3 | 3 | 2 | 4 | 2 | 5 | 4 | 1 | 3 | 3 | **30** | Still no tools; no longer false APPROVE |
| #3 xml scrub (local mini+showcase) | 4 | 4 | 4 | 4 | 3 | 4 | 5 | 3 | 4 | 4 | **39** | D5 inline |

### Evidence (one line)

- **#1:** Blocking null-guard on successCb is plausible race; nits on style. Memory seed only.
- **#2 GHA:** Correct high-signal block: format alias untested while getFieldsSpec tests present.
- **#2 F44 mini:** APPROVE despite same gap; medium findings are speculative (“other field types”); raw was prompt-polluted until F44.
- **#2 F45 gate:** Same body post-processed — APPROVE→COMMENT + F45 banner + score 55; honesty/trust up, findings unchanged.
- **#3:** Approve justified; tests cover str/bytes/lxml; showcase loop usable.

### #2 F44 sub-dims (D1=2, D3=2, D8=1)

| Sub | Score | Note |
|-----|------:|------|
| D1a true positives | 1 | Missed missing alias tests (known from GHA) |
| D1b false positives / noise | 2 | console.warn + cross-type alias expansion |
| D3a concrete fix steps | 2 | Diff suggestions rewrite same code |
| D3b test asks | 1 | Claimed coverage complete incorrectly |
| D8a SOUL/memory load | 1 | SOUL blocked prompt_injection |
| D8b tool/workspace use | 1 | tool_turns=0 |

### #2 F45 sub-dims (post-gate; D1=3, D8=1)

| Sub | Score | Note |
|-----|------:|------|
| D1a true positives | 1 | Still missed alias tests (gate does not invent findings) |
| D1b false approve risk | 4 | Fail-closed: no merge-green without tools |
| D4 trust | 4 | Banner + COMMENT state the incomplete loop |
| D8b tool/workspace use | 1 | Unchanged — still 0 tool turns |

## Rollup (best run per PR for corpus avg)

| PR | Best total | Primary gap |
|----|------------|-------------|
| #1 | 35 | Memory/context |
| #2 | 40 (GHA) | Memory; cheap path collapses to 25 |
| #3 | 39 | Inline precision |

**Corpus average (best-per-PR): 38.0 / 50**  
**Cheap-path penalty:** #2 mini run −15 vs GHA; F45 gate recovers +5 (25→30) without new model spend.

## Comparison notes (D10)

- PR-Agent-style: stronger structured findings tables + severity; Luffy GHA run competitive; chat-fallback path is not.
- Hermes-style: agentic tool loop is the product differentiator — F44 run had **0 tool turns**, so we under-used the stack.
- F45: control-plane fail-closed mirrors “don’t ship green without tools” — PR-Agent never claimed agentic; we must not green-light when we aren’t.

_Last updated: 2026-07-31 F45_
