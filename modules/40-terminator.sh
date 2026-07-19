#!/usr/bin/env bash
# Installs Terminator and applies the keybindings from
# config/terminator-keybindings.conf.
#
# Only the [keybindings] section is managed. An earlier version of this script
# wrote a whole config (theme plugin, profile colors, fonts, saved layout)
# built against a different distro's Terminator packaging, and it broke on
# Pop!_OS. Everything outside [keybindings] is left to Terminator's own
# defaults and to whatever you set in Preferences — those changes survive
# re-runs, because this module rewrites one section and preserves the rest.
set -euo pipefail

KEYBINDINGS_FILE="$ELD_REPO_DIR/config/terminator-keybindings.conf"
TERM_CONFIG_DIR="$HOME/.config/terminator"
TERM_CONFIG="$TERM_CONFIG_DIR/config"

apt_install terminator

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: merge [keybindings] from $KEYBINDINGS_FILE into $TERM_CONFIG"
    exit 0
fi

if [ ! -f "$KEYBINDINGS_FILE" ]; then
    log "terminator: $KEYBINDINGS_FILE missing, leaving config alone"
    exit 0
fi

mkdir -p "$TERM_CONFIG_DIR"
touch "$TERM_CONFIG"
backup_file "$TERM_CONFIG"

# Strip any existing [keybindings] section, then append ours. Terminator's
# format nests with doubled brackets ([[default]] inside [profiles]), so a
# top-level section header is "[" followed by anything that isn't another "[".
# Skipping stops at the next top-level header, which leaves every other
# section — including their subsections — untouched.
tmp="$(mktemp)"
awk '
    /^\[keybindings\][[:space:]]*$/ { skip = 1; next }
    /^\[[^[]/                       { skip = 0 }
    !skip                           { print }
' "$TERM_CONFIG" >"$tmp"

# Drop trailing blank lines so repeated runs produce a byte-identical file.
printf '%s\n' "$(cat "$tmp")" >"$tmp.trimmed"
{
    [ -s "$tmp.trimmed" ] && cat "$tmp.trimmed"
    echo "[keybindings]"
    grep -v '^[[:space:]]*#' "$KEYBINDINGS_FILE" | grep -v '^[[:space:]]*$'
} >"$TERM_CONFIG"
rm -f "$tmp" "$tmp.trimmed"

log "terminator: applied keybindings from $(basename "$KEYBINDINGS_FILE")"
