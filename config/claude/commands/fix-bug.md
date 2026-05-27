---
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Agent, Skill, AskUserQuestion
description: Investigate a bug, plan a fix, implement with tests, open a draft PR, loop reviews to approval, then mark ready.
argument-hint: "[bug description, error message, Jira link, or PR URL]"
---

# Fix Bug

End-to-end bug fix: investigate, plan, implement, draft PR, review-loop, then submit for review.

**Bug**: $ARGUMENTS

---

## Hard rules

- **NEVER** skip pre-commit hooks (no `--no-verify`).
- **NEVER** add `Co-authored-by` trailers to commits.
- **NEVER** force-push to `main` (or any default branch).
- Always find the root cause. No band-aid patches.
- Plans follow `config/CLAUDE.md`: Problem Summary -> Empathize -> Ideate (3 approaches) -> Design -> Failure Modes -> Questions.
- Target ~2:1 test-to-production line ratio. Save test output to a file each run.

If `$ARGUMENTS` is empty, ask the coworker for a bug description via `AskUserQuestion` before continuing.

---

## Phase 1: Investigate

Run the existing `/investigate` command via the `Skill` tool, passing `$ARGUMENTS`. Wait for its structured report (Problem statement, Affected code, Timeline, Key observations, Test coverage, Open questions).

Do not propose fixes yet. If the report has unresolved open questions that block planning, surface them via `AskUserQuestion`.

---

## Phase 2: Plan the fix

Save the plan to `.claude/plans/fix-bug-<slug>.md` (slug derived from the bug summary, kebab-case, max 40 chars). Create the directory if missing. This keeps the plan reviewable and out of git history.

The plan **must** contain, in this order:

1. **Problem Summary** — what is broken, who is affected, expected vs actual, why it matters.
2. **Empathize** — user need and the problem being solved.
3. **Ideate** — 3 distinct approaches with trade-offs.
4. **Design** — chosen approach broken into steps with file paths and line numbers, edge cases, contracts (inputs, outputs, error states).
5. **Failure Modes** — per step: what can go wrong, classification (transient / permanent / degraded), recovery, blast radius, assumptions.
6. **Test Plan** — explicit list of unit and integration test cases.
7. **Questions** — anything unresolved for the coworker.

Show the plan path and a one-paragraph summary, then ask the coworker for approval via `AskUserQuestion` before implementing.

---

## Phase 3: Implement

Create a branch off the default branch if not already on a feature branch (use existing `/create-branch` if a Jira link is available, otherwise `git checkout -b fix/<slug>`).

For each step in the plan:

1. Write the production code as a **new** function where possible (clearer diff).
2. Write unit tests for that step.
3. Run tests, redirect output to `/tmp/fix-bug-test-output.txt`. Review and fix any failures before continuing.
4. Commit with a focused message (no `Co-authored-by`).

After all steps: run integration tests, save output to the same file, fix any failures.

If a step gets stuck or assumptions in the plan turn out wrong, stop and re-plan with the coworker.

---

## Phase 4: Open draft PR

1. Push the branch with `-u` if it has no upstream.
2. Detect the PR template, in order: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, `docs/pull_request_template.md`. If found, fill it in. Otherwise use a default body with **Summary**, **Root cause**, **Fix**, **Test plan**.
3. Create the draft PR via `gh pr create --draft`, passing the body via HEREDOC, title under 70 chars.

Example:

```bash
gh pr create --draft --title "fix: <short summary>" --body "$(cat <<'EOF'
## Summary
<1-3 bullets>

## Root cause
<one paragraph>

## Fix
<one paragraph>

## Test plan
- [ ] <case 1>
- [ ] <case 2>
EOF
)"
```

Report the PR URL to the coworker.

---

## Phase 5: Review loop

Cap: **5 iterations**. If not converged after 5, stop and ask the coworker how to proceed.

For each iteration:

1. **Review**: Use the `Agent` tool (model: opus) with prompt:
   > Run the skill `/em-experimental:review-pr <PR-URL>`.
   > Return the full review output verbatim, including the verdict line.

2. **Verdict check**:
   - **APPROVE** or empty / "no issues" -> exit loop, go to Phase 6.
   - **REQUEST CHANGES** -> continue.

3. **Fix**: Use the `Agent` tool with the full list of issues and prompt:
   > You are a senior engineer fixing code review issues. For each issue:
   > 1. Read the cited file:line for context.
   > 2. Implement the fix at root cause, not symptom.
   > 3. Update or add tests; run them and save output to `/tmp/fix-bug-test-output.txt`.
   >
   > Fix all Critical and Important issues. Apply Suggestions only if trivial.
   > Stop and report if blocked.

4. Commit, push, loop back to step 1.

---

## Phase 6: Mark ready

Once the loop returns approval:

1. `gh pr ready <PR>` to flip draft -> ready for review.
2. `gh pr checks <PR>` to confirm CI is healthy.
3. Report final PR URL, iteration count, and a one-paragraph summary of the fix to the coworker.
