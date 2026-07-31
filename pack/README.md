# Luffy pack templates (F10)

| File | Use |
|------|-----|
| `luffy-pr-review-caller.yml` | Thin hub-managed workflow for target repos (`install-luffy.sh --caller`) |

Default install (without `--caller`) still copies the full pack (`agent/`, runtime `scripts/`, and a thin caller that points at the *target* repo for scripts).

## Memory (F28)

Pack install seeds **`.luffy/MEMORY.md`** on the target. After each review Luffy commits a slim run pack under `.luffy/runs/{trace_id}/` on the target default branch (`contents: write`). Hub memory is optional (`LUFFY_MEMORY_MODE=both|hub` or `LUFFY_HUB_PUBLISH=1`). Fat traces remain Actions artifacts only.
