# sprinx-skills

The Sprinx skill set for [Claude Code](https://claude.com/claude-code), packaged as a
plugin named **`sprinx-skills`**. The skills apply the Sprinx engineering standard
([engineering/engineering-standards](https://gitlab.sprinx.com/engineering/engineering-standards))
to whatever repository Claude Code is working in.

The repository contains no application code. The deliverable is the skill instructions
themselves.

## Skills

| Skill | What it does | Invoke with |
|---|---|---|
| [`sx-check-sprinx-standards`](skills/sx-check-sprinx-standards/SKILL.md) | Reads the repository's local `CLAUDE.md` and checks it against everything the engineering standard requires of it - sections 0-9, the adoption line, layers, the owner line, the revision pin. Read-only; reports every item as met / finding / does not apply / not determined. | explicitly only: "check sprinx standards", `/sprinx-skills:sx-check-sprinx-standards` |
| [`sx-check-basic-standards`](skills/sx-check-basic-standards/SKILL.md) | Checks that `CLAUDE.md` answers the eight basic points - branches and which one is production, how to test, how to run locally, the technology stack, how the documentation is structured, the instruction to keep it current, localization, and that the file is in English - that `README.md` exists, and that a bigger project has structured docs under `docs/` linked from the README. Read-only. | explicitly only: "check basic standards", `/sprinx-skills:sx-check-basic-standards` |

Every skill is named `sx-*`.

## Install

From inside Claude Code:

```
/plugin marketplace add sprinx-systems/sprinx-skills
/plugin install sprinx-skills@sprinx-system
```

To try a working copy without installing it:

```bash
claude --plugin-dir /path/to/sprinx-skills
```

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
skills/<name>/SKILL.md            one directory per skill
```

Conventions for adding a skill are in [`CLAUDE.md`](CLAUDE.md).
