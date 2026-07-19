#!/usr/bin/env bash
# ~/Dev is where all dev projects live, and the intended working directory
# for Claude Code (see modules/95-claude-code.sh) — Claude Code itself has no
# configurable default working directory, so this is just the conventional
# project root the user cd's into.
set -euo pipefail

DEV_DIR="$HOME/Dev"

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: mkdir -p $DEV_DIR"
    exit 0
fi

mkdir -p "$DEV_DIR"
log "dev-directory: ensured $DEV_DIR exists"
