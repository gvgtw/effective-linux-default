#!/usr/bin/env bash
# Installs Terminator and writes the final desired config directly, instead
# of the old README's "click through 6 Preferences tabs" — Terminator just
# reads $HOME/.config/terminator/config, so we can bake the whole result
# (Dark-Pastel-based profile, keybindings, layout) in one shot.
set -euo pipefail

TERM_CONFIG_DIR="$HOME/.config/terminator"
TERM_PLUGINS_DIR="$TERM_CONFIG_DIR/plugins"
THEMES_PLUGIN_URL="https://raw.githubusercontent.com/EliverLara/terminator-themes/master/plugin/terminator-themes.py"
THEMES_PLUGIN_DEST="$TERM_PLUGINS_DIR/terminator-themes.py"
CONFIG_TPL="$ELD_REPO_DIR/config/terminator/config.tpl"

apt_install terminator python3-requests

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: mkdir -p $TERM_PLUGINS_DIR"
    log "dry-run: download TerminatorThemes plugin to $THEMES_PLUGIN_DEST"
    log "dry-run: install $CONFIG_TPL -> $TERM_CONFIG_DIR/config"
    exit 0
fi

mkdir -p "$TERM_PLUGINS_DIR"

if [ ! -f "$THEMES_PLUGIN_DEST" ]; then
    log "terminator: fetching TerminatorThemes plugin"
    curl -fsSL "$THEMES_PLUGIN_URL" -o "$THEMES_PLUGIN_DEST"
else
    log "terminator: TerminatorThemes plugin already present, skipping download"
fi

backup_file "$TERM_CONFIG_DIR/config"
cp "$CONFIG_TPL" "$TERM_CONFIG_DIR/config"
log "terminator: wrote $TERM_CONFIG_DIR/config"
