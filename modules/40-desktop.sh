#!/usr/bin/env bash
# Default/monospace fonts (via gsettings, GNOME's config mechanism — the
# effective_kali branch uses xfconf-query for XFCE) and Terminator autostart.
# No wallpaper/lock-screen here: those were Kali-branded assets with no
# Ubuntu equivalent, dropped rather than guessed at.
set -euo pipefail

AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/terminator.desktop"

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: set GNOME default/monospace fonts (if gsettings available)"
    log "dry-run: write $AUTOSTART_FILE"
    exit 0
fi

if have_cmd gsettings; then
    gsettings set org.gnome.desktop.interface font-name "Sans Regular 11" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface monospace-font-name "Hack Regular 11" 2>/dev/null || true
    log "desktop: set default/monospace fonts"
else
    log "desktop: gsettings not found (not GNOME?), skipping font settings"
fi

mkdir -p "$AUTOSTART_DIR"
cat >"$AUTOSTART_FILE" <<'EOF'
[Desktop Entry]
Type=Application
Name=Terminator
Exec=terminator
X-GNOME-Autostart-enabled=true
EOF
log "desktop: enabled Terminator autostart"
