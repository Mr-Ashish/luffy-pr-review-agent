#!/usr/bin/env bash
# F22/F23/F24: Apply verdict-aware done signals after a Luffy run.
#
# - Parses review.md via parse-verdict.py
# - Writes key=value to GITHUB_OUTPUT (when set)
# - Appends job-summary section (when GITHUB_STEP_SUMMARY set)
# - Optionally reacts to the trigger comment (REACTION_COMMENT_ID)
# - Optionally posts a commit status on the PR head SHA (LUFFY_COMMIT_STATUS)
# - F23: Optionally submits a formal PR Review event (LUFFY_PR_REVIEW)
# - F24: Dismisses prior Luffy PR reviews (same marker) before posting a new one
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
#   LUFFY_PR_REVIEW — 1 (default) to submit formal PR review; 0/off to skip
#   LUFFY_REPLACE_PREVIOUS — 1 (default) also dismisses prior F23 PR reviews
#   HEAD_SHA — optional; resolved via gh pr view when empty
#   OUT_DIR — fallback locate review-*.md
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT/.luffy-out}"
PARSE="$ROOT/scripts/parse-verdict.py"
DISMISS="$ROOT/scripts/dismiss-prior-pr-reviews.sh"

log() { echo "$*" >&2; }
notice() { echo "::notice::$*" >&2; log "$*"; }

REVIEW_FILE="${1:-${REVIEW_FILE:-}}"
PIPELINE_RC="${2:-${PIPELINE_RC:-0}}"
REPO="${REPO:-${GITHUB_REPOSITORY:-}}"
PR_NUMBER="${PR_NUMBER:-}"
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
STATUS_ON="${LUFFY_COMMIT_STATUS:-1}"
CONTEXT="${LUFFY_STATUS_CONTEXT:-luffy/review}"
PR_REVIEW_ON="${LUFFY_PR_REVIEW:-1}"
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
  REVIEW_EVENT=COMMENT
  PIPELINE_OK=false
else
  VERDICT=UNKNOWN
  SCORE=
  CONFIDENCE=
  REACTION=eyes
  STATUS_STATE=success
  STATUS_DESC="Luffy: review complete"
  REVIEW_EVENT=COMMENT
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
      review_event=*) REVIEW_EVENT="${line#review_event=}" ;;
      pipeline_ok=*) PIPELINE_OK="${line#pipeline_ok=}" ;;
    esac
  done < <(python3 "$PARSE" "$REVIEW_FILE" --pipeline-rc "$PIPELINE_RC" --format kv)
fi

notice "F22/F23 verdict=$VERDICT reaction=$REACTION status=$STATUS_STATE review_event=$REVIEW_EVENT pipeline_ok=$PIPELINE_OK"

# GITHUB_OUTPUT
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "verdict=$VERDICT"
    echo "score=$SCORE"
    echo "confidence=$CONFIDENCE"
    echo "reaction=$REACTION"
    echo "status_state=$STATUS_STATE"
    echo "status_desc=$STATUS_DESC"
    echo "review_event=$REVIEW_EVENT"
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
      echo "### Luffy verdict (F22/F23)"
      echo "- **Verdict:** \`$VERDICT\`"
      echo "- **Pipeline ok:** $PIPELINE_OK"
      echo "- **Reaction:** \`$REACTION\`"
      echo "- **Commit status:** \`$STATUS_STATE\` — $STATUS_DESC"
      echo "- **PR review event (F23):** \`$REVIEW_EVENT\`"
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

# ---------------------------------------------------------------------------
# F23: Formal Pull Request Review (Reviews panel event)
# Soft; disable with LUFFY_PR_REVIEW=0. Full Markdown stays on the issue comment
# (F12 replace path); this is a short verdict signal + merge UX.
# APPROVE can be rejected by GitHub (self-review / org policy) → fall back to COMMENT.
# F24: dismiss prior Luffy reviews (APPROVED/CHANGES_REQUESTED) first when replace on.
# ---------------------------------------------------------------------------
case "${PR_REVIEW_ON}" in
  0|false|FALSE|off|OFF|no|NO) PR_REVIEW_ON=0 ;;
  *) PR_REVIEW_ON=1 ;;
