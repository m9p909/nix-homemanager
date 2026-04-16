---
allowed-tools: Bash(git:*), AskUserQuestion, Read, Glob, Grep
description: Split a large branch into stacked PRs using plain git commands.
argument-hint: [base-branch (default: main)]
---

# Stack Branch

Split the current branch into multiple smaller, stacked branches for easier review.

**Base branch**: `$ARGUMENTS` (default: `main` if no argument provided)

---

## Phase 1 — Analyze

Gather context about the current branch vs the base branch.

1. Run these git commands to understand the diff:
   - `git log --oneline <base>..HEAD` — list all commits
   - `git diff --stat <base>..HEAD` — file-level summary of changes
   - `git diff --stat --diff-filter=A <base>..HEAD` — new files only
   - `git diff --stat --diff-filter=M <base>..HEAD` — modified files only
   - `git diff <base>..HEAD` — full diff (use Read on large outputs)
   - `git branch --show-current` — current branch name

2. Analyze the changes and identify **logical groupings**. Good groupings are:
   - Self-contained features or behaviors
   - Infrastructure/config changes separate from logic
   - Test additions separate from implementation (when large)
   - Refactors separate from new functionality
   - Each group should compile/build independently when stacked

3. For each proposed branch, note:
   - Branch name (format: `<current-branch>/stack-<N>-<slug>`)
   - Which commits or file changes it includes
   - What it depends on (which stack branch must come before it)
   - Rough size (files changed, lines added/removed)

## Phase 2 — Propose

Present the breakdown to the user using `AskUserQuestion`:

Format the proposal as a numbered list:

```
Stack 1: <branch-name> — <description> (~N files, ~M lines)
  Commits: <commit-hashes or "cherry-pick from X">
  Depends on: base

Stack 2: <branch-name> — <description> (~N files, ~M lines)
  Commits: <commit-hashes or "changes to files X, Y">
  Depends on: Stack 1

...
```

Ask the user to approve, modify, or reject the breakdown. Do NOT proceed until the user approves.

## Phase 3 — Execute

Once approved, create the stacked branches using plain git commands:

1. **Save current state**: `git stash` if there are uncommitted changes, note the current branch name

2. **Create each stack branch in order** (from base upward):
   ```
   git checkout <base>
   git checkout -b <stack-1-branch>
   git cherry-pick <commits...>

   git checkout <stack-1-branch>
   git checkout -b <stack-2-branch>
   git cherry-pick <commits...>
   ```

   If cherry-pick is not clean (commits don't map 1:1 to groups), use this approach instead:
   ```
   git checkout <base>
   git checkout -b <stack-1-branch>
   git checkout <original-branch> -- <file1> <file2> ...
   git commit -m "<description>"
   ```

3. **Return to original branch**: `git checkout <original-branch>`

4. **Restore stash** if one was created: `git stash pop`

## Phase 4 — Report

Print a summary:

```
Created N stacked branches:

  1. <stack-1-branch> (based on <base>)
  2. <stack-2-branch> (based on stack-1)
  ...

Original branch '<branch>' is unchanged.

To push all stack branches:
  git push origin <stack-1> <stack-2> ...

To create PRs (each targeting the previous stack branch):
  gh pr create --head <stack-1> --base <base>
  gh pr create --head <stack-2> --base <stack-1>
  ...
```
