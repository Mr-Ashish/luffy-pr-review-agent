# Run run-20260731T224118-f42fe6

- session: `dogfood-luffy-session`
- model: `anthropic/claude-opus-5`
- hermes_rc: 0
- units: 4
- summary: The session shipped F50/H20 severity calibration: a post-review gate (scripts/severity_calibration.py) that upgrades APPROVE→REQUEST CHANGES when the review body self-reports missing/insufficient tests, gated by LUFFY_SEVERITY_CALIBRATION (default on) with a score cap of 69 and a sev-cal pack chip. Offline re-scores of the odoo e2e corpus quantify the effect (#2 36→42/50, #5 37→40/50, #4 clean no-op).
- at: 2026-07-31T17:11:50Z
- timings: {"assemble_s": 0.666, "extract_s": 30.615, "normalize_s": 0.001}
