---
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Agent, Skill, AskUserQuestion
description: Implement and review in a loop until the PR review passes.
argument-hint: "[PR number or URL]"
---

# Review Loop

Implement fixes and review the PR in a loop until the review passes.

**PR**: $ARGUMENTS

If no PR number is provided, use `gh pr list` to show open PRs and ask the human to pick one.

---

## Loop

Repeat the following until the reviewer returns **APPROVE**:

1. **Review**: Use the Agent tool (model: opus) to spawn a reviewer agent with the following prompt:
   > Run the skill `/em-experimental:review-pr $ARGUMENTS`.
   > Return the full review output verbatim, including the verdict line.

2. **Check verdict**:
   - If the verdict is **APPROVE**, stop the loop. Present the final review to the human and exit.
   - If the verdict is **REQUEST CHANGES**, continue to step 3.

3. **Implement**: Use the Agent tool to spawn an implementer agent with the full list of issues from the review and the following prompt:
   > You are a senior engineer fixing code review issues. For each issue flagged by the reviewer:
   > 1. Read the cited file and line number to understand the context.
   > 2. Implement the fix.
   > 3. If the issue has associated tests, run them and verify they pass.
   >
   > Fix all 🔴 Critical and 🟡 Important issues. Apply 🟢 Suggestions only if they are trivial.
   > Reference specific file paths and line numbers. Stop and report if you are blocked.

4. Go back to step 1.

After the loop ends, present the final **APPROVE** review to the human.
