---
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Agent, Skill
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
- **Fully autonomous** — never call `AskUserQuestion`, never wait on coworker confirmation. If you cannot decide, pick the most likely default, document the choice in the PR/plan under an "Assumptions" heading, and continue. Abort with a non-zero exit and a clear final report only when a hard cap is hit or no automated fallback exists.
- **NEVER modify Jira items or update their status.** This includes: transitioning state, editing fields, adding comments, assigning, linking, attaching, watching/unwatching. Jira access is **read-only**. If the workflow seems to require a status change (e.g. moving to In Progress / In Review), do not perform it — assume a separate human or automation handles it.

If `$ARGUMENTS` is empty, abort immediately with a final report stating "no bug description provided" — this command is invoked from `/fix-mc-bugs` which always supplies arguments, so an empty payload is a caller bug.

---

## Phase 1: Investigate

Run the existing `/investigate` command via the `Skill` tool, passing `$ARGUMENTS`. Wait for its structured report (Problem statement, Affected code, Timeline, Key observations, Test coverage, Open questions).

Do not propose fixes yet. If the report has unresolved open questions, **resolve them autonomously**: for each question pick the most likely answer based on the investigator's evidence (most common code path, simplest interpretation, prior commit conventions), record the question + chosen answer + rationale in the plan under "Open questions resolved autonomously", and proceed. Never escalate to coworker.

---

## Phase 2: Plan the fix

Save the plan to `.claude/plans/fix-bug-<slug>.md` in the working repo (slug = Jira key slug if present, e.g. `datago-12345`, else first 40 chars of the bug summary kebab-cased). Create the directory if missing. This keeps the plan reviewable and out of git history.

The plan **must** contain, in this order:

1. **Problem Summary** — what is broken, who is affected, expected vs actual, why it matters.
2. **Empathize** — user need and the problem being solved.
3. **Ideate** — 3 distinct approaches with trade-offs.
4. **Design** — chosen approach broken into steps with file paths and line numbers, edge cases, contracts (inputs, outputs, error states).
5. **Failure Modes** — per step: what can go wrong, classification (transient / permanent / degraded), recovery, blast radius, assumptions.
6. **Test Plan** — explicit list of unit and integration test cases.
7. **Open questions resolved autonomously** — each unresolved question + the chosen default + rationale.

Log the plan path and a one-paragraph summary, then proceed directly to implementation. No approval gate.

---

## Phase 3: Implement

Create a branch off the default branch if not already on a feature branch. Branch naming default:
- If a Jira key is present in `$ARGUMENTS` (e.g. `DATAGO-12345`), use `/create-branch` to produce `jclarke/datago-12345-<slug>` (or `fix/<jira-key-slug>` if `/create-branch` fails).
- Otherwise: `git checkout -b fix/<slug>`.

For each step in the plan:

1. Write the production code as a **new** function where possible (clearer diff).
2. Write unit tests for that step.
3. Run tests, redirect output to `/tmp/fix-bug-test-output.txt`. Review and fix any failures before continuing.
4. Commit with a focused message (no `Co-authored-by`).

After all steps: run integration tests, save output to the same file, fix any failures.

If a step gets stuck or assumptions in the plan turn out wrong: re-derive the assumption from the codebase (re-run `/investigate` on the narrower question if needed), append the revised assumption + rationale to the plan's "Open questions resolved autonomously" section, and continue. Only abort with a final report if no alternative path exists after 3 in-step retry attempts.

---

## Phase 4: Open draft PR

1. Push the branch with `-u` if it has no upstream.
2. Detect the PR template, in order: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, `docs/pull_request_template.md`. If found, fill it in. Otherwise use a default body with **Summary**, **Root cause**, **Fix**, **Test plan**, **Assumptions** (list every autonomous decision made in phases 1-3 so a human reviewer can sanity-check them).
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

## Assumptions
- <each autonomous decision made + rationale>
EOF
)"
```

Log the PR URL.

---

## Phase 5: CI gate

Wait for **all** GitHub Actions checks **and** SonarQube to pass before entering the review loop. SonarQube reports as a GitHub check (look for a name like `SonarQube`, `SonarCloud Code Analysis`, or similar) — treat it like any other required check.

Caps:
- **Total wait per attempt**: 60 minutes (30 iterations of 120s sleep).
- **Fix attempts**: 5. If exceeded, abort with a non-zero exit and a final report listing the failing checks, last failure log excerpt, and commits attempted.

### Step 1: Poll until checks complete

Prefer the blocking watch:

```bash
gh pr checks <PR> --watch
```

If `--watch` is unavailable or fails, fall back to a sleep loop. Use `sleep 120` directly in the shell (no `ScheduleWakeup` — this subagent does not have that tool):

```bash
for i in $(seq 1 30); do
  echo "[ci-gate] poll $i/30"
  gh pr checks <PR> && break
  sleep 120
done
```

Log each poll iteration with the current pass/fail/pending counts so streaming output is followable.

If the 60-minute cap is hit with checks still pending, abort with an explicit error listing which checks are still pending or running.

### Step 2: On any failed check

Do **not** enter the review loop. Instead:

1. Identify the failing check via `gh pr checks <PR>`.
2. Pull failure logs:
   ```bash
   gh run view <run-id> --log-failed
   ```
3. Fix the root cause (no band-aids). SonarQube findings (style, bugs, smells) should be fixed inline — analyse the report, apply the minimal change, and re-push.
4. Commit and push to the same branch (no `--no-verify`, no force-push to default branches, no `Co-authored-by`).
5. Restart this phase from Step 1.

Increment the fix-attempt counter on each restart. If the counter exceeds 5, abort and report:
- Which check is still failing.
- The last failure log excerpt.
- The commits attempted.

### Step 3: All green

Only when every check reports success, proceed to Phase 6.

---

## Phase 6: Review loop

Cap: **5 iterations**. If not converged after 5, abort with a non-zero exit and a final report listing remaining review issues, iteration count, and the latest review verdict. Do not ask the coworker.

For each iteration:

1. **Review**: Use the `Agent` tool (model: opus) with prompt:
   > Run the skill `/em-experimental:review-pr <PR-URL>`.
   > Return the full review output verbatim, including the verdict line.

2. **Verdict check**:
   - **APPROVE** or empty / "no issues" -> exit loop, go to Phase 7.
   - **REQUEST CHANGES** -> continue.

3. **Fix**: Use the `Agent` tool with the full list of issues and prompt:
   > You are a senior engineer fixing code review issues. For each issue:
   > 1. Read the cited file:line for context.
   > 2. Implement the fix at root cause, not symptom.
   > 3. Update or add tests; run them and save output to `/tmp/fix-bug-test-output.txt`.
   >
   > Fix all Critical and Important issues. Apply Suggestions only if trivial.
   > If blocked on a specific issue, log the blocker, skip that one issue, document the skip + rationale as a PR comment, and continue with the remaining issues. Never wait on a human.

4. Commit, push, loop back to step 1.

---

## Phase 7: Mark ready

Once the loop returns approval:

1. `gh pr ready <PR>` to flip draft -> ready for review.
2. `gh pr checks <PR>` to confirm CI is healthy.
3. Emit a final report (stdout) with: PR URL, iteration count, list of autonomous assumptions made, and a one-paragraph summary of the fix.
