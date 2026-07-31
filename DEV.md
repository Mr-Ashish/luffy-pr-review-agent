# DEV — engineering knowledge

> How this repository is built.

## Architecture

- Luffy is a gated GitHub Actions control plane, not a chat bot: `@luffy review this pr` → gate + per-PR concurrency → dual checkout → restore Hermes memory → assemble context → `hermes -z` → normalize → PR comment → distill memory → cache/artifacts.
- Orchestration is deterministic shell (`scripts/run-luffy-review.sh` composes stages and records timings); only the inner review step is LLM-driven, so every run leaves reproducible artifacts.
- Stage → script map: assemble-context.sh (gh pr meta + diff + prompt, no LLM), run-hermes-review.sh (Hermes one-shot over `WORKSPACE_ROOT`; F7 pin via hermes-pin.sh), normalize-review.py (contract/fences/size/HTML marker + secret redact), usage-summary.py (F21 cost footer + job summary from hermes-usage.json), parse-verdict.py + report-verdict.sh (F22 reaction/status + F23 formal PR review), distill-memory.sh, post-review-comment.sh, save-trace.sh, publish-run-to-hub.sh, hub-ingest-run.py.
- **F20/F10 install:** `scripts/install-luffy.sh` is the adoption entrypoint. Default **pack** mode copies `agent/`, runtime scripts, thin `luffy-pr-review.yml`, and `luffy-review-reusable.yml`. **`--caller`** installs only the hub-managed thin workflow from `pack/luffy-pr-review-caller.yml` (no agent/scripts). Optional `--with-hub-ingest` / `--with-runner-build` (pack mode). Stamp `.luffy-install-stamp` records `mode=pack|caller` + source SHA.
- Dual workspace separates trust domains: `luffy/` holds SOUL + prompts + scripts (from pack default branch or hub checkout), `workspace/` holds only the PR head, `.luffy-hermes-home/` holds Hermes config + growing memory.
- **F10 packaging split:** the whole review job lives in `.github/workflows/luffy-review-reusable.yml` (`on: workflow_call`, inputs `luffy_repository` / `luffy_ref`); `luffy-pr-review.yml` is a thin trigger-only caller that owns `issue_comment` / `workflow_dispatch`, concurrency and permissions, then `uses:` the reusable job.

## Design decisions

- Cost/abuse controls are layered: **F19 per-PR cooldown** (`scripts/cooldown-check.sh`, default 900s after a *successful* Luffy comment; failure stubs do not start the window; `@luffy review force` / `workflow_dispatch` / `LUFFY_COOLDOWN_SECONDS=0` bypass), author-association allowlist (default `OWNER,MEMBER,COLLABORATOR,CONTRIBUTOR`, override with repo var `LUFFY_ALLOWED_ASSOCIATIONS`, empty disables the gate), concurrency cancel-in-progress per PR, `MAX_DIFF_BYTES` (default 400000) diff cap, and a job timeout. **F21** makes spend visible on the PR comment + job summary without blocking runs.
- **F8 prebaked runner:** `ensure_hermes` short-circuits when `LUFFY_HERMES_PREBAKED=1` or `/root/.hermes-pin`/`$HOME/.hermes-pin` exists and `hermes` is on PATH (image from `docker/luffy-runner/`). Workflow optional `container: vars.LUFFY_RUNNER_IMAGE`; Hermes Actions cache is skipped when prebaked is detected.
- Hermes install is pinned for repro (F7): `scripts/hermes-pin.sh` resolves `LUFFY_HERMES_COMMIT` (default known-good SHA; `latest`/`main`/`floating`/empty = float), emits `install.sh` args (`--skip-setup --commit … --force-commit`), and supplies the Actions cache key suffix (`v4-<12-char-pin>`). Pin mismatch on a warm cache triggers reinstall.
- Re-runs replace prior Luffy comments by deleting bodies matching the `<!-- luffy-review pr=N` marker before posting; set `LUFFY_REPLACE_PREVIOUS=0` to stack instead.
- Failure UX is always-publish: missing OpenRouter secret, Hermes/model failure, and job crash before the review file each still produce a PR comment (failure stub / low-confidence COMMENT verdict) rather than a silent red X.

