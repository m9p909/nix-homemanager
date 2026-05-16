---
name: feature-workflow
description: Provides a list of steps to develop a feature on a software project. 
---


# How to build a feature


## Plan Phase

1. Analyze the codebase, create a plan. Ask the user if there is any confusion
2. Spawn a general subagent to analyze the codebase, then review the plan. The subagent must be highly critical. The subagent must provide a list in the format:
```
## Problem: 
## Explanation:
```
3. Ask the user to review the changes. The user will provide a list of items that need to be fixed.
4. Ask the user if another review is required, if it is then return to step 2 and repeat. Otherwise end.


## Implementation Phase
1. Check context, if context is high, compact.
2. Implement the implementation plan. 
3. Spawn a general subagent to analyze the implementation, and review. The subagent must be highly critical. The subagent must provide a list in the format. The subagent MUST provide file names and`` line numbers in their explanation
```
## Problem: 
## Explanation:
```
4. Ask the user to review the issues raised buy the subagent. The user will provide a list of items that need to be fixed. If there are items, return to step 2.

## Review Phase
1. Check context, if context is high compact
2. use a subagent and the /review Skill to review the changes
3. Provide the results to the user, the user will provide a list of necessary changes
4. continue

