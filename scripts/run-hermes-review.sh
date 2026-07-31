#!/usr/bin/env bash
# Run Hermes one-shot review with detailed agent-loop capture.
#
# Env:
#   OPENROUTER_API_KEY
#   LUFFY_ROOT, HERMES_HOME, WORKSPACE_ROOT
#   OUT_DIR, PROMPT_PATH (or meta.env)
#   LUFFY_MODEL / OPENROUTER_MODEL  (default: DEFAULT_LUFFY_MODEL below — F26 SoT)
#   LUFFY_TOOLSETS  (optional hermes -t value; default: terminal for workspace tools)
#   LUFFY_HERMES_COMMIT  pin SHA (default in hermes-pin.sh); empty/latest/main = floating
#   LUFFY_REVIEW_TIMEOUT_SECONDS  F36 wall-clock for hermes (default 1500; 0/off disables)
#   LUFFY_MAX_TURNS  F41 Hermes tool-iteration cap (default 40; 0/off = Hermes default ~500)
#   LUFFY_MODEL_TIER  F42 off|auto|cheap|full (default off) — auto picks cheap model for tiny/docs PRs
#   LUFFY_MODEL_CHEAP / LUFFY_MODEL_FULL  F42 tier models (defaults gpt-4.1-mini / opus-5)
#   LUFFY_MAX_COST_USD  F29 soft + F43 hard preflight threshold when set
#   LUFFY_PREFLIGHT_COST  F43 on|off|auto (default auto=hard when budget set)
#   LUFFY_PREFLIGHT_ACTION  F43 force_cheap|refuse|warn (default force_cheap)
#   PR_NUMBER
set -euo pipefail

log() { echo "$*" >&2; }
notice() { echo "::notice::$*" >&2; log "$*"; }
die() { echo "::error::$*" >&2; exit 1; }

: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY is required}"

# F26: single source of truth for the unpaid-default model id.
# OPERATIONS.md / USAGE.md / README / .env.example must match this string.
# Override per-repo with vars.LUFFY_MODEL (e.g. openai/gpt-5-mini) to cut cost.
DEFAULT_LUFFY_MODEL="anthropic/claude-opus-5"

LUFFY_ROOT="${LUFFY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
OUT_DIR="${OUT_DIR:-$LUFFY_ROOT/.luffy-out}"
HERMES_HOME="${HERMES_HOME:-$LUFFY_ROOT/.luffy-hermes-home}"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$LUFFY_ROOT}"
MODEL="${LUFFY_MODEL:-${OPENROUTER_MODEL:-$DEFAULT_LUFFY_MODEL}}"
TOOLSETS="${LUFFY_TOOLSETS:-terminal}"
PIN_HELPER="$LUFFY_ROOT/scripts/hermes-pin.sh"
MODEL_TIER_HELPER="$LUFFY_ROOT/scripts/model_tier.py"

mkdir -p "$OUT_DIR" "$HERMES_HOME/memories" "$HERMES_HOME/logs"

if [[ -f "$OUT_DIR/meta.env" ]]; then
  # shellcheck disable=SC1091
  source "$OUT_DIR/meta.env"
fi

PROMPT_PATH="${PROMPT_PATH:-$OUT_DIR/prompt.md}"
PR_NUMBER="${PR_NUMBER:-unknown}"
[[ -f "$PROMPT_PATH" ]] || die "Missing prompt: $PROMPT_PATH"

