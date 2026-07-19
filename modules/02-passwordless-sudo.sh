#!/usr/bin/env bash
# Functional equivalent of Kali's kali-grant-root, since Pop!_OS has no
# equivalent package: a NOPASSWD sudoers.d entry for the current user.
# Applies immediately, no reboot needed. Always validated with `visudo -c`
# BEFORE it's ever copied into /etc/sudoers.d/ — a broken file there can
# lock sudo out entirely, so an invalid fragment is discarded, never
# installed.
set -euo pipefail

SUDOERS_FILE="/etc/sudoers.d/effective-linux-default-nopasswd"
# Written by earlier revisions of this branch, back when it targeted stock
# Ubuntu. Left in place it'd be a second, redundant NOPASSWD grant.
LEGACY_SUDOERS_FILE="/etc/sudoers.d/effective-ubuntu-nopasswd"
EXPECTED_CONTENT="$USER ALL=(ALL) NOPASSWD:ALL"

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: remove $LEGACY_SUDOERS_FILE if present"
    log "dry-run: validate and install $SUDOERS_FILE granting $USER passwordless sudo"
    exit 0
fi

if [ -f "$LEGACY_SUDOERS_FILE" ]; then
    sudo rm -f "$LEGACY_SUDOERS_FILE"
    log "passwordless-sudo: removed legacy $LEGACY_SUDOERS_FILE"
fi

if [ -f "$SUDOERS_FILE" ] && [ "$(cat "$SUDOERS_FILE")" = "$EXPECTED_CONTENT" ]; then
    log "passwordless-sudo: $SUDOERS_FILE already in place, skipping"
    exit 0
fi

TMP_SUDOERS="$(mktemp)"
printf '%s\n' "$EXPECTED_CONTENT" >"$TMP_SUDOERS"

if ! sudo visudo -c -f "$TMP_SUDOERS" >/dev/null 2>&1; then
    log "passwordless-sudo: WARNING - generated sudoers fragment failed visudo validation, NOT installing it"
    rm -f "$TMP_SUDOERS"
    exit 1
fi

sudo install -o root -g root -m 0440 "$TMP_SUDOERS" "$SUDOERS_FILE"
rm -f "$TMP_SUDOERS"
log "passwordless-sudo: installed $SUDOERS_FILE"
