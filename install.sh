#!/usr/bin/env bash
# effective-linux-default — Pop!_OS provisioning script.
#
# First run (fresh Pop!_OS 22.04 LTS install):
#   curl -fsSL https://raw.githubusercontent.com/gvgtw/effective-linux-default/effective_popos/install.sh | bash
#
# Later, to rebuild after editing config (idempotent, safe to re-run):
#   cd ~/effective-linux-default && git pull && ./install.sh
#
# Flags:
#   --dry-run     print intended actions without changing anything
#   --no-reboot   don't auto-reboot even if a module flagged one as needed
set -euo pipefail

REPO_URL="https://github.com/gvgtw/effective-linux-default.git"
REPO_BRANCH="effective_popos"
DEFAULT_CLONE_DIR="$HOME/effective-linux-default"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/modules" ]; then
    ELD_REPO_DIR="$SCRIPT_DIR"
else
    ELD_REPO_DIR="$DEFAULT_CLONE_DIR"
    if [ -d "$ELD_REPO_DIR/.git" ]; then
        echo "Updating existing checkout at $ELD_REPO_DIR"
        git -C "$ELD_REPO_DIR" pull --ff-only
    else
        echo "Cloning effective-linux-default to $ELD_REPO_DIR"
        git clone --branch "$REPO_BRANCH" "$REPO_URL" "$ELD_REPO_DIR"
    fi
    exec "$ELD_REPO_DIR/install.sh" "$@"
fi
export ELD_REPO_DIR

# shellcheck source=lib/common.sh
source "$ELD_REPO_DIR/lib/common.sh"

ELD_DRY_RUN=0
ELD_NO_REBOOT=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) ELD_DRY_RUN=1 ;;
        --no-reboot) ELD_NO_REBOOT=1 ;;
        *) echo "Unknown flag: $arg" >&2; exit 1 ;;
    esac
done
export ELD_DRY_RUN

log "Starting effective-linux-default install.sh (dry-run=$ELD_DRY_RUN)"

sudo -v
(
    while kill -0 "$$" 2>/dev/null; do
        sudo -n true
        sleep 60
    done
) 2>/dev/null &
KEEPALIVE_PID=$!
trap 'kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT

results=()
for module in "$ELD_REPO_DIR"/modules/*.sh; do
    name="$(basename "$module")"
    log "==> $name"
    if ( source "$module" ); then
        results+=("OK      $name")
    else
        results+=("FAILED  $name")
        log "!! $name failed — continuing with remaining modules"
    fi
done

log "Summary:"
for r in "${results[@]}"; do
    log "  $r"
done

if [ -f "$ELD_REBOOT_MARKER" ]; then
    if [ "$ELD_NO_REBOOT" = "1" ] || [ "$ELD_DRY_RUN" = "1" ]; then
        log "Reboot recommended to finalize changes."
        log "Run again without --no-reboot, or 'sudo reboot' manually, then 'rm $ELD_REBOOT_MARKER'."
    else
        log "All done. Rebooting in 10s to finalize changes — press Ctrl+C to cancel."
        sleep 10
        rm -f "$ELD_REBOOT_MARKER"
        sudo reboot
    fi
else
    log "All done. No reboot needed."
fi
