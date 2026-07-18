# effective-kali-default

An idempotent shell-script setup for building (and rebuilding) a Kali Linux VirtualBox VM exactly the way I like it — Terminator, shell, desktop, and a growing set of dev tooling.

## Before you run anything

Change the default password first — this is intentionally left manual, not something a public script should ever do non-interactively:

```
sudo passwd kali
```

## Quickstart

On a fresh Kali VM:

```
curl -fsSL https://raw.githubusercontent.com/gvgtw/effective-linux-default/effective_kali/install.sh | bash
```

This clones the repo to `~/effective-linux-default` and runs `install.sh`. It will ask for your sudo password once and cache it for the whole run.

Later, to rebuild after editing config (idempotent — safe to re-run any time, e.g. after adding a package to `config/dev-packages.list`):

```
cd ~/effective-linux-default && git pull && ./install.sh
```

Flags:
- `--dry-run` — print what each module would do without changing anything
- `--no-reboot` — skip the automatic end-of-run reboot even if one's recommended

## What it does

Runs `modules/*.sh` in order, all in one continuous pass:

| Module | Does |
|---|---|
| `00-pimpmykali.sh` | Clones/updates [pimpmykali](https://github.com/Dewalt-arch/pimpmykali) and runs it with `--autonoroot` (non-interactive) |
| `01-github-cli.sh` | Installs GitHub CLI (`gh`) via the official apt repo |
| `02-passwordless-sudo.sh` | Enables passwordless sudo via `kali-grant-root` (preseeded, non-interactive) |
| `10-cleanup.sh` | Removes `~/Music`, `~/Videos`, `~/Templates`, `~/Public` |
| `20-terminator.sh` | Installs Terminator and writes the final config directly (Dark-Pastel-based profile, custom keybindings/layout, theme picker plugin) |
| `30-shell.sh` | Appends an override block to `~/.zshrc`: oneline prompt, syntax-highlight colors, `lt`/`lla` aliases |
| `40-desktop.sh` | Wallpaper, lock-screen background, default/monospace fonts, Terminator autostart |
| `50-guest-additions.sh` | Installs VirtualBox guest utilities (clipboard, shared folders, display resizing) |
| `60-dev-tools.sh` | Installs whatever's listed in `config/dev-packages.list` |

## How it works

- **Self-bootstrapping**: `install.sh` is the one entry point for both the first run (via `curl \| bash`) and every later rebuild. If it can't find a local `modules/` directory next to itself, it clones/pulls the repo and re-execs itself from there.
- **Idempotent**: every module is safe to re-run. Packages are only installed if missing, config files are either fully owned/regenerated (Terminator config, autostart entry) or updated via a marker-guarded block (`.zshrc`) rather than blind `sed` patches — so re-running after a Kali update doesn't corrupt anything.
- **One reboot, at the end**: `pimpmykali` and `kali-grant-root` both recommend a reboot, but neither blocks the rest of the script, so everything runs straight through and reboots (with a cancellable countdown) only once, at the very end — and only on a run where one of those two actually changed something. Routine "rebuild as I go" re-runs, where those two are already applied, finish with no reboot at all.
- A failure in one module doesn't stop the rest — `install.sh` prints an OK/FAILED summary for every module at the end.

## Extending it

`config/dev-packages.list` is the intended place to grow dev tooling as needs become concrete — add a package name per line, commit, `git pull && ./install.sh`. It intentionally starts minimal (git, build-essential, curl, tmux, jq, unzip) rather than guessing at languages/tooling up front.

To add a whole new step, drop a numbered script in `modules/` (following the existing idempotency patterns in `lib/common.sh`) — `install.sh` picks up anything in that directory automatically, in numeric order.

## Left manual, on purpose

- **`sudo passwd kali`** — see above.
- **Git identity** (`git config --global user.name/user.email`) — personal values that shouldn't be hardcoded into a public script, and a curl-piped script has no interactive stdin to prompt with anyway.

