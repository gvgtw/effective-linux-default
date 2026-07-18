#!/usr/bin/env bash
# Installs GitHub CLI (gh) via the official apt repo.
set -euo pipefail

if have_cmd gh; then
    log "github-cli: gh already installed, skipping"
    exit 0
fi

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: add cli.github.com apt repo and install gh"
    exit 0
fi

log "github-cli: adding apt repo"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages $(lsb_release -cs) main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

sudo apt-get update
apt_install gh
log "github-cli: done"
