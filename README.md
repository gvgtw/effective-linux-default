# effective-ubuntu-default

An idempotent shell-script setup for building (and rebuilding) an Ubuntu VirtualBox VM exactly the way I like it — Terminator, zsh, desktop, and a growing set of dev tooling. Sibling to the `effective_kali` branch, ported for Ubuntu.

Targets **Ubuntu 24.04 LTS ("Noble Numbat")**, the current LTS — unlike Kali's rolling release, package availability varies meaningfully by Ubuntu release, so this is written and checked against Noble specifically.

## Quickstart

On a fresh Ubuntu 24.04 Desktop install:

```
curl -fsSL https://raw.githubusercontent.com/gvgtw/effective-linux-default/effective_ubuntu/install.sh | bash
```

This clones the repo to `~/effective-linux-default` and runs `install.sh`. It will ask for your sudo password once and cache it for the whole run.

Later, to rebuild after editing config (idempotent — safe to re-run any time, e.g. after adding a package to `config/dev-packages.list`):

```
cd ~/effective-linux-default && git pull && ./install.sh
```

Flags:
- `--dry-run` — print what each module would do without changing anything
- `--no-reboot` — skip the automatic end-of-run reboot even if one's recommended (in practice, nothing on this branch requests one — see "How it works" below)

## What it does

Runs `modules/*.sh` in order, all in one continuous pass:

| Module | Does |
|---|---|
| `01-github-cli.sh` | Installs GitHub CLI (`gh`) via the official apt repo |
| `02-passwordless-sudo.sh` | Grants passwordless sudo via a `visudo`-validated `/etc/sudoers.d/` entry |
| `03-gh-auth.sh` | Runs `gh auth login` interactively — paste your fine-grained PAT when prompted (skipped if already authenticated) |
| `10-cleanup.sh` | Removes `~/Music`, `~/Videos`, `~/Templates`, `~/Public` |
| `20-terminator.sh` | Installs Terminator and writes the final config directly (Dark-Pastel-based profile, custom keybindings/layout, theme picker plugin) |
| `30-shell.sh` | Installs zsh and writes a complete `~/.zshrc`: oneline prompt, syntax-highlight colors, history/completion/keybinding defaults, `lt`/`lla` aliases — then makes zsh the default shell |
| `40-desktop.sh` | Default/monospace fonts (via `gsettings`), Terminator autostart |
| `50-guest-additions.sh` | Installs VirtualBox guest utilities (clipboard, shared folders, display resizing) |
| `60-dev-tools.sh` | Installs whatever's listed in `config/dev-packages.list` |
| `65-dev-directory.sh` | Creates `~/Dev` — the intended root for all dev projects and where Claude Code is meant to run from |
| `70-claude-code.sh` | Installs the Claude Code CLI via the native installer (updates it if already installed) |

## How it works

- **Self-bootstrapping**: `install.sh` is the one entry point for both the first run (via `curl \| bash`) and every later rebuild. If it can't find a local `modules/` directory next to itself, it clones/pulls the repo and re-execs itself from there.
- **Idempotent**: every module is safe to re-run. Packages are only installed if missing; config files are either fully owned/regenerated (Terminator config, `.zshrc`, autostart entry) or written only after validation (the sudoers fragment) — so re-running never corrupts anything.
- **No reboot needed on this branch.** Unlike `effective_kali` (which has to deal with `pimpmykali`/`kali-grant-root` both recommending one), nothing here requires it: the sudoers change applies immediately, and a shell change via `chsh` just takes effect on your next login. `install.sh` still checks for a reboot marker at the end (shared code with the Kali branch) — it'll just always report "no reboot needed" here.
- A failure in one module doesn't stop the rest — `install.sh` prints an OK/FAILED summary for every module at the end.

## Extending it

`config/dev-packages.list` is the intended place to grow dev tooling as needs become concrete — add a package name per line, commit, `git pull && ./install.sh`. Unlike the Kali branch, this list has to carry more of its own weight: there's no `pimpmykali`-equivalent quietly installing things for you, and `git`/`curl`/`build-essential` are confirmed **not** preinstalled on Ubuntu 24.04 Desktop.

To add a whole new step, drop a numbered script in `modules/` (following the existing idempotency patterns in `lib/common.sh`) — `install.sh` picks up anything in that directory automatically, in numeric order.

## Left manual, on purpose

- **Git identity** (`git config --global user.name/user.email`) — personal values that shouldn't be hardcoded into a public script, and a curl-piped script has no interactive stdin to prompt with anyway.
- **Claude Code login** — `70-claude-code.sh` installs the CLI, but logging in is an interactive browser OAuth flow; run `claude` from `~/Dev` (or a project under it) afterward to authenticate.

`03-gh-auth.sh` is the one exception: it's genuinely interactive (`gh auth login`, paste your fine-grained PAT when prompted) but still runs as part of the script rather than being left to the user. It reads from `/dev/tty` explicitly so it still works when `install.sh` was invoked via `curl | bash` (where stdin is the pipe, not a terminal), and skips itself entirely if `gh auth status` already shows you're logged in.

## Different from effective_kali

- No `pimpmykali` equivalent (Kali-only tool, detects/fixes Kali specifically) — this branch starts straight from the GitHub CLI/sudo/auth bootstrap steps.
- Passwordless sudo is a `/etc/sudoers.d/` fragment instead of `kali-grant-root`, always `visudo -c` validated before being installed so a bad fragment never lands and locks out sudo.
- `~/.zshrc` is a complete, self-owned file (`config/zshrc.tpl`) rather than an appended override block — a fresh Ubuntu zsh install has no pre-built config like Kali's to override.
- Font settings use `gsettings` (GNOME) instead of `xfconf-query` (XFCE). No wallpaper/lock-screen theming — the Kali-branded assets don't apply here and weren't replaced with anything.
