#!/usr/bin/env bash
# Shared helpers for effective-linux-default modules. Sourced, not executed directly.

ELD_HOME="${ELD_HOME:-$HOME/.effective-linux-default}"
ELD_LOG="$ELD_HOME/install.log"
ELD_REBOOT_MARKER="$ELD_HOME/needs-reboot"
ELD_MARK_START="# >>> eld:"
ELD_MARK_END="# <<< eld:"

mkdir -p "$ELD_HOME"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" | tee -a "$ELD_LOG"
}

# apt_install pkg [pkg...] — only installs packages that aren't already installed.
apt_install() {
    local missing=()
    local pkg
    for pkg in "$@"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done
    if [ "${#missing[@]}" -eq 0 ]; then
        log "apt: already installed: $*"
        return 0
    fi
    log "apt: installing: ${missing[*]}"
    if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
        log "dry-run: sudo apt-get install -y ${missing[*]}"
        return 0
    fi
    sudo apt-get install -y "${missing[@]}"
}

# ensure_line_in_file <file> <line> — appends line only if not already present.
ensure_line_in_file() {
    local file="$1" line="$2"
    if [ -f "$file" ] && grep -qF -- "$line" "$file"; then
        return 0
    fi
    if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
        log "dry-run: append to $file: $line"
        return 0
    fi
    printf '%s\n' "$line" >>"$file"
}

# ensure_block_in_file <file> <marker> <content> — replaces the block between
# "# >>> eld:<marker> >>>" and "# <<< eld:<marker> <<<" markers, appending it
# if the markers aren't present yet. Safe to call repeatedly.
ensure_block_in_file() {
    local file="$1" marker="$2" content="$3"
    local start="${ELD_MARK_START}${marker} >>>"
    local end="${ELD_MARK_END}${marker} <<<"

    touch "$file"

    if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
        log "dry-run: ensure block '$marker' in $file"
        return 0
    fi

    local tmp
    tmp="$(mktemp)"
    awk -v start="$start" -v end="$end" '
        $0 == start { skipping = 1; next }
        $0 == end   { skipping = 0; next }
        !skipping   { print }
    ' "$file" >"$tmp"

    {
        cat "$tmp"
        printf '%s\n%s\n%s\n' "$start" "$content" "$end"
    } >"$file"
    rm -f "$tmp"
}

# backup_file <file> — makes a one-time .orig copy before we ever touch it.
backup_file() {
    local file="$1"
    if [ -f "$file" ] && [ ! -f "$file.eld-orig" ]; then
        cp "$file" "$file.eld-orig"
        log "backed up $file -> $file.eld-orig"
    fi
}

# mark_needs_reboot — called by modules that made a first-time system change
# (pimpmykali actually ran, kali-grant-root policy actually flipped) so
# install.sh knows to reboot once at the very end of this run.
mark_needs_reboot() {
    touch "$ELD_REBOOT_MARKER"
}

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}
