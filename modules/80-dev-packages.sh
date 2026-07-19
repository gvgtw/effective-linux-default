#!/usr/bin/env bash
# Installs everything listed in config/dev-packages.list. Intentionally a
# thin, generic starter set — extend the list file as dev needs become
# concrete, rather than guessing language/tooling choices here.
set -euo pipefail

PACKAGES_LIST="$ELD_REPO_DIR/config/dev-packages.list"

mapfile -t packages < <(read_list_file "$PACKAGES_LIST")

if [ "${#packages[@]}" -eq 0 ]; then
    log "dev-packages: nothing listed in $PACKAGES_LIST"
    exit 0
fi

apt_install "${packages[@]}"
