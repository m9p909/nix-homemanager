---
allowed-tools: Agent, Bash, Read, Write, AskUserQuestion, mcp__plugin_atlassian_atlassian__*, mcp__claude_ai_Atlassian__*
description: Pull easy-fix items off the mission-control backlog and dispatch a /fix-bug subagent per issue.
argument-hint: "[optional JQL fragment, e.g. issuetype = Bug]"
---

<!--
NOTE on `allowed-tools`:
The Atlassian MCP entries above are intentionally left as broad wildcards
(`mcp__plugin_atlassian_atlassian__*`, `mcp__claude_ai_Atlassian__*`) because
the exact read-only tool names vary between MCP versions and narrowing them
here risks breaking the command. Read-only Jira access is instead enforced at
runtime by the hard rule in this file: **never modify Jira items.** Search and
read only — no transitions, comments, field edits, assignments, links,
attachments, or watch changes. This applies to this command and to every
subagent it dispatches.
-->

# Fix Mission-Control Bugs

Find the most easily-fixable high-priority items in the mission-control backlog, present them to the coworker for review, then on a second turn dispatch one background `/fix-bug` agent per approved issue.

This command is **two-phase**:

- **First invocation** (`/fix-mc-bugs [jql]`): fetch, filter, write dossier, print review list, then stop. No agents are spawned.
- **Second turn** (the coworker replies in plain text with their selection): parse the selection against the most recent dossier, then dispatch agents.

**Extra JQL**: $ARGUMENTS

---

## Constants

- `MAX_AGENTS = 10` — hard cap on parallel `/fix-bug` agents dispatched in one run.
- `TOP_N = 5` — default number of issues to action after filtering.
- `BASE_JQL = project = DATAGO AND statusCategory = "To Do" AND "Squad[Select List (cascading)]" in cascadeOption(11214, 11216) ORDER BY priority DESC, created DESC`

---

## Hard rules

- **NEVER modify Jira items or update their status.** This includes: transitioning state, editing fields, adding comments, assigning, linking, attaching, watching/unwatching. Jira access is **read-only** — search and read only. If the workflow seems to require a status change, do not perform it; a separate process handles that.
- **NEVER** dispatch more than `MAX_AGENTS` agents in a single run.
- **NEVER** spawn an agent for an issue you couldn't fully describe — if a Jira fetch fails for an issue, skip it and report.
- **Never dispatch agents on the first turn.** Always print the candidate list and wait for explicit selection from the coworker.
- **If parsing the selection fails, re-print the prompt — never default to "all" on ambiguous input.**
- **Every subagent must work in its own git worktree under `/tmp/fix-mc-bugs/`** so parallel agents don't fight over the same checkout.
- If zero issues survive filtering, report that fact and exit. Do not spawn empty agents.
- Do not wait, poll, or sleep after dispatch — the harness notifies on completion.

---

## Phase 1: Pick the Atlassian MCP

Detect which Atlassian/Jira MCP is available in this session. Prefer `mcp__plugin_atlassian_atlassian__*` if present, otherwise use `mcp__claude_ai_Atlassian__*`. If neither tool family is available, stop and tell the coworker which MCP to enable.

If the MCP requires authentication, call its `authenticate` tool first. If it returns an auth URL, surface it via `AskUserQuestion` and stop until the coworker confirms they've authenticated.

---

## Phase 2: Build the JQL

- If `$ARGUMENTS` is empty, use `BASE_JQL` verbatim.
- If `$ARGUMENTS` is non-empty, splice it in before the `ORDER BY` clause as an additional `AND` clause. Example with `$ARGUMENTS = issuetype = Bug`:

  ```
  project = DATAGO AND statusCategory = "To Do" AND "Squad[Select List (cascading)]" in cascadeOption(11214, 11216) AND issuetype = Bug ORDER BY priority DESC, created DESC
  ```

Search Jira via the chosen MCP. Request enough results to filter from (e.g. 25–50). Fetch full descriptions, not just summaries.

---

## Phase 3: Filter for "easily fixable"

Apply this heuristic to each result and keep the ones that pass:

- **Small scope** — fix likely lives in a single file or a small contained area.
- **Clear repro or clear expected behaviour** — description spells out what's wrong, not "explore this".
- **No architectural changes** — no new services, schemas, frameworks, or wide refactors.
- **No cross-team dependencies** — no waiting on another squad, infra, or external vendor.
- **Self-contained context** — a fresh engineer could load the ticket and start in under 10 minutes.

Sort the survivors by priority (descending), then created (descending). Keep the top `TOP_N`. Never exceed `MAX_AGENTS`.

If the filter empties the list, report `No easy-fix issues matched.` and exit.

---

## Phase 4: Save the issue dossier

Create the analysis directory if missing, then write one markdown file with one section per kept issue:

