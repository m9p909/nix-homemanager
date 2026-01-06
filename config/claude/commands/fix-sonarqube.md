---
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Task, TodoWrite
description: Fetch SonarQube issues for current PR and fix them
---

# Fix SonarQube Issues

This command fetches SonarQube analysis issues for the current PR using the `sonarqube_pr_analysis` CLI tool and the GitHub CLI, then systematically fixes all reported issues.

## Steps

1. **Get current branch and PR information**
   - Use `gh` CLI to identify the current PR number
   - Extract project information from git repository

2. **Fetch SonarQube issues**
   - Run `sonarqube_pr_analysis --project <PROJECT> --pr <PR_NUMBER>`
   - Parse the output to identify all issues (bugs, code smells, vulnerabilities, security hotspots)

3. **Analyze and fix issues**
   - Group issues by file and type
   - Create a todo list for all issues
   - For each issue:
     - Read the affected file
     - Understand the context around the issue
     - Apply the appropriate fix based on SonarQube's recommendation
     - Verify the fix doesn't break existing functionality

4. **Validate fixes**
   - Run relevant build/test commands to ensure fixes are correct
   - Re-run SonarQube analysis if possible to verify issues are resolved

## Execution

Start by getting the current PR information, then fetch and fix all SonarQube issues systematically.
