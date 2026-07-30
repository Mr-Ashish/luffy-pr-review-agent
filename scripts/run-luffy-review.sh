#!/usr/bin/env bash
# Luffy orchestrator: assemble → hermes → normalize → distill.
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

SCRIPTS="$LUFFY_ROOT/scripts"
chmod +x "$SCRIPTS"/*.sh 2>/dev/null || true

echo "::notice::Luffy orchestrator · root=$LUFFY_ROOT workspace=$WORKSPACE_ROOT" >&2

"$SCRIPTS/assemble-context.sh"
# shellcheck disable=SC1091
source "$OUT_DIR/meta.env"
export PROMPT_PATH PR_NUMBER REPO

"$SCRIPTS/run-hermes-review.sh"

REVIEW_FILE="$OUT_DIR/review-${PR_NUMBER}.md"
export REVIEW_FILE

"$SCRIPTS/distill-memory.sh"

if [[ "${POST_COMMENT:-0}" == "1" ]]; then
  "$SCRIPTS/post-review-comment.sh" "$REVIEW_FILE" "$PR_NUMBER"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "review_file=$REVIEW_FILE" >>"$GITHUB_OUTPUT"
  echo "pr_number=$PR_NUMBER" >>"$GITHUB_OUTPUT"
fi

echo "REVIEW_FILE=$REVIEW_FILE"
