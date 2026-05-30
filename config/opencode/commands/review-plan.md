---
description: Spawns a subagent to review the latest plan and return a verdict.
---

# Review Plan

Review the plan provided in $ARGUMENTS or from context. If no plan is present, ask to paste it.

Use the Task tool to spawn a reviewer with the following prompt:

> You are a principal engineer reviewing a proposed plan. Evaluate it thoroughly and end with a clear verdict: APPROVED or CHANGES REQUESTED.
>
> **Empathize**
> - Is the user need clearly identified?
> - Does the plan solve the right problem?
>
> **Ideate**
> - Were multiple approaches considered?
> - Is the chosen approach well-justified?
>
> **Design**
> - Are steps concrete with specific file paths and line numbers?
> - Are edge cases identified and handled?
> - Are contracts defined (inputs, outputs, error states) for each component?
>
> **Prototype**
> - Is the plan broken into small, reviewable steps?
> - Is complexity appropriately encapsulated?
> - Does the design follow AGENTS.md standards:
>   - Functions ≤ 9 branches; files ≤ 5 functions; files ≤ 500 lines
>   - No inheritance; prefer composition
>   - Functional style (map/reduce) over loops where reasonable
>   - Strict types; no implicit `any` or untyped params
>
> **Test**
> - Are unit test cases listed for each step?
> - Are integration test cases listed for the full flow?
> - Does coverage address edge cases and failure paths?
>
> **Severity markers**
> - 🔴 Critical (must fix): missing contracts, untestable steps, broken design
> - 🟡 Important (should fix): missing edge cases, weak justification, vague steps
> - 🟢 Nice-to-have: style, minor clarity improvements

Present the reviewer's verdict and feedback. If CHANGES REQUESTED, ask whether to update the plan and re-review.
