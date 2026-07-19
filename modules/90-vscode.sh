#!/usr/bin/env bash
# Installs Visual Studio Code from Microsoft's official apt repo, then
# reconciles the extensions listed in config/vscode-extensions.list.
#
# Same apt-repo pattern as modules/15-github-cli.sh, with one extra step: the
# `code` package's postinst asks whether to enable the Microsoft repo, which
# would block a non-interactive run. Preseeding that debconf question answers
# it up front.
#
# The extension pass runs on every invocation, not just the first — that's
# how newly added entries in the list file get picked up on a rebuild.
set -euo pipefail

EXTENSIONS_LIST="$ELD_REPO_DIR/config/vscode-extensions.list"
KEYRING="/usr/share/keyrings/microsoft.gpg"
SOURCES_FILE="/etc/apt/sources.list.d/vscode.sources"

# --- the editor itself ------------------------------------------------------
if have_cmd code; then
    log "vscode: code already installed, skipping install"
elif [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: preseed code/add-microsoft-repo, add packages.microsoft.com repo, install code"
else
    log "vscode: adding apt repo"
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections

    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc |
        sudo gpg --dearmor -o "$KEYRING"

    # deb822 format (apt >= 1.1, so fine on 22.04's apt 2.4) — this is the
    # layout Microsoft's own docs specify.
    sudo tee "$SOURCES_FILE" >/dev/null <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: $KEYRING
EOF

    sudo apt-get update
    apt_install code
    log "vscode: installed"
fi

# --- extensions -------------------------------------------------------------
mapfile -t extensions < <(read_list_file "$EXTENSIONS_LIST")

if [ "${#extensions[@]}" -eq 0 ]; then
    log "vscode: no extensions listed in $EXTENSIONS_LIST"
    exit 0
fi

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: install ${#extensions[@]} VS Code extension(s): ${extensions[*]}"
    exit 0
fi

# `code` won't be on PATH yet if the install above was skipped in a dry-run,
# or if the apt install failed earlier in this run.
if ! have_cmd code; then
    log "vscode: code not on PATH, skipping extensions"
    exit 0
fi

# --force is the idempotent path: it installs when missing, no-ops when the
# current version is already present, and never prompts.
for ext in "${extensions[@]}"; do
    if code --install-extension "$ext" --force >/dev/null 2>&1; then
        log "vscode: extension ok - $ext"
    else
        log "vscode: WARNING - failed to install extension $ext, continuing"
    fi
done
log "vscode: done"
