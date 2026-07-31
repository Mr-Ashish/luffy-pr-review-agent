# Luffy on Modal

GitHub Actions is the legacy doorbell + kitchen. Modal is the new kitchen (and webhook doorbell).

## Setup (once)

```bash
pip install modal
python3 -m modal token new   # browser auth → ~/.modal.toml
```

## Bit status

| Bit | What | Verify |
|-----|------|--------|
| **1** | Skeleton app + health | `modal run modal_app/app.py` → `BIT1_OK` |
| **2** | Image git/gh + secrets + clone | `modal run modal_app/app.py --bit 2` → `BIT2_OK` |
| 3 | Manual review worker | review one PR offline |
| 4 | Webhook + spawn | comment → Modal |
| 5 | E2E on Mr-Ashish/odoo | real PR |

## Commands

```bash
# Bit 1
modal run modal_app/app.py

# Bit 2 (clone Mr-Ashish/odoo + list PRs)
modal run modal_app/app.py --bit 2

# Deploy (later — public URL)
modal deploy modal_app/app.py
```

## Secrets

```bash
# OpenRouter (from Luffy .env)
modal secret create luffy-openrouter OPENROUTER_API_KEY=sk-or-…

# GitHub (PAT or `gh auth token`)
modal secret create luffy-github GITHUB_TOKEN=… GH_TOKEN=…
```

## Cheap profile (default)

Modal bills **max(request, usage)** for CPU/memory. We:

| Lever | Choice |
|-------|--------|
| CPU / memory | **No reservation** (Modal min ~0.125 core) — never `cpu=2` / `memory=4096` |
| GPU | None |
| Checkout | Sparse + `--depth 1` PR head (no full Odoo clone) |
| Diff | `MAX_DIFF_BYTES=200000` |
| LLM | `openai/gpt-4.1-mini` default (not Opus) |
| Memory publish | off in Modal path (`LUFFY_LOCAL_PUBLISH=0`) |
| Timeout | 25 min hard kill |

```bash
# cheapest e2e
modal run modal_app/app.py --bit 3 --repo Mr-Ashish/odoo --pr 3 --model openai/gpt-4.1-mini
```

## Notes

- Pipeline scripts under `scripts/` stay the product SoT.
- Do not run Hermes inside the webhook HTTP handler — always `spawn`.
- Fat traces → Modal Volume / object storage (not Actions artifacts).
- **F31:** `review_pr` sets `LUFFY_HOST=modal`; orchestrator writes `run-bundle.json` under `.luffy-out` (and the volume copy). Return dict includes `run_bundle` path when present.
