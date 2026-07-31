# Session

- **session_id:** `dogfood-luffy-session`
- **source:** `file`
- **project:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **timestamp:** ``

## Transcript / notes

# dogfood-luffy-session (F44)

We built and operate Luffy, a comment-triggered PR review agent (Hermes + OpenRouter + hub memory).

## F44 change
- `scripts/normalize-review.py` now extracts the real review from `hermes chat -q` chrome.
- Rejects prompt-template echo with placeholder `**Verdict:** < APPROVE | … >`.
- Promotes unbolded `Verdict:` / `Summary` headings so parse-verdict and contract checks work.
- Does not treat bare `───` separators as TUI chrome (models use them between findings).

## E2e evidence
- Multi-PR corpus on Mr-Ashish/odoo PRs #1 #2 #3 (luffy-eval titles).
- Cheap run on PR #2: hermes -z failed → chat fallback; without F44 would post full prompt.
- GHA prior review on PR #2 had higher signal (missing format:false tests) than no-tool mini run.

## Durable lessons
- Normalizer is a trust boundary: never treat prompt-echo as valid contract just because snippets match.
- tool_turns=0 on multi-file PRs is a quality smell for agentic review product.
- SOUL.md can be blocked by Hermes prompt_injection scanner — needs a P1 workaround.

