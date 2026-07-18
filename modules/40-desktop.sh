#!/usr/bin/env bash
# Wallpaper/lock-screen, fonts, and Terminator autostart. The font/wallpaper
# xfconf steps only apply on XFCE (Kali's default DE) — they no-op with a log
# line elsewhere rather than failing the whole module.
set -euo pipefail

AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/terminator.desktop"
LOGIN_BG_LINK="/usr/share/desktop-base/kali-theme/login/background"
LOGIN_BG_SRC="/usr/share/backgrounds/kali-2.0/kali-2.0-lock-1920x1080.png"

apt_install kali-wallpapers-all

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: symlink $LOGIN_BG_LINK -> $LOGIN_BG_SRC"
    log "dry-run: set xfce4-desktop wallpaper + xsettings fonts (if XFCE)"
    log "dry-run: write $AUTOSTART_FILE"
    exit 0
fi

if [ -f "$LOGIN_BG_SRC" ]; then
    sudo ln -fs "$LOGIN_BG_SRC" "$LOGIN_BG_LINK"
    log "desktop: set login screen background"
else
    log "desktop: WARNING - $LOGIN_BG_SRC not found, skipping login screen background"
fi

if have_cmd xfconf-query; then
    desktop_bg="$(find /usr/share/backgrounds -iname 'kali-red-sticker*' 2>/dev/null | head -1)"
    if [ -n "$desktop_bg" ]; then
        while read -r prop; do
            xfconf-query -c xfce4-desktop -p "$prop" -s "$desktop_bg"
        done < <(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep 'last-image$')
        log "desktop: set wallpaper to $desktop_bg"
    else
        log "desktop: WARNING - kali-red-sticker wallpaper not found, skipping"
    fi

    xfconf-query -c xsettings -p /Gtk/FontName -s "Sans Regular 11" 2>/dev/null || true
    xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "Hack Regular 11" 2>/dev/null || true
    log "desktop: set default/monospace fonts"
else
    log "desktop: xfconf-query not found (not XFCE?), skipping wallpaper/font settings"
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
