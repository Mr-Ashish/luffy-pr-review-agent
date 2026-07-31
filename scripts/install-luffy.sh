#!/usr/bin/env bash
# F20/F10: install Luffy into a target repository.
#
# Modes:
#   pack (default)  Copy agent/, runtime scripts/, thin caller + reusable workflow
#                   so the target is self-contained (scripts live on its default branch).
#   --caller        F10 hub-managed: only copy pack/luffy-pr-review-caller.yml
#                   (runtime checked out from hub each run — free upgrades).
#
# Usage:
#   ./scripts/install-luffy.sh /path/to/target-repo
#   ./scripts/install-luffy.sh --caller /path/to/target-repo
#   ./scripts/install-luffy.sh --dest /path/to/target-repo --dry-run
#   ./scripts/install-luffy.sh --dest . --force   # re-install over existing
#
# Options:
#   --dest DIR          Target repo root (required unless positional DIR)
#   --caller            Hub-managed thin workflow only (no agent/scripts copy)
#   --dry-run           Print actions; do not write
#   --force             Overwrite existing files without prompting
#   --with-hub-ingest   Also copy ingest-luffy-run.yml (hub repo only; pack mode)
#   --with-runner-build Also copy build-luffy-runner.yml + docker/luffy-runner/
#   --source DIR        Luffy source root (default: parent of scripts/)
#   -h | --help
#
# Exit: 0 ok (skips existing files unless --force), 1 usage/error
set -euo pipefail

SRC=""
DEST=""
DRY_RUN=0
FORCE=0
WITH_INGEST=0
WITH_RUNNER=0
CALLER_MODE=0

