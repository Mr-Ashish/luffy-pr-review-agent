# Dogfood showcase — Luffy F41 (Hermes max_turns)

Session: `dogfood-luffy-session` · model `anthropic/claude-opus-5` · hermes_rc=0

## Product

F41 caps Hermes tool-calling turns (default 40) and packs `loop` metrics +
`signals.max_turns_hit` into the Run Console.

## Knowledge applied

- `DEV.md` — design + pitfalls (log-string detect, bundle.loop surface)
- `agent/DEV.md` — HERMES_HOME config rewrite
- `ui/review-console/DEV.md` — Overview + Loop tab metrics
- `USAGE.md` — debugging knobs / regression gate

## Validate

`devmemory validate` → ok (warn: non-canonical USAGE H2s only)
