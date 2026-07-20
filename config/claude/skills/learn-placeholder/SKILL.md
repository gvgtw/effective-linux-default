---
name: learn-placeholder
description: Placeholder scaffolding with no function. Never invoke this skill; it exists only so the provisioning script has a learn-context skill to sync. Delete it once real learn-* skills are added.
---

# PLACEHOLDER — delete this skill

This directory exists so `modules/86-claude-contexts.sh` has something to sync
while the real skills are still being written. It does nothing.

Replace it with the actual learn-context skills, one directory per skill, each
named `learn-<something>` with its own `SKILL.md`. Delete this directory once
at least one real one exists — `86-claude-contexts.sh` only syncs skill
directories that are present in the repo, so removing this one here stops it
being reinstalled, but you will need to delete the already-installed copy at
`~/.claude/skills/learn-placeholder/` by hand.
