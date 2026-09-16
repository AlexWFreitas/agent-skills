# Implementation plan: <Task title>

Status: `draft` · Task: `<task-name>`<br>
Created: `<ISO-8601 timestamp with UTC offset>` · Updated: `<timestamp>`

## Current state

- Governing contract: <exact path and immutable version or snapshot>
- Active phase: <phase or none>
- Next action: <specific resumable action>
- Remaining acceptance criteria: <short summary or references>
- Blocking condition: <actual blocker or none>
- Latest plan snapshot: <link or none>

## Authorization

- State: `not-requested | awaiting-approval | approved | exhausted | revoked`
- Scope: `none | phase:<id> | complete-plan`
- Mode: `none | single-phase | change-sensitive | persistent`
- Evidence: <timestamp and explicit authorization text, or none>
- Authorized consequential actions: <named actions, or none>
- Mandatory stops: <task-specific limits and skill boundaries>

## Mutation surface

| Target | Intended change | Authority and recovery |
| --- | --- | --- |
| <Path or system> | <Local or external effect> | <Authorization and proportionate recovery> |

Name consequential actions individually. No omitted commit, push, deployment,
database write, destructive operation, purchase, or communication is implied.

## Phases and contract coverage

| Phase | Outcome and state | Contract criteria | Dependencies | Mutations | Verification and evidence |
| --- | --- | --- | --- | --- | --- |
| P01 | <Outcome> · `pending` | <Existing IDs, labels, or sections> | <Entry conditions> | <Targets> | <Planned check or actual result> |

Use only phases that create useful dependency, authority, recovery, or
verification boundaries. Phase states are `pending`, `in-progress`,
`complete`, `failed`, `blocked`, `skipped`, and `superseded`.
Explain terminal states other than complete.

Every material requirement and deliverable must reach an acceptance check.
Keep detailed evidence in linked files when needed; do not duplicate contract
requirements or create a second coverage ledger.

## Blockers and accepted limitations

| Item | Evidence and impact | Resolver and next step | Contingency or gate | State or acceptance |
| --- | --- | --- | --- | --- |
| <Actual blocker or limitation> | <Observation> | <Owner and action> | <Safe next step> | <Open, resolved, or explicit acceptance> |

Delete placeholder rows. Internal tuning choices and remote hypothetical
failures are not blockers.

## Supporting documents

| Document | Authoritative purpose | Update rule |
| --- | --- | --- |
| <Relative link> | <What the file governs> | <When it changes> |

Use one authoritative home for each fact. Link an existing discovery contract
directly when sufficient; do not copy it into a competing execution definition.

## Material-event trail

| Time | Event and evidence | Plan or authority impact |
| --- | --- | --- |
| <Timestamp> | <Approval, phase result, material replan, blocker, resume, or closure> | <Effect> |

Update affected current-state sections at material transitions and check the
whole record for contradictions. Do not rewrite unchanged text or log every
command. Snapshot at initial approval, material replanning, authority-mode
changes, and closure.
