# Task Definition: <Task title>

Status: `draft` · Task: `<task-name>` · Version: `draft`<br>
Created: `<ISO-8601 timestamp with UTC offset>` · Last updated:
`<ISO-8601 timestamp with UTC offset>` · Operational plan:
`implementation-plan.md`

Use this as an adaptable execution-grade contract, not a fill-in-the-blanks
form. Remove placeholder rows. Omit or condense a subsection only when doing so
cannot change implementation, authority, risk, or verification.

## Sources and authority

| ID | Source | Role and precedence | Supported claims | Evidence state or limitation |
| --- | --- | --- | --- | --- |
| S01 | <path, supplied text, user clarification, or reference> | <governing, supporting, or contextual> | <claims this source supports> | <verified, inference, assumption, unresolved, freshness, conflict, omission, or access limit> |

State how conflicts are resolved. Do not leave a material decision supported
only by unrecorded chat context.

## Objective

<State the governing goal, why it matters, who benefits, and what success
enables.>

## Problem and verified current state

<Describe the problem or opportunity and the relevant current behavior. Keep
verified facts distinct from inference and assumption.>

| Evidence | Supported current-state claim | Class and limitation |
| --- | --- | --- |
| <source or observation> | <claim> | <verified, inference, assumption, or unresolved; freshness/access limits> |

## Desired outcomes and success measures

| ID | Outcome | Success measure or observable signal |
| --- | --- | --- |
| O01 | <result, not implementation activity> | <measurement, behavior, or review evidence> |

## Requirements and invariants

| ID | Type | Requirement or invariant | Source | Verification implication |
| --- | --- | --- | --- | --- |
| R01 | `functional | non-functional | compatibility | security | operational | data | invariant` | <testable obligation or behavior that must remain unchanged> | <S-ID or authoritative file> | <required check or evidence> |

## Implementation context and affected systems

| Area, user, or stakeholder | Current role or behavior | Required impact or preserved boundary |
| --- | --- | --- |
| <component, workflow, data store, integration, operator, or user group> | <relevant context> | <intended change or invariant> |

Link detailed architecture, interfaces, schemas, research, or domain rules from
the supporting-document index rather than duplicating them here. Summarize the
implementation consequence of each material link.

## Scope and non-goals

**In scope**

- <Authorized outcome, system, data, or behavior.>

**Not in scope**

- <Boundary that prevents a likely misunderstanding or authority expansion.>

## Deliverables

| ID | Deliverable | Required outcome | Governing requirements |
| --- | --- | --- | --- |
| D01 | <artifact or change> | <essential result> | <R-IDs and O-IDs> |

## Constraints, dependencies, and assumptions

| ID | Kind | Statement | Implementation consequence | Validation or resolution |
| --- | --- | --- | --- | --- |
| C01 | `constraint | dependency | assumption` | <condition> | <how it changes sequencing, design, authority, or risk> | <check, owner, or gate> |

Include applicable toolchain, platform, time, cost, compatibility, regulatory,
access, sequencing, and consequential-action boundaries.

## Material decisions and rationale

| ID | Decision | Rationale and evidence | Constraint on implementation |
| --- | --- | --- | --- |
| DEC01 | <settled choice> | <why this choice governs> | <alternative a competent implementer must not silently choose> |

Record only decisions whose omission could let a fresh implementer choose a
different compliant-looking path. Put substantial analysis in a linked
decision document when needed.

## Risks and mitigations

| ID | Risk and trigger | Impact | Mitigation, contingency, or stop condition | Owner or resolver |
| --- | --- | --- | --- | --- |
| RSK01 | <risk> | <effect> | <prevention, detection, fallback, or gate> | <agent, user, team, or external party> |

## Managed unknowns and resolution gates

| ID | Unknown | Impact if unresolved | Resolver and resolution step | Safe contingency or gate |
| --- | --- | --- | --- | --- |
| U01 | <unavoidable unknown> | <affected scope, phase, risk, or check> | <owner and action> | <fallback or mandatory stop> |

Do not leave a material unknown unmanaged. Resolve it before approval or record
all four fields above.

## Supporting documents

The task definition and implementation plan are canonical entry points, not a
file-count limit. Create as many supporting documents as coherence requires.

| Document | Authoritative purpose | Material implementation consequence | Update rule |
| --- | --- | --- | --- |
| <relative link> | <architecture, API contract, migration, research, risk, test strategy, phase detail, or other purpose> | <what an implementer must do or preserve because of it> | <when it changes and which document wins on conflict> |

## Acceptance criteria and definition of done

| ID | Criterion | Required evidence | Limitation policy |
| --- | --- | --- | --- |
| A01 | <observable behavior, boundary, or result> | <test, measurement, observation, or review> | <whether and by whom a limitation may be accepted> |

## Contract traceability

| Outcome or requirement | Deliverable | Supporting authority | Planned phase | Acceptance check |
| --- | --- | --- | --- | --- |
| O01 / R01 | D01 | <S-ID or document link> | <phase ID or `pending planning`> | A01 |

Every material outcome and requirement must reach a deliverable and acceptance
check. Every deliverable and check must trace back to the governing contract.

The task is complete when all deliverables exist, every acceptance criterion
has the required evidence or an explicitly accepted limitation, actual state is
reconciled, and the stated non-goals and invariants remain preserved.