# ---------------------------------------------------------------------------
# F42: auto model tier by PR size (opt-in LUFFY_MODEL_TIER=auto)
# ---------------------------------------------------------------------------
MODEL_TIER_MODE="${LUFFY_MODEL_TIER:-off}"
MODEL_TIER_SELECTED="default"
MODEL_TIER_REASON="default_full"
if [[ -f "$MODEL_TIER_HELPER" ]]; then
  _tier_args=(select)
  [[ -n "${DIFF_SIZE:-}" ]] && _tier_args+=(--diff-bytes "$DIFF_SIZE")
  [[ -n "${FILE_COUNT:-}" ]] && _tier_args+=(--file-count "$FILE_COUNT")
  [[ -n "${DIFF_TRUNCATED:-}" ]] && _tier_args+=(--diff-truncated "$DIFF_TRUNCATED")
  [[ -f "${PR_JSON_PATH:-}" ]] && _tier_args+=(--pr-json "$PR_JSON_PATH")
  [[ -f "$OUT_DIR/meta.env" ]] && _tier_args+=(--meta "$OUT_DIR/meta.env")
  [[ -f "$OUT_DIR/files.txt" ]] && _tier_args+=(--paths-file "$OUT_DIR/files.txt")
  _tier_out="$(
    python3 "$MODEL_TIER_HELPER" "${_tier_args[@]}" 2>/dev/null || true
  )"
  if [[ -n "$_tier_out" ]]; then
    _m="$(printf '%s\n' "$_tier_out" | awk -F= '/^model=/{print substr($0,7); exit}')"
    _t="$(printf '%s\n' "$_tier_out" | awk -F= '/^tier=/{print $2; exit}')"
    _r="$(printf '%s\n' "$_tier_out" | awk -F= '/^reason=/{print $2; exit}')"
    _mode="$(printf '%s\n' "$_tier_out" | awk -F= '/^mode=/{print $2; exit}')"
    if [[ -n "$_m" ]]; then
      MODEL="$_m"
    fi
    MODEL_TIER_SELECTED="${_t:-$MODEL_TIER_SELECTED}"
    MODEL_TIER_REASON="${_r:-$MODEL_TIER_REASON}"
    MODEL_TIER_MODE="${_mode:-$MODEL_TIER_MODE}"
  fi
fi
# Export so hermes + capture see the effective model
export LUFFY_MODEL="$MODEL"
export OPENROUTER_MODEL="$MODEL"
# Trace/debug: record effective model (override, tier, or default)
printf '%s\n' "$MODEL" >"$OUT_DIR/luffy-model.txt" || true
{
  echo "mode=$MODEL_TIER_MODE"
  echo "tier=$MODEL_TIER_SELECTED"
  echo "reason=$MODEL_TIER_REASON"
  echo "model=$MODEL"
  echo "diff_bytes=${DIFF_SIZE:-}"
  echo "file_count=${FILE_COUNT:-}"
} >"$OUT_DIR/model-tier.env" || true
if [[ "$MODEL_TIER_MODE" == "auto" || "$MODEL_TIER_MODE" == "cheap" || "$MODEL_TIER_MODE" == "full" ]]; then
  notice "F42 model tier · mode=$MODEL_TIER_MODE tier=$MODEL_TIER_SELECTED reason=$MODEL_TIER_REASON model=$MODEL"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      echo "### Luffy model tier (F42)"
      echo "- **Mode:** \`$MODEL_TIER_MODE\` · **tier:** \`$MODEL_TIER_SELECTED\` · **reason:** \`$MODEL_TIER_REASON\`"
      echo "- **Model:** \`$MODEL\`"
      echo "- Opt-in: \`vars.LUFFY_MODEL_TIER=auto\` (cheap for tiny/docs; full otherwise)"
      echo
    } >>"$GITHUB_STEP_SUMMARY" || true
  fi
fi

