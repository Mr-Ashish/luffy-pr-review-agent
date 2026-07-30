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

- Download artifact `luffy-out-pr<N>-run<id>` — full `.luffy-out/` + memory snapshot (14 days)
- Download artifact **`luffy-trace-pr<N>-run<id>`** — structured per-run trace (90 days)

### Per-run trace layout

```text
traces/pr{N}-run{RUN_ID}-a{ATTEMPT}/
  meta.json          # identity, status, timings pointer, file hashes
  trace.json         # index
  prompt.md          # agent prompt
  context.md         # PR context
  pr.json / pr.diff  # GitHub PR data
  review.raw.md      # Hermes stdout
  review.md          # normalized posted body
  hermes.stderr      # errors if any
  timings.json       # stage durations
  memory-before.md   # MEMORY.md before review (if any)
  memory-after.md    # MEMORY.md after distill
```

Secrets (`sk-or-…`, `OPENROUTER_API_KEY=…`) are redacted before packaging.

```bash
# Download latest trace for a run
gh run download <run-id> -R owner/repo -n luffy-trace-pr1-run<run-id>
```
