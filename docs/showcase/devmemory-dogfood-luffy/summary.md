# Run run-20260731T213505-5fb391

- session: `dogfood-luffy-session`
- model: `anthropic/claude-opus-5`
- hermes_rc: 0
- units: 4
- summary: F44 makes scripts/normalize-review.py a hardened trust boundary between Hermes CLI output and GitHub: it extracts the real review out of `hermes chat -q` chrome/prompt echo and rejects placeholder-verdict template echo even when every required contract snippet is present. Session also records two durable operational hazards: `hermes -z` failing into the chat fallback, and Hermes' prompt_injection scanner blocking agent/SOUL.md.
- at: 2026-07-31T16:05:46Z
- timings: {"assemble_s": 0.902, "extract_s": 39.847, "normalize_s": 0.002}
