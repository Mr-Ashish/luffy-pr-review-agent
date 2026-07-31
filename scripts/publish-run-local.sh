#!/usr/bin/env bash
# Publish a Luffy run into the *target* repo under .luffy/ (repo-local memory).
#
# Writes slim pack only: MEMORY.md + runs/{trace_id}/{meta.json,review.md,summary.md}
# Fat traces stay as Actions artifacts (save-trace.sh) — never committed here.
#
# Env:
#   LUFFY_MEMORY_MODE   local|hub|both  (default local)
#   LUFFY_LOCAL_PUBLISH 0 to skip (default: on when mode is local|both)
#   LUFFY_MEMORY_PATH   default .luffy
#   REPO / GITHUB_REPOSITORY  target repo owner/name
#   GITHUB_TOKEN / GH_TOKEN    contents:write on target
#   OUT_DIR, PR_NUMBER, LUFFY_ROOT, ...
set -euo pipefail

log() { echo "$*" >&2; }
notice() { echo "::notice::$*" >&2; log "$*"; }

MODE="${LUFFY_MEMORY_MODE:-local}"
MODE="$(printf '%s' "$MODE" | tr '[:upper:]' '[:lower:]')"
# Local publish default: on for local|both
if [[ -z "${LUFFY_LOCAL_PUBLISH:-}" ]]; then
  case "$MODE" in
    hub) LUFFY_LOCAL_PUBLISH=0 ;;
    *) LUFFY_LOCAL_PUBLISH=1 ;;
  esac
fi
if [[ "${LUFFY_LOCAL_PUBLISH}" == "0" ]]; then
  log "LUFFY_LOCAL_PUBLISH=0; skip local .luffy publish"
  exit 0
fi

LUFFY_ROOT="${LUFFY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
OUT_DIR="${OUT_DIR:-$LUFFY_ROOT/.luffy-out}"
TOKEN="${LUFFY_LOCAL_TOKEN:-${GH_TOKEN:-${GITHUB_TOKEN:-}}}"
SOURCE_REPO="${REPO:-${GITHUB_REPOSITORY:-}}"
MEM_PATH="${LUFFY_MEMORY_PATH:-.luffy}"
# Branch to commit memory onto (default branch of target)
BRANCH="${LUFFY_MEMORY_BRANCH:-}"

if [[ -z "$SOURCE_REPO" ]]; then
  log "REPO/GITHUB_REPOSITORY missing; skip local publish"
  exit 0
fi
if [[ -z "$TOKEN" ]]; then
  log "No GITHUB_TOKEN; skip local publish"
  exit 0
fi

command -v python3 >/dev/null 2>&1 || { log "python3 not found; skip"; exit 0; }
command -v git >/dev/null 2>&1 || { log "git not found; skip"; exit 0; }

export OUT_DIR
python3 "$LUFFY_ROOT/scripts/build-hub-payload.py"
PAYLOAD="$OUT_DIR/hub-payload.json"
[[ -f "$PAYLOAD" ]] || { log "missing hub-payload.json"; exit 1; }

python3 - <<'PY' "$PAYLOAD" "$OUT_DIR/client_payload.json"
import json, sys
payload = json.loads(open(sys.argv[1]).read())
open(sys.argv[2], "w").write(json.dumps({"run": payload}, indent=2) + "\n")
print(sys.argv[2])
PY

export GH_TOKEN="$TOKEN"

# Resolve default branch if not set
if [[ -z "$BRANCH" ]]; then
  if command -v gh >/dev/null 2>&1; then
    BRANCH="$(gh api "repos/${SOURCE_REPO}" --jq .default_branch 2>/dev/null || true)"
  fi
  BRANCH="${BRANCH:-main}"
fi

notice "Local memory publish → ${SOURCE_REPO}@${BRANCH} path=${MEM_PATH}"
WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

git clone --depth 1 --branch "$BRANCH" \
  "https://x-access-token:${TOKEN}@github.com/${SOURCE_REPO}.git" \
  "$WORK/target" 2>/dev/null \
  || git clone --depth 1 \
    "https://x-access-token:${TOKEN}@github.com/${SOURCE_REPO}.git" \
    "$WORK/target"

INGEST="$LUFFY_ROOT/scripts/hub-ingest-run.py"
(
  cd "$WORK/target"
  git config user.name "luffy-memory-bot"
  git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  export CLIENT_PAYLOAD_FILE="$OUT_DIR/client_payload.json"
  export LUFFY_INGEST_LAYOUT=local
  export LUFFY_MEMORY_ROOT="$WORK/target"
  export LUFFY_MEMORY_PATH="$MEM_PATH"
  python3 "$INGEST"
  git add -- "$MEM_PATH"
  if git diff --cached --quiet; then
    log "No local memory changes to commit"
    echo "LOCAL_PUBLISH=noop"
    exit 0
  fi
  MSG="chore(memory): luffy local ingest PR #${PR_NUMBER:-?} $(date -u +%Y-%m-%dT%H%MZ)"
  git commit -m "$MSG"
  PUSH_REF="$(git rev-parse --abbrev-ref HEAD)"
  for i in 1 2 3 4 5; do
    if git pull --rebase origin "$PUSH_REF" 2>/dev/null || git pull --rebase origin "$BRANCH" 2>/dev/null; then
      :
    fi
    if git push origin "HEAD:${BRANCH}"; then
      notice "Pushed local .luffy memory to ${SOURCE_REPO}@${BRANCH}"
      echo "LOCAL_PUBLISH=ok"
      exit 0
    fi
    log "local push retry $i"
    sleep $((i * 2))
  done
  log "local push failed after retries (branch protection may require a PAT)"
  echo "LOCAL_PUBLISH=failed"
  exit 1
)
