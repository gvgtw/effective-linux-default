#!/usr/bin/env bash
# Puts ~/.local/bin on PATH for bash, the same way the eld block in .zshrc
# does for zsh (modules/50-zsh.sh).
#
# zsh is the default login shell here, but bash is still what you get from a
# `bash -lc`, a VS Code task, or a script with a bash shebang — and the Claude
# Code native installer drops `claude` into ~/.local/bin, which Ubuntu/Pop only
# add to PATH from ~/.profile. Without this, the installer warns that
# ~/.local/bin isn't on PATH and `claude` is missing from any bash shell.
#
# This module does NOT own ~/.bashrc — the additions go in a marker-guarded
# block, so the distro's stock file and anything else appending to it survive.
# Note the plain `echo ... >> ~/.bashrc` that Claude Code suggests would append
# a duplicate line on every re-run; ensure_block_in_file replaces in place.
set -euo pipefail

BASHRC="$HOME/.bashrc"

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: ensure eld block in $BASHRC (~/.local/bin on PATH)"
    exit 0
fi

backup_file "$BASHRC"

# Same guard as the zsh block: a login shell that already picked up
# ~/.local/bin from ~/.profile shouldn't get it prepended a second time.
ensure_block_in_file "$BASHRC" "bash" '# ~/.local/bin is where the Claude Code native installer puts `claude`.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac'
log "bash: ensured eld block in $BASHRC"

# Deliberately no `source ~/.bashrc` — sourcing it from this non-interactive
# script would only affect this module's subshell. It takes effect on the next
# shell, which the end-of-run reboot guarantees.