```bash
mkdir -p /tmp/issue-analysis
TS=$(date +%Y%m%d-%H%M%S)
ANALYSIS_FILE="/tmp/issue-analysis/${TS}.md"
```

File structure:

```markdown
# Fix MC Bugs — <timestamp>

JQL: <jql used>
Filtered to <N> of <M> results.

---

## DATAGO-XXXX — <summary>

- **Key**: DATAGO-XXXX
- **Priority**: <priority>
- **Issue type**: <type>
- **Link**: <browse url>

### Description

<full description verbatim>

### Why this was picked

<one line — which heuristic boxes it ticks>

---
```

Each section must stand alone — a subagent reading only its section should understand the issue without re-fetching Jira.

---

## Phase 5: Review gate

Print the candidate list to stdout and stop. **Do not call any tools, do not spawn any agents.** The first turn ends here.

Format the output exactly like this:

```
Candidate issues (<count>) — dossier: /tmp/issue-analysis/<timestamp>.md

1. DATAGO-1234 [P1, Bug] — <one-line summary>
   why: <one-line picked reason>
2. DATAGO-5678 [P2, Task] — <one-line summary>
   why: <one-line picked reason>
...

Reply with one of:
  all                       → dispatch all <count>
  <n1,n2,...>              → dispatch only those numbers
  drop <n1,n2,...>         → dispatch all except those
  cancel                    → abort, dispatch nothing

Waiting for your selection. No agents have been spawned yet.
```

After printing, halt. The next phase only runs on the coworker's reply.

---

## Phase 6: Dispatch (second turn)

**Wait for the coworker's reply on the previous turn before doing any of the below.** This phase only executes after the coworker has answered the review prompt from Phase 5.

Parse their reply against the numbered list in the most recent dossier:

- `all` (case-insensitive) → keep every issue.
- Comma-separated numbers (e.g. `1,3,5`) → keep only those indices (1-based, matching the printed list).
- `drop <numbers>` (e.g. `drop 2,4`) → keep everything except those indices.
- `cancel` / `none` / `abort` (case-insensitive) → exit cleanly with `Cancelled — no agents dispatched.` and stop.
- Unrecognised or ambiguous input → re-print the Phase 5 prompt verbatim once and wait again. Do not guess. Do not default to `all`.

Once the selection is parsed, for each kept issue, spawn a background agent via the `Agent` tool with `run_in_background: true`:

- **subagent_type**: `general-purpose`
- **name**: `fix-DATAGO-XXXX` (use the actual key)
- **prompt** (cold-start brief — the agent has no memory of this conversation):

  > You are fixing a single Jira issue end-to-end. Your assignment:
  >
  > - **Jira key**: `DATAGO-XXXX`
  > - **Dossier**: `/tmp/issue-analysis/<timestamp>.md` — read the section headed `## DATAGO-XXXX` for full context before doing anything else.
  > - **Isolated workspace (required)**: Before touching any code, create a dedicated git worktree so you do not collide with other parallel agents:
  >     1. From the dossier and `/investigate`, identify the target repo on disk (usually under `~/Repos/<repo>`).
  >     2. `cd` into that repo and run:
  >        ```
  >        WORKTREE=/tmp/fix-mc-bugs/DATAGO-XXXX
  >        BRANCH=fix/DATAGO-XXXX
  >        git fetch origin
  >        git worktree add -b "$BRANCH" "$WORKTREE" origin/main
  >        cd "$WORKTREE"
  >        ```
  >        If the worktree path already exists, abort and report — do not reuse a dirty workspace.
  >     3. All subsequent work (investigate, plan, implement, tests, commit, push, PR) must happen from inside `$WORKTREE`.
  >     4. After the PR is marked ready, leave the worktree in place — the coworker may want to inspect it. Do not run `git worktree remove`.
  > - **Action**: Run the `/fix-bug` slash command, passing the Jira key and a one-line summary from the dossier as `$ARGUMENTS`.
  > - **Constraints**: Follow every rule inside `/fix-bug` (investigate, plan, implement, draft PR, CI gate, review-loop, mark ready). Do not skip phases. Do not skip pre-commit hooks. No `Co-authored-by` trailers.
  > - **Never modify the Jira issue.** Read-only Jira access only — no status transitions, no comments, no field edits, no assignments.
  > - **Report**: When done, return the PR URL, iteration count, the worktree path used, and a one-paragraph summary.

Spawn **all** agents in a single message so they run in parallel.

---

## Phase 7: Report and exit

Print, then stop:

```
Dispatched (<count>) — dossier: /tmp/issue-analysis/<timestamp>.md
- [fix-DATAGO-XXXX] (general-purpose) — <one-line summary>
- [fix-DATAGO-YYYY] (general-purpose) — <one-line summary>
...
```

If any issues were skipped (fetch failure, over the cap), list them under a `Skipped:` heading with a one-line reason each.

No narration, no preamble, no waiting.
