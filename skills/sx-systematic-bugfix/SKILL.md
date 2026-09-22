---
name: sx-systematic-bugfix
description: Fix a bug the disciplined way - reproduce it first, find the real root cause, work out whether it is a regression or a bug by design, cover it with a regression test that fails before the fix, then write the fix report to docs/fixes/YYYY-MM-DD-bug-name.md. Use ONLY when the user explicitly asks for it ("systematic bugfix", "make a systematic bugfix", "systematic bugfix:", "fix this systematically", "use the systematic bugfix skill", "run sx-systematic-bugfix"). A plain bug report, a stack trace, a failing test or "this is broken, fix it" is not an invocation - fix those directly instead.
---

# Fix a bug systematically

This skill fixes one bug and leaves behind evidence that it is really fixed: a
reproduction that failed before, a root cause named in the code, a regression test
that fails without the fix, and one document under `docs/fixes/`.

The document is not a summary written afterwards - it is filled in as the work
happens, from notes taken while reproducing and while digging. What went into
finding the cause is worth as much as the diff.

Nothing here assumes a particular project, language or test runner - take those from
the repository's own `CLAUDE.md` and its manifest.

**Asking the user.** Where this skill says to put something to the user as a
**decision question**: one question, 2-4 labelled options, each with a one-line
description of its trade-off, your recommendation first. Use the structured question
tool of the agent you are running in where there is one (in Claude Code that is
`AskUserQuestion`); where there is none, write the question and its options as a
numbered list in your reply and let the user answer with a number. Either way
"Other" stays open to the user, and **your turn ends on the question**.

**The repository's instruction file.** Where this skill says `CLAUDE.md`, read
whichever instruction file the repository actually carries - `CLAUDE.md`,
`AGENTS.md`, or both when both exist.

## Hard rules

- **Explicit invocation only.** A bug report on its own, however detailed, is not an
  invocation. Only run when the user names a systematic bugfix.
- **Never fix before reproducing.** A bug you cannot reproduce is not fixed, it is
  guessed at. If reproduction fails, stop at step 2 and say so - do not carry on to
  a speculative patch.
- **Never fix the symptom.** A patch at the place where the error surfaced, with the
  cause upstream untouched, is not a fix. If the real cause is out of scope to
  repair, say so and put the containment patch in *Consequences and risks* as what
  it is.
- **Never write the regression test after the fix and call it green.** The test must
  be seen failing on the unfixed code first - that failure is what proves it tests
  the bug.
- **Never skip, disable, weaken or delete a test to get green.** A test that fails
  for a second, unrelated reason is a finding for *Follow-ups*, not an edit.
- **Never guess where the bug came from.** An origin is what `git blame`, a commit
  diff or a bisect showed. A commit named on a hunch is worse than "unknown", and
  the search for it is time-boxed - see step 4.
- **Never continue past an unanswered question.** After you ask a decision
  question your turn ends - no further tool calls, no edits.
- **The report is part of the work.** A fix without
  `docs/fixes/YYYY-MM-DD-bug-name.md` is unfinished.
- **Never record an ADR for a decision you did not implement.** The *ADR* section
  holds architectural decisions this fix carried out; anything proposed and left
  undone is a *Follow-up*.
- **One bug per run.** A second bug found on the way is a *Follow-up*, not an extra
  patch in the same commit.

## 1. Pin down what is reported

Write down, before touching anything, in the user's own terms:

- what was observed, and what was expected instead
- where it was observed - environment, version, branch, commit, data
- what the user gave you verbatim: the error text, the stack trace, the steps, the
  screenshot, the failing test name

If any of that is missing and the bug cannot be reproduced without it, ask a
decision question - one question, the readings you would otherwise guess between as
options - and **end the turn**. Do not start reading code to fill the gap for the
user.

Keep this text. It becomes *Reported problem* verbatim, not a paraphrase.

## 2. Reproduce it - this gate does not open on assumption

Build the smallest thing that shows the bug, and run it. Prefer, in this order:

1. a failing test in the repository's own suite
2. a script or command in the repository's own tooling
3. manual steps against the running app - use the repository's documented way to run
   it, and record the exact steps

Record the exact command and its exact output. Then reduce: strip the input, the
data and the steps until removing anything more makes the bug disappear. What is
left is the reproduction that goes in the report.

