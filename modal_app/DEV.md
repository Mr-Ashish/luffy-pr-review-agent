# DEV — engineering knowledge

> How this part of the system is built.

## Design decisions

- The Modal entrypoint is a first-class host in the F31 Run Console contract: `review_pr` exports `LUFFY_HOST=modal` so `pack-run-for-ui.py` stamps the bundle's host label as `modal` instead of falling through the `GITHUB_ACTIONS`/else auto-detect to `local`.
- `review_pr` also returns the `run_bundle` path in its result, so a Modal caller gets the console bundle handle back directly rather than having to download an Actions artifact (the GHA path's only option).

## Architecture

- Bit 4 (F32) splits the enqueue path into four units in `modal_app/app.py`: `parse_enqueue_payload` (normalize an incoming request into repo/pr/model/post_comment), `plan_enqueue` (pure plan, no side effects), `enqueue_review` (the spawn call), and `review_webhook` (the HTTP entrypoint). Parsing/planning are separable from spawning so the parser can be self-checked without any OpenRouter spend.
- `review_webhook` accepts two payload shapes: the simple API `{repo, pr, model, post_comment}`, and a raw GitHub `issue_comment` event whose comment body matches `@luffy … review` and whose issue is a PR. There is no third shape — non-PR issue comments and non-matching bodies are not enqueued.

## Pitfalls

- The webhook is unauthenticated: signature verification of GitHub deliveries is explicitly deferred hardening, so a deployed `review_webhook` URL is a spend-capable open endpoint. Treat the URL itself as the only secret until verification lands.
- Two independent dry switches exist and they are easy to confuse: `LUFFY_WEBHOOK_DRY_RUN=1` makes the *deployed HTTP handler* plan-only, while the CLI `--bit 4` is dry by default and needs `--spawn` to actually enqueue. Setting one does not affect the other — a "dry" CLI run says nothing about the deployed webhook's behaviour.
- Do not add work (Hermes, cloning, review assembly) to the HTTP handler even for convenience; the spawn-only rule is what keeps the request short-lived and the billed work inside `review_pr`.
