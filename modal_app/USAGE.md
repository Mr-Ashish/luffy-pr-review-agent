# USAGE — operational knowledge

> How to work with this part of the system.

## Common commands

- Bit 4 dry enqueue plan (no LLM spend, self-checks the payload parser): `modal run modal_app/app.py --bit 4 --repo Mr-Ashish/odoo --pr 3` → `BIT4_OK`.
- Actually enqueue the worker: append `--spawn` to the same command.
- Publish the webhook: `modal deploy modal_app/app.py`, then POST `{"repo":"Mr-Ashish/odoo","pr":3,"model":"openai/gpt-4.1-mini","post_comment":true}` to the `review_webhook` URL (or forward a GitHub `issue_comment` payload).
- Unified trigger CLI wraps all hosts: `./scripts/trigger-review.sh print <repo> <pr>` (no spend, just prints the commands), `local` (delegates to `scripts/review-local.sh`), `modal` (bit-3 worker) — e.g. `./scripts/trigger-review.sh modal Mr-Ashish/odoo 3 --cheap --no-post`.