log() { printf '%s\n' "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

usage() {
  # Header comment only (stop before set -euo pipefail)
  sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'
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
    --caller) CALLER_MODE=1; shift ;;
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
[[ -f "$SRC/.github/workflows/luffy-review-reusable.yml" ]] || die "source missing luffy-review-reusable.yml (F10)"
[[ -f "$SRC/pack/luffy-pr-review-caller.yml" ]] || die "source missing pack/luffy-pr-review-caller.yml (F10)"

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
  dismiss-prior-pr-reviews.sh
  distill-memory.sh
  hermes-pin.sh
  hub-ingest-run.py
  install-luffy.sh
  memory-health.sh
  normalize-review.py
  pack-run-for-ui.py
  parse-verdict.py
  post-review-comment.sh
  preload-hub-memory.sh
  publish-run-local.sh
  publish-run-to-hub.sh
  report-verdict.sh
  review-local.sh
  run-hermes-review.sh
  run-luffy-review.sh
  save-trace.sh
  review-to-openui.py
  sparse-pr-paths.sh
  usage-summary.py
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

write_stamp() {
  local mode="$1"
  local STAMP="$DEST/.luffy-install-stamp"
  local VERSION
  VERSION="$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY  would write $STAMP (mode=$mode source_sha=$VERSION)"
    return 0
  fi
  {
    echo "installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "source_sha=$VERSION"
    echo "source_path=$SRC"
    echo "mode=$mode"
    if [[ "$mode" == "caller" ]]; then
      echo "pack=luffy-pr-review-caller.yml (hub-managed F10)"
    else
      echo "pack=agent,scripts(runtime),luffy-pr-review.yml,luffy-review-reusable.yml"
    fi
  } >"$STAMP"
  log "OK   $STAMP"
}

log "Luffy install · source=$SRC"
log "               dest=$DEST dry_run=$DRY_RUN force=$FORCE caller=$CALLER_MODE"

# ---------------------------------------------------------------------------
# F10: hub-managed caller only
# ---------------------------------------------------------------------------
if [[ "$CALLER_MODE" == "1" ]]; then
  if [[ "$WITH_INGEST" == "1" || "$WITH_RUNNER" == "1" ]]; then
    log "WARN --with-hub-ingest / --with-runner-build ignored in --caller mode"
  fi
  copy_file \
    "$SRC/pack/luffy-pr-review-caller.yml" \
    "$DEST/.github/workflows/luffy-pr-review.yml"
  write_stamp "caller"
  log ""
  log "Next steps (hub-managed / F10 caller):"
  log "  1. Commit .github/workflows/luffy-pr-review.yml and push to the default branch."
  log "  2. Add secret OPENROUTER_API_KEY."
  log "  3. Memory defaults to repo-local .luffy/ (F28). Optional hub: LUFFY_MEMORY_MODE=both|hub and/or LUFFY_HUB_PUBLISH=1 + LUFFY_HUB_TOKEN."
  log "  4. Optional vars: LUFFY_MODEL, LUFFY_HERMES_COMMIT, LUFFY_COOLDOWN_SECONDS, LUFFY_RUNNER_IMAGE, LUFFY_MEMORY_PATH."
  log "  5. On a PR, comment: @luffy review this pr"
  log "  Runtime agent/scripts are fetched from Mr-Ashish/luffy-pr-review-agent@main each run."
  log "  Tip: pin the uses: ref to a commit SHA (not @main) to avoid blast radius from hub main."
  log "  Tip: seed .luffy/MEMORY.md on the target default branch (or re-install pack mode once)."
  log "Done."
  exit 0
fi

# ---------------------------------------------------------------------------
# Default pack mode (self-contained target)
# ---------------------------------------------------------------------------
# agent/*
AGENT_FILES=()
while IFS= read -r -d '' f; do
  AGENT_FILES+=("$(basename "$f")")
done < <(find "$SRC/agent" -maxdepth 1 -type f -print0 | sort -z)

copy_tree_files "agent" "${AGENT_FILES[@]}"

# runtime scripts
copy_tree_files "scripts" "${RUNTIME_SCRIPTS[@]}"

# F10: thin caller + reusable implementation (target keeps a copy of reusable for offline pin)
copy_file \
  "$SRC/.github/workflows/luffy-pr-review.yml" \
  "$DEST/.github/workflows/luffy-pr-review.yml"
copy_file \
  "$SRC/.github/workflows/luffy-review-reusable.yml" \
  "$DEST/.github/workflows/luffy-review-reusable.yml"

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

# F28: seed repo-local memory stub (committed; grows after each review)
seed_local_memory() {
  local mem_dir="$DEST/.luffy"
  local mem_file="$mem_dir/MEMORY.md"
  if [[ -e "$mem_file" && "$FORCE" != "1" ]]; then
    log "exists (skip, use --force): $mem_file"
    return 0
  fi
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY  seed $mem_file"
    return 0
  fi
  mkdir -p "$mem_dir"
  if [[ -f "$SRC/agent/MEMORY.seed.md" ]]; then
    cp -f "$SRC/agent/MEMORY.seed.md" "$mem_file"
  else
    cat >"$mem_file" <<'EOF'
# Luffy review memory

Cumulative notes from Luffy PR reviews (repo-local under `.luffy/`).
EOF
  fi
  log "OK   $mem_file"
}

seed_local_memory

write_stamp "pack"

log ""
log "Next steps on the target repo (default branch):"
log "  1. Commit the installed pack + .luffy/MEMORY.md and push to the default branch."
log "  2. Add secret OPENROUTER_API_KEY."
log "  3. Memory is repo-local (.luffy/) by default (F28). Optional hub: vars LUFFY_MEMORY_MODE=both|hub and/or LUFFY_HUB_PUBLISH=1 + secret LUFFY_HUB_TOKEN."
log "  4. Optional vars: LUFFY_MODEL / LUFFY_HERMES_COMMIT / LUFFY_COOLDOWN_SECONDS / LUFFY_RUNNER_IMAGE / LUFFY_MEMORY_PATH."
log "  5. On a PR, comment: @luffy review this pr"
log "  Tip: for hub-managed installs (no local scripts), re-run with --caller."
log "Done."
