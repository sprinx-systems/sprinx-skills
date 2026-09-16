# claude-skills

A collection of Claude Code skills, packaged as the plugin `sprinx`. There is no
application code - the deliverable is the skill instructions themselves.

## Layout

- `skills/<skill-name>/SKILL.md` - one directory per skill; the directory name equals the
  `name` in the frontmatter.
- `.claude-plugin/plugin.json` - this repository as an installable plugin.
- `.claude-plugin/marketplace.json` - this repository as a marketplace, listing the plugin
  with `"source": "./"`.
- `README.md` - the skill table and install instructions; update it whenever a skill is
  added, renamed or removed.

## Conventions for skills

- Every skill directory is named `sx-*`.
- The frontmatter `description` decides when the skill loads. It states what the skill
  does **and** when to use it, including the trigger phrases and, where the skill must not
  fire on its own, what does not count as an invocation.
- Skills are repository-agnostic: no project name, no hardcoded build or test command. A
  skill takes those from the target repository.
- **The engineering standard is never copied into a skill.** A skill that checks against
  `engineering-standards` reads the checklist, templates and playbooks from that
  repository at run time, at the revision the target repository is pinned to. A second
  copy drifts - the standard's own README says so.
- Instructions are imperative and addressed to the agent running the skill.
- A skill stands alone: it may mention another skill by name but must not require it.

## Versioning

- The version lives in `.claude-plugin/plugin.json` (top-level `version`) and in
  `.claude-plugin/marketplace.json` (`version` of the `sprinx` entry). Both are always
  equal.
- Bump on every merge to `main`: major when a skill is removed or renamed, minor when a
  skill is added or changes behaviour, patch for wording.

## Checks

No build, no tests. After a change:

- `plugin.json` and `marketplace.json` parse as JSON, and their versions are equal.
- Every `skills/*/SKILL.md` has frontmatter whose `name` equals its directory name.
- `README.md` lists exactly the skills present in `skills/`.