Confirm what the bug is **not**: the same command on a case that should work, coming
back correct. Without that, a broken environment reads as the bug.

If it does not reproduce, do not proceed. Report what you tried, what happened
instead, and what you would need - a version, a data set, a log, a config. State
plainly that no fix was made, and stop.

## 3. Find the root cause

Work from the reproduction down to the line that is wrong, and keep the trail:

- follow the actual values, not the intended ones - instrument, log, print, break -
  and find the first point where the state is already wrong
- read the code around it and its history (`git log -p`, `git blame` on the lines
  that matter) - a bug that arrived with a commit usually explains itself in that
  commit's diff
- know **why** the code is wrong, not just where. "This is null here" is a symptom;
  "this is null because the caller skips initialisation when the cache is warm" is a
  cause.

Say the cause out loud in one sentence before writing any fix. If that sentence
needs a "probably" or a "somewhere", you are not there yet - keep digging.

Remove your instrumentation once the cause is known. Nothing added for the hunt
stays in the fix.

## 4. Date the bug - regression or by design

The cause is known; spend a **bounded** effort on one more question, because it
changes what the fix has to respect. Two answers matter:

- **regression** - the code once handled this case and a change broke it. The commit
  that broke it was doing something; read its diff and its message, so the fix does
  not undo whatever that was.
- **by design** - the case was never handled. The bug is as old as the line, and the
  gap that allowed it belongs in *Follow-ups*.

Cheapest first, stop at the first one that answers:

1. `git blame` on the exact lines the cause lives at, then `git show` on the commit
   it names. A commit whose diff turns the working shape into the broken one is the
   answer, and its message usually says why.
2. Where blame lands on a move, a rename or a reformat, look past it -
   `git blame -w -C` on those lines, or `git log --follow -p -- <file>`.
3. Where blame names the commit that first wrote the code, and the lines have not
   changed since, that is "by design" - nothing further to run.
4. Only where 1-3 did not answer **and** the reproduction from step 2 is a single
   scriptable command: one `git bisect run <command>` between a commit known to work
   and the current one.

**The budget is a handful of commands and at most one bisect.** Stop and write
"unknown" the moment the search stops being cheap - a squashed or imported history,
a vendored tree, a reproduction that needs data, a service or a build that old
commits cannot produce. Say in one line what made it too costly. This step never
blocks the fix and never justifies a wider change: a bug whose origin resists the
search is still fixed.

## 5. Write the regression test first

Write a test that fails **now**, on the unfixed code, for the reason you just named.

```
run the test          -> it must FAIL, and the failure must be the bug
```

Record that failure output - it goes in the report. A test that passes before the
fix tests something else; rewrite it until it fails.

Put it where the repository puts tests of that kind, named as the repository names
them. Test the cause at the level the cause lives at - a unit test on the function
that is wrong, plus an end-to-end test only where the bug is about the wiring
between parts.

## 6. Fix the cause

Change the code that is wrong, and only that. The fix is the smallest change that
removes the cause - not a refactor of the area, not a tidy-up of neighbouring code,
not a defensive check bolted on at the call site.

Then run, in this order:

1. the regression test - it must now pass
2. the tests around the code you changed
3. the repository's own full checks: its test, build and lint commands, taken from
   `CLAUDE.md` and the project's manifest, never from memory of another project

A failure you caused is fixed here. A failure that was already there on the base
branch is reported as such, with the evidence - verify that claim by checking out
the base state, do not assert it.

Then ask, before writing the report: **where else does this cause reach?** The same
mistake in a sibling function, the same missing guard on a second path. What you
find is listed in *Follow-ups*; only the one occurrence the bug is about is fixed
here.

Where the smallest change that removes the cause is itself architectural - the fix
has to move an invariant, change a contract between modules or replace a mechanism,
because patching in place would leave the cause reachable - that is a decision, and
it goes in the report's *ADR* section. Decide it with the user through a decision
question before implementing it, and **end the turn** on the question. A
bug fixed in place decides nothing and needs no ADR.

## 7. Write the fix report

```bash
date +%F        # the YYYY-MM-DD prefix - never guess today's date
```

