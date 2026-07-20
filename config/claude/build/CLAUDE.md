## Documentation files
- TODO.md — open tasks with [ ] checkboxes. Sections: In Progress, Up Next.
- BACKLOG.md — not-yet-actionable work. Sections: Backlog (future tasks),
  Direction (long-term intent, roadmap-level goals).
- PLAN.md — the current plan only: approach, scope, open questions.
  Completed plans move to docs/plans/.
- DECISIONS.md — settled decisions: what we chose, what we rejected, why.
- JOURNAL.md — append-only session log, newest entry at the bottom. Never
  edit old entries. The permanent record of all completed tasks.
- ARCHITECTURE.md — map of the system as it exists: components and their
  responsibilities, interactions, entry points, non-obvious conventions.

## Session start
1. Read TODO.md and PLAN.md.
2. Read the last entry in JOURNAL.md (tail of the file).
3. Do NOT read the reference files now. Consult on demand:
   - DECISIONS.md — before proposing architectural/design changes, or when
     I ask "why did we do X?"
   - ARCHITECTURE.md — before exploring the codebase to locate the relevant
     subsystem; prefer it over broad searching.
   - BACKLOG.md — when I ask about future work, or when drafting a new
     PLAN.md (check the Direction section).
4. Confirm which TODO item we're working on before writing code.

## During the session
- For non-trivial tasks (3+ steps or design choices), present a plan and
  get approval before coding; the approved approach goes in PLAN.md.
- Check off TODO items with [x] as they're completed.
- Commit after each green test cycle: small, single-purpose commits.
- New ideas that aren't immediately actionable go to BACKLOG.md, not TODO.md.
- If work reveals the plan is wrong, stop and update PLAN.md before continuing.
- If we settle a design question, add it to DECISIONS.md immediately (one
  entry: date, decision, alternatives rejected, reason).

## Development workflow
- TDD is the default for all feature work and bug fixes:
  1. Write failing tests first that define the expected behavior.
  2. Confirm they fail before writing implementation.
  3. Write the minimum code to pass.
  4. Refactor with tests green.
- Never modify a test to make it pass unless the test itself was wrong;
  say so explicitly when that happens.
- For bug fixes: write a test reproducing the bug first, then fix.
- Refactor opportunistically in the area you're working, in separate
  commits from behavior changes. Refactors beyond the current task's
  scope go to TODO.md or BACKLOG.md instead.

## Subagents
- Default to subagents for: codebase exploration, broad searches, reading
  many files, research questions, and diff review. One focused task per
  subagent; run independent investigations in parallel.
- Subagents get no conversation history: give each one full context in
  the prompt (file paths, constraints, what to return).
- Ask subagents for conclusions, not raw output.
- Before completing a non-trivial TODO item, have a subagent review the
  diff in a fresh context against PLAN.md and the tests.

## Session end ("wrap up")
When I say "wrap up" (or before compacting), do all of the following in one pass:
1. Append a new entry to the end of JOURNAL.md containing:
   - Date
   - Completed tasks: every [x] item from TODO.md, copied verbatim
   - What's in flight
   - Gotchas or surprises
   - Recommended next step
2. Then remove all [x] items from TODO.md and add newly discovered tasks.
   Every removed item MUST appear in the journal entry from step 1.
   TODO.md should contain only open work after wrap-up.
3. Update PLAN.md if the approach changed; archive it to docs/plans/ if complete.
4. Promote anything from the journal entry that's actually a decision
   into DECISIONS.md.

## Token budget
Session-start ingest must stay small. Enforce these caps:
- CLAUDE.md — under 120 lines. If a rule is procedure-like or rarely
  relevant, move it to a skill or a path-scoped rule, not here.
- TODO.md — under 30 open items. If it exceeds this at wrap-up, move the
  lowest-priority items to BACKLOG.md and say so.
- PLAN.md — under 60 lines. One plan only; details belong in docs/plans/.
- Never use @imports in CLAUDE.md for reference files; mention them by
  plain-text name so they load only on demand.

## Compaction
When compacting, always preserve: the list of modified files, the current
TODO item, and any unrecorded decisions or gotchas not yet written to files.

## Reference file maintenance (not wrap-up items)
- ARCHITECTURE.md — update only when the system's shape changes. When I say
  "rebuild the architecture map", use a subagent to crawl the codebase and
  rewrite it from scratch.
- BACKLOG.md — when drafting a new PLAN.md, check the Direction section and
  move absorbed backlog items to TODO.md.

Use the `build-*` skills. Ignore the `learn-*` skills; they belong to the
teaching context and do not apply here.
