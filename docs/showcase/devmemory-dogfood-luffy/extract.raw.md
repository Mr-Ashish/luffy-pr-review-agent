```json
{
  "summary": "The F32 session adds durable detail about the Modal bit-4 enqueue/webhook layer: its function chain, the two accepted webhook payload shapes, the spawn-only doorbell rule with its dry-run switch and missing signature verification, plus the concrete bit-4 / deploy / unified-trigger commands and the fact that pack installs now ship trigger-review.sh.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": "modal_app",
      "action": "merge",
      "section": "Architecture",
      "content": "- Bit 4 (F32) splits the enqueue path into four units in `modal_app/app.py`: `parse_enqueue_payload` (normalize an incoming request into repo/pr/model/post_comment), `plan_enqueue` (pure plan, no side effects), `enqueue_review` (the spawn call), and `review_webhook` (the HTTP entrypoint). Parsing/planning are separable from spawning so the parser can be self-checked without any OpenRouter spend.\n- `review_webhook` accepts two payload shapes: the simple API `{repo, pr, model, post_comment}`, and a raw GitHub `issue_comment` event whose comment body matches `@luffy … review` and whose issue is a PR. There is no third shape — non-PR issue comments and non-matching bodies are not enqueued.\n- The doorbell and the kitchen are separate processes: the HTTP handler only ever `spawn`s `review_pr`, so Hermes never executes inside the webhook request. `modal deploy modal_app/app.py` is what turns `review_webhook` into a public URL; `modal run … --bit 4` exercises the same code path from the CLI.",
      "evidence": [
        "Modal bit 4: parse_enqueue_payload, plan_enqueue, enqueue_review, review_webhook",
        "Webhook accepts simple API {repo,pr,model,post_comment} or GitHub issue_comment with @luffy review on a PR",
        "HTTP path only spawns review_pr — Hermes never runs in the doorbell"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": "modal_app",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- The webhook is unauthenticated: signature verification of GitHub deliveries is explicitly deferred hardening, so a deployed `review_webhook` URL is a spend-capable open endpoint. Treat the URL itself as the only secret until verification lands.\n- Two independent dry switches exist and they are easy to confuse: `LUFFY_WEBHOOK_DRY_RUN=1` makes the *deployed HTTP handler* plan-only, while the CLI `--bit 4` is dry by default and needs `--spawn` to actually enqueue. Setting one does not affect the other — a \"dry\" CLI run says nothing about the deployed webhook's behaviour.\n- Do not add work (Hermes, cloning, review assembly) to the HTTP handler even for convenience; the spawn-only rule is what keeps the request short-lived and the billed work inside `review_pr`.",
      "evidence": [
        "LUFFY_WEBHOOK_DRY_RUN=1 plans only; CLI modal run --bit 4 dry by default, --spawn to enqueue",
        "Handler **only spawns** `review_pr` (set `LUFFY_WEBHOOK_DRY_RUN=1` to plan-only). Signature verification = later hardening.",
        "Do not run Hermes inside the webhook HTTP handler — always `spawn`."
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": "modal_app",
      "action": "merge",
      "section": "Common commands",
      "content": "- Bit 4 dry enqueue plan (no LLM spend, self-checks the payload parser): `modal run modal_app/app.py --bit 4 --repo Mr-Ashish/odoo --pr 3` → `BIT4_OK`.\n- Actually enqueue the worker: append `--spawn` to the same command.\n- Publish the webhook: `modal deploy modal_app/app.py`, then POST `{\"repo\":\"Mr-Ashish/odoo\",\"pr\":3,\"model\":\"openai/gpt-4.1-mini\",\"post_comment\":true}` to the `review_webhook` URL (or forward a GitHub `issue_comment` payload).\n- Unified trigger CLI wraps all hosts: `./scripts/trigger-review.sh print <repo> <pr>` (no spend, just prints the commands), `local` (delegates to `scripts/review-local.sh`), `modal` (bit-3 worker) — e.g. `./scripts/trigger-review.sh modal Mr-Ashish/odoo 3 --cheap --no-post`.",
      "evidence": [
        "scripts/trigger-review.sh modes: print (no spend), local (review-local.sh), modal (bit 3 worker)",
        "modal run modal_app/app.py --bit 4 --repo Mr-Ashish/odoo --pr 3 --spawn",
        "Deploy — public webhook URL for review_webhook"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": "pack",
      "action": "merge",
      "section": "Design decisions",
      "content": "- The install pack now ships `scripts/trigger-review.sh`, so an installed target repo can drive reviews from any host (print/local/modal) without cloning the hub. Adding a new top-level trigger script therefore requires updating the pack's copied-scripts list, not just the hub repo.",
      "evidence": ["install pack includes trigger-review.sh"],
      "confidence": "medium"
    }
  ]
}
```
