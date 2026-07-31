#!/usr/bin/env bash
# Luffy orchestrator: assemble → hermes → normalize → distill → save-trace.
#
# Env:
#   OPENROUTER_API_KEY (required)
#   REPO / GITHUB_REPOSITORY, PR_NUMBER
#   LUFFY_ROOT, WORKSPACE_ROOT, HERMES_HOME, OUT_DIR
#   LUFFY_MODEL, TRIGGER_COMMENT, MAX_DIFF_BYTES
#   POST_COMMENT=1 to also post (optional)
set -euo pipefail

LUFFY_ROOT="${LUFFY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export LUFFY_ROOT
export WORKSPACE_ROOT="${WORKSPACE_ROOT:-$LUFFY_ROOT}"
export OUT_DIR="${OUT_DIR:-$LUFFY_ROOT/.luffy-out}"
export HERMES_HOME="${HERMES_HOME:-$LUFFY_ROOT/.luffy-hermes-home}"
export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
export TRACE_ROOT="${TRACE_ROOT:-$OUT_DIR/traces}"

SCRIPTS="$LUFFY_ROOT/scripts"
chmod +x "$SCRIPTS"/*.sh 2>/dev/null || true

mkdir -p "$OUT_DIR"
export LUFFY_STARTED_AT
LUFFY_STARTED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TIMINGS_FILE="$OUT_DIR/timings.json"
: >"$OUT_DIR/timings.partial.tsv"

stage() {
  local name="$1"
  shift
  local start end elapsed
  start="$(date +%s)"
  echo "::notice::Luffy stage: $name" >&2
  set +e
  "$@"
  local rc=$?
  set -e
  end="$(date +%s)"
  elapsed=$((end - start))
  printf '%s\t%s\t%s\n' "$name" "$elapsed" "$rc" >>"$OUT_DIR/timings.partial.tsv"
  return "$rc"
}

echo "::notice::Luffy orchestrator · root=$LUFFY_ROOT workspace=$WORKSPACE_ROOT" >&2

# Snapshot memory before review (for trace)
if [[ -f "$HERMES_HOME/memories/MEMORY.md" ]]; then
  cp -f "$HERMES_HOME/memories/MEMORY.md" "$OUT_DIR/memory-before.md"
fi

# F28: repo-local memory default
export LUFFY_MEMORY_MODE="${LUFFY_MEMORY_MODE:-local}"
export LUFFY_MEMORY_PATH="${LUFFY_MEMORY_PATH:-.luffy}"

ORCH_RC=0
# F3/F28: preload MEMORY — local .luffy/ first, hub only if opted in
stage preload_memory "$SCRIPTS/preload-hub-memory.sh" || true

stage assemble "$SCRIPTS/assemble-context.sh" || ORCH_RC=$?

if [[ $ORCH_RC -eq 0 ]]; then
  # shellcheck disable=SC1091
  source "$OUT_DIR/meta.env"
  export PROMPT_PATH PR_NUMBER REPO
fi

if [[ $ORCH_RC -eq 0 ]]; then
  stage hermes "$SCRIPTS/run-hermes-review.sh" || ORCH_RC=$?
fi

# Capture hermes rc from timings if available
export HERMES_RC="${ORCH_RC}"

REVIEW_FILE="${OUT_DIR}/review-${PR_NUMBER:-unknown}.md"
if [[ -n "${PR_NUMBER:-}" && -f "$OUT_DIR/review-${PR_NUMBER}.md" ]]; then
  REVIEW_FILE="$OUT_DIR/review-${PR_NUMBER}.md"
fi
export REVIEW_FILE

if [[ $ORCH_RC -eq 0 ]]; then
  stage distill "$SCRIPTS/distill-memory.sh" || true
fi

# Build timings.json
python3 - <<'PY' "$OUT_DIR/timings.partial.tsv" "$TIMINGS_FILE" "$LUFFY_STARTED_AT"
from pathlib import Path
import json, sys
from datetime import datetime, timezone

tsv, out, started = sys.argv[1:4]
stages = []
total = 0
if Path(tsv).exists():
    for line in Path(tsv).read_text().splitlines():
        if not line.strip():
            continue
        name, elapsed, rc = line.split("\t")
        elapsed = int(elapsed)
        total += elapsed
        stages.append({"name": name, "seconds": elapsed, "exit_code": int(rc)})
Path(out).write_text(json.dumps({
    "started_at": started,
    "ended_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "total_seconds": total,
    "stages": stages,
}, indent=2) + "\n")
PY

export LUFFY_STATUS
if [[ $ORCH_RC -eq 0 && -s "${REVIEW_FILE:-}" ]]; then
  LUFFY_STATUS="success"
else
  LUFFY_STATUS="failed"
fi

stage save_trace "$SCRIPTS/save-trace.sh" || true

# Export TRACE_ID for hub payload if save-trace wrote latest dir
if [[ -f "$OUT_DIR/latest-trace-dir.txt" ]]; then
  TRACE_DIR="$(cat "$OUT_DIR/latest-trace-dir.txt")"
  export TRACE_DIR
  if [[ -f "$TRACE_DIR/meta.json" ]]; then
    export TRACE_ID
    TRACE_ID="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("trace_id",""))' "$TRACE_DIR/meta.json" 2>/dev/null || true)"
  fi
fi

# F28: always (default) publish slim pack → target .luffy/; hub only when opted in
# F30: soft-fail still records status + ::warning:: (does not flip LUFFY_STATUS)
stage publish_local "$SCRIPTS/publish-run-local.sh" || true
stage publish_hub "$SCRIPTS/publish-run-to-hub.sh" || true

# F30: emit memory health into logs / Actions annotations
if [[ -f "$SCRIPTS/memory-health.sh" ]]; then
  bash "$SCRIPTS/memory-health.sh" warn-if-bad || true
  bash "$SCRIPTS/memory-health.sh" summary >"$OUT_DIR/memory-health.md" 2>/dev/null || true
fi

# F31: auto-pack Run Console bundle (soft — never fails the review)
# Prefer TRACE_DIR (has meta.json + review.md); fall back to OUT_DIR.
if [[ -f "$SCRIPTS/pack-run-for-ui.py" ]]; then
  PACK_SRC=""
  if [[ -n "${TRACE_DIR:-}" && -d "${TRACE_DIR:-}" ]]; then
    PACK_SRC="$TRACE_DIR"
  elif [[ -f "$OUT_DIR/latest-trace-dir.txt" ]]; then
    PACK_SRC="$(cat "$OUT_DIR/latest-trace-dir.txt")"
  fi
  if [[ -z "$PACK_SRC" || ! -d "$PACK_SRC" ]]; then
    PACK_SRC="$OUT_DIR"
  fi
  PACK_ARGS=(
    python3 "$SCRIPTS/pack-run-for-ui.py"
    --dir "$PACK_SRC"
    -o "$OUT_DIR/run-bundle.json"
    --soft
  )
  if [[ -f "$OUT_DIR/memory-health.env" ]]; then
    PACK_ARGS+=(--memory-health "$OUT_DIR/memory-health.env")
  fi
  if [[ -n "${TRACE_DIR:-}" && -d "${TRACE_DIR:-}" ]]; then
    PACK_ARGS+=(--also "$TRACE_DIR/run-bundle.json")
  fi
  # Host auto-detect inside pack (GITHUB_ACTIONS / MODAL_* / LUFFY_HOST)
  stage pack_ui_bundle "${PACK_ARGS[@]}" || true
  if [[ -f "$OUT_DIR/run-bundle.json" ]]; then
    echo "RUN_BUNDLE=$OUT_DIR/run-bundle.json"
    if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
      {
        echo "### Luffy Run Console bundle (F31)"
        echo ""
        echo "- **path:** \`$OUT_DIR/run-bundle.json\` (also in trace artifact if present)"
        echo "- Load in \`ui/review-console\` via **Load bundle** (or \`npm run pack-fixture\` for fixtures)."
        echo ""
      } >>"$GITHUB_STEP_SUMMARY"
    fi
  fi
fi

if [[ "${POST_COMMENT:-0}" == "1" && -f "${REVIEW_FILE:-}" ]]; then
  stage post_comment "$SCRIPTS/post-review-comment.sh" "$REVIEW_FILE" "${PR_NUMBER:-}" || ORCH_RC=$?
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "review_file=${REVIEW_FILE:-}"
    echo "pr_number=${PR_NUMBER:-}"
    echo "luffy_status=$LUFFY_STATUS"
    if [[ -f "$OUT_DIR/latest-trace-dir.txt" ]]; then
      echo "trace_dir=$(cat "$OUT_DIR/latest-trace-dir.txt")"
    fi
    if [[ -f "$OUT_DIR/run-bundle.json" ]]; then
      echo "run_bundle=$OUT_DIR/run-bundle.json"
    fi
    if [[ -f "$OUT_DIR/memory-health.env" ]]; then
      # surface key lines for workflow consumers
      grep -E '^(MEMORY_SOURCE|LOCAL_PUBLISH|HUB_PUBLISH)=' "$OUT_DIR/memory-health.env" || true
    fi
  } >>"$GITHUB_OUTPUT"
fi

echo "REVIEW_FILE=${REVIEW_FILE:-}"
echo "LUFFY_STATUS=$LUFFY_STATUS"
if [[ -f "$OUT_DIR/latest-trace-dir.txt" ]]; then
  echo "TRACE_DIR=$(cat "$OUT_DIR/latest-trace-dir.txt")"
fi
if [[ -f "$OUT_DIR/run-bundle.json" ]]; then
  echo "RUN_BUNDLE=$OUT_DIR/run-bundle.json"
fi
if [[ -f "$OUT_DIR/memory-health.env" ]]; then
  echo "--- memory-health ---"
  cat "$OUT_DIR/memory-health.env"
fi

exit "$ORCH_RC"
