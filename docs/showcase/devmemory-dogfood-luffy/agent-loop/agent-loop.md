# Agent loop · `run-20260731T211755-5b5f81`

- **model:** `anthropic/claude-opus-5+offline-fallback`
- **hermes_rc:** 0
- **units:** 2
- **at:** 2026-07-31T15:47:58Z

## Summary

offline heuristic extract (2 units)

## Usage

```json
{
  "estimated_cost_usd": null,
  "cost_status": null,
  "cost_source": null,
  "input_tokens": null,
  "output_tokens": null,
  "cache_read_tokens": null,
  "cache_write_tokens": null,
  "reasoning_tokens": null,
  "total_tokens": null,
  "api_calls": 1,
  "model": null,
  "provider": null,
  "session_id": null,
  "completed": false,
  "failed": true,
  "service_tier": null
}
```

## Timings (seconds)

```json
{
  "assemble_s": 0.143,
  "extract_s": 2.779,
  "normalize_s": 0.0,
  "apply_s": 0.807,
  "total_s": 3.738
}
```

## Pipeline

```text
session → assemble → hermes -z (OpenRouter) → normalize → apply → git review
```
