# sprinx-skills

The Sprinx skill set for [Claude Code](https://claude.com/claude-code) and
[Codex](https://developers.openai.com/codex), packaged as a Claude Code plugin named
**`sprinx-skills`**. The skills apply the Sprinx way of working - the
engineering standard
([engineering/engineering-standards](https://gitlab.sprinx.com/engineering/engineering-standards))
and the plan / implement / fix workflow - to whatever repository the agent is working
in. One set of `SKILL.md` files serves both agents: nothing here is copied per agent.

The repository contains no application code. The deliverable is the skill instructions
themselves.

## Skills

| Skill | What it does | Invoke with |
|---|---|---|
| [`sx-check-sprinx-standards`](skills/sx-check-sprinx-standards/SKILL.md) | Reads the repository's local `CLAUDE.md` and checks it against everything the engineering standard requires of it - sections 0-9, the adoption line, layers, the owner line, the revision pin. Read-only; reports every item as met / finding / does not apply / not determined. | explicitly only: "check sprinx standards", `/sprinx-skills:sx-check-sprinx-standards`, `$sx-check-sprinx-standards` |
| [`sx-check-basic-standards`](skills/sx-check-basic-standards/SKILL.md) | Checks that `CLAUDE.md` answers the eight basic points - branches and which one is production, how to test, how to run locally, the technology stack, how the documentation is structured, the instruction to keep it current, localization, and that the file is in English - that `README.md` exists, and that a bigger project has structured docs under `docs/` linked from the README. Read-only. | explicitly only: "check basic standards", `/sprinx-skills:sx-check-basic-standards`, `$sx-check-basic-standards` |
| [`sx-brainstorming`](skills/sx-brainstorming/SKILL.md) | Runs the high-level planning phase of a change: gathers context, settles every important decision with the user one round at a time, and writes the agreed specification to `docs/specs/YYYY-MM-DD-feature-name.md`, committed and pushed on the branch the session is already on. No code, no branch of its own. | explicitly only: "brainstorm", `/sprinx-skills:sx-brainstorming`, `$sx-brainstorming` |
| [`sx-implement-spec`](skills/sx-implement-spec/SKILL.md) | Turns an agreed spec from `docs/specs/` into code without reopening its decisions, runs the repository's own checks, writes implementation notes to `docs/impl/YYYY-MM-DD-feature-name.md`, and pushes the work on its own branch. | explicitly only: "implement spec", `/sprinx-skills:sx-implement-spec`, `$sx-implement-spec` |
| [`sx-systematic-bugfix`](skills/sx-systematic-bugfix/SKILL.md) | Fixes one bug the disciplined way: reproduce first, find the real root cause, date it as a regression or a bug by design, cover it with a regression test seen failing before the fix, and write the fix report to `docs/fixes/YYYY-MM-DD-bug-name.md`. | explicitly only: "systematic bugfix", `/sprinx-skills:sx-systematic-bugfix`, `$sx-systematic-bugfix` |

Every skill is named `sx-*`. The middle column of the table is what the skill does; the
last column is how to start it - the same skill, whichever agent you run it in.

## Install

### Claude Code

From inside Claude Code:

```
/plugin marketplace add sprinx-systems/sprinx-skills
/plugin install sprinx-skills@sprinx-system
```

To try a working copy without installing it:

```bash
claude --plugin-dir /path/to/sprinx-skills
```

### Codex

Codex has no plugin installer: it reads skills from `<skills-dir>/<skill-name>/SKILL.md`
in the repository (`.agents/skills/`), the user (`~/.agents/skills/`) and the system. So
clone this repository once and point your personal skills directory at it:

```bash
git clone https://github.com/sprinx-systems/sprinx-skills.git
sprinx-skills/scripts/install-codex.sh
```

That symlinks every skill into `~/.agents/skills/`, so `git pull` in the clone updates
what Codex loads. `--copy` installs copies instead, `--target DIR` installs somewhere
else (older Codex releases read `~/.codex/skills`), and `--uninstall` removes what the
script installed. It never overwrites a directory it did not install itself.

Then, in Codex, run a skill by name:

```
$sx-brainstorming
```

To make the skills available to one repository only, and to everybody working in it,
commit them under that repository's `.agents/skills/` instead of installing them for
your user.

## What the skills need

`sx-check-sprinx-standards` reads the standard from a local clone of `engineering-standards`.
It looks for one next to the checked repository (`../engineering-standards`) first; if it
finds none it asks for the path. The checklist is never copied into this repository - it
is read from the standard at the revision the checked repository is pinned to, so the
skill cannot drift from the standard it checks against.

## Layout

```
.claude-plugin/plugin.json        the plugin
.claude-plugin/marketplace.json   this repository as a marketplace listing that plugin
skills/<name>/SKILL.md            one directory per skill - the only copy there is
.agents/skills -> ../skills       where Codex looks for the same directories
AGENTS.md -> CLAUDE.md            where Codex looks for the repository conventions
scripts/install-codex.sh          installs the skills into a Codex skills directory
```

The two symlinks are what makes one set of files serve both agents. A checkout on a
filesystem without symlinks (Windows without `core.symlinks`) gets them as text files;
Claude Code is unaffected, and Codex users there install with
`scripts/install-codex.sh --copy`.

Conventions for adding a skill are in [`CLAUDE.md`](CLAUDE.md).
