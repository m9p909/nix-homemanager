---
description: Guide for creating new slash commands for OpenCode
---

# Slash Command Creator Guide

## OpenCode Command Locations
- **Global**: `~/.config/opencode/commands/` (available across all projects)
- **Per-project**: `.opencode/commands/` (shared with team)
- **Home-manager managed**: `~/.config/home-manager/config/opencode/commands/` — for commands that should be version-controlled and deployed via home-manager. These are symlinked to `~/.config/opencode/commands/` on `home-manager switch`.

## Basic Structure

```markdown
---
description: Brief description of what this command does
agent: plan
model: anthropic/claude-sonnet-4.5
---

# Command Title

Your command instructions here.

Arguments: $ARGUMENTS

File reference: @path/to/file.js

Bash command output: !`git status`
```

## Common Patterns

### Simple Command
Create a file `~/.config/opencode/commands/<name>.md` with your instructions.

### Command with Arguments
```markdown
Fix issue #$ARGUMENTS following our coding standards
```

### Command with File References
```markdown
Compare @src/old.js with @src/new.js and explain differences
```

### Command with Bash Output
```markdown
---
description: Review recent changes
---
Current branch: !`git branch --show-current`
Current status: !`git status`
Recent commits: !`git log --oneline -5`

Create commit for these changes.
```

## Frontmatter Options
- `description`: Brief description (shows in the command palette)
- `agent`: Which agent should execute (plan, build, explore, general)
- `model`: Specific model to use
- `subtask`: Force subagent invocation (true/false)

## When to Use Home-manager

If the command should persist across machines or be tracked in git, create it in `~/.config/home-manager/config/opencode/commands/` and run `update` (or `home-manager switch --flake ~/.config/home-manager#jack`) to deploy it.

## Best Practices

- Keep command instructions focused and specific
- Use `$ARGUMENTS` for user-provided input
- Use `!` for shell command output in the prompt
- Use `@` for file references
- Test commands after creation
