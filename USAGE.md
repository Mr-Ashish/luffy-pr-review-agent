# USAGE — operational knowledge

> How to work with this repository.

## Common commands

```bash
devmemory extract --fixture sample-auth-module --apply
```

## Setup

- Install on each target repo by copying `agent/`, `scripts/`, and `.github/workflows/luffy-pr-review.yml` onto that repo's **default branch** (workflow only runs from default branch).
- Required secret: `OPENROUTER_API_KEY`. For cross-repo hub memory also add `LUFFY_HUB_TOKEN` (PAT with contents write on the hub).
- Optional repo variables: `LUFFY_MODEL` (script default `openai/gpt-5-mini`; showcase runs used `anthropic/claude-opus-5`), `LUFFY_HUB_REPO`, `LUFFY_HUB_MODE`, `LUFFY_ALLOWED_ASSOCIATIONS`, `LUFFY_REPLACE_PREVIOUS`, `MAX_DIFF_BYTES`, `MAX_MEMORY_BYTES`.
- Trigger a review by commenting `@luffy review this pr` (or `@luffy review`) on the PR.

## Debugging

- Local dry-run (needs authenticated `gh`, network, and `.env` with `OPENROUTER_API_KEY`): `./scripts/review-local.sh owner/repo 123`; add `POST_COMMENT=1` to actually comment on the PR.
- Two artifacts per run: `luffy-out-pr<N>-run<id>` (full `.luffy-out/` + memory snapshot, 14 days) and `luffy-trace-pr<N>-run<id>` (structured redacted trace, 90 days).
- Fetch a trace with `gh run download <run-id> -R owner/repo -n luffy-trace-pr<N>-run<run-id>`.
- Trace layout under `traces/pr{N}-run{RUN_ID}-a{ATTEMPT}/`: `meta.json`, `trace.json`, `prompt.md`, `context.md`, `pr.json`/`pr.diff`, `review.raw.md` (Hermes stdout) vs `review.md` (posted body), `hermes.stderr`, `timings.json`, `memory-before.md`/`memory-after.md` — diff raw vs normalized to isolate contract violations, and before/after memory to verify distill.
- `scripts/capture-hermes-loop.py` turns a run into a step-by-step agent-loop dump (API calls, tool turns, messages, token/cost estimates) as in `docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/`.
