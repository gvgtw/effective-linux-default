#!/usr/bin/env bash
# Runs Dewalt-arch/pimpmykali in fully non-interactive mode. --autonoroot
# reproduces the README's manual "select N in the menu" and "select N on the
# KALI-ROOT-LOGIN page" answers without any prompts.
#
# Numbered 90 so it runs LAST, on purpose: pimpmykali makes system changes
# that want an immediate reboot, and running it mid-script destabilises the
# terminal the remaining modules are executing in. Nothing earlier depends on
# the packages it pulls in (build-essential, jq), so the late slot is safe.
set -euo pipefail

PIMPMYKALI_DIR="$HOME/pimpmykali"
DONE_MARKER="$ELD_HOME/pimpmykali-done"

if [ -f "$DONE_MARKER" ]; then
    log "pimpmykali: already applied, skipping (delete $DONE_MARKER to force a re-run)"
    exit 0
fi

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: clone/update pimpmykali into $PIMPMYKALI_DIR and run --autonoroot"
    exit 0
fi

if [ -d "$PIMPMYKALI_DIR/.git" ]; then
    log "pimpmykali: updating existing checkout"
    git -C "$PIMPMYKALI_DIR" pull --ff-only
else
    log "pimpmykali: cloning"
    git clone https://github.com/Dewalt-arch/pimpmykali.git "$PIMPMYKALI_DIR"
fi

log "pimpmykali: running --autonoroot (non-interactive)"
sudo "$PIMPMYKALI_DIR/pimpmykali.sh" --autonoroot

if [ -f "$HOME/pimpmykali.log" ]; then
    mv "$HOME/pimpmykali.log" "$PIMPMYKALI_DIR/"
fi

touch "$DONE_MARKER"
mark_needs_reboot
log "pimpmykali: done"
