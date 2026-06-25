---
allowed-tools: Bash, Read, Write, AskUserQuestion, mcp__plugin_atlassian_atlassian__*, mcp__claude_ai_Atlassian__*
description: Generate a SAM Test Blitz markdown document, pre-filled with release metadata and a feature inventory pulled from the solace-agent-mesh-go repo.
argument-hint: "[version, e.g. v1.2.0]  [sprint, e.g. SC-2025-SPR20]  (both optional — coworker is prompted if missing)"
---

<!--
NOTE on `allowed-tools`:
The Atlassian MCP wildcards are intentionally broad because exact tool names
differ across MCP versions. Read-only Jira/Confluence access is enforced at
runtime by the hard rule below: **never modify Jira or Confluence.**
-->

# Make SAM Test Blitz

Generate a fully-fleshed-out **SAM Test Blitz** markdown document modelled on the canonical Confluence template (`sol-jira.atlassian.net/wiki/x/egCCTQE`). The output is a single markdown file that mirrors the Confluence page's 11 sections, with the metadata sections pre-filled from `$ARGUMENTS` and the feature sections pre-populated from a quick scan of `~/Repos/solace-agent-mesh-go`.

**Arguments**: `$ARGUMENTS`

Expected forms (positional, both optional):

- `v1.2.0` — release version of `solace-agent-mesh-enterprise`
- `SC-2025-SPR20` — sprint identifier

---

## Hard rules

- **Read-only Jira & Confluence.** No transitions, comments, field edits, page edits, or attachments. Search and read only.
- **No network writes anywhere.** This command only writes one local markdown file.
- **Never call `/fix-bug`, `/implement-task`, or any code-writing command.** This is a doc-generation command — no PRs, no commits, no branches.
- **Output path is `/tmp/sam-test-blitz-<timestamp>.md`** and nothing else. Do not write to the cwd, do not overwrite existing files.
- **If `~/Repos/solace-agent-mesh-go` is missing**, fall back to leaving the feature and environment sections empty with a `<!-- repo not found at ~/Repos/solace-agent-mesh-go -->` marker — never invent features.
- **Do not modify the canonical Confluence template page.** This command produces a *new local file*, it does not push back to Confluence.

---

## Phase 1: Resolve arguments

Parse `$ARGUMENTS` for two positional tokens:

- A `vX.Y.Z` or `X.Y.Z` token → version.
- Anything matching `^[A-Z]{2,}-\d{4}-[A-Z0-9]+$` (e.g. `SC-2025-SPR20`) → sprint.

If either is missing, prompt the coworker **once** with `AskUserQuestion`:

- Version question only if version is missing.
- Sprint question only if sprint is missing.

Empty/cancelled answers are allowed — leave them as `<version>` / `<sprint_name>` placeholders in the output and continue. Never block on this.

Also compute:

- `TS = $(date +%Y%m%d-%H%M%S)`
- `OUT = /tmp/sam-test-blitz-${TS}.md`
- `TODAY = $(date +%Y-%m-%d)` — used for the New Issues JQL `created >= …` clause.

---

## Phase 2: Inventory the repo

`solace-agent-mesh-go` is the **only** repo this command inspects. Capture its current default-branch tip and latest release tag (read-only):

```bash
REPO=~/Repos/solace-agent-mesh-go
git -C "$REPO" fetch --tags --quiet || true
git -C "$REPO" describe --tags --abbrev=0 2>/dev/null   # latest tag
git -C "$REPO" rev-parse --abbrev-ref HEAD              # current branch
git -C "$REPO" log -1 --format='%h %s' main 2>/dev/null # latest commit on main
```

These values populate the single row of the **Environment Setup** table.

If the repo is missing, write `<!-- repo not found at ~/Repos/solace-agent-mesh-go -->` in the row and continue.

---

## Phase 3: Discover candidate new features

For the **New Features** and **Experimental Features** sections, surface candidates from `solace-agent-mesh-go`'s recent history:

