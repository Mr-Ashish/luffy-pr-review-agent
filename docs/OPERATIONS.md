# Luffy operations

## Required setup

1. Put this project (or at least `agent/`, `scripts/`, `.github/workflows/luffy-pr-review.yml`) on the **default branch** of a GitHub repo.
2. Repository secret: `OPENROUTER_API_KEY`
3. Optional variable: `LUFFY_MODEL` (default in scripts: `openai/gpt-5-mini`)
4. On a PR, comment: `@luffy review this pr`

## Manual dispatch

Actions → **Luffy PR Review** → Run workflow → enter PR number.

## Local dry-run

```bash
cd pr-review-agent
# .env with OPENROUTER_API_KEY
./scripts/review-local.sh owner/repo 123
POST_COMMENT=1 ./scripts/review-local.sh owner/repo 123
```

Requires: `gh` authenticated, network for Hermes install + OpenRouter.

## Failure UX

| Failure | What users see |
|---------|----------------|
| Missing OpenRouter secret | PR comment explaining config error |
| Hermes/model failure | PR comment with low-confidence COMMENT verdict |
| Job crash before review file | Always-post step writes failure stub + comments |

## Cost controls

- Explicit comment trigger only (no auto on every push)
- Concurrency cancel-in-progress per PR
- Diff size cap (`MAX_DIFF_BYTES`, default 400000)
- Job timeout 45 minutes

## Memory

- Path: `.luffy-hermes-home/memories/MEMORY.md`
- Grows via `distill-memory.sh` after each review
- Rotates when exceeding `MAX_MEMORY_BYTES` (default 100000)
- Gitignored; restored via Actions cache

## Debug

- Download artifact `luffy-out-<pr>-<run_id>`
- Contains `.luffy-out/` (prompt, diff, raw/final review) and memory snapshot
