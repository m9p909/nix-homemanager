---
allowed-tools: Read, Glob, Bash(ls:*), Bash(wc:*), Bash(cat:*)
description: Analyze Claude history and recommend how to use Claude Code better
---

# Claude Usage Insights

Analyze the user's Claude Code history and provide actionable recommendations for using it more effectively.

## Instructions

1. **Read history sources**:
   - `~/.claude/history.jsonl` — recent conversation history
   - `~/.claude/projects/` — per-project session files (read a sample from each project)
   - `~/.claude/commands/` — existing custom commands
   - `~/.claude/CLAUDE.md` — current personal instructions

2. **Analyze for patterns**:
   - What types of tasks are most common? (debugging, writing, refactoring, etc.)
   - Are there repetitive workflows that could be turned into commands or skills?
   - Are CLAUDE.md instructions being followed, or are corrections frequently needed?
   - Are there common errors or misunderstandings in conversations?
   - Which projects get the most activity?
   - Are there gaps in the existing commands/skills that would save time?

3. **Identify opportunities**:
   - Repeated prompts that could become slash commands
   - Patterns where the user re-explains context that could live in CLAUDE.md
   - Workflows that would benefit from the `/implement-plan` or `/swe-design-checklist` commands
   - Areas where the user seems to course-correct Claude frequently

4. **Output a concise report**:
   - **Usage patterns**: top task types and projects
   - **Recommended new commands**: specific suggestions with what they'd do
   - **CLAUDE.md improvements**: instructions that would reduce repeated corrections
   - **Workflow tips**: specific Claude Code features or habits that would help based on observed patterns
   - Keep each recommendation actionable and specific
