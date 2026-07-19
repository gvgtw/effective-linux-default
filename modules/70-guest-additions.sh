#!/usr/bin/env bash
# VirtualBox Guest Additions, installed from the ISO the host provides
# (Devices -> Insert Guest Additions CD image...) rather than from apt.
#
# apt's virtualbox-guest-x11 lives in multiverse and is pinned to 6.1.32 on
# jammy, which is what Pop!_OS 22.04 resolves to. Against a VirtualBox 7.x
# host that version mismatch is what breaks display auto-resize and clipboard
# sharing. The ISO always matches the host exactly, so that's what we use.
#
# The trade-off is that this one step isn't fully unattended: the ISO has to
# be inserted from the host's menu. If it isn't there, this module logs how
# to do it and exits successfully rather than failing the run — re-run
# install.sh once the ISO is mounted and it'll pick it up.
set -euo pipefail

DONE_MARKER="$ELD_HOME/guest-additions-done"

find_installer() {
    local candidate
    for candidate in /media/"$USER"/VBox_GAs_*/VBoxLinuxAdditions.run \
        /media/cdrom/VBoxLinuxAdditions.run \
        /mnt/cdrom/VBoxLinuxAdditions.run; do
        if [ -f "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

if have_cmd VBoxClient && [ -f "$DONE_MARKER" ]; then
    log "guest-additions: already installed, skipping (delete $DONE_MARKER to force a re-run)"
    exit 0
fi

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: install kernel headers/dkms, then run VBoxLinuxAdditions.run from the mounted Guest Additions ISO"
    exit 0
fi

# The installer builds kernel modules, so it needs a toolchain and the
# headers for the running kernel.
apt_install dkms build-essential "linux-headers-$(uname -r)"

if ! installer="$(find_installer)"; then
    log "guest-additions: Guest Additions ISO not mounted — skipping."
    log "guest-additions: in the VirtualBox window, choose Devices -> Insert Guest Additions CD image,"
    log "guest-additions: then re-run ./install.sh to complete this step."
    exit 0
fi

log "guest-additions: running $installer"
# Exit 2 means "installed, reboot required to load the new modules" — that's
# a success, not a failure, so it's folded into the reboot marker below.
rc=0
sudo sh "$installer" || rc=$?
if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then
    log "guest-additions: installer exited $rc"
    exit 1
fi

# Shared folders show up as group vboxsf; without membership they're
# root-only and the folder looks empty.
if ! id -nG "$USER" | grep -qw vboxsf; then
    sudo usermod -aG vboxsf "$USER"
    log "guest-additions: added $USER to the vboxsf group (shared folders)"
fi

touch "$DONE_MARKER"
mark_needs_reboot
log "guest-additions: done — reboot required to load the new kernel modules"
