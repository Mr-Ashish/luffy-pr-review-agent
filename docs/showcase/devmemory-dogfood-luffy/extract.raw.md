```json
{
  "summary": "The only genuinely new durable knowledge is the F18 implementation pattern: a single shared secret-redaction helper in normalize-review.py applied twice around contract repair, with patterns deliberately kept in sync with save-trace.sh and build-hub-payload.py so posted comments, traces, and hub payloads share one scrub policy. The trust-model consequence is already recorded in DEV.md#Pitfalls, so only the pattern/ordering detail is emitted.",
  "session_ids": ["file-dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Patterns",
      "content": "- Secret scrubbing is a single choke-point helper (`redact_secrets()` in `scripts/normalize-review.py`) driven by one `_SECRET_PATTERNS` table: `sk-or-v1-…`, `[REDACTED] generic `api_key`-style assignments, `gh[pousr]_…`, and `github_pat_…`.\n- It is applied **twice per run**: once after `strip_outer_fence` (so the `### Raw agent output` contract-failure fallback is scrubbed too) and again after `ensure_contract` (so repair/templating cannot reintroduce a leak). Adding new output paths in `normalize-review.py` means re-checking both call sites.\n- Redaction patterns are intentionally duplicated-but-aligned across `normalize-review.py`, `scripts/save-trace.sh`, and `scripts/build-hub-payload.py`; when a pattern is added to one, add it to all three or posted comments, traces, and hub payloads drift apart in scrub policy.\n- Redaction is enforced mechanically at the post step, not delegated to the model: `agent/SOUL.md`'s \"never echo secrets\" rule remains the intent, but the guarantee lives in the normalize stage.\n- Regression tests in `tests/test_normalize_review.py` assert the leaked literal is absent *and* the placeholder (`[OPENROUTER_KEY_REDACTED]` / `[GITHUB_TOKEN_REDACTED]`) is present, including in the broken-output fallback case — copy that both-sided assertion shape for any new pattern.",
      "evidence": [
        "Redaction runs both before contract repair (so fallback 'raw agent output' is scrubbed) and after ensure_contract",
        "Patterns align with save-trace.sh and build-hub-payload.py so traces, hub payloads, and live comments share the same scrub policy",
        "agent/ SOUL trust model still applies; F18 is mechanical enforcement at the post choke-point."
      ],
      "confidence": "high"
    }
  ]
}
```
