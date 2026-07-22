# Task Definition: Refine Task Discovery Skill

Status: `ready-for-handoff` · Version: `v001` · Last updated:
`2026-07-21T21:10:00-03:00` · Supporting
record: `discovery-record.md`

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

- Update the skill guidance and bundled resources that control task-definition
  structure, discovery-record structure, compaction, and readiness review.
- Target `SKILL.md`, both bundled templates, and the readiness checklist;
  update `agents/openai.yaml` only if its visible description needs alignment.
- Make the task definition use six fixed sections: objective, implementation
  context, scope and non-goals, deliverables, execution plan, and verification
  and definition of done.
- Permit risks, dependencies, decisions, and traceability only when they
  materially change execution or verification.
- Require a materiality review before handoff instead of a hard length limit:
  remove or move any primary-brief content that does not change implementation,
  a boundary, or verification.
- Enforce these semantic rules through the final readiness review, while keeping
  automated repository validation limited to file and metadata correctness.
- Replace overlapping discovery-record ledgers with a current-state summary,
  one canonical chronological trail, and linked research notes; preserve every
  question, answer, evidence item, rationale, and managed unknown.

**Not in scope**

- Removing the discovery record, shortening it by deleting information, or
  making it a co-equal implementation handoff.
- Changing the skill's explicit invocation, one-question-at-a-time, read-only,
  and no-execution boundaries unless new evidence requires it.
- Editing the canonical skill during this discovery phase.

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| Revised skill guidance | Clear separation between exploration, a lossless supporting record, and the primary implementation brief. |
| Revised task-definition resource | Six fixed sections plus a materiality rule for any optional detail. |
| Revised discovery-record resource | Current-state summary, canonical decision trail, and linked research notes without duplicated ledgers or lost information. |
| Revised readiness guidance | Checks for navigability, separation of discovery from implementation, lossless record preservation, and removal of stale handoff content. |
| Positive reference example | A compact, concrete example of the intended medium-depth presentation; it is illustrative, not a fill-in template. |
| Optional negative guidance | Add only when it explains a boundary better than the rules and positive reference alone; use a short annotated fragment, never a full negative document. |
| Representative verification | Evidence that a fresh implementer can use the final definition without reading the complete discovery history. |

## Execution plan

1. **Find the sources of excess** — compare the current instructions, templates,
   readiness guidance, and prior output to identify which requirements cause
   unnecessary sections, duplication, or discovery content in the handoff.
2. **Define the new artifact contracts** — make the six-section task definition
   and the three-layer, lossless discovery record explicit; define when optional
   detail is material enough to retain.
3. **Align the skill resources** — update the relevant instructions, templates,
   and readiness checks so they all enforce the same document roles and
   compaction lifecycle.
4. **Validate against representative work** — confirm the primary definition is
   complete and navigable, the record remains auditable, and updated documents
   contain current synthesis rather than accumulated interim prose. Run
   `scripts\Test-Repository.ps1` and `tests\Run-Tests.ps1` under both `pwsh`
   and `powershell` after the source changes.

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| The primary handoff is navigable | A fresh implementer can find the outcome, scope, deliverables, ordered work, and completion checks without reconstructing them from lists. |
| Discovery and execution are separated | Questions, alternatives, and settled decisions stay in the record unless they directly constrain implementation. |
| Detail is material | Before handoff, review each optional section, paragraph, or table row: if removing it would not change an implementation choice, boundary, or verification activity, remove it from the handoff or move it to the record. |
| The supporting record is lossless | Every question, answer, evidence item, rationale, and managed unknown remains available in the canonical trail or linked notes. |
| Updates preserve quality | The task definition is rewritten from current decisions at material milestones and before handoff; stale or exploratory wording does not remain. |
| Anti-bloat review works | The materiality test is applied without relying on an arbitrary line-count limit. |
| Semantic rules are enforced appropriately | The readiness review checks presentation quality; automated repository validation remains limited to file and metadata correctness. |
| Example is correctly scoped | The reference example demonstrates the result without adding a second template or mandatory section set. |
| Negative guidance is proportionate | If included, it is limited to a useful anti-pattern rather than a second full example. |
| Repository checks pass | Run `scripts\Test-Repository.ps1` and `tests\Run-Tests.ps1` under both supported PowerShell hosts after implementation. |

The refinement is ready for implementation when the affected source resources
are identified, their changes trace to this definition, and these checks can
be performed on a representative discovery output.
