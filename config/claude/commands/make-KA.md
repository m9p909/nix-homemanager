---
allowed-tools: AskUserQuestion, Write, Bash(date:*), Read, Glob, Grep, Task
description: Interviews the user and produces a Knowledge Acquisition (KA) document.
argument-hint: [epic name or brief description]
---

# Make KA

Produce a Knowledge Acquisition document for: **$ARGUMENTS**

A KA is a collaborative planning artifact that answers technical questions and produces a system design sufficient for epic breakdown and story sizing.

## Step 0 — Codebase Scan

Before interviewing, use the Task tool with subagent_type=Explore to scan the current codebase. Gather:
- High-level structure (key directories, services, modules)
- Patterns relevant to the epic (e.g. existing auth flows, API patterns, domain models)
- Any existing code in areas likely touched by this epic (inferred from `$ARGUMENTS`)

Use this context to:
- Pre-fill answers where the codebase already makes them clear
- Ask sharper, more informed questions in the interview
- Produce a more accurate Proposed Solution

## Step 1 — Interview

Ask the following questions using `AskUserQuestion`. Group related questions into batches of up to 4 to avoid overwhelming the user. Wait for answers before continuing.

**Batch 1 — Problem & Scope**
- What problem does this epic solve? (1-3 sentences)
- What domains or services are affected? (e.g. IAM, OpsUI, SEMPv2)
- Are there any known out-of-scope items?

**Batch 2 — Technical Questions**
- What are the open technical questions the team needs answered before breaking down stories?
- Are there competing implementation approaches being considered?
- Are there any existing systems or patterns this must integrate with?

**Batch 3 — Constraints & Security**
- What are the hard requirements (MUST/MUST NOT)?
- What are softer requirements (SHOULD/SHOULD NOT)?
- Are there any security or privacy concerns? (e.g. PII handling, secrets, auth)

**Batch 4 — Non-functional Requirements**
- How should upgrades and backward compatibility be handled?
- What observability is needed? (logs, metrics, traces, dashboards)
- What quality/testing considerations are there? (integration tests, platform testing)
- Is there any new infrastructure? If so, how is disaster recovery handled?

## Step 2 — Produce the KA

Using the codebase scan and interview answers, write the KA document to `~/Downloads/KA_$ARGUMENTS_SLUG.md` where `$ARGUMENTS_SLUG` is the epic name lowercased with spaces replaced by underscores.

Use today's date from `date +%Y-%m-%d`.

The document MUST follow this exact structure. Every section must be filled in — mark sections as "N/A" with a brief reason if not applicable. Remove all 📝 Note panels. Keep all ℹ️ Info panels.

---

```markdown
# KA: {Epic Name}

**Page ID:** *(leave blank)*
**Status:** Draft | **Version:** 1
**Created:** {today} | **Last Updated:** {today}

---

## Table of Contents

- [Related Links](#related-links)
- [Problem Statement](#problem-statement)
  - [KA Questions](#ka-questions)
- [Reviewers](#reviewers)
- [Proposed Solution](#proposed-solution)
- [Solution Constraints](#solution-constraints)
- [Affected Domains](#affected-domains)
- [Security and Privacy Considerations](#security-and-privacy-considerations)
- [System Qualities](#system-qualities)
  - [Upgrades](#upgrades)
  - [Observability, Diagnostics and Troubleshooting](#observability-diagnostics-and-troubleshooting)
  - [Quality Considerations](#quality-considerations)
- [Infrastructure](#infrastructure)
  - [Disaster Recovery](#disaster-recovery)
- [Architecture Decision Records](#architecture-decision-records)
- [Appendix](#appendix)
  - [Related Blueprints](#related-blueprints)

---

# Related Links

| **Name** | **Link** |
|----------|----------|
| Epic | *(Link to the Epic in JIRA)* |
| FD | *(Link to FD in Confluence)* |

---

# Problem Statement

{problem statement from interview}

## KA Questions

{list of open technical questions and answers from interview}

---

# Reviewers

## Required

- [ ] Architect
- [ ] Development Lead
- [ ] Product Owner

## Optional

- [ ] Quality Owner
- [ ] Dev team member
- [ ] Consulted Architects

---

# Proposed Solution

{proposed solution with system design, sequence diagrams (as mermaid), and key design decisions derived from the interview answers}

---

# Solution Constraints

> **ℹ️ Info**
>
> The constraints imposed on the solution using keywords from [RFC 2119](https://tools.ietf.org/html/rfc2119).

{for each constraint from the interview, write an H2 heading: "Solution MUST/MUST NOT/SHOULD/SHOULD NOT have {Constraint Name}" with a brief explanation}

---

# Affected Domains

{list of affected domains from interview}

---

# Security and Privacy Considerations

> **ℹ️ Info**
>
> Personal Identifying Information (PII) is not allowed to be stored outside of the IAM service. Any PII required for the feature must be requested from the IAM service at runtime.

| **Threat** | **Mitigation** |
|------------|----------------|
{one row per threat/mitigation from interview}

---

# System Qualities

> **ℹ️ Info**
>
> System Qualities identifies non-functional requirements that guide the implementation.

## Upgrades

{upgrade and backward compatibility approach from interview}

## Observability, Diagnostics and Troubleshooting

{logs, metrics, traces, dashboards, and support diagnostics from interview}

## Quality Considerations

{testing scope and platform testing considerations from interview}

---

# Infrastructure

{new infrastructure description from interview, or N/A}

## Disaster Recovery

{disaster recovery approach from interview, or N/A}

---

# Architecture Decision Records

{any architecture decisions surfaced during interview, or N/A}

---

# Appendix

{supplementary information, considered alternatives, or N/A}

## Related Blueprints

{related blueprints, or N/A}
```

## Step 3 — Confirm

Tell the user the file path where the KA was written.
