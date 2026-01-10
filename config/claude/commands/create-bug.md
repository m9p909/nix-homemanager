---
description: Generate a bug report in standardized markdown format
argument-hint: [bug-title]
allowed-tools: Write
---

# Create Bug Report

Create a bug report markdown file with the following structure:

## Actual Behaviour
[Describe what is currently happening - include error messages, logs, screenshots]

## Impact
[Describe the severity and who/what is affected]

## Expected Behaviour
[Describe what should happen instead]

## Steps to Reproduce
[Numbered list of steps to reproduce the issue]

## Notes
[Additional context, root cause analysis, proposed solutions]

---

**Instructions:**
1. Be concise. Prioritize being concise over grammar
2. Ask the user for details if needed (title, actual behavior, impact, etc.)
3. Generate the bug report content
4. Save to a file named `bug-report-[slug-from-title].md` in the current directory
5. Use `###` for all section headings
6. Fill in placeholders with actual information from the user
