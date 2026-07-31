# Session

- **session_id:** `dogfood-luffy-session`
- **source:** `file`
- **project:** `/Users/ashishmishra/Documents/experiments/pr-review-agent`
- **timestamp:** ``

## Transcript / notes

# Dogfood session — F47 hermes -z reliability (H14)

## What shipped
- **F47 / H14:** Stopped passing `--max-turns N` on the `hermes` CLI in `scripts/run-hermes-review.sh`.
- Hermes argparse has no `--max-turns` flag; bare `N` was parsed as a subcommand → `invalid choice: '25'` → `hermes -z` rc=2 → forced `hermes chat -q` fallback with **tool_turns=0**.
- Iteration cap still applied via Hermes-native channels only:
  - `HERMES_MAX_ITERATIONS=<n>`
  - `agent.max_turns: <n>` in `$HERMES_HOME/config.yaml`
- On CLI argv rejection (invalid choice / unrecognized arguments), skip chat fallback and write `hermes-cli-argv.env` so we do not burn a zero-tool spend path.
- Tests: `tests/test_max_turns.py` asserts hermes -z block never contains `--max-turns` / `MAX_TURNS_ARGS`.

## Evidence
- F44 local PR #2: hermes-2.stderr showed `invalid choice: '25'` then chat fallback; max_turns=25 in hermes-max-turns.env.
- Repro: `hermes -z "hello" --max-turns 25` → same argparse error; without the flag, no argparse error.

## Operator notes
- If a run falls to chat fallback again after F47, look for real hermes/install/API failures — not max-turns argv.
- Next eval: live cheap mini re-run on Mr-Ashish/odoo#2 (H16) to re-score D1/D8 with tools + F46 SOUL load.

## Corpus
- https://github.com/Mr-Ashish/odoo/pull/1
- https://github.com/Mr-Ashish/odoo/pull/2
- https://github.com/Mr-Ashish/odoo/pull/3

