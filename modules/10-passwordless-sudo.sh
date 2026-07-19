#!/usr/bin/env bash
# Passwordless sudo for the current user, as a NOPASSWD /etc/sudoers.d/
# fragment. Applies immediately, no reboot needed.
#
# Always validated with `visudo -c` BEFORE it's ever copied into
# /etc/sudoers.d/ — a syntactically broken file there can lock sudo out
# entirely, so an invalid fragment is discarded rather than installed.
set -euo pipefail

SUDOERS_FILE="/etc/sudoers.d/effective-linux-default-nopasswd"
# Written by earlier revisions of this script under a different name. Left in
# place it'd be a second, redundant NOPASSWD grant.
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
