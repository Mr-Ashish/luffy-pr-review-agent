# Luffy review memory — `Mr-Ashish/milvus`

Cumulative notes from Luffy PR reviews (repo-local).

## Review run pr1-runlocal-a1
- Source: `Mr-Ashish/milvus` PR #1
- Status: success
- Model: openai/gpt-4.1-mini
- Verdict: COMMENT
- Blocking: - None
- Summary: This PR moves WAL insert body parsing into the `FunctionRunnerManager` and optimizes it by skipping parsing when no runner-backed functions are present in the schema. The changes affect insert message materialization paths and provide test coverage with mock insert messages in multiple test suites. The PR passes CI checks with no visible errors.
- Trigger:

---
## Local session notes
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

## Review 2026-07-31T16:29:58Z · Mr-Ashish/odoo PR #2 · luffy-eval: #276570+#275937 web getFieldsSpec + format:false

- Verdict: COMMENT
- Blocking notes: - None
- (Auto-distilled; refine manually if needed)

## Review 2026-07-31T16:39:04Z · Mr-Ashish/odoo PR #4 · luffy-eval: #279776 stock, mrp replenishment horizon PERF

- Verdict: COMMENT
- Blocking notes: - None
- (Auto-distilled; refine manually if needed)

## Review 2026-07-31T16:49:11Z · Mr-Ashish/odoo PR #2 · luffy-eval: #276570+#275937 web getFieldsSpec + format:false

- Verdict: APPROVE  
- Blocking notes: - None
- (Auto-distilled; refine manually if needed)

## Review 2026-07-31T16:54:34Z · Mr-Ashish/odoo PR #4 · luffy-eval: #279776 stock, mrp replenishment horizon PERF

- Verdict: APPROVE  
- Blocking notes: - None
- (Auto-distilled; refine manually if needed)

## Review 2026-07-31T17:02:39Z · Mr-Ashish/odoo PR #5 · luffy-eval: #279360 point_of_sale ticket screen responsiveness

- Verdict: APPROVE  
- Blocking notes: - None: No issues found that would cause correctness or security regressions based on visible new code diff. Changes are focused on frontend improvements.
- (Auto-distilled; refine manually if needed)

## Review 2026-07-31T17:22:06Z · Mr-Ashish/odoo PR #6 · luffy-eval: #279777 tools street_split regex + address fixtures

- Verdict: APPROVE  
- Blocking notes: - None
- (Auto-distilled; refine manually if needed)

## Review 2026-07-31T17:33:29Z · Mr-Ashish/odoo PR #6 · luffy-eval: #279777 tools street_split regex + address fixtures

- Verdict: APPROVE  
- Blocking notes: - None
- (Auto-distilled; refine manually if needed)

## Review 2026-07-31T18:24:18Z · Mr-Ashish/milvus PR #1 · luffy-eval: #51991 skip insert body parsing without functions

- Verdict: COMMENT  
- Blocking notes: - None
- (Auto-distilled; refine manually if needed)

## Review 2026-07-31T18:29:01Z · Mr-Ashish/milvus PR #2 · luffy-eval: #51962 raise bloom_match filter ceiling to 50M

- Verdict: APPROVE  
- Blocking notes: - None
- (Auto-distilled; refine manually if needed)

