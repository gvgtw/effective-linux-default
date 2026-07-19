#!/usr/bin/env bash
# Removes the default XDG home-directory clutter Pop!_OS ships with.
#
# Deleting the directories is not enough on its own. xdg-user-dirs-update
# runs at every login (/etc/xdg/autostart/xdg-user-dirs.desktop) and recreates
# anything still pointed at a real subdirectory in ~/.config/user-dirs.dirs,
# so on a stock install these four came straight back at the next login. The
# fix is to repoint them at $HOME first — which is exactly what Kali already
# ships, and why this module appeared to work there and not here.
#
# Only these four are touched; Desktop/Downloads/Documents/Pictures keep
# their normal managed directories.
set -euo pipefail

USER_DIRS_FILE="$HOME/.config/user-dirs.dirs"
# XDG key -> directory name
declare -A TARGETS=(
    [MUSIC]=Music
    [VIDEOS]=Videos
    [TEMPLATES]=Templates
    [PUBLICSHARE]=Public
)

for key in "${!TARGETS[@]}"; do
    dir="$HOME/${TARGETS[$key]}"

    if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
        log "dry-run: point XDG_${key}_DIR at \$HOME/ and rm -rf $dir"
        continue
    fi

    # Rewrite the entry before deleting, so a login racing this run can't
    # recreate the directory we're about to remove.
    if [ -f "$USER_DIRS_FILE" ] && grep -q "^XDG_${key}_DIR=" "$USER_DIRS_FILE"; then
        if ! grep -q "^XDG_${key}_DIR=\"\$HOME/\"$" "$USER_DIRS_FILE"; then
            backup_file "$USER_DIRS_FILE"
            sed -i "s|^XDG_${key}_DIR=.*|XDG_${key}_DIR=\"\$HOME/\"|" "$USER_DIRS_FILE"
            log "cleanup: pointed XDG_${key}_DIR at \$HOME/"
        fi
    fi

    if [ -d "$dir" ]; then
        rm -rf "$dir"
        log "cleanup: removed $dir"
    fi
done
