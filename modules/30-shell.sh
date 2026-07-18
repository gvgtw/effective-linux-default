#!/usr/bin/env bash
# Installs zsh and writes the final ~/.zshrc directly from config/zshrc.tpl —
# unlike the effective_kali branch, there's no pre-existing Ubuntu .zshrc
# structure to override, so this branch just fully owns the file (same
# pattern as modules/20-terminator.sh).
set -euo pipefail

ZSHRC="$HOME/.zshrc"
ZSHRC_TPL="$ELD_REPO_DIR/config/zshrc.tpl"

apt_install zsh zsh-syntax-highlighting zsh-autosuggestions

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: install $ZSHRC_TPL -> $ZSHRC"
    log "dry-run: chsh -s \$(command -v zsh) $USER (if not already the default shell)"
    exit 0
fi

backup_file "$ZSHRC"
cp "$ZSHRC_TPL" "$ZSHRC"
log "shell: wrote $ZSHRC"

zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$current_shell" = "$zsh_path" ]; then
    log "shell: $USER's default shell is already zsh, skipping chsh"
else
    # Run through sudo, not a plain `chsh` — chsh on your own account prompts
    # for your password via PAM; sudo (already cached for this run) avoids it.
    sudo chsh -s "$zsh_path" "$USER"
    log "shell: set $USER's default shell to $zsh_path (takes effect next login)"
fi
