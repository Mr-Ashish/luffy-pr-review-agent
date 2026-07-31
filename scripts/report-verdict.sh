#!/usr/bin/env bash
# F22: Apply verdict-aware done signals after a Luffy run.
#
# - Parses review.md via parse-verdict.py
# - Writes key=value to GITHUB_OUTPUT (when set)
# - Appends job-summary section (when GITHUB_STEP_SUMMARY set)
# - Optionally reacts to the trigger comment (REACTION_COMMENT_ID)
# - Optionally posts a commit status on the PR head SHA (LUFFY_COMMIT_STATUS)
#
# Usage:
#   ./scripts/report-verdict.sh [review.md] [pipeline_rc]
#
# Env:
#   REPO / GITHUB_REPOSITORY
#   PR_NUMBER
#   PIPELINE_RC (default 0; or pass as $2)
#   GH_TOKEN / GITHUB_TOKEN
#   REACTION_COMMENT_ID — issue comment id to react on (issue_comment runs)
#   LUFFY_COMMIT_STATUS — 1 (default) to post status; 0/off to skip
#   LUFFY_STATUS_CONTEXT — default "luffy/review"
#   HEAD_SHA — optional; resolved via gh pr view when empty
#   OUT_DIR — fallback locate review-*.md
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT/.luffy-out}"
PARSE="$ROOT/scripts/parse-verdict.py"

log() { echo "$*" >&2; }
notice() { echo "::notice::$*" >&2; log "$*"; }

REVIEW_FILE="${1:-${REVIEW_FILE:-}}"
PIPELINE_RC="${2:-${PIPELINE_RC:-0}}"
REPO="${REPO:-${GITHUB_REPOSITORY:-}}"
PR_NUMBER="${PR_NUMBER:-}"
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
STATUS_ON="${LUFFY_COMMIT_STATUS:-1}"
CONTEXT="${LUFFY_STATUS_CONTEXT:-luffy/review}"
COMMENT_ID="${REACTION_COMMENT_ID:-}"

if [[ -z "$REVIEW_FILE" ]]; then
  if compgen -G "$OUT_DIR/review-*.md" >/dev/null; then
    REVIEW_FILE="$(ls -t "$OUT_DIR"/review-*.md 2>/dev/null | grep -v '\.raw\.md$' | head -1 || true)"
  fi
fi

if [[ -z "${REVIEW_FILE:-}" || ! -f "$REVIEW_FILE" ]]; then
  log "No review file; emitting UNKNOWN failure signals"
  VERDICT=UNKNOWN
  SCORE=
  CONFIDENCE=
  REACTION="-1"
  STATUS_STATE=error
  STATUS_DESC="Luffy: no review artifact"
  PIPELINE_OK=false
else
  VERDICT=UNKNOWN
  SCORE=
  CONFIDENCE=
  REACTION=eyes
  STATUS_STATE=success
  STATUS_DESC="Luffy: review complete"
  PIPELINE_OK=true
  # bash 3.2-safe (no mapfile): parse kv lines from parse-verdict.py
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      verdict=*) VERDICT="${line#verdict=}" ;;
      score=*) SCORE="${line#score=}" ;;
      confidence=*) CONFIDENCE="${line#confidence=}" ;;
      reaction=*) REACTION="${line#reaction=}" ;;
      status_state=*) STATUS_STATE="${line#status_state=}" ;;
      status_desc=*) STATUS_DESC="${line#status_desc=}" ;;
      pipeline_ok=*) PIPELINE_OK="${line#pipeline_ok=}" ;;
    esac
  done < <(python3 "$PARSE" "$REVIEW_FILE" --pipeline-rc "$PIPELINE_RC" --format kv)
fi

notice "F22 verdict=$VERDICT reaction=$REACTION status=$STATUS_STATE pipeline_ok=$PIPELINE_OK"

# GITHUB_OUTPUT
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "verdict=$VERDICT"
    echo "score=$SCORE"
    echo "confidence=$CONFIDENCE"
    echo "reaction=$REACTION"
    echo "status_state=$STATUS_STATE"
    echo "status_desc=$STATUS_DESC"
    echo "pipeline_ok=$PIPELINE_OK"
  } >>"$GITHUB_OUTPUT"
fi

# Job summary
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  if [[ -f "${REVIEW_FILE:-}" ]]; then
    python3 "$PARSE" "$REVIEW_FILE" --pipeline-rc "$PIPELINE_RC" --format summary \
      >>"$GITHUB_STEP_SUMMARY" || true
  else
    {
      echo "### Luffy verdict (F22)"
      echo "- **Verdict:** \`$VERDICT\`"
      echo "- **Pipeline ok:** $PIPELINE_OK"
      echo "- **Reaction:** \`$REACTION\`"
      echo "- **Commit status:** \`$STATUS_STATE\` — $STATUS_DESC"
      echo
    } >>"$GITHUB_STEP_SUMMARY"
  fi
fi

# Reaction on trigger comment (soft)
if [[ -n "$COMMENT_ID" && -n "$REPO" && -n "$TOKEN" ]]; then
  export GH_TOKEN="$TOKEN"
  if command -v gh >/dev/null 2>&1; then
    gh api --method POST \
      -H "Accept: application/vnd.github+json" \
      "/repos/${REPO}/issues/comments/${COMMENT_ID}/reactions" \
      -f content="$REACTION" >/dev/null 2>&1 \
      && log "Reacted $REACTION on comment $COMMENT_ID" \
      || log "warn: reaction failed (comment=$COMMENT_ID content=$REACTION)"
  fi
fi

# Commit status on PR head (soft; disable with LUFFY_COMMIT_STATUS=0)
case "${STATUS_ON}" in
  0|false|FALSE|off|OFF|no|NO) STATUS_ON=0 ;;
  *) STATUS_ON=1 ;;
esac

if [[ "$STATUS_ON" == "1" && -n "$REPO" && -n "$TOKEN" ]]; then
  export GH_TOKEN="$TOKEN"
  HEAD_SHA="${HEAD_SHA:-}"
  if [[ -z "$HEAD_SHA" && -n "${PR_NUMBER:-}" ]] && command -v gh >/dev/null 2>&1; then
    HEAD_SHA="$(
      gh pr view "$PR_NUMBER" --repo "$REPO" --json headRefOid --jq '.headRefOid' 2>/dev/null || true
    )"
  fi
  if [[ -n "${HEAD_SHA:-}" ]] && command -v gh >/dev/null 2>&1; then
    # statuses API wants state + context + description (+ optional target_url)
    TARGET="${GITHUB_SERVER_URL:-https://github.com}/${REPO}/actions/runs/${GITHUB_RUN_ID:-}"
    gh api --method POST \
      -H "Accept: application/vnd.github+json" \
      "/repos/${REPO}/statuses/${HEAD_SHA}" \
      -f state="$STATUS_STATE" \
      -f context="$CONTEXT" \
      -f description="${STATUS_DESC:0:140}" \
      -f target_url="$TARGET" >/dev/null 2>&1 \
      && log "Commit status $STATUS_STATE on ${HEAD_SHA:0:12} ($CONTEXT)" \
      || log "warn: commit status failed (sha=${HEAD_SHA:0:12} state=$STATUS_STATE)"
  else
    log "Skip commit status (no HEAD_SHA / gh)"
  fi
fi

# Always print kv on stdout for local/debug consumers
cat <<EOF
verdict=$VERDICT
score=$SCORE
confidence=$CONFIDENCE
reaction=$REACTION
status_state=$STATUS_STATE
status_desc=$STATUS_DESC
pipeline_ok=$PIPELINE_OK
EOF
