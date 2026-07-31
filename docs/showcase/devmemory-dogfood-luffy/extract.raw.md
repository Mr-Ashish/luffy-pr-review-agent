```json
{
  "summary": "The session is mostly a restatement of already-indexed DEV/USAGE claims (F1–F24 backlog, install modes, hub memory, verdict signalling). Two genuinely new durable details surfaced from the F24 work: GitHub cannot dismiss COMMENTED reviews so Luffy's review history is only partially self-cleaning, and dismiss-prior-pr-reviews.sh has a fixture env hook for offline testing.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- F24 review hygiene is only partial: GitHub cannot dismiss reviews in state `COMMENTED`, so `dismiss-prior-pr-reviews.sh` can only clear prior Luffy reviews in `APPROVED` / `CHANGES_REQUESTED`. Repeated `@luffy review` on a PR whose verdict maps to `COMMENT` (including every pipeline-failure run) will accumulate COMMENTED entries in the Reviews panel — that is expected, not a bug.\n- The dismiss step is deliberately soft-fail and keyed off the `<!-- luffy-pr-review pr=N` marker: a review body whose marker was stripped or reformatted is invisible to F24 and survives re-runs untouched.",
      "evidence": [
        "prior Luffy reviews with marker `<!-- luffy-pr-review pr=N` in state APPROVED/CHANGES_REQUESTED are dismissed (soft)",
        "COMMENTED reviews cannot be dismissed by GitHub and may remain"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Debugging",
      "content": "- Test the F24 dismiss path without hitting GitHub: set `LUFFY_PR_REVIEWS_FIXTURE` to a canned PR-reviews payload so `scripts/dismiss-prior-pr-reviews.sh` runs against the fixture (see `tests/test_dismiss_prior_pr_reviews.py`).\n- If prior APPROVE/REQUEST_CHANGES reviews keep stacking on re-runs, check `LUFFY_REPLACE_PREVIOUS` — it is shared with F12 comment replacement, so setting it to `0` to keep comment history also disables review dismissal.",
      "evidence": [
        "Soft-fail; fixture-testable via `LUFFY_PR_REVIEWS_FIXTURE`",
        "Shares `LUFFY_REPLACE_PREVIOUS` with F12 (0 = leave history)"
      ],
      "confidence": "high"
    }
  ]
}
```
