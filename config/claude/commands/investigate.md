---
allowed-tools: Read, Glob, Grep, Bash, Agent, AskUserQuestion
description: Investigate a problem thoroughly without proposing solutions.
argument-hint: "[problem description, error message, Jira link, or PR URL]"
---

# Investigate

Gather and summarize all relevant information about a problem so the human can decide what to do.

**Problem**: $ARGUMENTS

---

## Rules

- **NEVER propose solutions, fixes, or recommendations.** Your job is to collect facts.
- Do not suggest code changes, architecture changes, or next steps.
- Do not speculate about what *should* be done. Only report what *is*.
- If you are unsure about something, say so explicitly.

---

## Phase 1: Clarify the problem

If the problem description is vague, ask the human to clarify using `AskUserQuestion`. Otherwise proceed.

## Phase 2: Gather evidence

Use the Agent tool to spawn a read-only investigator (model: sonnet) with the following prompt:

> You are an investigator. Your job is to find all information relevant to a problem. You must NEVER propose solutions or fixes — only gather facts.
>
> **Problem**: [insert problem description here]
>
> Investigate the following, skipping any that don't apply:
>
> **Codebase**
> - Find the code paths involved in the problem. Trace the flow from entry point to the failure.
> - Identify all files, functions, and line numbers touched by the relevant code path.
> - Read surrounding code for context (callers, callees, shared state).
> - Check for recent changes to these files: `git log --oneline -10 -- <file>`
>
> **Error context**
> - If an error message or stack trace is given, trace it to the source.
> - Identify the exact line that throws or logs the error.
> - Check if the error is caught, swallowed, or propagated.
>
> **Tests**
> - Find existing tests covering the affected code paths.
> - Note whether the failure scenario is tested or untested.
>
> **Configuration & dependencies**
> - Check relevant config files, env vars, or feature flags.
> - Check dependency versions if relevant (pom.xml, package.json, etc).
>
> **Git history**
> - Find commits that last touched the affected code.
> - Check if the problem correlates with a recent change.
>
> **External context**
> - If a Jira link or PR URL is provided, fetch its details with `gh` or other tools.
> - If logs or monitoring links are provided, fetch and summarize them.
>
> Return a structured report with all findings. Cite specific files and line numbers.

## Phase 3: Summarize for the human

Present the investigator's findings in this format:

### Problem statement
One-paragraph summary of the problem in your own words.

### Affected code
Table of files, functions, and line numbers involved.

### Timeline
Recent git changes or events that may be relevant, ordered chronologically.

### Key observations
Bulleted list of factual findings. Each must cite a file:line or source.

### Test coverage
What is tested vs untested for this code path.

### Open questions
Things you could not determine or that need human input.
