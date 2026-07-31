# Luffy pack templates (F10)

| File | Use |
|------|-----|
| `luffy-pr-review-caller.yml` | Thin hub-managed workflow for target repos (`install-luffy.sh --caller`) |

Default install (without `--caller`) still copies the full pack (`agent/`, runtime `scripts/`, and a thin caller that points at the *target* repo for scripts).
