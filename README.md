# Luffy — PR Review Agent

Comment-triggered PR reviews powered by **[Hermes Agent](https://github.com/nousresearch/hermes-agent)** + **OpenRouter**, posted back as a Markdown GitHub PR comment. Memory grows across runs.

## Architecture (short)

```text
@luffy review this pr
  → GitHub Actions (gate + concurrency)
  → luffy/ (scripts+SOUL) + workspace/ (PR head)
  → assemble context → Hermes -z → normalize Markdown
  → gh pr comment → distill MEMORY.md → cache
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/OPERATIONS.md](docs/OPERATIONS.md).

## Trigger

```text
@luffy review this pr
@luffy review
```

Also: **Actions → Luffy PR Review → Run workflow** (manual PR number).

## Setup

1. Put `agent/`, `scripts/`, and `.github/workflows/luffy-pr-review.yml` on the **default branch**.
2. Secret: `OPENROUTER_API_KEY`
3. Optional variable: `LUFFY_MODEL`
4. Comment on a PR: `@luffy review this pr`

## Local

```bash
# .env has OPENROUTER_API_KEY (gitignored)
./scripts/review-local.sh owner/repo 123
POST_COMMENT=1 ./scripts/review-local.sh owner/repo 123
```

## Layout

```text
agent/          SOUL, prompts, Hermes config, memory seed
scripts/        assemble → hermes → normalize → distill → post
.github/workflows/luffy-pr-review.yml
docs/           architecture + operations
tests/          normalizer unit tests
```

## Pipeline scripts

| Script | Role |
|--------|------|
| `assemble-context.sh` | PR meta + diff + prompt (no LLM) |
| `run-hermes-review.sh` | Hermes + OpenRouter one-shot |
| `normalize-review.py` | Contract, size, HTML marker |
| `distill-memory.sh` | Grow `MEMORY.md` |
| `post-review-comment.sh` | Post to PR |
| `run-luffy-review.sh` | Orchestrator |
| `save-trace.sh` | Per-run trace package (redacted) |
| `write-failure-review.sh` | Always-comment failure stub |

## Memory

`.luffy-hermes-home/memories/MEMORY.md` is restored via Actions cache and appended after each review (rotated at ~100KB).

## Traces (per run)

Every run writes a redacted trace under `.luffy-out/traces/pr{N}-run{id}-a{attempt}/` and uploads it as a GitHub Actions artifact:

- **`luffy-trace-pr{N}-run{id}`** — structured trace (90-day retention)
- **`luffy-out-pr{N}-run{id}`** — full debug bundle (14-day retention)

Includes prompt, context, diff, raw + final review, hermes stderr, timings, memory before/after, and `meta.json` with SHA256 inventory. See [docs/OPERATIONS.md](docs/OPERATIONS.md).

## v1 limits

- Full PR **comment** only (not inline review threads)
- Large diffs truncated (`MAX_DIFF_BYTES`)
- Hermes installed on runner (Docker pin later)
- Actions cache is best-effort for memory
