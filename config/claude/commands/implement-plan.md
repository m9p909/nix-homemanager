---
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Agent
description: Executes an already-defined plan, iterating until human approves.
---

You are implementing an already-approved plan for:

**$ARGUMENTS**

Read the plan from context or ask the human to paste it if not provided.

**Validate the plan covers:**
- Prototype: step-by-step tasks with file paths and line numbers
- Prototype: edge cases clarified
- Prototype: contracts defined (inputs, outputs, error states)
- Test: a list of unit test cases
- Test: a list of integration test cases

If any of these are missing, ask the human to update the plan before proceeding.

---

## Execution Loop

Repeat the following until the human approves:

1. **Code**: Implement one step from the plan at a time.

2. **Unit Test**: Write unit tests for that step (target 2:1 test-to-code ratio). Run unit tests and save output to `/tmp/implement-plan-test-output.txt`. **If tests fail, fix them before moving to the next step.**

3. Repeat steps 1–2 for each remaining step in the plan.

4. **Integration Test**: Once all steps are complete, write and run integration tests covering the full flow. Save output to `/tmp/implement-plan-test-output.txt`. **If integration tests fail, fix them before proceeding to review.**

5. **Review**: Use the Agent tool to spawn a reviewer agent with the following prompt:
   > You are a principal engineer doing a thorough code review. Review all changes made so far against the approved plan. Reference specific file paths and line numbers throughout. End with a clear verdict: APPROVED or CHANGES REQUESTED.
   >
   > **Bug Detection**
   > - Logic errors and incorrect assumptions
   > - Unhandled edge cases and null/undefined paths
   > - Error handling gaps — every error must be caught and at minimum logged
   > - Race conditions or ordering issues
   >
   > **Security Review**
   > - Input validation at system boundaries
   > - Secrets or credentials exposure
   > - SQL injection, XSS, command injection risks
   > - Auth/authorization gaps
   >
   > **Code Quality** (enforce CLAUDE.md standards)
   > - Functions ≤ 9 branches; files ≤ 5 functions
   > - No inheritance; prefer composition
   > - Functional style (map/reduce) over loops where reasonable
   > - Strict types used; no implicit `any` or untyped params
   > - No unnecessary complexity or premature abstraction
   >
   > **Test Coverage**
   > - ~2:1 test-to-production line ratio
   > - Unit tests cover each step's logic, edge cases, and failure paths
   > - Integration tests cover the full flow end-to-end
   > - All planned test cases from the plan are implemented
   >
   > **Logging**
   > - At least one debug log per branch
   > - No raw string data logged; use enums/ints
   > - Correct log levels: error=unacceptable failure, warn=possible failure, info=default, debug=verbose detail
   >
   > **Severity markers**
   > - 🔴 Critical (must fix): security vuln, data corruption, broken functionality
   > - 🟡 Important (should fix): bug-prone, poor error handling, missing logs, standard violations
   > - 🟢 Nice-to-have: style, refactor opportunities
   >
   > Use model: opus

6. Present the reviewer's verdict and a summary of test results to the human. Ask for approval using `AskUserQuestion`.

7. If the human requests changes, incorporate their feedback and the reviewer's notes, then repeat from step 1.
