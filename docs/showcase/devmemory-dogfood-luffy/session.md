# Session

- **session_id:** `dogfood-luffy-session`
- **source:** `file`
- **project:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **timestamp:** ``

## Transcript / notes

# dogfood-luffy-session

## Session notes (H22)
- Ran F49 mini e2e on Mr-Ashish/odoo#5 (POS ticket screen, port of odoo#279360).
- tool_turns recovered 0→8 via LUFFY_TOOL_TURNS_REPROMPT=1; F45 gate skipped; soul_blocked=0.
- Score 37/50; APPROVE 92; ~$0.028 · 56s; sessions 20260731_223146_62f430 → 20260731_223158_96a569.
- Corpus fully scored: #1 35, #2 GHA 40 / F49 36, #3 39, #4 F49 38, #5 F49 37.
- Next highest ROI: H20 severity calibration (missing tests blocking) or H23 sixth upstream PR.

## Shipped F50 / H20 severity calibration
- Gate: scripts/severity_calibration.py upgrades APPROVE→REQUEST CHANGES when review self-reports test gaps
- Evidence: odoo e2e #2 F49 APPROVE 95 with format:false test suggestion vs GHA REQUEST CHANGES
- Offline re-score: #2 36→42/50, #5 37→40/50 (#4 clean no-op)
- Env LUFFY_SEVERITY_CALIBRATION default on; score cap 69; pack chip sev-cal

