```json
{
  "summary": "Session documents F38 (path-glob free skip): a pre-checkout cost gate that skips paid Hermes/OpenRouter review when every changed path matches skip globs, plus its opt-in var, force escape hatches, fail-open exit-code contract, and CLI self-check commands. None of this appears in the existing DEV/USAGE claim index.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Design decisions",
      "content": "- **F38 path-glob free skip** sits early in the pipeline — after the sparse path list, *before* dual checkout — so a docs-only PR never pays for the monorepo checkout or the Hermes/OpenRouter call.\n- It is a whole-PR gate, not a filter: the skip fires only when **every** changed path matches the skip globs; one code file re-enables the paid run.\n- Default is **off** (`vars.LUFFY_SKIP_PATH_GLOBS` empty). Operators opt in with the built-in `docs` preset or a comma glob list (e.g. `*.md,docs/**`); `off` is also accepted as a preset name.\n- Two escape hatches keep the gate overridable per run: comment `@luffy review force` and `workflow_dispatch` (env form `LUFFY_SKIP_PATHS_FORCE=1`).\n- `scripts/path-skip-check.py` is **fail-open by contract**: exit 0 allow, exit 2 skip, exit 1 hard error which the caller treats as allow. A broken helper must never silently suppress reviews.\n- A skipped run is still a visible run: stub COMMENT body, rocket reaction, F37 verdict labels, and a **Luffy path skip (F38)** job summary — so skip is distinguishable from a crash, not from silence.\n- The helper emits `key=value` stdout (`allowed`, `reason`, `matched_n`, `total_n`, `globs`, `sample`) rather than JSON, matching the other shell-composed stages.",
      "evidence": [
        "Skip paid review when **every** changed file matches skip globs (docs/changelog PRs).",
        "Force paid run: `@luffy review force` or `workflow_dispatch`. Fail-open on script errors.",
        "Stub COMMENT + rocket + F37 labels; job summary **Luffy path skip (F38)**",
        "1  hard error (caller should fail-open → allow)"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Common commands",
      "content": "- Enable free skip on a target repo: set repo variable `LUFFY_SKIP_PATH_GLOBS` to `docs` (preset) or a comma list such as `*.md,docs/**`. Unset/empty = feature off.\n- Self-check the gate before wiring it up (exit code is the answer): `python3 scripts/path-skip-check.py --path README.md --path docs/a.md --globs docs` → exit 2 (skip); `python3 scripts/path-skip-check.py --path src/x.py --path README.md --globs docs` → exit 0 (allow).\n- Batch form for a real PR path list: `python3 scripts/path-skip-check.py --paths-file pr-paths.txt` (paths come from `scripts/sparse-pr-paths.sh`).\n- Regression coverage: `tests/test_path_skip_check.py`.",
      "evidence": [
        "python3 scripts/path-skip-check.py --path README.md --path docs/a.md --globs docs  # exit 2 skip",
        "python3 scripts/path-skip-check.py --paths-file pr-paths.txt"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Troubleshooting",
      "content": "- \"Luffy posted a stub instead of a review\": check the job summary for **Luffy path skip (F38)** — the PR was all-docs under `LUFFY_SKIP_PATH_GLOBS`. Re-run with `@luffy review force` to get a paid review.\n- Matching is `fnmatch`-based, so glob depth is literal: the `docs` preset ships both `docs/**` and `**/docs/**` because a top-level-only pattern will not match nested `pkg/docs/…`. Add both shapes when writing custom globs for a monorepo.\n- Extension globs in the preset are unanchored (`*.md`, `*.mdx`, `*.rst`, `*.txt`, `*.adoc`) — a `.txt` fixture inside `src/` counts as skippable, so audit `matched_n`/`sample` output before trusting the preset on a mixed repo.",
      "evidence": [
        "\"docs/**\",\n    \"**/docs/**\",",
        "DOCS_PRESET: list[str] = [\n    \"*.md\",",
        "sample=path1,path2"
      ],
      "confidence": "medium"
    }
  ]
}
```
