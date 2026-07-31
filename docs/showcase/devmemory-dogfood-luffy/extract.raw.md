```json
{
  "summary": "New durable knowledge is the F36 review wall-clock timeout: scripts/run-with-timeout.py wraps hermes -z (and the chat fallback) as a process group with a 1500s default, exits 124, discards partial output and skips the fallback to avoid double spend, plus its CLI/trace surface. Everything else in the session (F35 footer, F9/F9b anchors, F28 local memory, packaging, SOUL contract) restates the existing claim index.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Design decisions",
      "content": "- **F36 review timeout:** `scripts/run-with-timeout.py` wraps `hermes -z` (and the chat fallback) as a child **process group** and kills it after a wall-clock limit, so a hung agent/OpenRouter loop cannot burn the full job cap (GHA 90m / Modal ~25m). Default `LUFFY_REVIEW_TIMEOUT_SECONDS=1500`; `0`/`off`/`false`/`no` disables.\n- Timeout semantics are deliberately conservative: exit code **124** (GNU `timeout` convention), partial model output is **discarded**, and the chat fallback is **skipped** — retrying after a timeout would double the spend that the limit exists to cap. The run then posts an honest COMMENT failure stub plus a job-summary section **Luffy review timeout (F36)**.\n- The helper never rewrites the child's exit code except timeout→124 (`125` is reserved for invalid usage / empty command), so normal Hermes failures still surface unchanged upstream.\n- F36 and F29 are complementary, not overlapping: F29's soft `LUFFY_MAX_COST_USD` annotates a run that already *finished*, while F36 is the only mechanism that stops a run that never finishes.\n- Timeout evidence lands in the trace as `hermes-timeout.env` and `hermes-timeout-seconds.txt`, so a 124 can be distinguished from a model/contract failure after the fact.",
      "evidence": [
        "F36: portable wall-clock timeout for a child process group.",
        "124 on wall-clock timeout (GNU `timeout` convention)",
        "partial model output discarded, chat fallback **skipped** (would double spend)",
        "Complements F29 (soft $ budget annotates after a finished run; F36 stops a hung loop)."
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Common commands",
      "content": "- Show the effective review timeout (resolves `LUFFY_REVIEW_TIMEOUT_SECONDS`, else the 1500s default): `python3 scripts/run-with-timeout.py resolve`.\n- Self-check the killer without spending on a model: `python3 scripts/run-with-timeout.py --seconds 2 -- sleep 10` → exits **124**.\n- Both `--seconds N -- cmd …` and the positional `N -- cmd …` forms are accepted; regression coverage is `tests/test_run_with_timeout.py`.\n- Override per repo with `vars.LUFFY_REVIEW_TIMEOUT_SECONDS`; set `0` or `off` to disable the timeout entirely.",
      "evidence": [
        "python3 scripts/run-with-timeout.py resolve          # effective seconds",
        "python3 scripts/run-with-timeout.py --seconds 2 -- sleep 10   # exits 124",
        "python3 scripts/run-with-timeout.py 1500 -- cmd [args...]"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Troubleshooting",
      "content": "- A review that comes back as a COMMENT failure stub with **no findings** is often an F36 timeout, not a bad model run: check the job summary for **Luffy review timeout (F36)** and the trace for `hermes-timeout.env` / `hermes-timeout-seconds.txt` before blaming the prompt or contract.\n- After a timeout there is intentionally no chat-fallback review body — do not read the missing fallback as a broken fallback path.\n- If long PRs legitimately need more wall time, raise `LUFFY_REVIEW_TIMEOUT_SECONDS` rather than disabling it; on Modal the 1500s default is already aligned with the `review_pr` hard cap, so a larger value will be cut off by the host instead.",
      "evidence": [
        "job summary section **Luffy review timeout (F36)**. Trace: `hermes-timeout.env`, `hermes-timeout-seconds.txt`.",
        "Align with Modal review_pr hard cap (~25m). 0 = disabled."
      ],
      "confidence": "medium"
    },
    {
      "kind": "dev",
      "path": "modal_app",
      "action": "merge",
      "section": "Design decisions",
      "content": "- The F36 default of **1500s** is chosen to sit just under Modal's `review_pr` hard cap (~25m) rather than under the GHA job cap (90m) — the tighter host sets the shared default, so the same number is safe on both. Changing `DEFAULT_SECONDS` in `scripts/run-with-timeout.py` without re-checking the Modal function timeout would let a Modal run be killed by the platform instead of by the helper (losing the honest 124 stub and job-summary section).",
      "evidence": [
        "# Align with Modal review_pr hard cap (~25m). 0 = disabled.",
        "default **1500s** (aligned with Modal hard cap)",
        "full job timeout (GHA 90m / Modal 25m)"
      ],
      "confidence": "medium"
    }
  ]
}
```
