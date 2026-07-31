```json
{
  "summary": "The session's genuinely new durable content is the F21 cost/usage telemetry layer: the `scripts/usage-summary.py` contract (footer/append/step-summary subcommands, soft no-op on missing telemetry), its regex coupling to the brand footer that `normalize-review.py` appends, the soft-failing hook in `run-hermes-review.sh`, and its inclusion in the install pack's runtime-script allowlist. Existing knowledge already covered F1–F20, architecture, hub memory, agent SOUL, and the prebaked runner, so those are omitted.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Design decisions",
      "content": "- **F21 cost visibility** is a post-normalize decoration, not a pipeline stage: `scripts/usage-summary.py` reads the `hermes --usage-file` JSON (`hermes-usage.json`) written by `run-hermes-review.sh` and exposes three subcommands — `footer` (emit one italic Markdown line), `append` (inject/update that line on an existing `review.md`), `step-summary` (a **Luffy cost / usage** section for `$GITHUB_STEP_SUMMARY` with model, estimated USD, tokens, API calls, stage timings).\n- Telemetry is explicitly non-load-bearing: missing, empty, non-dict, or unparseable usage files are soft no-ops that exit 0, and `run-hermes-review.sh` calls the `append` step guarded by `[[ -f … ]]` with `|| notice \"usage-summary append soft-failed\"` — cost reporting can never fail a review.\n- Both the PR-comment footer and the job summary are fed from the same usage file so cost is visible without downloading an artifact; number formatting is deliberately lossy/human (tokens as `1.5k`/`10k`/`1.0M`, `n/a` when a field is absent or non-numeric, booleans rejected as numbers).\n- `usage-summary.py` is part of the F20 install pack's `RUNTIME_SCRIPTS` allowlist in `scripts/install-luffy.sh`, so target repos get cost visibility on install; image-build/benchmark scripts (`build-luffy-runner-image.sh`, `benchmark-hermes-startup.sh`) remain excluded.",
      "evidence": [
        "Cost UX | `scripts/usage-summary.py` | Append cost/tokens footer + job-summary from `hermes-usage.json` (F21)",
        "Missing or empty usage files are soft no-ops (exit 0) so the pipeline never fails because cost telemetry was absent.",
        "python3 \"$LUFFY_ROOT/scripts/usage-summary.py\" append --usage \"$USAGE_FILE\" --review \"$FINAL_OUT\" || notice \"usage-summary append soft-failed\""
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- `usage-summary.py` is textually coupled to `normalize-review.py`: `_FOOTER_RX` matches the exact brand footer line (`*Luffy · Hermes Agent · OpenRouter · memory-backed review…*`) to anchor where the cost line goes. Editing that footer string in `normalize-review.py` silently misplaces (or drops) the F21 cost line — change both together.\n- Re-appending is idempotent by design via `_COST_LINE_RX` (`^\\*Cost / usage:.*\\*$`): an existing cost line is replaced, not stacked. Rewriting that line's shape in one place breaks dedup and produces duplicated footers on re-runs.\n- A missing `*Cost / usage: …*` line on a posted review is not necessarily a bug — it is the documented soft no-op when `hermes-usage.json` is absent/empty/malformed. Check the usage file before suspecting the review path.",
      "evidence": [
        "# Matches the brand footer normalize-review.py appends.\n_FOOTER_RX = re.compile(r\"^\\*Luffy · Hermes Agent · OpenRouter · memory-backed review[^*]*\\*\\s*$\", re.M)",
        "_COST_LINE_RX = re.compile(r\"^\\*Cost / usage:.*\\*\\s*$\", re.M)",
        "append — inject/update that line on an existing review.md"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Common commands",
      "content": "- Render the F21 cost line standalone: `python3 scripts/usage-summary.py footer --usage <hermes-usage.json>`.\n- Inject/refresh the cost line on a normalized review body: `python3 scripts/usage-summary.py append --usage <hermes-usage.json> --review <review.md>` (idempotent; safe to re-run).\n- Produce the Actions job-summary section: `python3 scripts/usage-summary.py step-summary --usage <hermes-usage.json>` (accepts a timings JSON for stage durations).\n- All three exit 0 with no output when the usage file is missing or empty, so they are safe to wire into scripts unguarded.",
      "evidence": [
        "footer        — one Markdown italic line for the posted review\n  append        — inject/update that line on an existing review.md\n  step-summary  — Markdown section for $GITHUB_STEP_SUMMARY",
        "Reads hermes --usage-file JSON (see run-hermes-review.sh)"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Debugging",
      "content": "- To audit what a review cost, read the **Luffy cost / usage** section in the Actions job summary first — no artifact download needed; the same numbers appear as the `*Cost / usage: …*` footer on the PR comment.\n- For deeper digging, `hermes-usage.json` travels with the run package (see `docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/hermes-usage.json` for a captured example alongside `timings.json`).\n- If cost/token values render as `n/a`, the usage JSON parsed but the specific field was absent or non-numeric; if the whole line is missing, the usage file itself was missing/empty and every subcommand no-opped.",
      "evidence": [
        "the Actions job summary has a matching **Luffy cost / usage** section (no artifact download required)",
        "docs/showcase/e2e-odoo-pr3-opus5-agentic-loop/hermes-usage.json",
        "def format_tokens(n: float | int | None) -> str:\n    if n is None:\n        return \"n/a\""
      ],
      "confidence": "medium"
    }
  ]
}
```
