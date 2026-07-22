# Discovery Record: Refine Task Discovery Skill

Status: `ready-for-handoff` · Task: `refine-task-discovery-skill` · Session: `1`
Created: `2026-07-21T19:56:10.2686962-03:00` · Closed:
`2026-07-21T21:10:00-03:00`

## Current state

The task definition is the primary handoff. It has six fixed sections:
objective, implementation context, scope and non-goals, deliverables, execution
plan, and verification/definition of done. Any further detail is included only
when it changes implementation, a boundary, or verification.

The discovery record is the lossless supporting artifact: it provides this
current-state view, one canonical decision trail, and linked research notes.
It may eliminate duplicate presentation but must preserve every question,
answer, evidence item, rationale, and managed unknown in the trail or linked
notes. No managed unknown remains.

Primary handoff: `task-definition.md`  
Research and source detail: `research-notes.md`  
Snapshot: `versions/task-definition-v001.md`

## Canonical decision trail

| # | Question and reason | Recommendation | Answer and resulting decision |
| --- | --- | --- | --- |
| 1 | Confirm the discovery name so the phase has an isolated directory. | Use `refine-task-discovery-skill`. | Accepted exactly; created this distinct discovery directory. |
| 2 | Identify the concrete failure before proposing a fix. | Start from the user's observed result. | The documents were too large, hard to navigate, and mixed discovery work with implementation work. |
| 3 | Decide whether the definition is an execution brief or a second transcript. | Keep exploration in the record and execution work in the definition. | The definition must not mix settled discovery work into scope and must present a coherent sequence, not a catalogue. |
| 4 | Define the expected role of discovery. | Lead with an outcome and ordered implementation story. | Discovery must brainstorm and challenge assumptions, then make implementation easier rather than transfer its complexity. |
| 5 | Choose the primary handoff. | Make the definition primary and the record supporting context. | Accepted. A fresh implementer must not need the record to understand the work. |
| 6 | Calibrate the initial lean outline. | Use five core sections. | The user requested an example rather than deciding from abstract headings. |
| 7 | Test the concise example. | Adopt it if sufficiently complete. | The presentation was right but too simple; target medium depth and prevent append-only accumulation. |
| 8 | Decide the lifecycle for frequent updates. | Rewrite the definition from current decisions while retaining history elsewhere. | Accepted. The definition is a mutable synthesis, not an append-only log. |
| 9 | Test a six-section medium-depth outline. | Use objective, context, scope/non-goals, deliverables, ordered plan, and verification/done. | The user requested a fuller example, not a template. |
| 10 | Decide fixed versus conditional detail. | Keep six sections and add other detail only when material. | Accepted. Risks, dependencies, decisions, and traceability are conditional. |
| 11 | Compare the proposed compact record with current behavior. | Use short decision-focused entries and linked research. | The user requested clarification; source review found the current template's overlapping ledgers cause duplication. |
| 12 | Protect against loss during record compaction. | Require lossless compaction. | Accepted. No question, answer, evidence, rationale, or managed unknown may be discarded. |
| 13 | Choose a readable lossless record shape. | Use a current summary, continuous trail, and linked notes. | Accepted. This record uses that structure. |
| 14 | Prevent primary-handoff bloat. | Use a materiality review instead of a line limit. | Accepted. Move or remove content that does not change implementation, boundaries, or verification. |
| 15 | Decide whether an example is needed. | Include one compact positive example. | Accepted, with the condition that it is illustrative—not a template. |
| 16 | Decide whether contrast is useful. | Prefer only the positive example. | A bad example is allowed only if it helps. |
| 17 | Bound the negative example if used. | Use a small annotated fragment, not a second document. | Accepted conditionally: include it only when helpful. |
| 18 | Choose semantic enforcement. | Use final readiness self-review, not mechanical size or heading linting. | Accepted. Repository validation remains for file and metadata correctness. |

## Readiness review

| Area | Result | Evidence |
| --- | --- | --- |
| Phase integrity | pass | Discovery writes stayed in this directory; no canonical skill was changed. |
| Intent and outcomes | pass | User-confirmed failure, desired presentation, and handoff hierarchy are in the task definition. |
| Context and evidence | pass | Canonical resources, repository guidance, and the prior problematic output are recorded in `research-notes.md`. |
| Scope and deliverables | pass | Affected resource types and expected outputs are bounded in the task definition. |
| Feasibility and execution | pass | The plan aligns instructions, two templates, readiness guidance, and optional metadata only when needed. |
| Validation and completion | pass | Materiality, navigability, separation, lossless preservation, representative review, and repository checks are defined. |
| Unknowns and consistency | pass | No material user-owned uncertainty remains; this record and task definition agree. |

Result: `ready-for-handoff`

## Closure

Discovery ended without implementing the defined changes. The next authorized
step is implementation from `task-definition.md`; preserve the current source
behavior unless the definition explicitly changes it.
