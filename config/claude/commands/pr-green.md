---
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Agent, Monitor, Skill
description: Get a PR's CI to green - diagnose failing checks, fix real failures, rerun flakes, push, repeat. Never merges.
argument-hint: "[PR number or URL]"
---

# PR Green

Drive the PR's checks to all-green without merging.

**PR**: $ARGUMENTS

If no PR is given, use the PR for the current branch (`gh pr view --json number,url`). If there is none, list open PRs with `gh pr list` and stop.

---

## Hard rules

- **NEVER** merge, enable auto-merge, or mark the PR ready. Green is the deliverable.
- **NEVER** skip hooks, force-push, or edit CI config to make a check pass.
- **NEVER** delete or `@Disabled` a test to make it pass. A test that is wrong gets fixed, with the reason in the commit message.
- Work in the PR's branch inside a worktree if the current checkout is on a different branch.
- Always find the root cause. Use `superpowers:systematic-debugging` before any fix.
- Save every log you pull to the scratchpad and grep it. Do not trust exit codes alone.
- Full job logs: `gh api repos/OWNER/REPO/actions/jobs/<id>/logs`. `gh run view --log` truncates long jobs.
- Maven runs need `JAVA_HOME=$(/usr/libexec/java_home -v 25)` and `MAAS_ID=test` (or `env -u MAAS_ID`).

---

## Loop

Repeat until every check is green, at most 5 rounds.

### 1. Snapshot the checks

```
gh pr checks $ARGUMENTS --json name,state,link,bucket
gh pr view $ARGUMENTS --json headRefOid,headRefName,baseRefName,mergeable
```

If `mergeable` is `CONFLICTING`, rebase onto the base branch first (round counts as one).

### 2. Classify every failing check

For each failed job, download the full log to the scratchpad and sort it into one bucket:

| Bucket | Evidence | Action |
|---|---|---|
| Real | Test assertion, compile error, checkstyle, lint tied to the diff | Fix in step 3 |
| Flake | Timeout, runner lost, network/registry error, test passes locally and on base | Rerun in step 4 |
| Pre-existing | Same failure on base branch head | Report, do not fix here |
| Infra | Secrets, permissions, quota | Stop and report |

Verify a suspected flake by checking the same job on the base branch's latest run before calling it one. Record the bucket and one line of evidence per job in a scratchpad table.

### 3. Fix real failures

Spawn one implementer agent (model: sonnet) per independent real failure, in parallel, with: the job name, the exact failing test or error line, the log path, and the hard rules above. Each agent reproduces locally, fixes, runs the targeted test, then the module's unit tests, and reports file:line changes. Commit each fix separately with a message naming the check it fixes.

### 4. Push and rerun

- Push the branch.
- For flakes with no code change: `gh run rerun <run-id> --failed`.
- Wait with Monitor on `gh pr checks $ARGUMENTS --watch`, long fallback. Do not poll with sleep.

### 5. Back to step 1

---

## Exit

Report in this order:

1. Check status table: name, final state, rounds it took.
2. Fixes pushed: commit SHA, check fixed, one line on the root cause.
3. Flakes rerun and how many reruns each needed.
4. Anything left red with its bucket and why it stopped here.

If a job flaked more than twice, say so explicitly so the coworker can decide whether to open a flake ticket.
