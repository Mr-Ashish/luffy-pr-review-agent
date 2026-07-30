# E2E showcase — Luffy on a complex Odoo PR

**Issue:** [odoo/odoo#271153](https://github.com/odoo/odoo/issues/271153) — `remove_control_characters` left U+FFFE/U+FFFF (and other non-XML chars) intact, crashing EDI/UBL export.  
**PR:** [Mr-Ashish/odoo#3](https://github.com/Mr-Ashish/odoo/pull/3) — Unicode-level sanitizer + `dict_to_xml` + regression tests.  
**Run:** [Actions #30572964204](https://github.com/Mr-Ashish/odoo/actions/runs/30572964204)  
**Trace id:** `pr3-run30572964204-a1`  
**Model:** `openai/gpt-5-mini` via OpenRouter · Hermes one-shot  

## Why this run matters

| Signal | Value |
|--------|-------|
| Verdict | **REQUEST CHANGES** (not rubber-stamp) |
| Score | **88/100** |
| Review effort | **3/5** |
| Confidence | high |
| Hermes stage | ~130s |
| Review size | ~7.3 KB structured Markdown |
| Hub memory preload | 2970 B prior odoo memory |

Luffy produced a structured staff review: walkthrough, blocking finding with **concrete trigger scenario**, severity table, security audit, code suggestion diff, and test-gap analysis. The author then landed a follow-up commit addressing the blocking decode policy.

## Trace package (this folder)

| File | Purpose |
|------|---------|
| `meta.json` | run identity, model, file hashes |
| `timings.json` | stage wall-clock (preload / assemble / hermes / distill) |
| `review.md` | final PR comment body (contract + HTML marker) |
| `pr.diff` | capped unified diff Hermes saw |
| `context.md` | assembled untrusted PR context |
| `files.txt` | changed-files summary |
| `prompt.excerpt.md` | start of the assembled agent prompt |
| `trace.json` | package index |

Download live artifacts any time:

```bash
gh run download 30572964204 -R Mr-Ashish/odoo -n luffy-trace-pr3-run30572964204
```

## Pipeline stages (this run)

```text
preload_hub_memory (0s) → assemble (2s) → hermes (130s) → distill (0s)
→ save_trace → publish_hub → PR comment + artifacts
```
