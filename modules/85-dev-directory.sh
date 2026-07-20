#!/usr/bin/env bash
# ~/Dev is where all dev projects live, and the intended working directory
# for Claude Code (see modules/95-claude-code.sh) — Claude Code itself has no
# configurable default working directory, so this is just the conventional
# project root the user cd's into.
#
# The two subdirectories are the Claude Code contexts: projects under
# ~/Dev/build get the vibe-coding CLAUDE.md, projects under ~/Dev/learn get
# the teaching one. modules/86-claude-contexts.sh puts those files in place.
# ~/Dev itself deliberately gets no CLAUDE.md, so a project left directly in
# it is unconfigured rather than wrongly configured.
set -euo pipefail

DEV_DIR="$HOME/Dev"
CONTEXT_DIRS=("$DEV_DIR/build" "$DEV_DIR/learn")

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: mkdir -p $DEV_DIR ${CONTEXT_DIRS[*]}"
    exit 0
fi

mkdir -p "$DEV_DIR" "${CONTEXT_DIRS[@]}"
log "dev-directory: ensured $DEV_DIR and its build/ and learn/ contexts exist"
