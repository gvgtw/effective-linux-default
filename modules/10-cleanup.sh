#!/usr/bin/env bash
# Removes the default XDG home-directory clutter Kali ships with.
set -euo pipefail

DIRS=("$HOME/Music" "$HOME/Videos" "$HOME/Templates" "$HOME/Public")

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
            log "dry-run: rm -rf $dir"
        else
            rm -rf "$dir"
            log "cleanup: removed $dir"
        fi
    fi
done
