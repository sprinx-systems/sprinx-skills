---
name: sx-brainstorming
description: Lead the user through high-level planning of a change - gather context, settle every important decision with the user one question at a time, then write a specification to docs/specs/YYYY-MM-DD-feature-name.md. Use ONLY when the user explicitly asks for it ("brainstorm", "brainstorming", "use the brainstorming skill", "let's brainstorm this", "run sx-brainstorming"). Never start it on your own from an ordinary feature request.
---

# Brainstorm a change into a specification

This skill runs the **high-level planning phase** of a change, and nothing else. Its
only deliverable is one document under `docs/specs/`. It produces no code, no
refactor, no task breakdown and no implementation.

The value of the document is that it records **what the user decided and why**, not
what you would have decided. Every important choice is put to the user as a
**decision question** and answered by the user before the session moves on.

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

- **Explicit invocation only.** A feature request, a bug report or a vague "what do
  you think about X" is not an invocation. Only run when the user names
  brainstorming.
- **Never write or change source code during the session.** The only file you create
  is the spec, and the only commit you make is the one that carries it.
- **Never create a branch, and never switch branches.** The spec is committed and
  pushed on the branch the checkout is already on - see step 4. Which branch this
  work belongs on was decided before the session started, and never by this skill.
- **Never commit the spec on the repository's main branch.** Not by switching to it,
  and not by committing there because the checkout happens to be on it.
- **Never continue past an unanswered question.** After you ask a decision
  question your turn ends - no further tool calls, no edits, no "meanwhile I
  will...".
  Silence, elapsed time and an interruption are not answers.
- **Never invent an answer.** If the user's reply is ambiguous, ask again rather
  than picking the reading that suits you. If the user answers "Other" with free
  text, that text is the decision, verbatim.
- **Never put implementation steps in the spec.** File-by-file plans, function
  signatures, commit sequences and effort estimates belong to a later phase.

## 1. Gather context first - no questions yet

Before the first question, learn enough that the questions are about real choices in
this codebase and not about things the repo already answers.

- Read `CLAUDE.md` and the `README.md` sections it points at for the area involved.
- Read the code the change would touch, and any existing `docs/specs/*.md` or
  `docs/*.md` covering the same ground - a superseded design document is context.
- Check what already exists: half the requests are an extension of something built.

Then state back, in a short paragraph, what you understood the request to be and what
exists today. Ask the user for facts only when the repo cannot supply them (external
constraints, deadlines, an API you have no access to).

## 2. Settle the decisions, one round at a time

Work through the open choices in dependency order - what the change **is** before
where it lives, where it lives before how it is stored, how it is stored before how
it is presented.

Ask about things that change the shape of the result:

- scope boundaries - what this change includes, and what it deliberately does not
- which existing module the feature extends, versus a new one
- data model, storage and schema choices, and migration of what exists
- the user-facing shape - where the entry point is, what the user sees
- which deploy modes and runtimes it must serve, and what a deployment that does not
  serve it does instead
- backwards compatibility, and what happens to data written by the old behaviour
- what is deferred to a later change

Do not spend a question on anything the repository already decides (conventions,
naming, styling, package manager, test framework), nor on implementation detail.

**Question quality:**

- 2-4 options, mutually exclusive, each a choice someone could actually defend.
- Every option gets a one-line description naming its trade-off, not restating its
  label.
- Put your recommendation first and mark it `(Recommended)`. Recommend one; do not
  survey.
- Where the question carries a short label of its own, keep it to 12 characters.
- Let the user choose more than one option only when the options genuinely combine.
- Group at most 2-3 tightly related decisions into one round. Independent decisions
  get their own round, so an early answer can reshape the later question.

Immediately after each answer comes back, append that round to the spec's
**Decisions** section (see step 3) - the question, all offered options with their
descriptions, and the answer. Do this while it is in front of you; do not
reconstruct a whole session's questions from memory at the end.

Stop asking when what is left is implementation detail. A typical session is three
to eight rounds; more than that usually means you are asking about things the code
already answers.

## 3. Write the specification

```bash
date +%F        # the YYYY-MM-DD prefix - never guess today's date
```

Path: `docs/specs/YYYY-MM-DD-feature-name.md`, the name in lowercase kebab-case,
three or four words describing the feature and not the request ("bulk-price-edit",
not "user-wants-faster-prices"). Create the file once context is agreed and
grow it through the session; do not wait until the end.

The document contains exactly these sections:

```markdown
# <Feature name>

Status: draft | agreed
Date: YYYY-MM-DD
Area: <modules / deploy modes the change touches>

## Context of the change

What exists today in this repository, what it does not do, and why that is being
changed now. Point at real files and README anchors. A reader who has never seen the
conversation must be able to follow from here.

## User request

The user's own request, reformulated into one continuous text: all of their prompts
across the session joined, tidied and ordered, with the noise removed.

Nothing in this section may be information the user did not give. No inferred
requirement, no invented constraint, no solution of yours, no scope you added. If two
prompts contradict each other, keep both and note which came later.

## Decisions

One subsection per decision round, in the order asked.

### <the question, verbatim>

| Option | What it means |
|---|---|
| <label> | <the description offered> |
| <label> | <the description offered> |

**Answer: <the option the user chose, or their free text>** - plus any reasoning the
user gave. If the user chose "Other", record their words, not a paraphrase.

## High-level plan

The change described as a handful of phases or workstreams, each with what it
delivers and what it depends on. Prose and headings, not a task list, no file names,
no ordering finer than "this before that".

## Architecture decisions

The parts that are expensive to change later: the seam between modules, the data
structures and where they live, the schema, which side of the client/worker split
owns what, what gets a capability flag, what invariant a test has to enforce. State
each decision and the reason it beat the alternative.

## Weaknesses and risks

Honest and specific. For each: what could go wrong, how likely, what it costs, and
what would reduce it. Include the questions deliberately left open and what has to
happen before they can be answered.

## Out of scope

What this change explicitly does not do, so a later reader does not read the gaps as
oversights.
```

No section is dropped. If a section has nothing in it, say so in one line and say
why - an empty "Weaknesses and risks" means you did not look.

Style: ASCII only, present tense, tables where a table reads better than prose, and
keep it under roughly 300 lines. This is a document a person reads before agreeing to
the work, not a transcript.

## 4. Hand back

Report the path, then summarise the decisions in a few lines. Say plainly that this
is the planning phase and that implementation is a separate step - do not start it,
and do not offer to start it in the same breath as the summary.

**Commit the spec on the branch the checkout is already on, and push that branch.**
A brainstorming session cuts no branch of its own and names none: the working branch
is whatever the session was started on, and that is where the spec goes. Do not
switch, do not create, do not ask for a name. Commit the spec on its own, with a
message naming the feature.

```bash
git add docs/specs/YYYY-MM-DD-feature-name.md
git commit -m "docs: spec for <feature name>"
git push                  # git push -u origin HEAD the first time, if there is no upstream yet
```

The spec gets a commit of its own - it never rides along in a code commit - and the
push is part of the hand-back. Never force, never rewrite the branch.

On a checkout sitting on the repository's main branch, do not commit: say the spec is
written but uncommitted and let the user say where it goes.

Taking the spec further - into the main branch, into a pull request, into code - is
the caller's step.
