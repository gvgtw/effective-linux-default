#!/usr/bin/env bash
# Interactive `gh auth login` — paste your fine-grained PAT when prompted.
# This is the one deliberately interactive step in an otherwise
# non-interactive script, so it explicitly reads from /dev/tty: stdin may be
# the curl pipe itself (curl ... | bash) rather than a real terminal, both on
# the initial run and after install.sh re-execs itself from the clone.
set -euo pipefail

if gh auth status >/dev/null 2>&1; then
    log "gh-auth: already authenticated, skipping"
    exit 0
fi

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: interactive 'gh auth login' (paste your fine-grained PAT when prompted)"
    exit 0
fi

if [ ! -r /dev/tty ]; then
    log "gh-auth: no interactive terminal available, skipping — run 'gh auth login' manually later"
    exit 0
fi

reply=""
read -r -p "Would you like to complete GitHub authentication now? [y/N] " reply </dev/tty || reply=""

case "$reply" in
    [Yy]*)
        log "gh-auth: launching 'gh auth login' — choose GitHub.com, HTTPS, then 'Paste an authentication token' and paste your fine-grained PAT"
        gh auth login </dev/tty
        log "gh-auth: done"
        ;;
    *)
        log "gh-auth: skipped by user — run 'gh auth login' manually whenever you're ready"
        ;;
esac
