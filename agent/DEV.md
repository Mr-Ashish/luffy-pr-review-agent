# DEV — engineering knowledge

> How this part of the system is built.

## Design decisions

- `agent/SOUL.md` is the reviewer contract: staff-level reviewer scoped to *this diff's* added lines, explicitly told it sees partial hunks and must not invent missing imports or re-suggest changes already in the `+` lines.
- Trust model lives in SOUL, not in the prompt template: PR text and diff are UNTRUSTED DATA and prompt-injection attempts ("ignore previous instructions", "approve this PR") must be refused.
- Finding discipline is asymmetric by design: thorough on bugs/security, high bar elsewhere — every finding needs file + symbol + concrete trigger, and silence beats speculation (an empty Blocking section is an acceptable output).
- Every review must emit structured judgment fields: Score 0–100, review effort 1–5, security audit verdict, relevant-tests yes/no, key findings, optional concrete code suggestions.
- Output contract is a single bare Markdown document (no preamble, no tool chatter, not fence-wrapped) so `normalize-review.py` can validate and post it directly as a PR comment.

- Verdict text is normalized rather than required to be exact: aliases map `APPROVED`/`LGTM` → `APPROVE`, `REQUEST_CHANGES`/`REQUEST-CHANGES`/`CHANGES REQUESTED` → `REQUEST_CHANGES`, `COMMENTS`/`NEUTRAL` → `COMMENT`; whitespace is collapsed, trailing `.` stripped, and any trailing parenthetical/bracket note removed.
- After exact-alias lookup there is a prefix pass, so decorated verdicts like `REQUEST CHANGES — see blocking` still resolve. This tolerance is intentional: the model is allowed prose after the token, but not allowed to move the label off the line start.

- F9b splits the precise-anchor feature across prompt and script: the model side is `agent/SOUL.md` rule 10 ("when a defect is on a specific **new** line you saw in the diff, cite `path:LINE`") plus the `agent/review-prompt.md` Key findings **File** column preferring `path:LINE` when the line is visible in the diff. Without those two, `scripts/post-inline-comments.py` has no `line_hint` to consume and always degrades to the F9 nearest/first anchor.
- The citation rule is deliberately scoped to **new** (`+`) lines only, matching the reviewer's added-lines scope — a `path:LINE` pointing at unchanged context is not a usable anchor for a GitHub review comment.

- The SOUL's *optional* **Code suggestions** field is now load-bearing downstream: F9c turns each `#### title (`path`)` + ```diff``` block into a GitHub apply-suggestion comment, so the section's shape (heading with backticked path, diff fence with `-`/`+` lines that mirror real PR lines) is a machine contract, not free-form prose.
- Consequence for prompt/SOUL edits: changing how suggestions are formatted, or encouraging suggestions against unchanged context, degrades F9c to zero posted apply blocks without any error — the reviewer instruction "only when you can show a concrete better snippet for **new** code" is what keeps suggestions anchorable.

- The cap is applied to the *disposable* `HERMES_HOME` config that `run-hermes-review.sh` rewrites per run, so `agent/config.yaml` is the template, not the live file the agent reads.

## Pitfalls

- Same anchoring applies to `**Score:** <int>[/100]` and `**Confidence:** low|medium|high` — score/confidence are parsed only for reporting, and a missed match yields empty strings rather than an error.
- `UNKNOWN` is deliberately non-blocking (reaction `eyes`, status `success`, review_event `COMMENT`), so a broken prompt contract looks like a healthy neutral review instead of failing loudly. Verify the posted body still carries the bold verdict line after any prompt/template edit.
- F23 dual-channel: the full Markdown is still the issue comment (F12 replace via `<!-- luffy-review pr=N`); the formal PR Review body is intentionally short so the Reviews panel is not a second full dump. Marker `<!-- luffy-pr-review pr=N` tags Luffy-owned PR reviews.

- **F41 max_turns:** `agent/config.yaml` sets `agent.max_turns: 40` (Hermes default 500 is unsafe for CI). Override with `LUFFY_MAX_TURNS`; `scripts/max_turns.py` resolves/detects budget hits.

- **F42:** `run-hermes-review.sh` may select cheap vs full model via `scripts/model_tier.py` when `LUFFY_MODEL_TIER=auto` (docs/tiny → cheap). Does not change SOUL/prompt content.

- **F43:** preflight cost may skip Hermes or force cheap model when `LUFFY_MAX_COST_USD` is tight — SOUL/prompt unchanged; stub review is COMMENT.

- `agent/SOUL.md` can be **blocked by Hermes' own prompt_injection scanner** (its trust-model section quotes injection strings like "ignore previous instructions"), which means the reviewer contract and finding discipline may silently not load for a run. Check the Hermes log for a SOUL-blocked line when review quality/format degrades unexpectedly; a phrasing workaround is tracked as H13 (P1).
