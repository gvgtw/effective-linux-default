#!/usr/bin/env bash
# Enables passwordless sudo via kali-grant-root, reproducing the manual
# "select Enable password-less privilege escalation" debconf prompt
# non-interactively. Checks /etc/group directly (not the current session's
# cached group list) so it's accurate even before the reboot/relogin that
# would normally refresh group membership.
set -euo pipefail

apt_install kali-grant-root

current_members="$(getent group kali-trusted | cut -d: -f4)"
if [ "${ELD_DRY_RUN:-0}" != "1" ] && echo ",${current_members}," | grep -q ",${USER},"; then
    log "passwordless-sudo: $USER already in kali-trusted, skipping"
    exit 0
fi

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: preseed kali-grant-root/policy=enable and dpkg-reconfigure"
    exit 0
fi

log "passwordless-sudo: enabling via kali-grant-root"
echo "kali-grant-root kali-grant-root/policy select enable" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure kali-grant-root

mark_needs_reboot
log "passwordless-sudo: done"
