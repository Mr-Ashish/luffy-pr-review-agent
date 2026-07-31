```json
{
  "summary": "Two genuinely new areas beyond the claim index: (1) the uncommitted F8 prebaked-runner escape hatch in ensure_hermes plus the docker/ image + benchmark tooling, and (2) the mechanism-level contract of scripts/cooldown-check.sh (exit codes, fail-open, success-vs-failure comment detection, fixture/clock injection, gh --paginate multi-array pitfall). Existing F19/F7 design-level claims were not restated.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": "docker/luffy-runner",
      "action": "merge",
      "section": "Design decisions",
      "content": "- F8 prebaked runner: `ensure_hermes` in `scripts/run-hermes-review.sh` short-circuits the whole install/cache path when `LUFFY_HERMES_PREBAKED=1` **or** a `/root/.hermes-pin` / `$HOME/.hermes-pin` marker file exists *and* `hermes` is already on PATH — it just logs `command -v hermes` + `hermes --version` and returns.\n- The pin file is still resolved and written to `$OUT_DIR/hermes-pin.txt` *before* the prebaked check, so traces record the intended pin even on runs that never invoke `install.sh`.\n- Image is built from `docker/luffy-runner/Dockerfile` via `scripts/build-luffy-runner-image.sh`, published by `.github/workflows/build-luffy-runner.yml`, and its startup win is measured with `scripts/benchmark-hermes-startup.sh` — the image is the artifact that must carry the marker file, otherwise runners silently fall back to the slow cold-install path.",
      "evidence": [
        "# F8: prebaked Docker/custom runner (image sets LUFFY_HERMES_PREBAKED=1 or /.hermes-pin)",
        "if [[ \"${LUFFY_HERMES_PREBAKED:-}\" == \"1\" || -f /root/.hermes-pin || -f \"${HOME}/.hermes-pin\" ]]",
        "F8 | Prebaked Hermes runner image + startup benchmark | M | Shipped (docker/ + build workflow + benchmark script)"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Patterns",
      "content": "- Gate helpers follow a stdout-contract pattern: `scripts/cooldown-check.sh` prints `allowed=`, `reason=`, `age_s=`, `remaining_s=` key=value lines that the workflow parses straight into `$GITHUB_OUTPUT`, and signals decisions through exit codes — `0` allow, `2` cooldown active (skip paid run), `1` hard error.\n- Exit `1` is deliberately **fail-open**: the workflow logs `::warning::F19 cooldown check failed (rc=$RC); fail-open allow` and sets `allowed=true`, so a GitHub API hiccup never blocks reviews (the trade-off is it can also leak a paid run).\n- \"Successful review\" is inferred from the posted comment, not from job state: body must contain the `<!-- luffy-review pr=N` marker **and** match none of the `FAIL_SNIPPETS` (missing secret, config error, \"luffy failed to produce a review\", …), which is what makes failure stubs retryable immediately.\n- The script is designed for hermetic tests: `LUFFY_COOLDOWN_FIXTURE` supplies a JSON array of `{created_at, body}` comments (no network) and `NOW_EPOCH` pins the clock — see `tests/test_cooldown_check.py`.",
      "evidence": [
        "#   0  allow run\n#   2  cooldown active (skip paid review)\n#   1  hard error (workflow should soft-fail open → allow)",
        "FAIL_SNIPPETS = (\"luffy failed to produce a review\", \"missing required secret\", …)",
        "LUFFY_COOLDOWN_FIXTURE     path to JSON array of {created_at,body} comments (tests; no network)"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- `gh api --paginate` can emit **several concatenated JSON arrays** (one per page), so a plain `json.loads` on its output fails; `cooldown-check.sh` walks the buffer with `json.JSONDecoder().raw_decode` and extends a single list. Reuse that loop for any new paginated `gh api --jq` consumer instead of assuming one array.\n- A non-integer `LUFFY_COOLDOWN_SECONDS` is treated as **disabled** (`reason=disabled_invalid`, warning only) rather than an error — a typo in the repo variable silently removes the spend guard.\n- Clock skew is clamped, not trusted: a comment timestamp newer than `now` yields `age=0`, which means a bad clock maximises the cooldown rather than bypassing it.",
      "evidence": [
        "# gh --paginate may emit multiple JSON arrays\ndec = json.JSONDecoder()",
        "echo \"::warning::LUFFY_COOLDOWN_SECONDS='${RAW_CD}' not an integer; treating as disabled\"",
        "if age < 0:\n    age = 0"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Debugging",
      "content": "- Reproduce a cooldown decision offline (no `gh`, no network): `LUFFY_COOLDOWN_FIXTURE=/tmp/comments.json NOW_EPOCH=1753963200 bash scripts/cooldown-check.sh 1` — fixture is a JSON array of `{created_at, body}` objects; read the `allowed=`/`reason=`/`remaining_s=` lines and the exit code (0 allow, 2 skip, 1 error).\n- Force an allow while debugging without touching repo variables: `LUFFY_COOLDOWN_FORCE=1 bash scripts/cooldown-check.sh <pr>` (prints `reason=force`); on a real PR the operator-facing equivalents are `@luffy review force` and `workflow_dispatch`.\n- When a trigger comment produces a rocket reaction and no review, check the job summary section \"Luffy cooldown (F19)\" for the remaining seconds before suspecting the gate or the model.",
      "evidence": [
        "LUFFY_COOLDOWN_FORCE=1     always allow (operator override)",
        "NOW_EPOCH                  optional fixed clock for tests",
        "echo \"### Luffy cooldown (F19)\""
      ],
      "confidence": "medium"
    },
    {
      "kind": "usage",
      "path": "docker",
      "action": "merge",
      "section": "Common commands",
      "content": "- Build the prebaked Hermes runner image locally: `bash scripts/build-luffy-runner-image.sh` (source `docker/luffy-runner/Dockerfile`); CI equivalent is the **Build Luffy Runner** workflow (`.github/workflows/build-luffy-runner.yml`).\n- Measure the startup win the image is supposed to deliver: `bash scripts/benchmark-hermes-startup.sh` — compare against a cold-install job before switching `runs-on`.\n- To make a custom/self-hosted runner skip Hermes installation entirely, export `LUFFY_HERMES_PREBAKED=1` or drop a `.hermes-pin` marker at `/root/.hermes-pin` or `$HOME/.hermes-pin` with `hermes` already on PATH.",
      "evidence": [
        "docker/luffy-runner/Dockerfile",
        "?? scripts/build-luffy-runner-image.sh\n?? scripts/benchmark-hermes-startup.sh",
        "?? .github/workflows/build-luffy-runner.yml"
      ],
      "confidence": "medium"
    }
  ]
}
```
