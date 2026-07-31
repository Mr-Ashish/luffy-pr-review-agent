#!/usr/bin/env bash
# Preload MEMORY.md into HERMES_HOME before review.
#
# Order (F28 repo-local memory):
#   1) Target repo .luffy/MEMORY.md (or LUFFY_MEMORY_PATH) from default branch via API
#   2) Hub memory/repos/{slug}/MEMORY.md if hub opted in
#   3) Leave seed/local only
#
# Env:
#   REPO / GITHUB_REPOSITORY
#   HERMES_HOME
#   LUFFY_MEMORY_MODE   local|hub|both  (default local)
#   LUFFY_MEMORY_PATH   default .luffy
#   LUFFY_HUB_REPO      default Mr-Ashish/luffy-pr-review-agent
#   LUFFY_HUB_PUBLISH / LUFFY_HUB_TOKEN / GITHUB_TOKEN
set -euo pipefail

log() { echo "$*" >&2; }
notice() { echo "::notice::$*" >&2; log "$*"; }

REPO="${REPO:-${GITHUB_REPOSITORY:-}}"
HERMES_HOME="${HERMES_HOME:-}"
HUB_REPO="${LUFFY_HUB_REPO:-Mr-Ashish/luffy-pr-review-agent}"
TOKEN="${LUFFY_HUB_TOKEN:-${GH_TOKEN:-${GITHUB_TOKEN:-}}}"
MEM_PATH="${LUFFY_MEMORY_PATH:-.luffy}"
MODE="${LUFFY_MEMORY_MODE:-local}"
MODE="$(printf '%s' "$MODE" | tr '[:upper:]' '[:lower:]')"

if [[ -z "$REPO" || -z "$HERMES_HOME" ]]; then
  log "REPO/HERMES_HOME missing; skip memory preload"
  if [[ -n "${OUT_DIR:-}" && -f "$(dirname "${BASH_SOURCE[0]}")/memory-health.sh" ]]; then
    OUT_DIR="${OUT_DIR}" bash "$(dirname "${BASH_SOURCE[0]}")/memory-health.sh" record "MEMORY_SOURCE=skipped_no_repo" || true
  fi
  exit 0
fi

_MH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/memory-health.sh"
record_mh() {
  if [[ -n "${OUT_DIR:-}" && -f "$_MH" ]]; then
    OUT_DIR="$OUT_DIR" bash "$_MH" record "$1" >/dev/null || true
  fi
  echo "$1"
}

mkdir -p "$HERMES_HOME/memories"
LOCAL_DEST="$HERMES_HOME/memories/MEMORY.md"
record_mh "MEMORY_MODE=${MODE}"
record_mh "MEMORY_PATH=${MEM_PATH}"

# Hub fallback allowed?
HUB_OK=0
if [[ "${LUFFY_HUB_PUBLISH:-}" == "1" ]]; then
  HUB_OK=1
fi
case "$MODE" in
  hub|both) HUB_OK=1 ;;
esac
# Explicit off wins
if [[ "${LUFFY_HUB_PUBLISH:-}" == "0" && "$MODE" != "hub" && "$MODE" != "both" ]]; then
  HUB_OK=0
fi

fetch_raw() {
  # $1 = owner/repo  $2 = path  → writes to $TMP, sets HTTP
  local api_repo="$1" path="$2"
  local API="https://api.github.com/repos/${api_repo}/contents/${path}"
  local HDR=(-H "Accept: application/vnd.github.raw+json")
  if [[ -n "$TOKEN" ]]; then
    HDR+=(-H "Authorization: Bearer ${TOKEN}")
  fi
  set +e
  HTTP=$(curl -sS -L -o "$TMP" -w "%{http_code}" "${HDR[@]}" "$API")
  set -e
}

merge_into_hermes() {
  # merge $TMP into LOCAL_DEST
  if [[ -f "$LOCAL_DEST" && -s "$LOCAL_DEST" ]]; then
    {
      cat "$TMP"
      echo ""
      echo "---"
      echo "## Local session notes"
      cat "$LOCAL_DEST"
    } >"${LOCAL_DEST}.merged"
    mv "${LOCAL_DEST}.merged" "$LOCAL_DEST"
  else
    cp -f "$TMP" "$LOCAL_DEST"
  fi
}

TMP="$(mktemp)"
HTTP=""

# 1) Repo-local .luffy/MEMORY.md (default branch contents API — do not rely on sparse PR workspace)
LOCAL_MEM="${MEM_PATH}/MEMORY.md"
# strip leading ./
LOCAL_MEM="${LOCAL_MEM#./}"
fetch_raw "$REPO" "$LOCAL_MEM"
if [[ "$HTTP" == "200" && -s "$TMP" ]]; then
  merge_into_hermes
  notice "Preloaded local memory: ${REPO}/${LOCAL_MEM} ($(wc -c <"$LOCAL_DEST" | tr -d ' ') bytes)"
  record_mh "MEMORY_SOURCE=local"
  echo "HUB_MEMORY=local"
  rm -f "$TMP"
  exit 0
fi
log "No local memory yet at ${REPO}/${LOCAL_MEM} (HTTP ${HTTP:-?})"

# 2) Hub fallback when opted in
if [[ "$HUB_OK" == "1" ]]; then
  SLUG="$(printf '%s' "$REPO" | sed 's|/|--|g')"
  HUB_MEM="memory/repos/${SLUG}/MEMORY.md"
  fetch_raw "$HUB_REPO" "$HUB_MEM"
  if [[ "$HTTP" == "200" && -s "$TMP" ]]; then
    merge_into_hermes
    notice "Preloaded hub memory: ${HUB_REPO}/${HUB_MEM} ($(wc -c <"$LOCAL_DEST" | tr -d ' ') bytes)"
    record_mh "MEMORY_SOURCE=hub"
    echo "HUB_MEMORY=preloaded"
    rm -f "$TMP"
    exit 0
  fi
  log "No hub memory for ${SLUG} (HTTP ${HTTP:-?}); using seed/local only"
  record_mh "MEMORY_SOURCE=missing"
  echo "HUB_MEMORY=missing"
else
  log "Hub preload skipped (mode=${MODE}, LUFFY_HUB_PUBLISH=${LUFFY_HUB_PUBLISH:-unset})"
  record_mh "MEMORY_SOURCE=seed"
  echo "HUB_MEMORY=skipped"
fi
rm -f "$TMP"