- The review step is agentic, not a single completion: Hermes runs with `LUFFY_TOOLSETS` (default `terminal`) so the reviewer can inspect files under `WORKSPACE_ROOT` beyond the assembled diff, and `capture-hermes-loop.py` records the tool loop.
- Observability is forced on at the env level (`HERMES_TUI_TOOL_PROGRESS=verbose`, `PYTHONUNBUFFERED=1`) so agent/tool activity is recoverable from logs even for a run that later fails.
- `HERMES_HOME` is seeded per run but `MEMORY.md` is explicitly preserved through seeding — the home directory is disposable, the memory file is not.

- `install-luffy.sh` picks the pack in two different ways on purpose: runtime scripts come from a hardcoded `RUNTIME_SCRIPTS` array (image-build/bench tooling excluded unless `--with-runner-build`), while `agent/` is enumerated dynamically (`find "$SRC/agent" -maxdepth 1 -type f`), so adding an agent file propagates automatically but adding a script does not.
- The installer copies **itself** into the target pack (`install-luffy.sh` is in `RUNTIME_SCRIPTS`), so an installed repo can re-run the install/update from its own tree; executable bits are preserved per-file (`[[ -x "$from" ]] && chmod +x`).
- Source root defaults to the parent of `scripts/` (`--source` overrides) and is validated by three presence checks — `agent/`, `scripts/`, `.github/workflows/luffy-pr-review.yml` — before any copy, so a wrong `--source` fails fast instead of half-installing.
- Installing the pack into the Luffy source tree itself (`SRC == DEST`) is refused unless `--force`, explicitly to avoid half-copies over the canonical tree.
- Exit contract: `0` ok, `1` usage/error (including refuse install into source tree without `--force`); existing target files are **skipped** (not exit 2) unless `--force`. All human output goes to **stderr** via `log()`.
- Provenance is a plain-text stamp, not a version string: `.luffy-install-stamp` records `installed_at`, `source_sha`, `source_path`, `mode=pack|caller`, and pack description.

- **F22/F23 verdict signal** is a post-post decoration: `scripts/parse-verdict.py` reads `**Verdict:**` from the posted review and maps APPROVE→`+1`/`success`/`APPROVE`, REQUEST CHANGES→`-1`/`failure`/`REQUEST_CHANGES`, COMMENT→`eyes`/`success`/`COMMENT`; pipeline_rc≠0 forces `-1`/`error`/`COMMENT` (infra fail must not look like product REQUEST CHANGES). `scripts/report-verdict.sh` applies soft reaction + commit status `luffy/review` + short formal PR Review (F23) and writes a job-summary section. Opt-outs: `LUFFY_COMMIT_STATUS=0`, `LUFFY_PR_REVIEW=0`. Required checks can require context `luffy/review`.
- **F21 cost visibility** is a post-normalize decoration, not a pipeline stage: `scripts/usage-summary.py` reads `hermes-usage.json` and exposes `footer` / `append` / `step-summary`.
- Telemetry is explicitly non-load-bearing: missing, empty, non-dict, or unparseable usage files are soft no-ops that exit 0, and `run-hermes-review.sh` calls the `append` step guarded by `[[ -f … ]]` with `|| notice "usage-summary append soft-failed"` — cost reporting can never fail a review.
- Both the PR-comment footer and the job summary are fed from the same usage file so cost is visible without downloading an artifact; number formatting is deliberately lossy/human (tokens as `1.5k`/`10k`/`1.0M`, `n/a` when a field is absent or non-numeric, booleans rejected as numbers).

- The reusable workflow declares **no `permissions:` block** — "Permissions come from the caller workflow/job", so every caller must grant `contents`/`pull-requests`/`issues`/`actions` write itself; a caller that forgets one fails at post/cache time, not at call time.
- Both reusable secrets (`OPENROUTER_API_KEY`, `LUFFY_HUB_TOKEN`) are declared `required: false` and callers are expected to use `secrets: inherit`; this keeps forks/unfunded repos from failing the `workflow_call` contract up front, with `LUFFY_HUB_TOKEN` falling back to `GITHUB_TOKEN`.
- Reusable inputs default to the hub (`luffy_repository: Mr-Ashish/luffy-pr-review-agent`, `luffy_ref: main`), so an under-specified caller still resolves to a working runtime instead of erroring.
- `install-luffy.sh` preflights **both** F10 files (`.github/workflows/luffy-review-reusable.yml` and `pack/luffy-pr-review-caller.yml`) before copying anything, so a source tree missing the reusable pair dies before producing a half-install.

## Pitfalls

