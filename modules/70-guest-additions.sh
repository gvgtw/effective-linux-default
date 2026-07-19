#!/usr/bin/env bash
# VirtualBox Guest Additions, installed from the ISO the host provides
# (Devices -> Insert Guest Additions CD image...) rather than from apt.
#
# apt's virtualbox-guest-x11 lives in multiverse and is pinned to 6.1.32 on
# jammy, which is what Pop!_OS 22.04 resolves to. Against a VirtualBox 7.x
# host that version mismatch is what breaks display auto-resize and clipboard
# sharing. The host's ISO always matches the host exactly, so that's the one
# we use.
#
# Attaching a virtual CD is a host-side operation — a guest has no way to ask
# for it — so this is the one step that can need a hand. The module does as
# much as it can from in here: it uses the disc if the desktop already
# auto-mounted it, mounts it itself if it's attached but not mounted, and
# only then asks you to insert it, re-checking each time you say you have.
# You can skip the whole step at that prompt.
set -euo pipefail

DONE_MARKER="$ELD_HOME/guest-additions-done"
# Our own mountpoint, used only when we mount the disc ourselves.
# Overridable so tests can point it somewhere writable without root.
ELD_MOUNTPOINT="${ELD_MOUNTPOINT:-/media/eld-guest-additions}"
eld_mounted=0

# Unmount only what we mounted; a desktop auto-mount is left alone.
cleanup_mount() {
    if [ "$eld_mounted" = "1" ]; then
        sudo umount "$ELD_MOUNTPOINT" 2>/dev/null || true
        sudo rmdir "$ELD_MOUNTPOINT" 2>/dev/null || true
        eld_mounted=0
    fi
}
trap cleanup_mount EXIT

# Prints the path to VBoxLinuxAdditions.run if the disc is mounted anywhere we
# know to look, including our own mountpoint.
find_installer() {
    local candidate
    for candidate in /media/"$USER"/VBox_GAs_*/VBoxLinuxAdditions.run \
        /media/cdrom/VBoxLinuxAdditions.run \
        /mnt/cdrom/VBoxLinuxAdditions.run \
        "$ELD_MOUNTPOINT"/VBoxLinuxAdditions.run; do
        if [ -f "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

# First optical device that actually has media in it.
disc_device() {
    local dev
    for dev in /dev/cdrom /dev/sr0 /dev/sr1; do
        # blkid fails on an empty drive, which is exactly the test we want.
        if [ -b "$dev" ] && sudo blkid "$dev" >/dev/null 2>&1; then
            printf '%s\n' "$dev"
            return 0
        fi
    done
    return 1
}

# Mounts an attached-but-unmounted disc read-only. Returns non-zero and
# cleans up if it isn't the Guest Additions disc.
try_mount_disc() {
    local dev
    dev="$(disc_device)" || return 1

    sudo mkdir -p "$ELD_MOUNTPOINT"
    if ! sudo mount -o ro "$dev" "$ELD_MOUNTPOINT" 2>/dev/null; then
        sudo rmdir "$ELD_MOUNTPOINT" 2>/dev/null || true
        return 1
    fi
    eld_mounted=1

    if [ ! -f "$ELD_MOUNTPOINT/VBoxLinuxAdditions.run" ]; then
        log "guest-additions: $dev is mounted but isn't the Guest Additions disc"
        cleanup_mount
        return 1
    fi

    log "guest-additions: mounted $dev at $ELD_MOUNTPOINT"
    return 0
}

if have_cmd VBoxClient && [ -f "$DONE_MARKER" ]; then
    log "guest-additions: already installed, skipping (delete $DONE_MARKER to force a re-run)"
    exit 0
fi

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: locate or mount the Guest Additions disc (prompting to insert it if absent)"
    log "dry-run: install kernel headers/dkms, then run VBoxLinuxAdditions.run"
    exit 0
fi

# --- locate the disc --------------------------------------------------------
installer=""
while true; do
    # Already mounted by the desktop?
    if installer="$(find_installer)"; then
        break
    fi
    # Attached but not mounted — mount it ourselves.
    if try_mount_disc && installer="$(find_installer)"; then
        break
    fi

    # Nothing there. Ask, unless there's no terminal to ask with — under
    # `curl | bash` stdin is the pipe, so this reads /dev/tty explicitly.
    if ! have_tty; then
        log "guest-additions: no disc found and no terminal to prompt with — skipping."
        log "guest-additions: insert the disc (Devices -> Insert Guest Additions CD image) and re-run ./install.sh"
        exit 0
    fi

    echo
    echo "  Guest Additions disc not found. This enables clipboard sharing,"
    echo "  shared folders and display resizing."
    echo
    echo "  In the VirtualBox window menu, choose:"
    echo "      Devices -> Insert Guest Additions CD image..."
    echo
    reply=""
    read -r -p "  Press Enter once inserted to retry, or 's' to skip: " reply </dev/tty || reply="s"
    case "$reply" in
        [Ss]*)
            log "guest-additions: skipped by user — re-run ./install.sh later to install it"
            exit 0
            ;;
    esac
done

# --- install ----------------------------------------------------------------
# The installer builds kernel modules, so it needs a toolchain and the headers
# for the running kernel.
apt_install dkms build-essential "linux-headers-$(uname -r)"

log "guest-additions: running $installer"
# Exit 2 means "installed, reboot required to load the new modules" — that's a
# success, not a failure, so it's folded into the reboot marker below.
rc=0
sudo sh "$installer" || rc=$?
if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then
    log "guest-additions: installer exited $rc"
    exit 1
fi

# Shared folders show up as group vboxsf; without membership they're root-only
# and the folder looks empty.
if ! id -nG "$USER" | grep -qw vboxsf; then
    sudo usermod -aG vboxsf "$USER"
    log "guest-additions: added $USER to the vboxsf group (shared folders)"
fi

touch "$DONE_MARKER"
mark_needs_reboot
log "guest-additions: done — reboot required to load the new kernel modules"
