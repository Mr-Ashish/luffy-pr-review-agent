# DEV — engineering knowledge

> How this part of the system is built.

## Design decisions

- The Modal entrypoint is a first-class host in the F31 Run Console contract: `review_pr` exports `LUFFY_HOST=modal` so `pack-run-for-ui.py` stamps the bundle's host label as `modal` instead of falling through the `GITHUB_ACTIONS`/else auto-detect to `local`.
- `review_pr` also returns the `run_bundle` path in its result, so a Modal caller gets the console bundle handle back directly rather than having to download an Actions artifact (the GHA path's only option).

- F34 deliberately reverses F33's behaviour rather than extending it: F33 allowed unauthenticated requests with a warning when no secret/token was configured; F34 makes that same state `auth=denied` so the production-safe posture is the default and misconfiguration is loud instead of silent.
- The open-mode escape hatch is exposed on three surfaces that must stay in sync: env `LUFFY_WEBHOOK_ALLOW_OPEN=1`, the `allow_open=True` argument on the auth helper, and the `--allow-open` flag on `scripts/webhook_auth.py`. All three exist for dev/self-check only — none is a supported production configuration.

- The F36 default of **1500s** is chosen to sit just under Modal's `review_pr` hard cap (~25m) rather than under the GHA job cap (90m) — the tighter host sets the shared default, so the same number is safe on both. Changing `DEFAULT_SECONDS` in `scripts/run-with-timeout.py` without re-checking the Modal function timeout would let a Modal run be killed by the platform instead of by the helper (losing the honest 124 stub and job-summary section).

## Architecture

- Bit 4 (F32) splits the enqueue path into four units in `modal_app/app.py`: `parse_enqueue_payload` (normalize an incoming request into repo/pr/model/post_comment), `plan_enqueue` (pure plan, no side effects), `enqueue_review` (the spawn call), and `review_webhook` (the HTTP entrypoint). Parsing/planning are separable from spawning so the parser can be self-checked without any OpenRouter spend.
- `review_webhook` accepts two payload shapes: the simple API `{repo, pr, model, post_comment}`, and a raw GitHub `issue_comment` event whose comment body matches `@luffy … review` and whose issue is a PR. There is no third shape — non-PR issue comments and non-matching bodies are not enqueued.

## Pitfalls

- **F33/F34:** production must set `LUFFY_WEBHOOK_SECRET` and/or `LUFFY_WEBHOOK_TOKEN` on the Modal function (e.g. fold into `luffy-github`). **F34 fail-closed:** if neither is set, requests are **denied** unless `LUFFY_WEBHOOK_ALLOW_OPEN=1` (dev escape only).
- HMAC verification needs the **raw** request body (not a re-serialized dict). The webhook reads `await request.body()` before `json.loads`; do not switch back to a typed `item: dict` parameter or signatures will never match.
- Two independent dry switches exist and they are easy to confuse: `LUFFY_WEBHOOK_DRY_RUN=1` makes the *deployed HTTP handler* plan-only, while the CLI `--bit 4` is dry by default and needs `--spawn` to actually enqueue. Setting one does not affect the other — a "dry" CLI run says nothing about the deployed webhook's behaviour.
- Do not add work (Hermes, cloning, review assembly) to the HTTP handler even for convenience; the spawn-only rule is what keeps the request short-lived and the billed work inside `review_pr`.