- `GITHUB_TOKEN` cannot call `repository_dispatch` (HTTP 403), so the hub publish default is `mode=direct` (clone hub → ingest → push `main`); the dispatch path needs a classic PAT on the target repo.
- Cross-repo publishing requires `LUFFY_HUB_TOKEN` (PAT with contents write on the hub); only when Luffy runs on the hub repo itself is `GITHUB_TOKEN` + `contents: write` sufficient.
- PR title, body, comments, and diff are untrusted input — the agent must not honour embedded instructions, and secrets must never be echoed; `normalize-review.py` redacts `sk-or-…`, `OPENROUTER_API_KEY=…`, and common GitHub tokens before any PR comment is posted (F18); traces/hub scrub again before packaging.
- `MEMORY.md` rotates when it exceeds `MAX_MEMORY_BYTES` (default 100000); unbounded growth would otherwise blow the prompt budget.
- Historical bug classes worth watching (per the ranked ROI backlog): broken Hermes home cache key, sparse-checkout path count bug, and dishonest success reactions on failed runs.

- Default model diverges by layer: `scripts/run-hermes-review.sh` falls back to `anthropic/claude-opus-5` while the ops docs advertise `openai/gpt-5-mini` as the default. Anyone reasoning about cost from the docs alone will be wrong for local/dry runs — set `LUFFY_MODEL` explicitly instead of relying on either default.
- Pin verification degrades to a substring check: when the install tree has no `.git`, `ensure_hermes` accepts the binary if `hermes --version` merely contains the pin's first 8 chars. A cached install without git metadata can therefore pass the pin gate on weak evidence — check `hermes-pin.txt` in the trace when a run's behaviour looks off for the pinned SHA.
- `DEFAULT_HERMES_COMMIT` is hardcoded in `scripts/hermes-pin.sh` and duplicated as the workflow env fallback (`vars.LUFFY_HERMES_COMMIT || <sha>`); bumping the pin means editing both or the workflow will keep overriding the script default.

- `gh api --paginate` can emit **several concatenated JSON arrays** (one per page), so a plain `json.loads` on its output fails; `cooldown-check.sh` walks the buffer with `json.JSONDecoder().raw_decode` and extends a single list. Reuse that loop for any new paginated `gh api --jq` consumer instead of assuming one array.
- A non-integer `LUFFY_COOLDOWN_SECONDS` is treated as **disabled** (`reason=disabled_invalid`, warning only) rather than an error — a typo in the repo variable silently removes the spend guard.
- Clock skew is clamped, not trusted: a comment timestamp newer than `now` yields `age=0`, which means a bad clock maximises the cooldown rather than bypassing it.

- Re-running `install-luffy.sh` without `--force` is a silent no-op per file: `copy_file` logs `exists (skip, use --force)` and returns 0, so an *upgrade* over an already-installed repo leaves the old pack in place while the command still exits successfully. Upgrades require `--force`.
- A missing source file only warns (`WARN missing in source: $rel/$f`) and continues, so a drifted/incomplete source tree can produce a partially installed pack with exit code 0 — read the stderr log, don't trust the exit status alone.
- `RUNTIME_SCRIPTS` is a hand-maintained allowlist: any new runtime script added to `scripts/` must be appended there or target repos silently never receive it (the workflow then fails at run time, not install time).
- `agent/` is copied with `-maxdepth 1 -type f`, so nested files under `agent/` are never installed — keep agent assets flat.
- `usage()` renders help by slicing the file header (`sed -n '2,25p' "$0"`); editing or growing the top comment block silently truncates or corrupts `--help` output.

- `usage-summary.py` is textually coupled to `normalize-review.py`: `_FOOTER_RX` matches the brand footer line to anchor the cost line — edit both together.
- Re-appending is idempotent by design via `_COST_LINE_RX` (`^\*Cost / usage:.*\*$`): an existing cost line is replaced, not stacked. Rewriting that line's shape in one place breaks dedup and produces duplicated footers on re-runs.
- A missing `*Cost / usage: …*` line on a posted review is not necessarily a bug — it is the documented soft no-op when `hermes-usage.json` is absent/empty/malformed. Check the usage file before suspecting the review path.

- The `@luffy review` gate `if:` expression is duplicated in *both* the thin caller job and the reusable job. Changing the trigger phrase or association logic in one place silently no-ops (caller filters everything out) or double-gates; keep the two conditions in sync.
- Hub-managed callers point at `…/luffy-review-reusable.yml@main`, i.e. unpinned by design — a broken hub `main` breaks every `--caller` target repo at once, and there is no per-target rollback short of editing that `uses:` ref.

