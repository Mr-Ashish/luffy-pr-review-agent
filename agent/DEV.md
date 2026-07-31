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

## Pitfalls

- The F22/F23 signal depends on a *textual* contract with the model output, not a structured field: `scripts/parse-verdict.py` matches `^\*\*Verdict:\*\*\s*(.+)$` (MULTILINE, case-insensitive), so the verdict must be a bold `**Verdict:**` label at the start of a line in the normalized body. Reformatting that line in `agent/review-prompt.md` (plain text, inline, indented, inside a fence) silently degrades every run to `UNKNOWN` (and F23 posts a neutral COMMENT review event).
- Same anchoring applies to `**Score:** <int>[/100]` and `**Confidence:** low|medium|high` — score/confidence are parsed only for reporting, and a missed match yields empty strings rather than an error.
- `UNKNOWN` is deliberately non-blocking (reaction `eyes`, status `success`, review_event `COMMENT`), so a broken prompt contract looks like a healthy neutral review instead of failing loudly. Verify the posted body still carries the bold verdict line after any prompt/template edit.
- F23 dual-channel: the full Markdown is still the issue comment (F12 replace via `<!-- luffy-review pr=N`); the formal PR Review body is intentionally short so the Reviews panel is not a second full dump. Marker `<!-- luffy-pr-review pr=N` tags Luffy-owned PR reviews.
- F24 dismisses prior Luffy formal reviews with that marker (APPROVED/CHANGES_REQUESTED only) before posting a new one; COMMENTED cannot be dismissed by GitHub.
