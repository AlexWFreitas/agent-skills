# Task Definition: Refine the Task-Discovery Skill

## Objective

Refine `task-discovery` so its final handoff is a clear, medium-depth
implementation brief rather than a long accumulation of discovery material.
The result should preserve the skill's questioning and challenge phase while
giving a fresh implementer a concise explanation of the outcome, the bounded
work, and how to verify it.

## Implementation context

The current canonical skill is `skills/task-discovery/`. Its task-definition
template contains many predefined sections, and the representative output in
`docs/discovery/prepare-agent-skill-repository/` grew to 389 lines with about
20 headings. That output included discovery work—such as determining agent
roles—in implementation scope. The desired design keeps detailed questions,
rationale, alternatives, and history in `discovery-record.md`; the task
definition is the current synthesis for implementation.

## Scope and non-goals

**In scope**

- Revise the task-discovery instructions and bundled guidance so the primary
  handoff is an outcome-led, medium-depth brief.
- Replace or reshape the task-definition template so it has a small default
  structure and adds detail only when it changes execution or verification.
- Define the compaction lifecycle: update the discovery record chronologically,
  but rewrite the task definition from current decisions at material milestones
  and before handoff.
- Add validation that detects discovery material, stale text, and disconnected
  catalogues in the primary handoff.

**Not in scope**

- Removing the discovery record or its role as traceable supporting context.
- Changing the one-question-at-a-time discovery behavior unless separate
  evidence identifies a problem with it.
- Retrofitting historical discovery directories beyond using one as evidence.

## Deliverables

| Deliverable | What it must provide |
| --- | --- |
| Revised skill guidance | Clear rules for separating exploration from implementation handoff and for compacting the primary brief. |
| Revised task-definition resource | A readable default structure that begins with outcome and boundaries, then presents the work in order. |
| Readiness or validation guidance | Checks that the final definition stands alone, omits stale exploration, and remains sufficient to implement. |
| Representative verification | A comparison against the prior problematic output showing the new structure remains complete without recreating its bulk. |

## Execution plan

1. **Identify the pressure toward exhaustive output** — compare the current
   instructions, template, and readiness guidance with the prior output; map
   each pressure to a specific behavior that must change.
2. **Define the core handoff shape** — establish the small default set of
   sections and the materiality rule for optional detail. Keep execution facts
   near the step or check they affect instead of collecting them in separate
   catalogues.
3. **Update the skill resources** — make the source instructions, template,
   and readiness checks agree on document roles, compaction, and the desired
   presentation sequence.
4. **Verify with a representative task** — use the prior discovery result or a
   comparable scenario to confirm a fresh implementer can identify the work,
   boundaries, deliverables, and completion checks without reading the record.

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| The handoff has a coherent narrative | It leads from objective through bounded work to verification, without requiring readers to reconstruct the plan from lists. |
| Discovery material is separated | Questions, rejected alternatives, and settled decisions appear in the record unless they directly constrain implementation. |
| The brief is complete but compact | A representative output covers execution, boundaries, deliverables, and verification without defaulting to unnecessary sections. |
| Updates do not accumulate clutter | After multiple discoveries, the final task definition contains only current synthesis; the record retains the historical trail. |
| The skill remains usable | A fresh agent can follow the refined instructions and produce a self-contained task definition without chat context. |

The refinement is complete when these checks pass, the revised resources agree
with one another, and the resulting brief is demonstrably easier to navigate
than the prior representative output.
