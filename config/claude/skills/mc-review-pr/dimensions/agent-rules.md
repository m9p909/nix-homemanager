# Agent rules file review

For every added or modified rules file (CLAUDE.md, AGENTS.md, .cursorrules, .cursor/rules/*.mdc, .cursor/rules/*.md), check:
- **Valid format**: .mdc files have well-formed YAML frontmatter with `description` and, when scoped, valid `globs`; markdown parses cleanly
- **No contradictions**: new rules don't conflict with existing rules in this file or other rules files in the repo
- **No duplication**: rule isn't already stated elsewhere; duplicated rules drift apart over time
- **Actionable and unambiguous**: each rule is a concrete instruction an agent can follow, not vague aspiration
- **Correct scope**: rule placed at the right level (repo root vs subdirectory) and glob scope matches the files it governs
- **No stale references**: paths, commands, and file names the rule mentions actually exist in the repo
