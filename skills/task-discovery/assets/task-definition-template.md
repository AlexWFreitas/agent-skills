# Task Definition: <Task title>

Status: `in-progress` · Task: `<task-name>` · Last updated:
`<ISO-8601 timestamp with UTC offset>` · Supporting record:
`discovery-record.md`

## Objective

<State the outcome, why it matters, and what success enables. Do not recount
the discovery conversation.>

## Implementation context

<Include only facts a fresh implementer needs to begin correctly: current
behavior, affected systems or files, material evidence, and decisions that
directly constrain work. When material, use task-specific subsections such as
sources and authority, current state, requirements and invariants, or linked
supporting documents. For every supporting document, state what it governs and
the implementation consequence retained here. Delete guidance and optional
subsections that do not affect this task. Preserve bounded implementation
latitude; do not promote ordinary algorithms, tuning values, or remote
contingencies into requirements.>

## Scope and non-goals

**In scope**

- <Bounded change or outcome.>

**Not in scope**

- <Boundary that prevents a likely misunderstanding.>

<Keep a requirement, invariant, or settled decision near this scope when
omitting it would let a competent implementer reasonably choose a different
material outcome or cross an authority or scope boundary while believing they
complied. Include rationale only when needed to preserve the decision.
Translate a material lifecycle, propagation, availability, compatibility, or
manual-operation non-goal into observable behavior: state when a change takes
effect, what already-running or in-flight consumers continue to see, and any
required restart, reconnect, redeploy, or other manual action. Omit this detail
when it is not material.>

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| <artifact or change> | <essential result> |

## Recommended implementation approach

1. **<Outcome-led step or workstream>** — <work and intended result.>
2. **<Outcome-led step or workstream>** — <work and intended result.>
3. **<Outcome-led step or workstream>** — <work and intended result.>

<Describe only the sequencing, dependencies, decision gates, risks, or managed
unknowns needed to implement correctly. This is not a command-by-command plan,
a separate phased implementation plan, or authorization to execute. Leave
routine implementation techniques and reversible defaults to the implementer.>

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| <behavior or boundary> | <test, observation, or review evidence> |

<When material, add task-specific acceptance or contract-traceability
subsections that connect governing outcomes and choices to deliverables and
checks. Verify representative semantic values and behavior, not only structural
shape or field presence. When required output values depend on an unverified
source schema, record the implementation inspection dependency and safe stop
gate. Do not duplicate an authoritative supporting document.>

The task is complete when the deliverables exist, the checks pass, and the
stated non-goals have not been absorbed into implementation. This sentence
describes completed implementation, not readiness of this discovery document.
