---
allowed-tools: Bash(git:*), Bash(ls:*), Bash(find:*), Bash(head:*), Bash(cat:*), Read, Glob
description: Read file tree and git history to gain context on what we are working on
---

# Catchup - Understand Current Work Context

Analyze the current state of the repository to understand what's being worked on.

## Git History & Status
Recent commits (last 10):
!`git log --oneline -10`

Current branch:
!`git branch --show-current`

Current changes:
!`git status`

Unstaged changes summary:
!`git diff --stat`

Staged changes summary:
!`git diff --cached --stat`

## Recent File Activity
Recently modified files (last 24 hours):
!`find . -type f -name "*.java" -o -name "*.xml" -o -name "*.md" -o -name "*.json" -mtime -1 2>/dev/null | head -20`

## Task
Based on the git history, current branch name, staged/unstaged changes, and recently modified files:

1. Summarize what feature or bug fix is being worked on
2. Identify the key files involved
3. Note any patterns in the changes (new features, refactoring, bug fixes, etc.)
4. Highlight any potential concerns or next steps
5. If there are untracked files, mention what they appear to be for

Keep the summary concise but informative.
