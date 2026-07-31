#!/usr/bin/env bash
# F20: copy the Luffy runtime pack into a target repository.
#
# Pack (what target repos need on their *default* branch):
#   agent/                              SOUL, prompts, config, memory seed
#   scripts/                            orchestration (runtime helpers)
#   .github/workflows/luffy-pr-review.yml
#
# Usage:
#   ./scripts/install-luffy.sh /path/to/target-repo
#   ./scripts/install-luffy.sh --dest /path/to/target-repo --dry-run
#   ./scripts/install-luffy.sh --dest . --force   # re-install over existing
#
# Options:
#   --dest DIR          Target repo root (required unless positional DIR)
#   --dry-run           Print actions; do not write
#   --force             Overwrite existing files without prompting
#   --with-hub-ingest   Also copy ingest-luffy-run.yml (hub repo only)
#   --with-runner-build Also copy build-luffy-runner.yml + docker/luffy-runner/
#   --source DIR        Luffy source root (default: parent of scripts/)
#   -h | --help
#
# Exit: 0 ok, 1 usage/error, 2 refused (exists without --force)
set -euo pipefail

SRC=""
DEST=""
DRY_RUN=0
FORCE=0
WITH_INGEST=0
WITH_RUNNER=0

log() { printf '%s\n' "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

usage() {
  sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)
      DEST="${2:-}"
      shift 2
      ;;
    --source)
      SRC="${2:-}"
      shift 2
      ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force) FORCE=1; shift ;;
    --with-hub-ingest) WITH_INGEST=1; shift ;;
    --with-runner-build) WITH_RUNNER=1; shift ;;
    -h | --help) usage 0 ;;
    --)
      shift
      break
      ;;
    -*)
      die "unknown option: $1 (try --help)"
      ;;
    *)
      if [[ -z "$DEST" ]]; then
        DEST="$1"
        shift
      else
        die "unexpected argument: $1"
      fi
      ;;
  esac
done

SRC="${SRC:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
[[ -n "$DEST" ]] || die "target directory required (positional or --dest)"
DEST="$(cd "$DEST" 2>/dev/null && pwd)" || die "target not found: $DEST"
SRC="$(cd "$SRC" && pwd)"

[[ -d "$SRC/agent" ]] || die "source missing agent/: $SRC"
[[ -d "$SRC/scripts" ]] || die "source missing scripts/: $SRC"
[[ -f "$SRC/.github/workflows/luffy-pr-review.yml" ]] || die "source missing luffy-pr-review.yml"

# Refuse installing pack into itself unless forced (avoids half-copies)
if [[ "$SRC" == "$DEST" && "$FORCE" != "1" ]]; then
  die "refusing to install into the Luffy source tree itself (use --force if intentional)"
fi

# Runtime script allowlist — exclude image build / bench from target packs by default
# (still available when --with-runner-build copies docker tooling separately).
RUNTIME_SCRIPTS=(
  assemble-context.sh
  association-allowed.sh
  build-hub-payload.py
  capture-hermes-loop.py
  cooldown-check.sh
  distill-memory.sh
  hermes-pin.sh
  hub-ingest-run.py
  install-luffy.sh
  normalize-review.py
  post-review-comment.sh
  preload-hub-memory.sh
  publish-run-to-hub.sh
  review-local.sh
  run-hermes-review.sh
  run-luffy-review.sh
  save-trace.sh
  sparse-pr-paths.sh
  write-failure-review.sh
)

copy_file() {
  local from="$1" to="$2"
  if [[ -e "$to" && "$FORCE" != "1" ]]; then
    log "exists (skip, use --force): $to"
    return 0
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY  $from → $to"
    return 0
  fi
  mkdir -p "$(dirname "$to")"
  cp -f "$from" "$to"
  # Preserve executable bit for scripts
  if [[ -x "$from" ]]; then
    chmod +x "$to"
  fi
  log "OK   $to"
}

copy_tree_files() {
  # copy selected files under a subdir (not full recursive junk)
  local rel="$1"
  shift
  local f
  for f in "$@"; do
    local from="$SRC/$rel/$f"
    local to="$DEST/$rel/$f"
    [[ -f "$from" ]] || {
      log "WARN missing in source: $rel/$f"
      continue
    }
    copy_file "$from" "$to"
  done
}

log "Luffy install · source=$SRC"
log "               dest=$DEST dry_run=$DRY_RUN force=$FORCE"

# agent/*
AGENT_FILES=()
while IFS= read -r -d '' f; do
  AGENT_FILES+=("$(basename "$f")")
done < <(find "$SRC/agent" -maxdepth 1 -type f -print0 | sort -z)

copy_tree_files "agent" "${AGENT_FILES[@]}"

# runtime scripts
copy_tree_files "scripts" "${RUNTIME_SCRIPTS[@]}"

# main workflow
copy_file \
  "$SRC/.github/workflows/luffy-pr-review.yml" \
  "$DEST/.github/workflows/luffy-pr-review.yml"

if [[ "$WITH_INGEST" == "1" ]]; then
  copy_file \
    "$SRC/.github/workflows/ingest-luffy-run.yml" \
    "$DEST/.github/workflows/ingest-luffy-run.yml"
fi

if [[ "$WITH_RUNNER" == "1" ]]; then
  copy_file \
    "$SRC/.github/workflows/build-luffy-runner.yml" \
    "$DEST/.github/workflows/build-luffy-runner.yml"
  if [[ -f "$SRC/docker/luffy-runner/Dockerfile" ]]; then
    copy_file \
      "$SRC/docker/luffy-runner/Dockerfile" \
      "$DEST/docker/luffy-runner/Dockerfile"
  fi
  if [[ -f "$SRC/docker/luffy-runner/README.md" ]]; then
    copy_file \
      "$SRC/docker/luffy-runner/README.md" \
      "$DEST/docker/luffy-runner/README.md"
  fi
  for extra in build-luffy-runner-image.sh benchmark-hermes-startup.sh; do
    [[ -f "$SRC/scripts/$extra" ]] && copy_file "$SRC/scripts/$extra" "$DEST/scripts/$extra"
  done
fi

# Stamp for operators (not secret)
STAMP="$DEST/.luffy-install-stamp"
VERSION="$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo unknown)"
if [[ "$DRY_RUN" == "1" ]]; then
  log "DRY  would write $STAMP (source_sha=$VERSION)"
else
  {
    echo "installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "source_sha=$VERSION"
    echo "source_path=$SRC"
    echo "pack=agent,scripts(runtime),luffy-pr-review.yml"
  } >"$STAMP"
  log "OK   $STAMP"
fi

log ""
log "Next steps on the target repo (default branch):"
log "  1. Commit the installed pack and push to the default branch."
log "  2. Add secret OPENROUTER_API_KEY."
log "  3. Optional: LUFFY_HUB_TOKEN, vars LUFFY_MODEL / LUFFY_HERMES_COMMIT / LUFFY_COOLDOWN_SECONDS / LUFFY_RUNNER_IMAGE."
log "  4. On a PR, comment: @luffy review this pr"
log "Done."
