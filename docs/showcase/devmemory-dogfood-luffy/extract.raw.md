```json
{
  "summary": "F33 webhook auth adds durable detail beyond what's already recorded: the exact precedence ladder inside scripts/webhook_auth.py (open → HMAC → bearer → deny), the fact that a deployment with only LUFFY_WEBHOOK_SECRET set rejects unsigned token-style calls, that the helper is pure-stdlib with a sign|authorize CLI, and the named auth self-checks emitted by the Modal bit 4 dry plan.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Design decisions",
      "content": "- `scripts/webhook_auth.py` is **pure stdlib** (`hmac`/`hashlib`/`json` only) exposing `authorize_webhook()` + `github_hmac_hex()` plus a `sign|authorize` CLI, so the Modal image needs no extra dependency and the auth decision is unit-testable outside Modal (`tests/test_webhook_auth.py`).\n- Auth is a single ordered ladder, not a set of independent checks: (1) neither `LUFFY_WEBHOOK_SECRET` nor `LUFFY_WEBHOOK_TOKEN` configured → `auth=open` + warning; (2) `X-Hub-Signature-256` present → HMAC-SHA256 against `LUFFY_WEBHOOK_SECRET`; (3) otherwise `Authorization: Bearer` **or** `X-Luffy-Token` compared against `LUFFY_WEBHOOK_TOKEN`; (4) anything else → denied. Header presence, not deployment config, selects the HMAC branch.",
      "evidence": [
        "scripts/webhook_auth.py pure stdlib: authorize_webhook, github_hmac_hex, CLI sign|authorize",
        "X-Hub-Signature-256 present → HMAC-SHA256 with LUFFY_WEBHOOK_SECRET",
        "Else [REDACTED] [REDACTED] X-Luffy-Token with LUFFY_WEBHOOK_TOKEN"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- A deployment that sets **only** `LUFFY_WEBHOOK_SECRET` denies plain JSON callers: with a secret configured and no `X-Hub-Signature-256` header the request falls through to the [REDACTED], finds no `LUFFY_WEBHOOK_TOKEN`, and is rejected. If you want the simple `{repo, pr, …}` API (curl, Run Console, scripts) you must set `LUFFY_WEBHOOK_TOKEN` too — the GitHub secret alone only authenticates real GitHub deliveries.",
      "evidence": [
        "Secret set without signature → denied (use token for simple API)"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": "modal_app",
      "action": "merge",
      "section": "Debugging",
      "content": "- The bit 4 dry plan doubles as the auth regression harness: `modal run modal_app/app.py --bit 4 --repo … --pr …` prints named self-checks `auth_open_ok`, `auth_hmac_ok`, `auth_hmac_bad`, `auth_bearer_ok`, `auth_denied_ok` before `BIT4_OK` — no OpenRouter spend and no spawn, so it is the cheapest way to confirm the auth ladder after changing `scripts/webhook_auth.py` or the webhook env.\n- If a live POST is rejected, reproduce locally first: `python3 scripts/webhook_auth.py sign` to mint an `X-Hub-Signature-256` over the exact raw body, then `python3 scripts/webhook_auth.py authorize` to see which branch fired, rather than guessing from the Modal response.",
      "evidence": [
        "Bit 4 dry plan self-checks auth_open_ok, auth_hmac_ok, auth_hmac_bad, auth_bearer_ok, auth_denied_ok",
        "Pure helper: `python3 scripts/webhook_auth.py sign|authorize`"
      ],
      "confidence": "high"
    }
  ]
}
```
