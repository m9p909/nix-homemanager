---
name: mc-review-pr
description: Code review a pull request
argument-hint: "[PR number or URL]"
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Task", "Agent"]
model: inherit
color: green
---

Code review the given pull request: "$ARGUMENTS"

## Steps

1. If no PR number is provided in the args, use `gh pr list` to show open PRs
2. If a PR number is provided, use `gh pr view <number>` to get PR details
3. Use `gh pr diff <number>` to get the diff
4. Read any agent rules files in the repo root and in directories touched by the PR: CLAUDE.md, AGENTS.md, .cursorrules, and .cursor/rules/ — apply their rules to the review
5. Determine which review dimensions apply (see below) and Read the relevant files
6. Spawn the two bug-tracing subagents (see below) — do this before your own analysis so they run while you review
7. Analyze the changes yourself and produce the review
8. Validate every subagent-reported bug yourself (see below) before including it

## Guidelines

- Focus on real bugs and significant issues a senior engineer would flag
- Skip nitpicks, formatting, and things CI/linters will catch
- Skip pre-existing issues not introduced by this PR
- Be concise and actionable

## Review focus

- Code correctness and logic errors
- Agent rules (CLAUDE.md, cursor rules) and project convention compliance
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
| Agent rules files | `dimensions/agent-rules.md` | Adds or modifies CLAUDE.md, AGENTS.md, .cursorrules, or files under .cursor/rules/ |

Use Read to load each relevant dimension file from the `dimensions/` directory relative to this skill, then apply its checklist to the PR diff.

## Bug tracing subagents

Spawn exactly two subagents with the Agent tool, both with `subagent_type: "Explore"` and `model: "sonnet"`, in a single message so they run concurrently. They trace execution paths for bugs — they do not review style, naming, or structure.

Give each the PR number, the changed file paths, and this instruction: read the changed code and the callers/callees around it, then trace concrete execution paths looking for defects. Require every finding to state file:line, the exact input or state that triggers it, and the resulting wrong behavior. Findings without a concrete trigger must be dropped, not reported as "possible". Tell them to return a plain list of findings and nothing else — no summary, no praise, no verdict.

Split the search so they do not duplicate each other:

| Agent | Traces |
|-------|--------|
| `trace-data-flow` | Values through the change: null/empty/zero/boundary inputs, type and unit mismatches, off-by-one, uninitialized or stale state, unchecked returns, data that escapes validation |
| `trace-control-flow` | Paths through the change: error and exception branches, early returns that skip cleanup, resource leaks, retry and partial-failure states, ordering and lifecycle assumptions, callers whose contract the change breaks |

## Validating subagent findings

Subagent findings are claims, not facts. For each one, Read the cited file:line yourself and confirm the trigger actually reaches that code and produces the stated behavior.

- Confirmed → include in Issues, at the severity you judge, cited normally
- Not reproducible from the code, already handled upstream, or pre-existing → drop it silently
- Cannot confirm either way → drop it; do not hedge it into the review

Never pass a finding through unverified. You own every issue in the output.

## Output format

Structure your review with clear sections:

### Overview
Brief summary of what the PR does.

### Dimensions applied
List which dimension files were loaded and why.

### Bug trace
One line: how many findings each tracing agent returned, and how many you confirmed.

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
