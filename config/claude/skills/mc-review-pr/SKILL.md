---
name: mc-review-pr
description: Code review a pull request
argument-hint: "[PR number or URL]"
allowed-tools: ["Bash", "Glob", "Grep", "Read"]
model: inherit
color: green
---

Code review the given pull request: "$ARGUMENTS"

## Steps

1. If no PR number is provided in the args, use `gh pr list` to show open PRs
2. If a PR number is provided, use `gh pr view <number>` to get PR details
3. Use `gh pr diff <number>` to get the diff
4. Read any CLAUDE.md files in the repo root and in directories touched by the PR
5. Determine which review dimensions apply (see below) and Read the relevant files
6. Analyze the changes and provide a thorough code review

## Guidelines

- Focus on real bugs and significant issues a senior engineer would flag
- Skip nitpicks, formatting, and things CI/linters will catch
- Skip pre-existing issues not introduced by this PR
- Be concise and actionable

## Review focus

- Code correctness and logic errors
- CLAUDE.md and project convention compliance
- Performance implications
- Error handling quality

## Review dimensions

After analyzing the diff, Read ONLY the dimension files relevant to this PR's changes:

| Dimension | File | Load when PR... |
|-----------|------|-----------------|
| Naming & structure | `dimensions/naming-structure.md` | Always — applies to all code changes |
| Test coverage | `dimensions/test-coverage.md` | Adds or modifies test files |
| Security | `dimensions/security.md` | Touches auth, user input, secrets, or system boundaries |
| Logging | `dimensions/logging.md` | Adds or modifies log statements |
| User-facing text | `dimensions/user-facing-text.md` | Includes user-facing strings in the API, error messages, or UI text |
| API contract | `dimensions/api-contract.md` | Adds or modifies API endpoints, routes, or controllers |
| Concurrency | `dimensions/concurrency.md` | Touches DB access, queues, locks, thread pools, or external service calls |

Use Read to load each relevant dimension file from the `dimensions/` directory relative to this skill, then apply its checklist to the PR diff.

## Output format

Structure your review with clear sections:

### Overview
Brief summary of what the PR does.

### Dimensions applied
List which dimension files were loaded and why.

### Issues
Categorized by severity:
- 🔴 **Critical** (must fix) — security vulnerability, data corruption, broken functionality
- 🟡 **Important** (should fix) — bug-prone code, poor error handling, missing logs, standard violations
- 🟢 **Suggestion** — style, refactoring, nice-to-have improvements

For each issue, cite the specific file and line number.

### Strengths
Note what the PR does well.

### Verdict
End with exactly one of:
- **APPROVE** — no critical or important issues remain
- **REQUEST CHANGES** — one or more critical or important issues must be addressed