- F23 formal PR reviews are **additive** to the issue comment, not a replace for F12: cooldown still keys off the issue-comment marker `<!-- luffy-review pr=N`, and re-runs do not dismiss prior PR reviews (they stack in the Reviews panel). If review noise becomes a problem, add dismiss-previous or set `LUFFY_PR_REVIEW=0`.
- GitHub often rejects `APPROVE` when the actor is the PR author or org policy forbids bot approves — `report-verdict.sh` soft-falls back to `COMMENT` so the Reviews panel still gets a row; do not treat missing green check as a pipeline failure.
- Pipeline failures map to `review_event=COMMENT` on purpose: an OpenRouter outage must not show as "Changes requested" on the product.

## Patterns

- Secret scrubbing is a single choke-point helper (`redact_secrets()` in `scripts/normalize-review.py`) driven by one `_SECRET_PATTERNS` table: `sk-or-v1-…`, `OPENROUTER_API_KEY=…`, generic `api_key`-style assignments, `gh[pousr]_…`, and `github_pat_…`.
- It is applied **twice per run**: once after `strip_outer_fence` (so the `### Raw agent output` contract-failure fallback is scrubbed too) and again after `ensure_contract` (so repair/templating cannot reintroduce a leak). Adding new output paths in `normalize-review.py` means re-checking both call sites.
- Redaction patterns are intentionally duplicated-but-aligned across `normalize-review.py`, `scripts/save-trace.sh`, and `scripts/build-hub-payload.py`; when a pattern is added to one, add it to all three or posted comments, traces, and hub payloads drift apart in scrub policy.
- Redaction is enforced mechanically at the post step, not delegated to the model: `agent/SOUL.md`'s "never echo secrets" rule remains the intent, but the guarantee lives in the normalize stage.
- Regression tests in `tests/test_normalize_review.py` assert the leaked literal is absent *and* the placeholder (`[OPENROUTER_KEY_REDACTED]` / `[GITHUB_TOKEN_REDACTED]`) is present, including in the broken-output fallback case — copy that both-sided assertion shape for any new pattern.

- `scripts/hermes-pin.sh` is a pure, network-free resolver with a 5-verb CLI (`resolve`, `install-args`, `matches <head>`, `cache-suffix`, `default`); every consumer (workflow step, `run-hermes-review.sh`) calls it instead of re-deriving pin logic, so the pin lives in exactly one place.
- Pin comparison is prefix-tolerant in both directions (`head == pin*` or `pin == head*`), so short and full SHAs interoperate; no pin means `matches` always succeeds (floating mode is a no-op gate).
- `cache-suffix` truncates the pin to 12 chars (or prints `latest` when floating) purely to keep the Actions cache key readable — cache keys are derived, never hand-written.
- `ensure_hermes` in `run-hermes-review.sh` verifies an already-present binary before trusting it: probe `~/.hermes/hermes-agent`, `$HERMES_INSTALL_DIR`, `~/.local/share/hermes-agent` for a `.git` HEAD; on mismatch it reinstalls rather than silently reviewing with the wrong build.
- After any install the script re-exports PATH, sources `~/.bashrc`, runs `hash -r`, then probes `~/.local/bin/hermes`, `~/.hermes/bin/hermes`, `~/.hermes/hermes` — installer layout is treated as unstable, so the binary is located by search, not assumption.

- Gate helpers follow a stdout-contract pattern: `scripts/cooldown-check.sh` prints `allowed=`, `reason=`, `age_s=`, `remaining_s=` key=value lines that the workflow parses straight into `$GITHUB_OUTPUT`, and signals decisions through exit codes — `0` allow, `2` cooldown active (skip paid run), `1` hard error.
- Exit `1` is deliberately **fail-open**: the workflow logs `::warning::F19 cooldown check failed (rc=$RC); fail-open allow` and sets `allowed=true`, so a GitHub API hiccup never blocks reviews (the trade-off is it can also leak a paid run).
- The script is designed for hermetic tests: `LUFFY_COOLDOWN_FIXTURE` supplies a JSON array of `{created_at, body}` comments (no network) and `NOW_EPOCH` pins the clock — see `tests/test_cooldown_check.py`.
