#!/usr/bin/env bash
# Publish a Luffy run to the central hub repo via repository_dispatch (luffy-run).
#
# Env:
#   LUFFY_HUB_REPO   default: Mr-Ashish/luffy-pr-review-agent
#   LUFFY_HUB_TOKEN  required for cross-repo; falls back to GH_TOKEN/GITHUB_TOKEN
#   OUT_DIR, REPO, PR_NUMBER, TRACE_ID, LUFFY_STATUS, ...
#
# Optional:
#   LUFFY_HUB_PUBLISH=0  to skip
set -euo pipefail

log() { echo "$*" >&2; }
notice() { echo "::notice::$*" >&2; log "$*"; }

if [[ "${LUFFY_HUB_PUBLISH:-1}" == "0" ]]; then
  log "LUFFY_HUB_PUBLISH=0; skip hub publish"
  exit 0
fi

LUFFY_ROOT="${LUFFY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
OUT_DIR="${OUT_DIR:-$LUFFY_ROOT/.luffy-out}"
HUB_REPO="${LUFFY_HUB_REPO:-Mr-Ashish/luffy-pr-review-agent}"
TOKEN="${LUFFY_HUB_TOKEN:-${GH_TOKEN:-${GITHUB_TOKEN:-}}}"

if [[ -z "$TOKEN" ]]; then
  log "No LUFFY_HUB_TOKEN/GITHUB_TOKEN; skip hub publish"
  exit 0
fi

command -v gh >/dev/null 2>&1 || {
  log "gh not found; skip hub publish"
  exit 0
}
command -v python3 >/dev/null 2>&1 || {
  log "python3 not found; skip hub publish"
  exit 0
}

export OUT_DIR
python3 "$LUFFY_ROOT/scripts/build-hub-payload.py"
PAYLOAD="$OUT_DIR/hub-payload.json"
[[ -f "$PAYLOAD" ]] || {
  log "missing hub-payload.json"
  exit 1
}

# Write payload to a temp file for gh --input
notice "Publishing run to hub $HUB_REPO (repository_dispatch luffy-run)"

# Build API body: { event_type, client_payload }
# client_payload must be an object — nest our payload under "run"
python3 - <<'PY' "$PAYLOAD" "$OUT_DIR/dispatch-body.json"
import json, sys
payload = json.loads(open(sys.argv[1]).read())
body = {"event_type": "luffy-run", "client_payload": {"run": payload}}
open(sys.argv[2], "w").write(json.dumps(body))
print(sys.argv[2])
PY

export GH_TOKEN="$TOKEN"
set +e
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/${HUB_REPO}/dispatches" \
  --input "$OUT_DIR/dispatch-body.json"
RC=$?
set -e

if [[ $RC -ne 0 ]]; then
  log "repository_dispatch failed (rc=$RC). Check LUFFY_HUB_TOKEN scopes (repo) on $HUB_REPO"
  exit "$RC"
fi

notice "Hub dispatch accepted for $HUB_REPO (async ingest workflow should run)"
echo "HUB_REPO=$HUB_REPO"
echo "HUB_DISPATCH=ok"
