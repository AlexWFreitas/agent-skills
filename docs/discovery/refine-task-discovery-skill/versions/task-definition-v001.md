# Task Definition: Refine Task Discovery Skill

Status: `ready-for-handoff` · Version: `v001` · Closed:
`2026-07-21T21:10:00-03:00`

## Objective

Refine `task-discovery` so it preserves the useful brainstorm-and-challenge
phase but produces a clear, medium-depth implementation handoff. The primary
task definition must tell a fresh implementer what to do, what not to do, and
how to confirm completion—without becoming a transcript of exploration.

## Implementation context

The canonical source is `skills/task-discovery/`: `SKILL.md`, two bundled
templates, and `references/readiness-checklist.md`; optional `agents/openai.yaml`
must stay aligned if its visible description changes. A representative generated
definition at `docs/discovery/prepare-agent-skill-repository/` reached 389
lines and about 20 headings. It also placed discovery work, such as determining
agent roles, in the executor's scope. The refined behavior must make
`task-definition.md` the current synthesis and `discovery-record.md` the
lossless supporting trail.

## Scope and non-goals

**In scope**

- Update `SKILL.md`, both bundled templates, and readiness guidance; update
  `agents/openai.yaml` only if its visible description needs alignment.
- Make the task definition use six fixed sections: objective, implementation
  context, scope and non-goals, deliverables, execution plan, and verification
  and definition of done.
- Permit risks, dependencies, decisions, and traceability only when they
  materially change execution or verification.
- Require a materiality review before handoff instead of a hard length limit:
  remove or move any primary-brief content that does not change implementation,
  a boundary, or verification.
- Enforce semantic rules through final readiness self-review while keeping
  automated repository validation limited to file and metadata correctness.
- Replace overlapping discovery-record ledgers with a current-state summary,
  one canonical chronological trail, and linked research notes; preserve every
  question, answer, evidence item, rationale, and managed unknown.

**Not in scope**

- Removing the discovery record, shortening it by deleting information, or
  making it a co-equal implementation handoff.
- Changing explicit invocation, one-question-at-a-time, read-only, no-execution,
  snapshot, or resume behavior unless new evidence requires it.

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| Revised skill guidance | Clear separation between exploration, a lossless record, and the implementation brief. |
| Revised task-definition resource | Six fixed sections plus a materiality rule for optional detail. |
| Revised discovery-record resource | Current summary, canonical trail, and linked research without duplicates or loss. |
| Revised readiness guidance | Checks for navigability, separation, lossless preservation, and current synthesis. |
| Positive reference example | A compact illustrative output, not a fill-in template. |
| Optional negative guidance | Only a useful short annotated anti-pattern fragment; never a second full document. |
| Representative verification | Evidence a fresh implementer can act without reading the history. |

## Execution plan

1. Compare current instructions, templates, checklist, and prior output to map
   each source of excess to a bounded behavior change.
2. Define and align the six-section primary brief, three-layer lossless record,
   materiality test, examples, and readiness checks.
3. Update the affected skill resources while preserving unrelated safeguards.
4. Validate against representative work, then run `scripts\Test-Repository.ps1`
   and `tests\Run-Tests.ps1` under both `pwsh` and `powershell`.

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| Navigable primary handoff | A fresh implementer finds outcome, scope, deliverables, ordered work, and completion checks directly. |
| Separation | Discovery questions and settled decisions stay in the record unless they constrain execution. |
| Material detail | Each optional item changes implementation, a boundary, or verification; otherwise move or remove it. |
| Lossless record | Every question, answer, evidence item, rationale, and managed unknown remains recoverable. |
| Quality-preserving updates | The definition is rewritten at material milestones and before handoff; no stale exploration remains. |
| Proportionate examples | Positive reference is illustrative; any negative guidance is a useful short fragment only. |
| Validation | Representative review passes and both repository validation scripts pass under PowerShell 7 and Windows PowerShell. |

The work is complete when all source resources agree with these contracts and
the checks pass on a representative discovery output.
