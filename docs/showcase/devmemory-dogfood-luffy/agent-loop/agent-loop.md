# Agent loop · `run-20260731T212248-fdd703`

- **model:** `anthropic/claude-opus-5+offline-fallback`
- **hermes_rc:** 0
- **units:** 1
- **at:** 2026-07-31T15:52:50Z

## Summary

offline heuristic extract (1 units)

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
  "assemble_s": 0.141,
  "extract_s": 2.782,
  "normalize_s": 0.0,
  "apply_s": 0.019,
  "total_s": 2.949
}
```

## Pipeline

```text
session → assemble → hermes -z (OpenRouter) → normalize → apply → git review
```
