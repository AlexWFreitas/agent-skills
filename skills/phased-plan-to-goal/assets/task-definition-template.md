# Task definition: <Task title>

Status: `draft` · Task: `<task-name>` · Version: `draft`<br>
Created: `<ISO-8601 timestamp with UTC offset>` · Updated: `<timestamp>`<br>
Operational plan: [implementation-plan.md](implementation-plan.md)

Use this template only when a sufficient governing definition does not already
exist. Remove instructional placeholders. Preserve supplied originals and
record source authority; adapt depth to the task.

## Objective

<State the intended outcome, why it matters, and observable success.>

## Implementation context

<Describe verified current behavior, affected systems and users, governing
sources and their precedence, and the decisions, requirements, invariants,
dependencies, and constraints a fresh implementer needs. Distinguish verified
facts, inference, assumptions, and unresolved evidence. Add subsections only
when they change implementation or verification.>

<Link substantial supporting documents, state what each governs, and retain its
implementation consequence here. A recommendation is not a requirement unless
evidence or an explicit owner decision makes it governing.>

## Scope and non-goals

**In scope**

- <Required outcome or affected behavior.>

**Not in scope**

- <Boundary that prevents a material misunderstanding.>

<Explain material operational limits in observable terms, including delayed
effects, in-flight consumers, and required manual actions where applicable.>

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| <Artifact or change> | <Essential result and governing constraint> |

## Recommended implementation approach

1. <Outcome-led sequence or dependency.>
2. <Required inspection, decision, or recovery boundary when material.>

<Preserve ordinary implementation latitude. For a material unknown, state its
impact, resolver, resolution step, and safe contingency or gate. Record only
plausible significant risks that constrain delivery. Detailed phases and their
changing status belong in the plan. This section is not execution authority.>

## Verification and definition of done

| Criterion | Required evidence |
| --- | --- |
| <Observable behavior or preserved boundary> | <Test, observation, or review> |

<Connect each material deliverable and requirement to its check. Existing IDs,
short labels, or section references are sufficient; add a separate traceability
table only when it helps. Check representative semantic behavior and data, not
only structural shape. Unverified source values need an inspection dependency
and safe gate.>

The task is complete when the deliverables exist and every required criterion
has evidence or an explicitly accepted limitation, with scope and invariants
preserved. Contract readiness is not implementation completion.
