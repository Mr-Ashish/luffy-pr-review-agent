# Odoo multi-PR e2e learn log

Target fork: [Mr-Ashish/odoo](https://github.com/Mr-Ashish/odoo) (upstream odoo/odoo).  
Local clone: `/Users/ashishmishra/Documents/experiments/odoo` → `odoo-luffy-e2e`.  
Luffy SoT: this repo only.

## Corpus (luffy-eval PRs)

| PR | Title | Upstream | Files | +/− | Status |
|----|-------|----------|------|-----|--------|
| [#1](https://github.com/Mr-Ashish/odoo/pull/1) | luffy-eval: #273306 website_cf_turnstile form callback guards | odoo#273306 / PR ~279479 | 1 JS | +12/−5 | OPEN |
| [#2](https://github.com/Mr-Ashish/odoo/pull/2) | luffy-eval: #276570+#275937 web getFieldsSpec + format:false | issues 276570, 275937 | 4 (JS+test) | +85/−9 | OPEN |
| [#3](https://github.com/Mr-Ashish/odoo/pull/3) | luffy-eval: #271153 tools Unicode XML control-char strip | odoo#271153 | 3 (py+test) | +88/−18 | OPEN |

Corpus size: **3** open eval PRs (retitled F44 fire).

## Runs

| When | PR | Run id | Model | Host | Notes |
|------|----|--------|-------|------|-------|
| 2026-07-30 | #1 | GHA 30558836212, 30559624590 | (workflow default) | Actions | REQUEST CHANGES — successCb null race |
| 2026-07-30 | #2 | GHA 30560489187 | (workflow default) | Actions | REQUEST CHANGES — missing format:false tests |
| 2026-07-30/31 | #3 | local + showcase | openai/gpt-4.1-mini + opus showcase | local | APPROVE 90; agentic-loop showcase |
| **2026-07-31 F44** | **#2** | **local / pr2-runlocal-a1** | **openai/gpt-4.1-mini** | local | hermes -z failed → chat -q; tool_turns=0; SOUL.md blocked as prompt_injection; raw polluted with Query+template; **F44 normalizer** extracts real body → APPROVE 90 (weaker than GHA: missed missing alias tests) |
| **2026-07-31 F45** | **#2** | **offline gate on F44 body** | n/a (post-process) | local | **H12/F45** re-apply: tool_turns=0 + 4 files → **APPROVE→COMMENT**, score 55, F45 banner; no new Hermes spend |

Artifacts: `.luffy-out-e2e-pr2-f44/` (review, raw, run-bundle, traces/pr2-runlocal-a1); F45 offline: `/tmp/f45-pr2-review-gated.md`.

## Introspect (F46)

1. **Root cause of SOUL block:** Hermes `threat_patterns` `prompt_injection` matched the literal quote `ignore previous instructions` in the trust-model examples — not a malicious SOUL.
2. **Fix is phrasing + regression scan:** product SOUL now clean under Hermes `scan_for_threats(scope=context)`; `soul_context_scan.py check` guards future regressions.
3. **Next P0:** H14 hermes `-z` reliability (chat fallback still forces F44 scrub + F45 gate path).

## Introspect (F45)

1. **Fail-closed without re-prompt is correct first step:** prevents false merge-green on zero-tool multi-file runs; does not invent the missing test finding (still needs tools / H14).
2. **Trust/ops win over signal quality:** D4/D9 improve via honesty; D1 still limited until agent actually reads files.
3. **Was next P0:** H13 SOUL.md prompt_injection — **shipped F46**.

## Introspect (F44)

1. **Chat fallback pollution (P0, fixed F44):** `hermes chat -q` echoes full prompt (including Markdown *template* with every required snippet). Pre-F44 normalizer treated that as contract-OK and would post the prompt to GitHub.
2. **Signal regression on cheap no-tool run:** GHA run correctly blocked on missing format-alias tests; gpt-4.1-mini with 0 tool turns APPROVE’d with medium “expand to other field types” noise instead.
3. **SOUL blocked:** hermes log `Context file SOUL.md blocked: prompt_injection` — review discipline may not load.
4. **Pin reinstall tax:** hermes pin mismatch forced full reinstall (~1–2 min) before the agent loop.
5. **Verdict parse** depends on `**Verdict:**`; chat mode often emits unbolded `Verdict:` — F44 promotes loose headings.

## Introspect (F47 / H14)

1. **Root cause of hermes -z rc=2:** Luffy passed `--max-turns N` on the hermes CLI. Hermes has **no** such argparse flag; bare `N` is parsed as subcommand → `invalid choice: '25'` → exit 2 before any model call.
2. **Why chat fallback looked "successful" but tool_turns=0:** `hermes chat -q` accepts the bad argv more leniently (or ignores it) and runs a non-agentic single-shot with no workspace tools.
3. **Fix:** F47 removes CLI `--max-turns`; cap remains via `HERMES_MAX_ITERATIONS` + `agent.max_turns` config rewrite (Hermes-native). On CLI argv rejection, skip chat fallback (`hermes-cli-argv.env`) so we do not double-spend a zero-tool path.
4. **Next:** H16 live mini re-run on #2 to confirm tool_turns>0 + SOUL loads (F46) and re-score D1/D8.

## Next learn targets

- H16: Live re-score #2 mini after F47 (-z tools + F46 SOUL).
- H15: optional one-shot re-prompt after F45 annotate (recover findings without always COMMENT-only).
- Corpus maintain ≥3; optional 4th complex upstream PR when idle.
