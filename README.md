# effective-popos-default

An idempotent shell-script setup for building (and rebuilding) a Pop!_OS VirtualBox VM exactly the way I like it — Terminator, zsh, desktop, and a growing set of dev tooling. Sibling to the `effective_kali` branch, ported for Pop!_OS.

Targets **Pop!_OS 22.04 LTS**, which is built on Ubuntu 22.04 ("Jammy Jellyfish") and reports `jammy` as its codename — that's what the apt repo setup keys off. Unlike Kali's rolling release, package availability varies meaningfully by release, so this is written and checked against 22.04 specifically.

## Quickstart

On a fresh Pop!_OS 22.04 install:

```
curl -fsSL https://raw.githubusercontent.com/gvgtw/effective-linux-default/effective_popos/install.sh | bash
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
| `01-github-cli.sh` | Installs GitHub CLI (`gh`) via the official apt repo |
| `02-passwordless-sudo.sh` | Grants passwordless sudo via a `visudo`-validated `/etc/sudoers.d/` entry |
| `03-gh-auth.sh` | Asks whether you want to authenticate now; if yes, runs `gh auth login` interactively — paste your fine-grained PAT when prompted (skipped entirely if already authenticated) |
| `10-cleanup.sh` | Removes `~/Music`, `~/Videos`, `~/Templates`, `~/Public` — and repoints them at `$HOME` in `user-dirs.dirs` so GNOME doesn't recreate them |
| `20-terminator.sh` | Installs Terminator, stock config |
| `30-shell.sh` | Installs zsh + Oh My Zsh (stock theme/plugins) with `zsh-autosuggestions` and `zsh-syntax-highlighting`, then makes zsh the default shell |
| `40-desktop.sh` | Default/monospace fonts (via `gsettings`, plus `fonts-hack`), Terminator autostart |
| `50-guest-additions.sh` | Installs VirtualBox Guest Additions from the host's ISO (clipboard, shared folders, display resizing) |
| `60-dev-tools.sh` | Installs whatever's listed in `config/dev-packages.list` |
| `65-dev-directory.sh` | Creates `~/Dev` — the intended root for all dev projects and where Claude Code is meant to run from |
| `70-claude-code.sh` | Installs the Claude Code CLI via the native installer (updates it if already installed) |

## How it works

- **Self-bootstrapping**: `install.sh` is the one entry point for both the first run (via `curl \| bash`) and every later rebuild. If it can't find a local `modules/` directory next to itself, it clones/pulls the repo and re-execs itself from there.
- **Idempotent**: every module is safe to re-run. Packages are only installed if missing; config files are either fully owned/regenerated (autostart entry), updated via a marker-guarded block (`.zshrc`), or written only after validation (the sudoers fragment) — so re-running never corrupts anything.
- **`~/.zshrc` is not ours.** Oh My Zsh writes it on first install and this branch never overwrites it afterwards; our additions go in a marker-guarded block appended at the end. That matters because the Claude Code installer appends its own `PATH` line to the same file — a module that rewrote `.zshrc` wholesale would silently delete it on the second rebuild.
- **One reboot, at the end, only if needed**: the sudoers change applies immediately and `chsh` takes effect at next login, so most runs need no reboot. Guest Additions is the exception — it builds kernel modules, so a run that installs it flags a reboot and `install.sh` does it once at the very end with a cancellable countdown.
- A failure in one module doesn't stop the rest — `install.sh` prints an OK/FAILED summary for every module at the end.

## Extending it

`config/dev-packages.list` is the intended place to grow dev tooling as needs become concrete — add a package name per line, commit, `git pull && ./install.sh`. Unlike the Kali branch, this list has to carry more of its own weight: there's no `pimpmykali`-equivalent quietly installing things for you, and `git`/`curl`/`build-essential` are **not** preinstalled.

To add a whole new step, drop a numbered script in `modules/` (following the existing idempotency patterns in `lib/common.sh`) — `install.sh` picks up anything in that directory automatically, in numeric order.

## Left manual, on purpose

- **Git identity** (`git config --global user.name/user.email`) — personal values that shouldn't be hardcoded into a public script, and a curl-piped script has no interactive stdin to prompt with anyway.
- **Claude Code login** — `70-claude-code.sh` installs the CLI, but logging in is an interactive browser OAuth flow; run `claude` from `~/Dev` (or a project under it) afterward to authenticate.
- **Inserting the Guest Additions CD image** — `50-guest-additions.sh` installs from the ISO the host provides (Devices → Insert Guest Additions CD image), because that's always version-matched to your VirtualBox host. If the ISO isn't mounted the module says so and exits cleanly; insert it and re-run `install.sh`.

`03-gh-auth.sh` is the one interactive step that runs inline. It asks `Would you like to complete GitHub authentication now? [y/N]` and only launches the login flow if you say yes. It reads from `/dev/tty` explicitly so it still works when `install.sh` was invoked via `curl | bash` (where stdin is the pipe, not a terminal), and skips itself entirely if `gh auth status` already shows you're logged in.

## Different from effective_kali

- No `pimpmykali` equivalent (Kali-only tool, detects/fixes Kali specifically) — this branch starts straight from the GitHub CLI/sudo/auth bootstrap steps.
- Passwordless sudo is a `/etc/sudoers.d/` fragment instead of `kali-grant-root`, always `visudo -c` validated before being installed so a bad fragment never lands and locks out sudo.
- **Terminator is installed and left alone.** The Kali branch bakes in a full config (Dark-Pastel profile from the TerminatorThemes plugin, custom keybindings/layout); that config was written against Kali's Terminator build and its theme assets, and porting it here left Terminator broken. Stock defaults work fine.
- **zsh is configured with Oh My Zsh** rather than the Kali branch's hand-rolled prompt/alias override block.
- Font settings use `gsettings` (GNOME) instead of `xfconf-query` (XFCE), and `fonts-hack` has to be installed explicitly — it ships with Kali's desktop but not with Pop!_OS, and `gsettings` accepts an unavailable font name without complaint, so leaving it out meant the monospace setting silently did nothing.
- `10-cleanup.sh` also has to rewrite `~/.config/user-dirs.dirs`. Kali already ships with those four entries pointed at `$HOME`; Pop!_OS doesn't, so `xdg-user-dirs-update` recreated all four at the next login until this branch started repointing them.
- Guest Additions comes from the host ISO rather than apt: `virtualbox-guest-x11` is in `multiverse` and pinned to 6.1.32 on jammy, which breaks display auto-resize and clipboard against a VirtualBox 7.x host.
