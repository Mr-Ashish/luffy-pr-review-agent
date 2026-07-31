```json
{
  "summary": "Session adds durable knowledge about the F44 review normalizer acting as a trust boundary against Hermes chat-mode chrome and prompt-template echo, the empirical rationale for the F45 fail-closed tool_turns=0 gate, and the F46 discovery that agent/SOUL.md can be refused by Hermes' prompt_injection scanner (with the soul_context_scan workaround). Commands for verifying both are new operator knowledge.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- **F44 normalizer is a trust boundary, not a formatter.** When `hermes -z` fails and the run falls back to `hermes chat -q`, the captured stdout contains TUI chrome plus (worst case) the *echoed review prompt template*. Without stripping, Luffy would post the entire prompt as the review.\n- Snippet/fence checks alone do not prove a valid review: a prompt echo satisfies them. `scripts/normalize-review.py` therefore rejects output whose verdict line is the placeholder `**Verdict:** < APPROVE | … >` — never accept prompt echo as a satisfied contract just because the shape matches.\n- Chat-mode output may carry the verdict/summary headings *unbolded* (`Verdict:` / `Summary`); the normalizer promotes them so `parse-verdict.py` and the contract checks still match. Any new heading-emitting model style needs the same promotion, or the verdict silently degrades to `UNKNOWN`.\n- Bare `───` separator lines are **not** treated as TUI chrome: models legitimately use them between findings, so stripping them by pattern would eat review content.",
      "evidence": [
        "Rejects prompt-template echo with placeholder `**Verdict:** < APPROVE | … >`",
        "Cheap run on PR #2: hermes -z failed → chat fallback; without F44 would post full prompt",
        "Does not treat bare `───` separators as TUI chrome (models use them between findings)"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Design decisions",
      "content": "- The F45 gate exists because `tool_turns=0` on a multi-file PR is treated as a **product quality smell**, not a cost win: for an agentic reviewer, a no-tool answer means the model never read the repo beyond the diff. Measured on the Mr-Ashish/odoo luffy-eval corpus (PRs #1–#3), the earlier GHA review of PR #2 flagged real gaps (missing `format:false` tests) that the cheap no-tool mini run missed.\n- Hence the gate fail-closes rather than warns: APPROVE is downgraded to COMMENT and the score is capped at 55, so a zero-tool run cannot rubber-stamp a code change. Docs-only and single-file PRs are exempt (a no-tool read is legitimate there), and `LUFFY_TOOL_TURNS_GATE=off` is the escape hatch.",
      "evidence": [
        "tool_turns=0 on multi-file PRs is a quality smell for agentic review product",
        "GHA prior review on PR #2 had higher signal (missing format:false tests) than no-tool mini run",
        "downgrades APPROVE to COMMENT, caps score at 55, injects F45 banner"
      ],
      "confidence": "medium"
    },
    {
      "kind": "dev",
      "path": "agent",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- **Hermes' own prompt_injection threat scanner can refuse to load `agent/SOUL.md`** — the trust-model section describes injection attacks, so quoting classic injection phrasing makes SOUL.md match the scanner's patterns and the reviewer contract is dropped from context entirely (silent quality collapse, not an error).\n- F46 fix is wording, not disabling the scanner: the SOUL trust model was rephrased to state the untrusted-data rule without reproducing textbook injection strings. Keep that constraint in mind when editing the trust-model or refusal sections.\n- Detection is automated: `scripts/soul_context_scan.py` (`check` / `detect`) writes `soul-context.env`, surfaced as the `soul-blocked` pack chip — treat that chip as \"the reviewer ran without its contract\".",
      "evidence": [
        "Hermes blocks SOUL.md when it matches threat patterns (prompt_injection)",
        "Luffy rephrased agent/SOUL.md trust model to avoid quoting classic injection phrases",
        "scripts/soul_context_scan.py check/detect; soul-context.env; pack chip soul-blocked"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Debugging",
      "content": "- If a posted review looks like the review prompt itself, the run took the `hermes chat -q` fallback (`hermes -z` failed) and normalization was bypassed/stale. Re-run `python3 scripts/normalize-review.py` over `review.raw.md`: a placeholder verdict line (`**Verdict:** < APPROVE | … >`) means prompt echo and must be rejected, not published.\n- Check SOUL loadability before blaming the model for a shallow review: `python3 scripts/soul_context_scan.py check` (or `detect` on captured Hermes output) → `soul-context.env`; the `soul-blocked` chip in the run bundle means Hermes refused `agent/SOUL.md` as prompt_injection and the reviewer had no contract.\n- Cross-check zero-tool runs against a previous higher-effort review of the same PR before trusting an APPROVE; the odoo luffy-eval PRs (#1–#3) are the standing comparison corpus for cheap-vs-agentic signal.",
      "evidence": [
        "Cheap run on PR #2: hermes -z failed → chat fallback; without F44 would post full prompt",
        "scripts/soul_context_scan.py check/detect; soul-context.env; pack chip soul-blocked",
        "Multi-PR corpus on Mr-Ashish/odoo PRs #1 #2 #3 (luffy-eval titles)"
      ],
      "confidence": "medium"
    }
  ]
}
```
