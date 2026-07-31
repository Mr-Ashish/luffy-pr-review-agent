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
| **3** | Manual review worker | `modal run … --bit 3 --repo … --pr …` → `BIT3_OK` |
| **4** | Enqueue + webhook (F32) | `modal run … --bit 4` dry plan → `BIT4_OK`; deploy POST `review_webhook` |
| 5 | E2E on Mr-Ashish/odoo | real PR (paid) |

## Commands

```bash
# Bit 1
modal run modal_app/app.py

# Bit 2 (clone Mr-Ashish/odoo + list PRs)
modal run modal_app/app.py --bit 2

# Bit 3 — cheap review worker (OpenRouter spend)
modal run modal_app/app.py --bit 3 --repo Mr-Ashish/odoo --pr 3 --model openai/gpt-4.1-mini

# Bit 4 — dry enqueue plan (no Hermes spend; parser self-check)
modal run modal_app/app.py --bit 4 --repo Mr-Ashish/odoo --pr 3
# Bit 4 — actually spawn worker
modal run modal_app/app.py --bit 4 --repo Mr-Ashish/odoo --pr 3 --spawn

# Unified CLI (also print|local)
./scripts/trigger-review.sh print Mr-Ashish/odoo 3
./scripts/trigger-review.sh modal Mr-Ashish/odoo 3 --cheap --no-post

# Deploy — public webhook URL for review_webhook
modal deploy modal_app/app.py
```

### Webhook (bit 4)

POST JSON (simple API):

```json
{"repo": "Mr-Ashish/odoo", "pr": 3, "model": "openai/gpt-4.1-mini", "post_comment": true}
```

Or a GitHub `issue_comment` event on a PR whose body matches `@luffy … review`.  
Handler **only spawns** `review_pr` (set `LUFFY_WEBHOOK_DRY_RUN=1` to plan-only). Signature verification = later hardening.

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
