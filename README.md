# effective-linux-default

A single script that turns a fresh Pop!_OS VirtualBox VM into a ready-to-use development environment — Terminator, zsh, VS Code, GitHub CLI, and Claude Code — and that stays safe to re-run as your tooling grows.

Built for spinning up contained VMs to code and experiment in, without hand-configuring the same twelve things every time.

## Requirements

**Pop!_OS 22.04 LTS**, running in Oracle VirtualBox.

Grab the 22.04 ISO specifically — [System76's download page](https://system76.com/pop/download/) defaults to 24.04 now. 24.04 ships the COSMIC desktop, which has an [open bug where automatic screen resizing doesn't work inside a VM](https://github.com/pop-os/cosmic-epoch/issues/1351), and its config format is different enough that the desktop settings in this script wouldn't apply.

## Before you start

Four things have to be done by hand on a fresh VM, in this order. Pop!_OS 22.04
ships neither `curl` nor `git`, and without Guest Additions there's no
clipboard sharing — so without these there's no practical way to even get the
install command into the VM.

1. Update apt and install the two tools the installer needs:

   ```
   sudo apt update
   sudo apt install curl git
   ```

2. In the VirtualBox window menu, choose **Devices → Insert Guest Additions CD
   image...**

3. Run the installer from the disc:

   ```
   /media/$USER/VBox_GAs_*/autorun.sh
   ```

4. Reboot.

Attaching a virtual CD is a host-side action and a guest has no way to request
it, which is why this one can't be scripted from inside the VM.

## Quickstart

On a fresh VM:

```
curl -fsSL https://raw.githubusercontent.com/gvgtw/effective-linux-default/main/install.sh | bash
```

This clones the repo to `~/effective-linux-default` and runs it. You'll be asked for your sudo password, then whether you want to authenticate with GitHub — both in the first few seconds, so you can answer and walk away. The run ends with a reboot on a ten-second cancellable countdown.

To rebuild later — after adding a package, an extension, or a whole new module:

```
cd ~/effective-linux-default && git pull && ./install.sh
```

Flags:
- `--dry-run` — print what each module would do, change nothing
- `--no-reboot` — skip the end-of-run reboot

## What it does

Runs `modules/*.sh` in numeric order, in one continuous pass:

| Module | Does |
|---|---|
| `10-passwordless-sudo.sh` | Passwordless sudo via a `visudo`-validated `/etc/sudoers.d/` fragment |
| `15-github-cli.sh` | GitHub CLI (`gh`) from the official apt repo |
| `20-gh-auth.sh` | Asks whether to authenticate now; if yes, runs `gh auth login` so you can paste a PAT |
| `30-xdg-cleanup.sh` | Removes `~/Music`, `~/Videos`, `~/Templates`, `~/Public` — and stops GNOME recreating them |
| `40-terminator.sh` | Installs Terminator and applies the keybindings in `config/terminator-keybindings.conf` |
| `50-zsh.sh` | zsh + Oh My Zsh (`risto` theme) with autosuggestions and syntax highlighting; makes zsh your default shell |
| `55-bash.sh` | Puts `~/.local/bin` on `PATH` for bash, as `50-zsh.sh` does for zsh |
| `60-desktop.sh` | Default/monospace fonts, Terminator autostart |
| `80-dev-packages.sh` | Everything in `config/dev-packages.list` |
| `85-dev-directory.sh` | Creates `~/Dev` and its `build/` and `learn/` context directories |
| `86-claude-contexts.sh` | Installs each context's `CLAUDE.md` and syncs both skill sets into `~/.claude/skills/` |
| `90-vscode.sh` | VS Code from Microsoft's apt repo, plus everything in `config/vscode-extensions.list` |
| `95-claude-code.sh` | Claude Code CLI via the native installer (updates it if already present) |

## How it works

- **One entry point.** `install.sh` handles both the first `curl | bash` run and every rebuild. If it can't find a `modules/` directory next to itself, it clones the repo and re-execs from there.
- **Idempotent throughout.** Packages install only when missing. Config files are either fully owned and regenerated, updated through a marker-guarded block, or written only after validation. Re-running is a normal thing to do, not a risk.
- **`~/.zshrc` belongs to Oh My Zsh, not to this script.** Our additions go in a marker-guarded block appended at the end. This matters: the Claude Code installer appends its own `PATH` line to that same file, and a script that rewrote `.zshrc` wholesale would silently delete it on the second run.
- **One reboot, always, at the very end.** Modules never reboot mid-run; `install.sh` reboots once at the end with a cancellable countdown. It's unconditional because `chsh`, group membership and `PATH` changes only fully land on a new login, and that's cheaper to reason about than tracking which module changed what. `--no-reboot` skips it.
- **One module failing doesn't stop the rest.** You get an OK/FAILED summary for every module at the end.

## Claude Code contexts

Two working modes, chosen by where the project lives rather than by a flag you
have to remember:

| Directory | Context |
|---|---|
| `~/Dev/build/` | Agent-heavy vibe-coding |
| `~/Dev/learn/` | Claude teaches and guides instead of writing the code |

**Create projects one level down** — `~/Dev/learn/rust-basics`, not `~/Dev/rust-basics`.
Anything sitting directly in `~/Dev` gets no context at all, which is
deliberate: unconfigured beats wrongly configured.

Edit the contexts in `config/claude/`:

```
config/claude/
  build/CLAUDE.md          → ~/Dev/build/CLAUDE.md
  learn/CLAUDE.md          → ~/Dev/learn/CLAUDE.md
  skills/build-*/          → ~/.claude/skills/build-*/
  skills/learn-*/          → ~/.claude/skills/learn-*/
```

Both currently ship as **placeholders** — replace them with your own.

**Why the skills don't live next to their CLAUDE.md.** Claude Code finds a
`CLAUDE.md` by walking up the directory tree, and that walk crosses a git repo
boundary, so `~/Dev/learn/CLAUDE.md` reaches every project underneath. Skill
discovery *stops* at the repo root. Skills placed beside each `CLAUDE.md`
would therefore be invisible from inside any real project — the failure mode
being not an error but Claude quietly never using them. So both sets install
at user level, and each `CLAUDE.md` says which prefix to use and to ignore the
other. Both sets load in every session; the separation is by instruction, not
enforcement. That's the trade for setup that needs no per-project step.

Skills are synced one directory at a time, so anything you write by hand in
`~/.claude/skills/` survives a rebuild untouched. The flip side: deleting a
skill from `config/claude/skills/` stops it being reinstalled but doesn't
remove the copy already on the machine.

## Extending it

Three config files are the intended growth points — edit, commit, `git pull && ./install.sh`:

- `config/dev-packages.list` — apt packages
- `config/vscode-extensions.list` — VS Code extension IDs (`code --list-extensions` dumps what you have)
- `config/terminator-keybindings.conf` — Terminator keybindings

The two `.list` files start minimal on purpose rather than guessing at languages and toolchains up front.

**Terminator is only partly managed, deliberately.** The script owns the `[keybindings]` section of `~/.config/terminator/config` and nothing else — so colors, fonts, profiles and layouts you set through Preferences survive re-runs untouched. Once you've settled on the rest, the natural next step is to promote whichever sections you care about into a config file the same way.

For anything bigger, drop a numbered script in `modules/` — `install.sh` picks it up automatically. Use the helpers in `lib/common.sh` (`apt_install`, `ensure_block_in_file`, `backup_file`, `read_list_file`, `mark_needs_reboot`, `log`) so it inherits the same idempotency and dry-run behavior as everything else.

## Left manual, on purpose

- **Git identity** (`git config --global user.name/user.email`) — personal values that don't belong hardcoded in a public script, and a curl-piped script has no interactive stdin to prompt with anyway.
- **Claude Code login** — the CLI installs automatically, but logging in is an interactive browser OAuth flow. Run `claude` from a project under `~/Dev` afterward.
- **Guest Additions** — see [Before you start](#before-you-start). Attaching a virtual CD is a host-side action a guest can't request, and it has to happen before the script runs anyway, since without clipboard sharing there's no way to get the install command into the VM.

GitHub auth is the one interactive step that runs inline, and it asks first. It reads from `/dev/tty` so it works even under `curl | bash`, and skips itself entirely if you're already logged in.