Path: `docs/fixes/YYYY-MM-DD-bug-name.md`, where the date is **today** and
`bug-name` is a short slug naming the bug, not the fix - what was broken, in three
or four words, lowercase with hyphens (`csv-import-drops-last-row`, not
`fix-off-by-one`). Create `docs/fixes/` if the repository has no such directory yet.

Sections, all of them, in this order:

```markdown
# <Bug in one line>

Date: YYYY-MM-DD
Status: fixed | mitigated
Area: <modules the bug and the fix touched>
Origin: regression in <commit> | by design | unknown

## Reported problem

What the user reported, in their terms - observed behaviour, expected behaviour,
where it was seen. The error text, the stack trace or the steps they gave, quoted
as given, not reworded.

## Reproduction

The smallest case that shows the bug, as something a reader can run:

    <exact command>
    <exact output, trimmed to the lines that matter>

Then the conditions it needs - data, config, state, environment - and the case that
correctly works, which rules out a broken environment.

## Root cause

Why the code was wrong, in a short paragraph: the file and the lines, the state that
was already wrong by the time it got there, and the reasoning error behind it. This
section explains, it does not narrate the search - where the bug came from belongs
in *Origin*.

## Origin

Whether the bug is a regression or was there by design, and what showed it. For a
regression: the commit - hash, date, subject - what it was doing, and how it broke
this case. For a bug by design: the case the code never handled, and since when.
For "unknown": what was searched and what made going further too costly, in one
line, with no guess at a culprit.

## The fix

What was changed and why that removes the cause - the files and the shape of the
change, a few lines. Anything considered and rejected, one line each, with the
reason. Not a diff: the commit is the diff.

## Regression tests

The tests added, by name and path, and what each one pins down. For each, the
failure it produced on the unfixed code:

    <test command>
    <the failure output, before the fix>

Then which checks were run afterwards and what they reported.

## Consequences and risks

What else this change moves: behaviour that is now different, callers affected,
performance, data or migrations touched, anything relying on the old broken
behaviour. Then what could still go wrong - the case the fix does not cover, the
assumption it rests on, why it is a mitigation rather than a fix if the status says
so. Nothing risky: say what makes it safe, in one line.

## Follow-ups

The weaknesses this hunt exposed and did not repair, most valuable first, one line
each: the same cause reachable elsewhere, the missing test that would have caught
it earlier, the logging that made the search slow, the design that made the bug
possible. Nothing found: say "None." and nothing else.

## ADR

Only the architectural decisions this fix actually made **and implemented** - a rule
now enforced in code, an invariant moved to where it cannot be bypassed, a contract
between two modules changed, a mechanism replaced rather than patched. One numbered
entry each, in this shape:

### 1. <Decision in one line, imperative>

Context: what about the code forced a decision here rather than a local patch.
Decision: what was chosen, and where it now lives in the code.
Alternatives: what else was on the table, one line each, and why it lost.
Consequences: what this now costs or constrains for code written later.

An ordinary bug fixed in place decides nothing architectural - most fixes have no
ADR. Say "None - the fix changes no architecture." and nothing else. A decision you
propose but did not implement is a *Follow-up*, never an ADR.
```

Style: ASCII only, present tense, and short - a page. *Root cause*, *Regression
tests* and *Consequences and risks* carry the weight; if *The fix* is the longest
section, the cause was probably not found.

## 8. Commit, push and hand back

Commit the fix and the test together - they belong to one change - then the report
on its own, `docs: fix report for <bug name>`.

Stay on the current branch if it is already a feature or fix branch. If the checkout
is on the main branch, cut one first, named for the bug plus six random hex
characters so the name is free whoever else is working:

```bash
git switch -c "claude/fix-<bug-name>-$(openssl rand -hex 3)"
```

Follow the repository's own branch naming convention instead where it has one that
says otherwise.

**Then push the branch.** Work that exists only in the checkout it was written in is
work nobody else can read:

```bash
git push -u origin <branch>
```

Retry a push that failed on a network error up to 4 times, backing off 2s, 4s, 8s,
16s. A push the remote rejects is reported with the branch name and the commits left
on it - never force, and never rewrite the branch to get around it.

Report, in a few lines: the root cause in one sentence, whether it is a regression or by design (or that
the origin is unknown), what was changed, the
regression test by name and that it was seen failing first, the state of the checks,
the branch and that it was pushed, and the report path. Do not restate the
follow-ups - they are in the file.
