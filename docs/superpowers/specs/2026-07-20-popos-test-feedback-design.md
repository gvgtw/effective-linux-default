# Pop!_OS first-test feedback — design

Date: 2026-07-20
Status: approved, ready for implementation planning

Six changes arising from the first real Pop!_OS 22.04 VM test. Five are
adjustments to existing behavior; the sixth adds a new capability.

---

## 1. README: prerequisites section

Add a **Before you start** section above Quickstart, listing the steps that
must be done by hand on a fresh VM, in order:

```
sudo apt update
sudo apt install curl git
```
Then, from the VirtualBox window menu: Devices → Insert Guest Additions CD
image, followed by:
```
/media/$USER/VBox_GAs_*/autorun.sh
```
Then reboot.

Use `$USER`, not a literal username — the path is per-account.

State the reason in one line: Pop!_OS 22.04 ships neither `curl` nor `git`,
and without Guest Additions there is no clipboard sharing, so there is no
practical way to get the install command into the VM.

Delete the Guest Additions bullet from **Left manual, on purpose** — it is a
prerequisite now, not a runtime prompt.

## 2. Delete `modules/70-guest-additions.sh`

Guest Additions becomes a documented prerequisite rather than a module.

- Delete the module file and its README table row.
- Keep `have_tty` in `lib/common.sh` — `modules/20-gh-auth.sh` still uses it.
- The `ELD_MOUNTPOINT` variable, disc-mounting logic, and insert-the-disc
  prompt are removed with the module. Nothing else references them.

Rationale: with the manual install done first, the module's skip check
(`have_cmd VBoxClient && [ -f "$DONE_MARKER" ]`) would fail on the marker,
causing a full redundant reinstall plus a forced reboot on every fresh VM.

## 3. Reboot becomes unconditional

`install.sh` currently gates the end-of-run reboot on `$ELD_REBOOT_MARKER`
(line 79). Remove the gate so the cancellable countdown always runs.

- `--no-reboot` and `--dry-run` still suppress the reboot and print the
  existing advisory instead.
- Keep the stale-marker cleanup.
- `mark_needs_reboot` stays defined in `lib/common.sh` but no longer gates
  anything. Rewrite its comment to say so — do not leave a comment describing
  behavior the code no longer has.
- Update the README bullet from "at most one reboot, at the very end" to
  reflect that every run ends with a cancellable reboot.

Rationale: `chsh`, group membership, and PATH changes only fully take effect
on a new login. This supersedes the earlier "routine rebuilds must not reboot"
decision; the cost on a no-op rebuild is one keypress.

## 4. New `modules/55-bash.sh`

Puts `~/.local/bin` on PATH for bash, mirroring what the eld block in
`.zshrc` already does for zsh. Without it the Claude Code installer warns
that `~/.local/bin` is not on PATH.

- Use `ensure_block_in_file` with marker `bash`, not a raw `>>` append — a
  raw append duplicates the line on every re-run.
- Reuse the same guard as `50-zsh.sh` so PATH is not double-prepended:
  ```
  case ":$PATH:" in
      *":$HOME/.local/bin:"*) ;;
      *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
  ```
- No `source ~/.bashrc`. It has no effect from a non-interactive script; the
  change lands on next shell.
- Honor `ELD_DRY_RUN`.
- Numbered 55 so it runs before `95-claude-code.sh`.
- Add a README table row.

## 5. Oh My Zsh theme: `clean` → `risto`

Change `OMZ_THEME` in `modules/50-zsh.sh` and the README table's theme
mention. The module's existing in-place `sed` on the `ZSH_THEME` line already
migrates an installed VM on its next run; no additional work.

## 6. Two Claude Code contexts

Two working modes with different instructions and skills: **build**
(agent-heavy vibe-coding) and **learn** (Claude teaches and guides rather
than writing the code). Context is a property of the project directory, not
of the session — you `cd` and run `claude`, with no mode to remember.

### Verified discovery behavior

Tested on 2026-07-20 against the installed Claude Code binary, with a probe
skill and marker file two directories above the working directory:

| Parent-directory asset | non-git subdir | git repo |
|---|---|---|
| `CLAUDE.md` | discovered | **discovered** |
| `.claude/skills/` | discovered | **NOT discovered** |

**Skill discovery stops at the git repo root; CLAUDE.md discovery does not.**
This is why skills cannot simply live beside each context's CLAUDE.md — real
projects are git repos, and the skills would be silently invisible.

### Repo layout

New `config/claude/` subtree:

```
config/claude/
  build/CLAUDE.md
  learn/CLAUDE.md
  skills/
    build-*/SKILL.md
    learn-*/SKILL.md
```

### Directory convention

`modules/85-dev-directory.sh` extends to create `~/Dev/build/` and
`~/Dev/learn/`. Projects are created or cloned one level down
(`~/Dev/learn/rust-basics`), where the parent CLAUDE.md reaches them across
the git boundary.

`~/Dev` itself gets no CLAUDE.md — a project sitting directly in it is
unconfigured rather than wrongly configured.

### New `modules/86-claude-contexts.sh`

- Copies `config/claude/build/CLAUDE.md` → `~/Dev/build/CLAUDE.md` and
  `config/claude/learn/CLAUDE.md` → `~/Dev/learn/CLAUDE.md`. The repo is
  source of truth; the module regenerates these, calling `backup_file` on
  first overwrite. Safe to own outright — unlike `.zshrc`, nothing else
  writes them.
- Mirrors `config/claude/skills/*` into `~/.claude/skills/`, **per skill
  directory, never a blanket wipe of `~/.claude/skills/`**. Hand-written
  skills living there must survive re-runs; only eld-managed skill
  directories are refreshed.
- Honors `ELD_DRY_RUN`.
- Add a README table row and a short section documenting the two contexts and
  the one-level-down project convention.

### Isolation model

Both skill sets are installed at user level and load in every session.
Isolation is **by instruction, not enforcement**: each context's CLAUDE.md
names which prefix to use and states that the other is to be ignored. This is
the deliberate trade for setup that is genuinely automatic in any repo at any
depth.

### Content: placeholders first

The user's real CLAUDE.md and skill content is not on this machine. Build the
plumbing with clearly-marked placeholder files; the user fills in
`config/claude/` afterward. Placeholders must be obviously placeholders —
not plausible-looking instructions that could be mistaken for finished
content.

### Open risk

Committing this content to `effective-linux-default` puts personal prompting
content in a public repo. Fine for generic teaching instructions; review
before committing anything referencing private projects or employer
specifics.

---

## Out of scope

- Session-level context switching or `CLAUDE_CONFIG_DIR` profiles. Confirmed
  supported by the binary, but rejected: the context is a property of the
  project, and separate config dirs would require logging in twice.
- Per-project skill copying or symlinking. Rejected as not automatic.
- Making modules report whether they changed anything, to keep no-op rebuilds
  reboot-free. Rejected as a larger refactor than the rest of this work
  combined.
