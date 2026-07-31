# Agent loop · `run-20260731T224118-f42fe6`

- **model:** `anthropic/claude-opus-5`
- **hermes_rc:** 0
- **units:** 4
- **at:** 2026-07-31T17:11:54Z

## Summary

The session shipped F50/H20 severity calibration: a post-review gate (scripts/severity_calibration.py) that upgrades APPROVE→REQUEST CHANGES when the review body self-reports missing/insufficient tests, gated by LUFFY_SEVERITY_CALIBRATION (default on) with a score cap of 69 and a sev-cal pack chip. Offline re-scores of the odoo e2e corpus quantify the effect (#2 36→42/50, #5 37→40/50, #4 clean no-op).

## Usage

```json
{
  "estimated_cost_usd": 0.27356625,
  "cost_status": "estimated",
  "cost_source": "provider_models_api",
  "input_tokens": 2,
  "output_tokens": 2318,
  "cache_read_tokens": 0,
  "cache_write_tokens": 34497,
  "reasoning_tokens": 264,
  "total_tokens": 36817,
  "api_calls": 1,
  "model": "anthropic/claude-opus-5",
  "provider": "openrouter",
  "session_id": "20260731_224120_31ac74",
  "completed": true,
  "failed": false,
  "service_tier": null
}
```

## Timings (seconds)

```json
{
  "assemble_s": 0.666,
  "extract_s": 30.615,
  "normalize_s": 0.001,
  "apply_s": 3.919,
  "total_s": 35.208
}
```

## Pipeline

```text
session → assemble → hermes -z (OpenRouter) → normalize → apply → git review
```
