#!/usr/bin/env bash
# Sets up the two Claude Code working contexts.
#
#   ~/Dev/build/  — agent-heavy vibe-coding
#   ~/Dev/learn/  — Claude teaches and guides rather than writing the code
#
# The context is a property of the directory, not of the session: you cd into
# a project and run `claude`, with no mode to remember and no flag to forget.
#
# Why the CLAUDE.md files and the skills go to different places
# -------------------------------------------------------------
# Claude Code discovers a CLAUDE.md by walking up the directory tree, and that
# walk crosses a git repo boundary — so ~/Dev/learn/CLAUDE.md reaches
# ~/Dev/learn/some-repo/ just fine. Skill discovery does NOT cross that
# boundary: it stops at the repo root. Verified on 2026-07-20 with a probe
# skill two levels up, seen from a plain subdirectory and unseen from a git
# repo at the same depth.
#
# So skills beside each CLAUDE.md would be silently invisible in every real
# project. They're installed at user level instead, prefixed build-/learn-,
# and each CLAUDE.md says which prefix to use and to ignore the other. Both
# sets load in every session — the isolation is by instruction, which is the
# trade for setup that just works at any depth in any repo.
set -euo pipefail

CLAUDE_SRC="$ELD_REPO_DIR/config/claude"
DEV_DIR="$HOME/Dev"
SKILLS_DEST="$HOME/.claude/skills"

if [ ! -d "$CLAUDE_SRC" ]; then
    log "claude-contexts: $CLAUDE_SRC not found, nothing to install"
    exit 0
fi

# --- CLAUDE.md per context --------------------------------------------------
# The repo is the source of truth for these and this module regenerates them.
# Safe to own outright, unlike ~/.zshrc: nothing else writes them. Local edits
# are preserved once as a .eld-orig copy the first time we overwrite.
install_context_md() {
    local context="$1"
    local src="$CLAUDE_SRC/$context/CLAUDE.md"
    local dest="$DEV_DIR/$context/CLAUDE.md"

    if [ ! -f "$src" ]; then
        log "claude-contexts: no CLAUDE.md for '$context' in the repo, skipping"
        return 0
    fi

    if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
        log "dry-run: install $src -> $dest"
        return 0
    fi

    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        log "claude-contexts: $dest already current"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    backup_file "$dest"
    cp "$src" "$dest"
    log "claude-contexts: installed $dest"
}

install_context_md build
install_context_md learn

# --- skills at user level ---------------------------------------------------
# Refreshed one skill directory at a time. Never wipe $SKILLS_DEST wholesale:
# skills written by hand live there too, and this module has no business
# deleting them. Only the directory names that exist in the repo are touched.
if [ -d "$CLAUDE_SRC/skills" ]; then
    for src_skill in "$CLAUDE_SRC"/skills/*/; do
        [ -d "$src_skill" ] || continue
        skill_name="$(basename "$src_skill")"
        dest_skill="$SKILLS_DEST/$skill_name"

        if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
            log "dry-run: sync skill '$skill_name' -> $dest_skill"
            continue
        fi

        mkdir -p "$SKILLS_DEST"
        rm -rf "$dest_skill"
        cp -r "$src_skill" "$dest_skill"
        log "claude-contexts: synced skill '$skill_name'"
    done
fi

if [ "${ELD_DRY_RUN:-0}" != "1" ]; then
    log "claude-contexts: done — create projects one level down, e.g. $DEV_DIR/learn/my-project"
fi
