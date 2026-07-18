#!/usr/bin/env bash
# Installs everything listed in config/dev-packages.list. Intentionally a
# thin, generic starter set — extend the list file as dev needs become
# concrete, rather than guessing language/tooling choices here.
set -euo pipefail

PACKAGES_LIST="$ELD_REPO_DIR/config/dev-packages.list"
packages=()

while IFS= read -r line; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)" # trim whitespace
    [ -n "$line" ] && packages+=("$line")
done <"$PACKAGES_LIST"

if [ "${#packages[@]}" -eq 0 ]; then
    log "dev-tools: no packages listed in $PACKAGES_LIST"
    exit 0
fi

apt_install "${packages[@]}"
