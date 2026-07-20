---
name: build-wrap-up
description: End-of-session close-out for build-context projects - log completed work to JOURNAL.md, prune TODO.md, update PLAN.md, promote decisions. Use when the user says "wrap up", "close out", "end session", or before compacting a long session.
disable-model-invocation: true
---

# Session wrap-up

Perform all steps in order, in one pass. Order matters: the journal entry
is written while completed items still exist in TODO.md, so the record is
copied from source rather than reconstructed from memory.

## Steps

1. Append a new entry to the end of JOURNAL.md:
   - Date
   - Completed tasks: every [x] item from TODO.md, copied verbatim
   - What's in flight
   - Gotchas or surprises
   - Recommended next step

2. Remove all [x] items from TODO.md; add newly discovered tasks.
   Every removed item must appear in the journal entry from step 1.

3. If TODO.md now exceeds 30 open items, move the lowest-priority items
   to BACKLOG.md and report which ones moved.

4. Update PLAN.md if the approach changed this session. If the plan is
   complete, archive it to docs/plans/ and leave PLAN.md empty.

5. Promote any decisions from the journal entry into DECISIONS.md
   (date, decision, alternatives rejected, reason).

## Verify before finishing
- TODO.md contains no [x] items and no more than 30 open items.
- The journal entry ends with a recommended next step.
Report a one-line summary of what was updated.
