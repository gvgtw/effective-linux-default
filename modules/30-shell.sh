#!/usr/bin/env bash
# Instead of sed-patching specific lines inside Kali's default .zshrc (fragile
# across Kali releases), redefine configure_prompt() and override the
# variables/styles/aliases it depends on in one appended, marker-guarded
# block at the end of the file. Function redefinition + PROMPT_ALTERNATIVE
# reassignment + re-calling configure_prompt reproduces the README's manual
# edits regardless of how the rest of the file is written.
set -euo pipefail

ZSHRC="$HOME/.zshrc"

read -r -d '' BLOCK <<'EOF' || true
configure_prompt() {
    prompt_symbol=㉿
    PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n'$prompt_symbol$'%m%b%F{reset}:%B%F{blue}%~ %b%F{reset}%(#.#.$) '
    RPROMPT=
    unset prompt_symbol
}
PROMPT_ALTERNATIVE=oneline
NEWLINE_BEFORE_PROMPT=no
configure_prompt

ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta

alias lt='ls -lArt'
alias lla='la -lA'
EOF

if [ "${ELD_DRY_RUN:-0}" = "1" ]; then
    log "dry-run: ensure zsh-overrides block in $ZSHRC"
    exit 0
fi

backup_file "$ZSHRC"
ensure_block_in_file "$ZSHRC" "zsh-overrides" "$BLOCK"
log "shell: updated $ZSHRC"