# ---------------------------------------------------------------------------
# F43: hard preflight spend estimate (before Hermes / OpenRouter)
# ---------------------------------------------------------------------------
PREFLIGHT_HELPER="$LUFFY_ROOT/scripts/preflight_cost.py"
PREFLIGHT_DECISION="allow"
PREFLIGHT_REASON="skipped"
PREFLIGHT_EST=""
PREFLIGHT_REFUSED=0
PREFLIGHT_FORCED_CHEAP=0
if [[ -f "$PREFLIGHT_HELPER" ]]; then
  _pf_args=(decide --model "$MODEL" --diff-bytes "${DIFF_SIZE:-0}" --file-count "${FILE_COUNT:-0}")
  [[ -n "${LUFFY_MAX_COST_USD:-}" ]] && _pf_args+=(--max-usd "$LUFFY_MAX_COST_USD")
  [[ -n "${LUFFY_PREFLIGHT_COST:-}" ]] && _pf_args+=(--mode "$LUFFY_PREFLIGHT_COST")
  [[ -n "${LUFFY_PREFLIGHT_ACTION:-}" ]] && _pf_args+=(--action "$LUFFY_PREFLIGHT_ACTION")
  [[ -n "${LUFFY_MODEL_CHEAP:-}" ]] && _pf_args+=(--cheap-model "$LUFFY_MODEL_CHEAP")
  [[ -n "${LUFFY_MAX_TURNS:-}" ]] && _pf_args+=(--max-turns "$LUFFY_MAX_TURNS")
  set +e
  _pf_out="$(python3 "$PREFLIGHT_HELPER" "${_pf_args[@]}" 2>/dev/null)"
  _pf_rc=$?
  set -e
  if [[ -n "$_pf_out" ]]; then
    PREFLIGHT_DECISION="$(printf '%s\n' "$_pf_out" | awk -F= '/^decision=/{print $2; exit}')"
    PREFLIGHT_REASON="$(printf '%s\n' "$_pf_out" | awk -F= '/^reason=/{print $2; exit}')"
    PREFLIGHT_EST="$(printf '%s\n' "$_pf_out" | awk -F= '/^estimated_usd=/{print $2; exit}')"
    _pf_model="$(printf '%s\n' "$_pf_out" | awk -F= '/^model=/{print substr($0,7); exit}')"
    _pf_forced="$(printf '%s\n' "$_pf_out" | awk -F= '/^forced_cheap=/{print $2; exit}')"
    _pf_refused="$(printf '%s\n' "$_pf_out" | awk -F= '/^refused=/{print $2; exit}')"
    if [[ "$_pf_forced" == "true" && -n "$_pf_model" ]]; then
      MODEL="$_pf_model"
      export LUFFY_MODEL="$MODEL"
      export OPENROUTER_MODEL="$MODEL"
      printf '%s\n' "$MODEL" >"$OUT_DIR/luffy-model.txt" || true
      PREFLIGHT_FORCED_CHEAP=1
      # Reflect forced cheap in model-tier.env
      {
        echo "mode=${MODEL_TIER_MODE:-off}"
        echo "tier=cheap"
        echo "reason=f43_preflight_force_cheap"
        echo "model=$MODEL"
        echo "diff_bytes=${DIFF_SIZE:-}"
        echo "file_count=${FILE_COUNT:-}"
      } >"$OUT_DIR/model-tier.env" || true
    fi
    if [[ "$_pf_refused" == "true" || "$_pf_rc" -eq 2 ]]; then
      PREFLIGHT_REFUSED=1
    fi
  fi
  # Always persist telemetry
  {
    printf '%s\n' "$_pf_out"
    echo "preflight_rc=${_pf_rc:-0}"
  } >"$OUT_DIR/preflight-cost.env" || true
  notice "F43 preflight cost · decision=${PREFLIGHT_DECISION:-?} reason=${PREFLIGHT_REASON:-?} est=\$${PREFLIGHT_EST:-?} model=$MODEL"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      echo "### Luffy preflight cost (F43)"
      echo "- **Decision:** \`${PREFLIGHT_DECISION:-?}\` · **reason:** \`${PREFLIGHT_REASON:-?}\`"
      echo "- **Estimate:** \~$\`${PREFLIGHT_EST:-n/a}\` · model \`$MODEL\`"
      echo "- Budget: \`vars.LUFFY_MAX_COST_USD\` · action \`vars.LUFFY_PREFLIGHT_ACTION\` (default force_cheap)"
      echo
    } >>"$GITHUB_STEP_SUMMARY" || true
  fi
fi

if [[ "$PREFLIGHT_REFUSED" -eq 1 ]]; then
  notice "F43 preflight REFUSED paid Hermes (est=\$${PREFLIGHT_EST:-?} > budget) — writing stub review"
  _pf_summary="Luffy **preflight cost gate (F43)** refused the paid Hermes run. Estimated spend ~\$${PREFLIGHT_EST:-?} (model was headed for premium tokens on a large PR) exceeds \`LUFFY_MAX_COST_USD\`. No OpenRouter agent loop was started."
  _pf_blocking="Raise \`LUFFY_MAX_COST_USD\`, set \`LUFFY_PREFLIGHT_ACTION=warn\`, force with \`LUFFY_PREFLIGHT_FORCE=1\` / \`@luffy review force\`, use a cheaper \`LUFFY_MODEL\`, or shrink the PR."
  cat >"$OUT_DIR/review-${PR_NUMBER}.md" <<EOF
<!-- luffy-review pr=${PR_NUMBER} -->
## 🏴‍☠️ Luffy Review — PR #${PR_NUMBER}

**Verdict:** COMMENT
**Confidence:** low

