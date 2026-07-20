---
name: study-wrap
description: End-of-study-session close-out - run a Feynman check, update CONCEPTS.md mastery levels, log the session to LEARNING_LOG.md, and capture open questions. Use when the user says "study wrap", "wrap up", "end session", "close out", or is finishing a learning session.
disable-model-invocation: true
---

# Study session wrap-up

Perform all steps in order. The Feynman check comes first because its result
drives the CONCEPTS.md updates — don't log anything until the check is done.

## Steps

1. **Feynman check.** Ask me to explain the main concept from today's
   session as if teaching a beginner. Then grade it honestly:
   - PASS: correct mechanism, correct why, own words. Surface-level
     pattern-matching or recited definitions do not pass — probe with one
     follow-up question ("what would happen if...") before passing.
   - PARTIAL: right idea, gaps or imprecision in the mechanism.
   - FAIL: wrong mechanism or unable to explain without notes.
   Being generous here defeats the entire system; a false PASS means the
   concept never resurfaces for review. When in doubt, grade down.

2. **Update CONCEPTS.md** based on today's full session, not just the check:
   - Feynman PASS on a Shaky/Struggling concept → promote one tier.
   - PARTIAL → keep current tier; note the specific gap next to the entry.
   - FAIL or repeated errors during the session → demote to Struggling and
     record the root misconception in one sentence.
   - New concepts covered today enter as Shaky (never directly to Mastered —
     mastery requires a later successful recall, not same-day performance).
   - Any concept learned via "direct mode" today enters as Shaky with a
     "(direct)" tag.

3. **Append a LEARNING_LOG.md entry** to the end of the file:
   - Date and course/topic
   - Topics covered
   - Feynman check: concept, grade, and the gap if not a PASS
   - Misconceptions uncovered today (verbatim from step 2)
   - 2-3 specific review items for next session, favoring Struggling
     concepts and anything tagged (direct)

4. **Capture open questions.** Add anything unresolved from today to
   QUESTIONS.md, phrased so it's askable in a lecture or office hours
   ("Why does X use Y instead of Z?" — not "confused about X").

## Verify before finishing
- Every concept discussed today appears somewhere in CONCEPTS.md.
- The log entry contains at least 2 review items.
- No concept was promoted to Mastered on same-day performance alone.
Report a one-line summary: check grade, promotions/demotions, and review
items queued.
