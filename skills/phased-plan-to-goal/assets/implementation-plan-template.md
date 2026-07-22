# Implementation Plan: <Task title>

Status: `draft` · Task: `<task-name>`<br>
Created: `<ISO-8601 timestamp with UTC offset>` · Last updated:
`<ISO-8601 timestamp with UTC offset>` · Governing contract:
`task-definition.md`

## Current state

<Rewrite this as a concise, coherent operational summary after each material
lifecycle event.>

- Active phase: `<phase-id or none>`
- Next action: `<specific next action or none>`
- Overall progress: `<current outcome-based summary>`
- Governing contract version: `<approved version or draft>`
- Blocking condition: `<managed blocker or none>`
- Latest plan snapshot: `<link or none>`

## Authorization

- State: `not-requested | awaiting-approval | approved | exhausted | revoked`
- Scope: `none | phase:<id> | complete-plan`
- Mode: `none | single-phase | change-sensitive | persistent`
- Approval evidence: `<timestamp and unambiguous user authorization or none>`
- Authorized consequential actions: `<named actions or none>`
- Mandatory stops: `<task-specific additions plus the skill contract>`

## Mutation surface

| Target or system | Planned mutation | Reversibility and authority |
| --- | --- | --- |
| <path, repository, service, database, or external party> | <change> | <reversible, contingency, consequential authorization, or unresolved> |

## Supporting documents

The two primary documents are canonical entry points, not a file-count limit.
Add as many supporting files as coherence requires and keep each material fact
authoritative in one place.

| Document | Role | Authority and update rule |
| --- | --- | --- |
| <relative link> | <architecture, research, risk, migration, API, testing, phase detail, or other purpose> | <governing or supporting; when it changes> |

## Contract coverage

| Contract item | Planned delivery and phase | Verification evidence | Coverage state |
| --- | --- | --- | --- |
| O01 / R01 / D01 / A01 | <deliverable and phase IDs> | <planned or actual evidence> | `planned | in-progress | verified | accepted-limitation | blocked` |

No material outcome, requirement, deliverable, invariant, or acceptance
criterion may remain orphaned. Update this synthesis when the plan materially
changes; do not create a second competing traceability ledger.

## Phased plan

| Phase | Outcome and status | Contract coverage | Entry conditions and dependencies | Expected mutations | Verification and completion evidence | Contingency |
| --- | --- | --- | --- | --- | --- | --- |
| P01 | <outcome> · `pending` | <O/R/D/A IDs> | <conditions> | <targets and effects> | <checks and evidence> | <rollback, fallback, or not material> |

Allowed phase states: `pending`, `in-progress`, `complete`, `failed`,
`blocked`, `skipped`, or `superseded`. Explain every terminal state other than
`complete` in the trail and current state.

## Verification summary

| Check | State | Evidence or accepted limitation |
| --- | --- | --- |
| <A-ID and criterion> | `pending` | <link, result, or limitation> |

## Managed blockers and limitations

| Item | Impact | Resolver and resolution step | Safe contingency or gate | State |
| --- | --- | --- | --- | --- |
| <blocker or limitation> | <effect> | <owner and action> | <fallback or stop> | `open` |

## Canonical material-event trail

| Time | Event | Evidence or reason | Plan and authorization impact |
| --- | --- | --- | --- |
| <timestamp> | Draft created | <source and initial state> | <initial definition and plan state> |

Record approvals, authorization changes, phase transitions, material decisions,
deviations, replans, blocker transitions, resume reconciliation, and closure
once. Do not append routine command output or transient observations.
