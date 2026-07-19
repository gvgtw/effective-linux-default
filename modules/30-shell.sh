#!/usr/bin/env bash
# Installs zsh + Oh My Zsh with stock defaults, plus the two plugins worth
# having (autosuggestions, syntax highlighting).
#
# Unlike the effective_kali branch, this does NOT own ~/.zshrc. Oh My Zsh
# writes its own .zshrc on first install and this module never overwrites it
# afterwards — everything we add goes in a marker-guarded block appended at
# the end, via ensure_block_in_file. That block is also where ~/.local/bin
# gets onto PATH: the Claude Code installer (modules/70-claude-code.sh)
# appends its own PATH line to ~/.zshrc, and a module that rewrote the file
# wholesale on every run would silently delete it on the second rebuild.
set -euo pipefail

ZSHRC="$HOME/.zshrc"
OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}"
OMZ_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

apt_install zsh git curl

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: install Oh My Zsh (unattended) into $OMZ_DIR"
    log "dry-run: clone zsh-autosuggestions and zsh-syntax-highlighting into $OMZ_CUSTOM/plugins"
    log "dry-run: ensure eld block in $ZSHRC (plugin sourcing + ~/.local/bin on PATH)"
    log "dry-run: chsh -s \$(command -v zsh) $USER (if not already the default shell)"
    exit 0
fi

# --- Oh My Zsh itself -------------------------------------------------------
# First install lets the installer lay down its stock .zshrc (robbyrussell
# theme, plugins=(git)). Re-runs skip the installer entirely and just
# fast-forward the checkout, so a rebuild never touches .zshrc. RUNZSH=no
# stops the installer dropping us into an interactive zsh mid-script; CHSH=no
# leaves the shell change to the block at the bottom, which goes through the
# already-cached sudo instead of prompting via PAM.
if [ -d "$OMZ_DIR/.git" ]; then
    log "shell: Oh My Zsh already installed, updating"
    git -C "$OMZ_DIR" pull --ff-only --quiet || log "shell: Oh My Zsh update failed, continuing"
else
    log "shell: installing Oh My Zsh"
    backup_file "$ZSHRC"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL "$OMZ_INSTALL_URL")" "" --unattended
fi

# --- plugins ----------------------------------------------------------------
# Neither ships inside Oh My Zsh, so they're cloned into ZSH_CUSTOM. They get
# sourced explicitly in the block below rather than added to the plugins=()
# array, which would mean sed-ing a line inside a file we don't own.
clone_plugin() {
    local name="$1" url="$2" dest="$OMZ_CUSTOM/plugins/$1"
    if [ -d "$dest/.git" ]; then
        log "shell: $name already present, updating"
        git -C "$dest" pull --ff-only --quiet || log "shell: $name update failed, continuing"
    else
        log "shell: cloning $name"
        git clone --depth 1 --quiet "$url" "$dest"
    fi
}

clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git

# --- our additions ----------------------------------------------------------
# Appended at the end of .zshrc on purpose: zsh-syntax-highlighting has to be
# sourced last, after everything else that defines widgets.
ensure_block_in_file "$ZSHRC" "shell" 'ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ~/.local/bin is where the Claude Code native installer puts `claude`.
# Ubuntu/Pop only add it to PATH from ~/.profile, which zsh never reads.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

[ -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] &&
    source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# must stay last
[ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] &&
    source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"'
log "shell: ensured eld block in $ZSHRC"

# --- default shell ----------------------------------------------------------
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