```bash
git -C ~/Repos/solace-agent-mesh-go log main --since='6 weeks ago' \
  --no-merges --format='%h %s' \
  | grep -iE ' (feat|feature)(\(|:)' \
  | head -30
```

Heuristic for **Experimental Features**: commits whose subject contains `experimental`, `preview`, `beta`, `wip`, or that touch files under `experimental/` or `preview/`:

```bash
git -C ~/Repos/solace-agent-mesh-go log main --since='6 weeks ago' --no-merges \
  --format='%h %s' -- 'experimental/*' 'preview/*' | head -30
```

If nothing matches, leave the table body empty — never invent rows.

Cap at **10 features** total across the two tables to keep the doc readable.

---

## Phase 4: Discover scenario rows from the repo

For each of the seven Test Case categories below, scan `~/Repos/solace-agent-mesh-go` for evidence of what should be tested. Emit **one row per discovered item** with two columns filled: **Scenario** (short imperative name, e.g. `Install via Homebrew`) and **Description** (one line — what the tester actually does or verifies). Leave `Tested By` and `Test Results` blank.

Cap each category at **15 rows**. If a category yields zero hits, leave the table headers-only.

All scans below are read-only `git ls-files` / `grep` / `find` invocations. **Do not execute any code** in the repo — discovery only.

Use these signals (treat them as *hints* — adapt if the repo layout differs):

| Category | Repo signals |
| --- | --- |
| **Installation Scenarios** | `README*`, `INSTALL*`, `Makefile` install targets, `goreleaser*.y*ml` artefacts, `Dockerfile*`, `brew/` formulae, install-related docs under `docs/install*`. One row per distribution channel (homebrew, docker, go install, binary download, …). |
| **CLI Scenarios** | `cmd/**/*.go` cobra commands (`Use:` field), `cli/**`, `main.go` flag definitions. One row per top-level subcommand and per major flag-combo worth testing. |
| **Plugin Scenarios** | `plugin/**`, `plugins/**`, files containing `Plugin` interfaces, `examples/plugins/**`. One row per plugin discovered or per plugin-loading code path (load, enable, disable, conflict). |
| **Built-in Tools Scenarios** | `tools/**`, `internal/tools/**`, anything implementing a `Tool` interface, `examples/tools/**`. One row per built-in tool. |
| **Gateway Scenarios** | `gateway/**`, `gateways/**`, files mentioning REST/HTTP/WebSocket/STOMP/MQTT/AMQP/Kafka entry points. One row per gateway transport. |
| **Access Scenarios** | `auth/**`, `rbac/**`, `acl/**`, files mentioning `role`, `policy`, `permission`, `OAuth`, `OIDC`, `SAML`, `apikey`. One row per auth mechanism or role-vs-resource matrix worth covering. |
| **UI Scenarios** | `ui/**`, `web/**`, `frontend/**`, `*.tsx`/`*.vue` page entries, route definitions. One row per top-level UI screen / route. If the repo has no UI directory, leave the table headers-only. |

For each category, prefer **specific, testable scenarios** (`Install v1.2.0 via Homebrew on macOS`) over generic ones (`Installation works`). If you can't write a concrete description from what you found, drop the row instead of padding it.

If `~/Repos/solace-agent-mesh-go` is missing entirely, skip Phase 4 — every Test Case table stays headers-only.

---

## Phase 5: Compose the markdown

Write `OUT` with exactly this structure. Every heading is H2 (no H1, no H3 — matching the canonical template). Placeholders that the coworker is expected to fill remain in angle brackets (`<…>`).

