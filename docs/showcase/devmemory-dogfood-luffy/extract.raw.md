```json
{
  "summary": "Session documents the F40 ops-signals contract: which artifact/text source each bundle signal flag is derived from in pack-run-for-ui.py's collect_signals, that path-skip steps must persist ops-signals.env for the signal to survive into the pack, and how the Run Console surfaces the flags. The USAGE-level F40 bullet already exists verbatim in USAGE.md, so no usage unit is emitted.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Design decisions",
      "content": "- **F40 ops signals** are *derived*, not newly emitted by the reviewer: `collect_signals()` in `pack-run-for-ui.py` reconstructs four booleans from existing run artifacts — `timeout` ← `hermes-timeout.env` / F36 review text, `path_skip` ← `ops-signals.env` / F38 stub text, `over_budget` ← the `OVER BUDGET` marker in the normalized review (F29), `diff_truncated` ← `DIFF_TRUNCATED` in `meta.env` (F27) — and attaches them as `bundle[\"signals\"]` alongside a flat `flags[]` list.\n- Because each flag has a **file source plus a review-text fallback**, a signal survives even when the env file is missing; conversely the F38 path-skip step had to start writing `ops-signals.env` so the skip is durable in the pack rather than only inferrable from the stub comment text.\n- Purpose is operator triage, not new data: the goal is answering \"why free-skip / kill / overspend / incomplete run?\" from the bundle alone instead of grepping Actions artifacts.",
      "evidence": [
        "`timeout` | `hermes-timeout.env` / F36 review text",
        "Path-skip steps write `ops-signals.env`",
        "def collect_signals( ... \"signals\": signals,  # F40: timeout / path-skip / budget / truncation"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": "ui/review-console",
      "action": "merge",
      "section": "Architecture",
      "content": "- The console renders `bundle.signals` in two places: header **chips** (shown only when at least one flag is set) and an **Ops signals (F40)** panel in the Overview tab — so a clean run stays visually quiet and any degraded run is visible without opening a tab.\n- Phase tracker state: Phase 2 (standalone review console shell) is **superseded** by the full Run Console; F40 (\"ops signals in console\", phase 4d) is done, while **4c live progress streaming remains pending** — treat streaming as the next console workstream, not signals.",
      "evidence": [
        "Console: header chips + Overview **Ops signals (F40)**.",
        "| 4c Stream progress | pending (live status stream while review runs) |",
        "| 2 Review console shell | **superseded** by full **Run Console**"
      ],
      "confidence": "medium"
    }
  ]
}
```
