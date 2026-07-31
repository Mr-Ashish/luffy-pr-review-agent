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
| #2 web fields (H16 mini post-F47) | 2 | 3 | 2 | 4 | 2 | 5 | 4 | 2 | 3 | 3 | **30** | -z ok; tool_turns=0 model choice; F45 gate |
| #3 xml scrub (local mini+showcase) | 4 | 4 | 4 | 4 | 3 | 4 | 5 | 3 | 4 | 4 | **39** | D5 inline |
| #4 stock/mrp PERF (mini post-F48) | 2 | 3 | 2 | 4 | 2 | 5 | 5 | 2 | 3 | 3 | **31** | tool_turns=0; multi-module needs tools |

### Evidence (one line)

- **#1:** Blocking null-guard on successCb is plausible race; nits on style. Memory seed only.
- **#2 GHA:** Correct high-signal block: format alias untested while getFieldsSpec tests present.
- **#2 F44 mini:** APPROVE despite same gap; medium findings are speculative (“other field types”); raw was prompt-polluted until F44.
- **#2 F45 gate:** Same body post-processed — APPROVE→COMMENT + F45 banner + score 55; honesty/trust up, findings unchanged.
- **#2 H16 mini:** F47 confirmed — `hermes -z` (no argv reject, no chat fallback); 1 API call · ~$0.003 · 12s; still `tool_turns=0` (model single-shot); F45→COMMENT/55; F46 preflight clean; **false** runtime `soul_blocked` from stale agent.log → **F48**.
- **#3:** Approve justified; tests cover str/bytes/lxml; showcase loop usable.
- **#4 mini:** Port of odoo#279776 (7 files stock/mrp/purchase_mrp); `-z` ok; F48 `soul_blocked=0`; tool_turns=0 → F45 COMMENT/55; soft rename nit only; ~$0.002 · 16s.

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

### #2 H16 sub-dims (post-F47 live mini; D1=2, D8=2)

| Sub | Score | Note |
|-----|------:|------|
| D1a true positives | 1 | Still missed missing `format:false` alias tests (GHA gap) |
| D1b false positives / noise | 3 | Mostly empty findings; one soft rename nit |
| D7a hermes -z path | 5 | No `invalid choice`; no chat fallback; no `hermes-cli-argv.env` |
| D8a SOUL/memory load | 3 | Preflight clean; pin `scan_for_threats` empty; runtime FP fixed in F48 |
| D8b tool/workspace use | 1 | `tool_turns=0` — model chose text stop (not CLI failure) |

### #4 mini sub-dims (D1=2, D8=2)

| Sub | Score | Note |
|-----|------:|------|
| D1a true positives | 1 | No cache/correctness risks called out on multi-module PERF |
| D1b noise | 3 | Soft rename nit only after F45 |
| D7a ops (F48) | 5 | `soul_blocked=0`; `-z` clean; no argv env |
| D8b tool/workspace use | 1 | tool_turns=0 on 7-file PR |

## Rollup (best run per PR for corpus avg)

| PR | Best total | Primary gap |
|----|------------|-------------|
| #1 | 35 | Memory/context |
| #2 | 40 (GHA) | Memory; cheap path still 30 (tools not used) |
| #3 | 39 | Inline precision |
| #4 | 31 (mini) | tool_turns=0; no GHA/full-model run yet |

**Corpus average (best-per-PR): 36.3 / 50** (was 38.0 @3 PRs; #4 mini pulls avg down until tool-using run)  
**Cheap-path pattern (replicated #2+#4):** gpt-4.1-mini + working `-z` still **0 tools** → F45 COMMENT; D1 stuck ~2 until H15/H18.

## Comparison notes (D10)

- PR-Agent-style: stronger structured findings tables + severity; Luffy GHA run competitive; chat-fallback path is not.
- Hermes-style: agentic tool loop is the product differentiator — F44/H16 mini still **0 tool turns** on gpt-4.1-mini even with working `-z`.
- F45: control-plane fail-closed mirrors “don’t ship green without tools” — PR-Agent never claimed agentic; we must not green-light when we aren’t.

### F46 note (SOUL load)

Product `agent/SOUL.md` no longer trips Hermes `prompt_injection` (verified with
pin `scan_for_threats`). H16 preflight clean. Historical F44 SOUL-block row kept.

### F47 note (hermes -z reliability)

Root cause of F44 zero-tool path: bogus CLI `--max-turns` → `-z` rc=2 → `chat -q`.
**H16 live verify:** `-z` path works (stderr header `hermes -z`, no argv env). Residual
`tool_turns=0` is **model behaviour** (single text response), not CLI failure.

### F48 note (SOUL detect false positive)

H16 ops noise: `soul_blocked=1` while this-invocation `hermes-run.log` had no block line.
Root cause: detect scanned full `HERMES_HOME` agent.log history (prior session still had
`Context file SOUL.md blocked`). F48: pass `HERMES_LOG_OFFSET` into capture; package only
the this-run log slice; detect only invocation-scoped logs.

### Corpus #4 note

Sourced upstream [odoo/odoo#279776](https://github.com/odoo/odoo/pull/279776) → [Mr-Ashish/odoo#4](https://github.com/Mr-Ashish/odoo/pull/4).
First multi-module backend PERF eval PR. Confirms H16 cheap-path residual on a second PR.

_Last updated: 2026-07-31 corpus #4_

