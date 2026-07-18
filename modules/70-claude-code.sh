#!/usr/bin/env bash
# Installs the Claude Code CLI via the official native installer (no Node.js
# dependency, unlike the npm install path). Auth is left to the user —
# it's an interactive browser OAuth flow, same reasoning as gh-auth and git
# identity: not something a public script should do on your behalf.
set -euo pipefail

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    if have_cmd claude; then
        log "dry-run: claude already installed, would run 'claude update'"
    else
        log "dry-run: install Claude Code via https://claude.ai/install.sh"
    fi
    exit 0
fi

if have_cmd claude; then
    log "claude-code: already installed ($(claude --version 2>/dev/null || echo unknown)), checking for updates"
    claude update || log "claude-code: update check failed, continuing"
else
    log "claude-code: installing via native installer"
    curl -fsSL https://claude.ai/install.sh | bash
    log "claude-code: installed — run 'claude' from ~/Dev (or a project under it) to log in"
fi