```markdown
# SAM Test Blitz — <sprint_name>

> Generated from `/make-sam-test-blitz` on <TODAY>. Source template: https://sol-jira.atlassian.net/wiki/x/egCCTQE

## Trigger

Release `solace-agent-mesh-go` `<version>`.

## Objectives

The main outcomes that the quality plan looks to achieve.

> **Quality issues are tracked with bugs in JIRA.**

## New Features

| **Feature** | **Commit** |
| --- | --- |
| <feature subject> | <short sha> |
| … | … |

## Experimental Features

| **Feature** | **Enabled** | **Comments** |
| --- | --- | --- |
| <feature subject> | <yes/no> | <short sha> |
| … | … | … |

## Out-of-Scope

- <add items here>

## Host Instructions

| **Step** |
| --- |
| Create a copy of this document for `<sprint_name>: SAM Test Blitz`. |
| Prepare a test environment and update the **Environment Setup** section below. |
| Announce the test blitz is starting in `#ai-sam-test-blitz`. Team should use this channel for discussions and announcing issues found. |

## Instructions

| **Step** |
| --- |
| Add your name to the Test Cases tables. |
| Record the test results in the tables; create/update test cases if needed. Update the test blitz doc if needed. |
| If you encounter any unexpected problems during the test, create a bug using the label `sam-blitz` and let the team know in `#ai-sam-test-blitz`. |

🪲 **Use the label `sam-blitz` for all bugs raised as a result of this activity.** 🪲

## Environment Setup

**URL**: `<staging URL>`

| **Service** | **Image Tag / version / branch** |
| --- | --- |
| solace-agent-mesh-go | <tag or branch> |

## Test Cases

### Installation Scenarios

| **Installation Scenarios** | **Description** | **Tested By** | **Test Results** |
| --- | --- | --- | --- |

### CLI Scenarios

| **CLI Scenarios** | **Description** | **Tested By** | **Test Results** |
| --- | --- | --- | --- |

### Plugin Scenarios

| **Plugin Scenarios** | **Description** | **Tested By** | **Test Results** |
| --- | --- | --- | --- |

### Built-in Tools Scenarios

| **Built-in Tools Scenarios** | **Test Case** | **Tested By** | **Test Results** |
| --- | --- | --- | --- |

### Gateway Scenarios

| **Gateway Scenarios** | **Description** | **Tested By** | **Test Results** |
| --- | --- | --- | --- |

### Access Scenarios

| **Access Scenarios** | **Description** | **Tested By** | **Test Results** |
| --- | --- | --- | --- |

### UI Scenarios

| **UI Scenarios** | **Description** | **Tested By** | **Test Results** |
| --- | --- | --- | --- |

## New Issues

Bugs raised during this blitz. JQL:

```
labels = sam-blitz AND created >= <TODAY>
```

Browse: https://sol-jira.atlassian.net/issues/?jql=labels%20%3D%20sam-blitz%20AND%20created%20%3E%3D%20<TODAY>

## Outcome

1. Release `solace-agent-mesh-go` `<version>`.
2. Follow-ups identified during the blitz (e.g. automate a flaky test case, file a hardening Jira).
```

For each of the seven Test Case tables, render the rows you discovered in Phase 4: fill columns 1 (Scenario) and 2 (Description), leave columns 3 (`Tested By`) and 4 (`Test Results`) blank. If a category found no scenarios, render the header row only.

For the **New Features** and **Experimental Features** tables, replace the placeholder rows with the rows you collected in Phase 3. If you found zero candidates for a section, leave the table with just the header row + a single empty row.

---

## Phase 6: Report

Print exactly:

```
Wrote SAM Test Blitz to /tmp/sam-test-blitz-<timestamp>.md
- Version: <version | unset>
- Sprint:  <sprint  | unset>
- Repo:    solace-agent-mesh-go @ <branch> (<latest tag or "no tags">)
- New Features:          <N>  candidate rows
- Experimental Features: <M>  candidate rows
- Scenarios discovered:
    Installation:    <count>
    CLI:             <count>
    Plugin:          <count>
    Built-in Tools:  <count>
    Gateway:         <count>
    Access:          <count>
    UI:              <count>
```

Then stop. No narration, no preamble, no follow-up actions.
