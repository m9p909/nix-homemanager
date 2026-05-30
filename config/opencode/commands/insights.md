---
description: Analyze OpenCode history and recommend how to use it better
---

# OpenCode Usage Insights

Analyze your OpenCode history and provide actionable recommendations for using it more effectively.

## Instructions

1. **Read history sources**:
   - `~/.local/share/opencode/` — OpenCode sessions and history
   - `~/.config/opencode/commands/` — existing custom commands
   - `~/.config/opencode/AGENTS.md` — current global instructions
   - `~/.claude/CLAUDE.md` — Claude/OpenCode fallback instructions

2. **Analyze for patterns**:
   - What types of tasks are most common? (debugging, writing, refactoring, etc.)
   - Are there repetitive workflows that could be turned into commands or skills?
   - Are coding instructions being followed, or are corrections frequently needed?
   - Are there common errors or misunderstandings in conversations?
   - Which projects get the most activity?
   - Are there gaps in the existing commands/skills that would save time?

3. **Identify opportunities**:
   - Repeated prompts that could become slash commands
   - Patterns where you re-explain context that could live in AGENTS.md
   - Workflows that would benefit from dedicated commands
   - Areas where you frequently course-correct

4. **Output a concise report**:
   - **Usage patterns**: top task types and projects
   - **Recommended new commands**: specific suggestions with what they'd do
   - **AGENTS.md improvements**: instructions that would reduce repeated corrections
   - **Workflow tips**: specific OpenCode features or habits that would help based on observed patterns
   - Keep each recommendation actionable and specific