esac

if [[ "$PR_REVIEW_ON" == "1" && -n "$REPO" && -n "${PR_NUMBER:-}" && -n "$TOKEN" ]] \
  && command -v gh >/dev/null 2>&1; then
  export GH_TOKEN="$TOKEN"
  HEAD_SHA="${HEAD_SHA:-}"
  if [[ -z "$HEAD_SHA" ]]; then
    HEAD_SHA="$(
      gh pr view "$PR_NUMBER" --repo "$REPO" --json headRefOid --jq '.headRefOid' 2>/dev/null || true
    )"
  fi

  # F24: clear prior Luffy Reviews-panel rows (soft)
  if [[ -x "$DISMISS" ]]; then
    bash "$DISMISS" "$PR_NUMBER" || log "warn: F24 dismiss-prior soft-failed"
  elif [[ -f "$DISMISS" ]]; then
    bash "$DISMISS" "$PR_NUMBER" || log "warn: F24 dismiss-prior soft-failed"
  fi

  # Short body: full review lives on the issue comment (marker <!-- luffy-review pr=N)
  BODY_LINES="## 🏴‍☠️ Luffy — ${VERDICT}"$'\n'
  if [[ -n "${SCORE:-}" ]]; then
    BODY_LINES+="**Score:** ${SCORE}/100"
    [[ -n "${CONFIDENCE:-}" ]] && BODY_LINES+=" · **Confidence:** ${CONFIDENCE}"
    BODY_LINES+=$'\n'
  elif [[ -n "${CONFIDENCE:-}" ]]; then
    BODY_LINES+="**Confidence:** ${CONFIDENCE}"$'\n'
  fi
  BODY_LINES+=$'\n'"${STATUS_DESC}"$'\n\n'
  BODY_LINES+="_Full review is the PR comment with marker \`<!-- luffy-review pr=${PR_NUMBER}\`._"$'\n'
  BODY_LINES+="<!-- luffy-pr-review pr=${PR_NUMBER} run=${GITHUB_RUN_ID:-local} -->"

  submit_pr_review() {
    local event="$1"
    local args=(
      --method POST
      -H "Accept: application/vnd.github+json"
      "/repos/${REPO}/pulls/${PR_NUMBER}/reviews"
      -f event="$event"
      -f body="$BODY_LINES"
    )
    if [[ -n "${HEAD_SHA:-}" ]]; then
      args+=(-f commit_id="$HEAD_SHA")
    fi
    gh api "${args[@]}" >/dev/null 2>&1
  }

  EVENT="$REVIEW_EVENT"
  case "$EVENT" in
    APPROVE|REQUEST_CHANGES|COMMENT) ;;
    *) EVENT=COMMENT ;;
  esac

  if submit_pr_review "$EVENT"; then
    log "F23 PR review event=$EVENT on #$PR_NUMBER"
  elif [[ "$EVENT" == "APPROVE" ]]; then
    # Common: cannot approve own PR / org forbids bot approve → COMMENT still lands in Reviews
    if submit_pr_review "COMMENT"; then
      log "F23 PR review: APPROVE rejected; fell back to COMMENT on #$PR_NUMBER"
      REVIEW_EVENT=COMMENT
    else
      log "warn: F23 PR review failed (event=APPROVE then COMMENT) on #$PR_NUMBER"
    fi
  else
    log "warn: F23 PR review failed (event=$EVENT) on #$PR_NUMBER"
  fi
else
  log "Skip F23 PR review (disabled or missing REPO/PR_NUMBER/gh)"
fi

# Always print kv on stdout for local/debug consumers
cat <<EOF
verdict=$VERDICT
score=$SCORE
confidence=$CONFIDENCE
reaction=$REACTION
status_state=$STATUS_STATE
status_desc=$STATUS_DESC
review_event=$REVIEW_EVENT
pipeline_ok=$PIPELINE_OK
EOF
