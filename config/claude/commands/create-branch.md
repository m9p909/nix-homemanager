---
allowed-tools: Bash(git:*), WebFetch
description: Creates a branch in the format jclarke/DATAGO-12345-feature-name from a Jira link.
argument-hint: [jira-url]
---

# Create Branch

Create a git branch from the Jira ticket provided in `$ARGUMENTS`.

## Steps

1. **Fetch the Jira ticket**: Use WebFetch on `$ARGUMENTS` to retrieve the ticket title and issue key (e.g. `DATAGO-12345`).

2. **Derive the branch name**:
   - Format: `jclarke/{ISSUE_KEY}-{slugified-title}`
   - Slugify the title: lowercase, replace spaces and special characters with `-`, strip leading/trailing `-`, truncate slug to 40 chars max
   - Example: `jclarke/DATAGO-12345-fix-login-redirect-bug`

3. **Create the branch**: Run `git checkout -b {branch-name}` from the current repo.

4. **Report** the created branch name to the user.
