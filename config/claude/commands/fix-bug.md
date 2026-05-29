---
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Agent, Skill
description: Investigate a bug and implement a fix autonomously (thin wrapper over /implement-task).
argument-hint: "[Jira link, ticket key, or bug description]"
---

# Fix Bug

Thin wrapper over `/implement-task` with bug-specific framing. All process rules (autonomy, worktrees, CI gate, review loop, mark ready, no `--no-verify`, no `Co-authored-by`, read-only Jira, branch naming `jclarke/<JIRA-KEY>-<slug>`) come from `/implement-task` — do not duplicate them here.

**Bug**: $ARGUMENTS

If `$ARGUMENTS` is empty, abort with "no bug description provided".

## Action

Invoke `/implement-task` via the `Skill` tool, passing `$ARGUMENTS` plus the following bug-specific framing **prepended** to the arguments so the downstream phases see it:

- **Phase 1 (`/investigate`)**: focus on root cause, regression source (when did this start failing — bisect commits if useful), and all affected code paths. Do not stop at the symptom.
- **Phase 4 (PR)**: the PR **title must start with `fix:`** (e.g. `fix: prevent null deref in token refresh`).
- **Phase 4 (PR Assumptions section)**: must explicitly call out the suspected root cause and any alternate hypotheses considered but rejected.

Delegate. Return whatever `/implement-task` returns.