### Summary
${_pf_summary}

### Blocking
- ${_pf_blocking}

### Suggestions
- Split the PR or enable \`LUFFY_MODEL_TIER=auto\` / a cheap model for large diffs
- Or raise the soft/hard budget via \`vars.LUFFY_MAX_COST_USD\`

### Nits
- None

### Tests & risk
- Coverage: n/a (preflight refuse — no agent review)
- Risk: unknown (review skipped to protect spend)
- Rollback: n/a

### What I checked
- F43 preflight cost estimate only (diff bytes + model rate proxy)
- Reason: \`${PREFLIGHT_REASON:-refused}\`

---
*Luffy · Hermes Agent · OpenRouter · memory-backed review · F43 preflight refuse*
*Cost / usage: model=\`none\` · ~\$0 (preflight refuse) · budget gate*
EOF
  # Also raw for any consumers expecting it
  cp -f "$OUT_DIR/review-${PR_NUMBER}.md" "$OUT_DIR/review-${PR_NUMBER}.raw.md" 2>/dev/null || true
  printf '0\n' >"$OUT_DIR/hermes-skipped.txt" || true
  echo "skip=preflight_cost" >>"$OUT_DIR/preflight-cost.env" || true
  notice "F43 stub review written; skipping Hermes install + agent loop"
  exit 0
fi

export HERMES_HOME
export OPENROUTER_API_KEY
export PATH="${HOME}/.local/bin:${HOME}/.hermes/bin:${PATH}"
# Encourage verbose file logging for agent/tool activity
export HERMES_TUI_TOOL_PROGRESS="${HERMES_TUI_TOOL_PROGRESS:-verbose}"
export PYTHONUNBUFFERED=1

# ---------------------------------------------------------------------------
# F7: Ensure Hermes (pinned install; path cached by workflow when possible)
# ---------------------------------------------------------------------------
_hermes_install_head() {
  local d
  for d in \
    "${HOME}/.hermes/hermes-agent" \
    "${HERMES_INSTALL_DIR:-}" \
    "${HOME}/.local/share/hermes-agent"; do
    [[ -n "$d" && -d "$d/.git" ]] || continue
    git -C "$d" rev-parse HEAD 2>/dev/null && return 0
  done
  return 1
}

ensure_hermes() {
  export PATH="${HOME}/.local/bin:${HOME}/.hermes/bin:${PATH}"
  chmod +x "$PIN_HELPER" 2>/dev/null || true

  local pin head
  pin="$("$PIN_HELPER" resolve 2>/dev/null | tr -d '\n' || true)"
  printf '%s\n' "${pin:-floating}" >"$OUT_DIR/hermes-pin.txt" || true

  # F8: prebaked Docker/custom runner (image sets LUFFY_HERMES_PREBAKED=1 or /.hermes-pin)
  if [[ "${LUFFY_HERMES_PREBAKED:-}" == "1" || -f /root/.hermes-pin || -f "${HOME}/.hermes-pin" ]] \
    && command -v hermes >/dev/null 2>&1; then
    notice "hermes prebaked runner: $(command -v hermes)"
    hermes --version 2>/dev/null || true
    return
  fi

  if command -v hermes >/dev/null 2>&1; then
    head="$(_hermes_install_head || true)"
    if [[ -z "$pin" ]]; then
      notice "hermes (cached/present, floating): $(command -v hermes)"
      hermes --version 2>/dev/null || true
      return
    fi
    if "$PIN_HELPER" matches "$head"; then
      notice "hermes (cached/present, pin=$pin head=${head:-unknown}): $(command -v hermes)"
      hermes --version 2>/dev/null || true
      return
    fi
    # Version string may still mention short pin when git dir missing
    local ver
    ver="$(hermes --version 2>/dev/null || true)"
    if [[ -n "$ver" && "$ver" == *"${pin:0:8}"* ]]; then
      notice "hermes version matches pin ${pin:0:8}: $(command -v hermes)"
      return
    fi
    notice "hermes present but pin mismatch (want $pin head=${head:-n/a}); reinstalling..."
  else
    notice "Installing Hermes Agent (cold, pin=${pin:-floating})..."
  fi

  local args
  # shellcheck disable=SC2207
  args=( $("$PIN_HELPER" install-args) )
  notice "hermes install.sh args: ${args[*]}"
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- "${args[@]}"
  export PATH="${HOME}/.local/bin:${HOME}/.hermes/bin:${PATH}"
  # shellcheck disable=SC1091
  [[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc" || true
  hash -r 2>/dev/null || true
  for candidate in \
    "${HOME}/.local/bin/hermes" \
    "${HOME}/.hermes/bin/hermes" \
    "${HOME}/.hermes/hermes"; do
    if [[ -x "$candidate" ]]; then
      export PATH="$(dirname "$candidate"):${PATH}"
      break
    fi
  done
  command -v hermes >/dev/null 2>&1 || die "hermes not found after install"
  head="$(_hermes_install_head || true)"
  notice "hermes installed: $(command -v hermes) head=${head:-unknown} pin=${pin:-floating}"
  hermes --version 2>/dev/null || true
}

ensure_hermes

# ---------------------------------------------------------------------------
# Seed HERMES_HOME (preserve growing MEMORY.md)
# ---------------------------------------------------------------------------
cp -f "$LUFFY_ROOT/agent/config.yaml" "$HERMES_HOME/config.yaml"
cp -f "$LUFFY_ROOT/agent/SOUL.md" "$HERMES_HOME/SOUL.md"
umask 077
cat >"$HERMES_HOME/.env" <<EOF
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
EOF

if [[ ! -f "$HERMES_HOME/memories/MEMORY.md" ]]; then
  if [[ -f "$LUFFY_ROOT/agent/MEMORY.seed.md" ]]; then
    cp -f "$LUFFY_ROOT/agent/MEMORY.seed.md" "$HERMES_HOME/memories/MEMORY.md"
  else
    printf '# Luffy review memory\n\n' >"$HERMES_HOME/memories/MEMORY.md"
  fi
fi

PROMPT="$(cat "$PROMPT_PATH")"
RAW_OUT="$OUT_DIR/review-${PR_NUMBER}.raw.md"
STDERR_FILE="$OUT_DIR/hermes-${PR_NUMBER}.stderr"
FINAL_OUT="$OUT_DIR/review-${PR_NUMBER}.md"
USAGE_FILE="$OUT_DIR/hermes-usage.json"
LOOP_DIR="$OUT_DIR/agent-loop"
# Snapshot log position for this run only
LOG_FILE="$HERMES_HOME/logs/agent.log"
LOG_OFFSET=0
if [[ -f "$LOG_FILE" ]]; then
  LOG_OFFSET=$(wc -c <"$LOG_FILE" | tr -d ' ')
fi
echo "$LOG_OFFSET" >"$OUT_DIR/hermes-log-offset.txt"

# F36: wall-clock timeout for Hermes (kill hung agent loops / runaway OpenRouter)
TIMEOUT_HELPER="$LUFFY_ROOT/scripts/run-with-timeout.py"
TIMEOUT_SECS="$(
  python3 "$TIMEOUT_HELPER" resolve "${LUFFY_REVIEW_TIMEOUT_SECONDS-}" 2>/dev/null || echo 1500
)"
# normalize non-integer
case "$TIMEOUT_SECS" in
  ''|*[!0-9]*) TIMEOUT_SECS=1500 ;;
esac
printf '%s\n' "$TIMEOUT_SECS" >"$OUT_DIR/hermes-timeout-seconds.txt" || true

# F41: Hermes max_turns iteration budget (complements F36 wall-clock)
MAX_TURNS_HELPER="$LUFFY_ROOT/scripts/max_turns.py"
MAX_TURNS_RAW="$(
  python3 "$MAX_TURNS_HELPER" resolve "${LUFFY_MAX_TURNS-}" 2>/dev/null || echo 40
)"
MAX_TURNS_ARGS=()
MAX_TURNS_ENABLED=0
MAX_TURNS_VAL=""
if [[ "$MAX_TURNS_RAW" != "off" && -n "$MAX_TURNS_RAW" ]]; then
  case "$MAX_TURNS_RAW" in
    *[!0-9]*) MAX_TURNS_RAW=40 ;;
  esac
  if [[ "$MAX_TURNS_RAW" -gt 0 ]]; then
    MAX_TURNS_ENABLED=1
    MAX_TURNS_VAL="$MAX_TURNS_RAW"
    MAX_TURNS_ARGS=(--max-turns "$MAX_TURNS_VAL")
    export HERMES_MAX_ITERATIONS="$MAX_TURNS_VAL"
    # Ensure HERMES_HOME config matches CLI (agent.config copy may lag installer)
    python3 - <<'PY' "$HERMES_HOME/config.yaml" "$MAX_TURNS_VAL"
from pathlib import Path
import re, sys
path, n = Path(sys.argv[1]), sys.argv[2]
text = path.read_text(encoding="utf-8") if path.is_file() else ""
block = f"agent:\n  max_turns: {n}\n"
if re.search(r"(?m)^agent:\s*$", text):
    text2, cnt = re.subn(
        r"(?m)^(agent:\s*\n(?:[ \t]+.+\n)*)",
        block,
        text,
        count=1,
    )
    if cnt:
        text = text2
    else:
        text = text.rstrip() + "\n\n" + block
elif re.search(r"(?m)^agent:\s*\n", text):
    text = re.sub(
        r"(?ms)^agent:.*?(?=^[a-zA-Z_]|\Z)",
        block,
        text,
        count=1,
    )
else:
    text = text.rstrip() + "\n\n" + block
path.write_text(text if text.endswith("\n") else text + "\n", encoding="utf-8")
PY
  fi
fi
{
  echo "max_turns_enabled=$MAX_TURNS_ENABLED"
  echo "max_turns=${MAX_TURNS_VAL:-off}"
} >"$OUT_DIR/hermes-max-turns.env" || true

_hermes_wrap() {
  # Run hermes under F36 timeout when enabled; else bare exec.
  if [[ "${TIMEOUT_SECS}" -gt 0 && -f "$TIMEOUT_HELPER" ]]; then
    python3 "$TIMEOUT_HELPER" --seconds "$TIMEOUT_SECS" -- "$@"
  else
    "$@"
  fi
}

notice "Hermes review · model=$MODEL tier=${MODEL_TIER_SELECTED:-?} toolsets=$TOOLSETS workspace=$WORKSPACE_ROOT hermes_home=$HERMES_HOME timeout=${TIMEOUT_SECS}s max_turns=${MAX_TURNS_VAL:-off}"

TIMED_OUT=0
set +e
(
  cd "$WORKSPACE_ROOT"
  # --usage-file: tokens/cost/session_id for the agentic loop package
  # -t toolsets: allow terminal/file tools so the loop can inspect the workspace
  _hermes_wrap hermes -z "$PROMPT" \
    --provider openrouter \
    --model "$MODEL" \
    -t "$TOOLSETS" \
    --usage-file "$USAGE_FILE" \
    ${MAX_TURNS_ARGS[@]+"${MAX_TURNS_ARGS[@]}"} \
    >"$RAW_OUT" 2>"$STDERR_FILE"
)
RC=$?
if [[ $RC -eq 124 ]]; then
  TIMED_OUT=1
  notice "F36 hermes -z TIMED OUT after ${TIMEOUT_SECS}s (skip chat fallback to avoid double spend)"
  # Drop partial model output — force the timeout failure stub below
  : >"$RAW_OUT"
  {
    echo "timed_out=1"
    echo "timeout_seconds=$TIMEOUT_SECS"
    echo "stage=hermes-z"
  } >"$OUT_DIR/hermes-timeout.env" || true
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      echo "### Luffy review timeout (F36)"
      echo "- **Timed out** after \`${TIMEOUT_SECS}s\` wall-clock during \`hermes -z\`"
      echo "- Chat fallback skipped (would double OpenRouter spend)"
      echo "- Override: \`vars.LUFFY_REVIEW_TIMEOUT_SECONDS\` (\`0\`/\`off\` disables)"
      echo
    } >>"$GITHUB_STEP_SUMMARY" || true
  fi
fi
if [[ $TIMED_OUT -eq 0 && ( $RC -ne 0 || ! -s "$RAW_OUT" ) ]]; then
  notice "hermes -z failed or empty (rc=$RC); trying hermes chat -q"
  (
    cd "$WORKSPACE_ROOT"
    _hermes_wrap hermes chat -q "$PROMPT" \
      --provider openrouter \
      --model "$MODEL" \
      ${MAX_TURNS_ARGS[@]+"${MAX_TURNS_ARGS[@]}"} \
      >"$RAW_OUT" 2>>"$STDERR_FILE"
  )
  RC=$?
  if [[ $RC -eq 124 ]]; then
    TIMED_OUT=1
    notice "F36 hermes chat TIMED OUT after ${TIMEOUT_SECS}s"
    : >"$RAW_OUT"
    {
      echo "timed_out=1"
      echo "timeout_seconds=$TIMEOUT_SECS"
      echo "stage=hermes-chat"
    } >"$OUT_DIR/hermes-timeout.env" || true
  fi
fi
set -e

if [[ $RC -ne 0 ]]; then
  if [[ $TIMED_OUT -eq 1 ]]; then
    notice "hermes exit=$RC (F36 wall-clock timeout ${TIMEOUT_SECS}s)"
  else
    notice "hermes exit=$RC"
  fi
  [[ -s "$STDERR_FILE" ]] && tail -c 8000 "$STDERR_FILE" >&2 || true
fi

# Slice of agent.log written during this invocation
if [[ -f "$LOG_FILE" ]]; then
  python3 - <<'PY' "$LOG_FILE" "$OUT_DIR/hermes-run.log" "$LOG_OFFSET"
import sys
from pathlib import Path
src, dest, off = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3] or 0)
data = src.read_bytes()
chunk = data[off:] if off < len(data) else data[-200_000:]
dest.write_bytes(chunk)
print(f"hermes-run.log bytes={len(chunk)}", file=sys.stderr)
PY
fi

# Detailed agentic-loop package (messages, tool calls, usage, logs)
export HERMES_HOME OUT_DIR LUFFY_MODEL="$MODEL" OPENROUTER_MODEL="$MODEL"
export HERMES_USAGE_FILE="$USAGE_FILE"
export AGENT_LOOP_DIR="$LOOP_DIR"
export LUFFY_PROVIDER=openrouter
chmod +x "$LUFFY_ROOT/scripts/capture-hermes-loop.py" 2>/dev/null || true
python3 "$LUFFY_ROOT/scripts/capture-hermes-loop.py" || notice "capture-hermes-loop soft-failed"

# F41: detect Hermes iteration-budget exhaustion (logs / stderr / agent-loop)
MAX_TURNS_HIT=0
if [[ -f "$MAX_TURNS_HELPER" ]]; then
  _detect_paths=()
  [[ -f "$STDERR_FILE" ]] && _detect_paths+=("$STDERR_FILE")
  [[ -f "$OUT_DIR/hermes-run.log" ]] && _detect_paths+=("$OUT_DIR/hermes-run.log")
  [[ -f "$LOOP_DIR/agent-loop.md" ]] && _detect_paths+=("$LOOP_DIR/agent-loop.md")
  [[ -f "$LOOP_DIR/agent.log" ]] && _detect_paths+=("$LOOP_DIR/agent.log")
  if [[ ${#_detect_paths[@]} -gt 0 ]]; then
    if python3 "$MAX_TURNS_HELPER" detect "${_detect_paths[@]}" >/dev/null 2>&1; then
      : # hit=0 (exit 0)
    else
      _drc=$?
      if [[ $_drc -eq 2 ]]; then
        MAX_TURNS_HIT=1
      fi
    fi
  fi
fi
{
  echo "max_turns_enabled=$MAX_TURNS_ENABLED"
  echo "max_turns=${MAX_TURNS_VAL:-off}"
  echo "max_turns_hit=$MAX_TURNS_HIT"
} >"$OUT_DIR/hermes-max-turns.env" || true
if [[ "$MAX_TURNS_HIT" -eq 1 ]]; then
  notice "F41 Hermes max_turns hit (cap=${MAX_TURNS_VAL:-?}) — iteration budget exhausted"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      echo "### Luffy max turns (F41)"
      echo "- **Iteration budget exhausted** at \`${MAX_TURNS_VAL:-?}\` tool-calling turns"
      echo "- Raise \`vars.LUFFY_MAX_TURNS\` or use a faster/cheaper model; \`0\`/\`off\` disables the cap"
      echo
    } >>"$GITHUB_STEP_SUMMARY" || true
  fi
fi

if [[ ! -s "$RAW_OUT" ]]; then
  _fail_summary="Luffy failed to produce a review (hermes exit ${RC}). Check workflow logs, Hermes install, and OpenRouter credits/key."
  _fail_blocking="Review agent run failed — re-trigger with \`@luffy review this pr\` after fixing CI/OpenRouter."
  if [[ $TIMED_OUT -eq 1 ]]; then
    _fail_summary="Luffy review **timed out** after ${TIMEOUT_SECS}s wall-clock (F36). Hermes was killed to stop runaway OpenRouter spend. Re-trigger with a cheaper model or raise \`LUFFY_REVIEW_TIMEOUT_SECONDS\`."
    _fail_blocking="Agent loop exceeded \`LUFFY_REVIEW_TIMEOUT_SECONDS=${TIMEOUT_SECS}\` — increase the var, use a faster model (\`vars.LUFFY_MODEL\`), or re-run with a smaller PR diff."
  elif [[ "$MAX_TURNS_HIT" -eq 1 ]]; then
    _fail_summary="Luffy review hit the **Hermes iteration budget** (F41, max_turns=${MAX_TURNS_VAL:-?}). The agent loop stopped before producing a full review to cap OpenRouter spend. Raise \`LUFFY_MAX_TURNS\` or simplify the PR."
    _fail_blocking="Agent loop exhausted \`LUFFY_MAX_TURNS=${MAX_TURNS_VAL:-?}\` tool turns — increase the var, disable with \`0\`/\`off\`, or re-run with a smaller diff / cheaper model."
  fi
  cat >"$RAW_OUT" <<EOF
## 🏴‍☠️ Luffy Review — PR #${PR_NUMBER}

**Verdict:** COMMENT
**Confidence:** low
**Score:** 20/100
**Review effort:** 1/5

### Summary
${_fail_summary}

### Walkthrough
- Agent runner failure only

### Blocking
- ${_fail_blocking}

### Key findings
None — runner failure.

### Security audit
No

### Suggestions
- None

### Code suggestions
None

### Nits
- None

### Tests & risk
- Relevant tests added/updated: unknown
- Coverage: unknown
- Risk: unknown
- Rollback: n/a

### What I checked
- Agent runner only (no successful model response)

---
*Luffy · Hermes Agent · OpenRouter · memory-backed review*
EOF
fi

# Normalize into final review.md
# F27: pass --diff-truncated when assemble-context capped the PR diff (meta.env)
_NORM_EXTRA=()
case "${DIFF_TRUNCATED:-false}" in
  true|TRUE|1|yes|YES) _NORM_EXTRA+=(--diff-truncated) ;;
esac
python3 "$LUFFY_ROOT/scripts/normalize-review.py" \
  --input "$RAW_OUT" \
  --output "$FINAL_OUT" \
  --pr "$PR_NUMBER" \
  --run-id "${GITHUB_RUN_ID:-local}" \
  "${_NORM_EXTRA[@]+"${_NORM_EXTRA[@]}"}"

if [[ "${#_NORM_EXTRA[@]}" -gt 0 ]]; then
  notice "F27 diff was truncated — banner injected into posted review"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
      echo "### Luffy diff truncation (F27)"
      echo "- **DIFF_TRUNCATED:** true — review saw only the first \`MAX_DIFF_BYTES\` of the PR diff"
      echo "- Posted review includes a visible ⚠️ banner"
      echo
    } >>"$GITHUB_STEP_SUMMARY" || true
  fi
fi

# F21/F29: surface cost/tokens (+ soft budget note) on the posted comment
if [[ -f "$LUFFY_ROOT/scripts/usage-summary.py" ]]; then
  python3 "$LUFFY_ROOT/scripts/usage-summary.py" append \
    --usage "$USAGE_FILE" \
    --review "$FINAL_OUT" \
    --max-usd "${LUFFY_MAX_COST_USD:-}" || notice "usage-summary append soft-failed"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "review_file=$FINAL_OUT"
    echo "raw_file=$RAW_OUT"
    echo "hermes_rc=$RC"
    echo "agent_loop_dir=$LOOP_DIR"
    echo "usage_file=$USAGE_FILE"
  } >>"$GITHUB_OUTPUT"
fi

echo "REVIEW_FILE=$FINAL_OUT"
echo "AGENT_LOOP_DIR=$LOOP_DIR"
notice "Review written: $FINAL_OUT ($(wc -c <"$FINAL_OUT" | tr -d ' ') bytes)"
if [[ -f "$LOOP_DIR/agent-loop.json" ]]; then
  notice "Agent loop captured: $LOOP_DIR"
fi
