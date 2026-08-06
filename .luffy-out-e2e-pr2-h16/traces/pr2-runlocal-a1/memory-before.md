# Luffy review memory (seed)

## Review craft
- Focus findings on **new code** introduced by the PR; require a concrete trigger scenario.
- Bugs/security: thorough. Style/nits: high bar or omit.
- Prefer silence over low-confidence guesses unless impact is high (data loss, security, money).
- Always fill: Score, Review effort, Security audit, Relevant tests, Key findings.
- Cite `path` / `symbol`; never dump secrets from the workspace.

## Domain notes
- Monorepos: sparse checkout may hide unrelated modules — do not invent missing symbols.
- Diff may be size-truncated; state that under What I checked and lower confidence when needed.

## Review 2026-07-31T16:00:34Z · Mr-Ashish/odoo PR #2 · luffy-eval: #276570+#275937 web getFieldsSpec + format:false

- Verdict: < APPROVE | REQUEST CHANGES | COMMENT >
- Blocking notes: - <file + issue + concrete trigger scenario, or `None`>
- (Auto-distilled; refine manually if needed)

