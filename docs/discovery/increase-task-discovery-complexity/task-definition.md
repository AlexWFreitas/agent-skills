# Task Definition: Deepen Task Discovery Without Losing Coherence

Status: `ready-for-handoff` · Task: `increase-task-discovery-complexity` · Version: `v001`<br>
Last updated: `2026-07-21T23:51:44.0195377-03:00` · Supporting record:
`discovery-record.md`

## Objective

Deepen `task-discovery` so it can produce a complete, implementation-ready task
definition for complex work while remaining coherent and easy for a fresh
implementer to follow. Final document quality governs; the skill does not need
to prescribe a particular rewrite frequency or named discovery phases.

## Implementation context

The recent refinement reduced the final definition to six stable top-level
sections after a representative output became excessive and mixed discovery
work into implementation scope. The user now wants to restore useful depth
without restoring that failure. `skills/phased-plan-to-goal/` demonstrates
relevant contract dimensions—sources and authority, outcomes, requirements and
invariants, decisions, risks, unknowns, supporting documents, acceptance, and
traceability—but its execution lifecycle and large fixed template should not be
copied mechanically.

The discovery record remains the lossless evidence and decision trail. Before
handoff, the task definition must be synthesized as one reader-oriented whole
from the current governing decisions, not presented as accumulated question
history.

Intermediate update cadence is intentionally flexible. The hard lifecycle
requirements are lossless preservation of material discovery content and a
final whole-document synthesis that passes semantic readiness before handoff.
“Implementation-ready” means a fresh agent can understand the outcome,
boundaries, governing choices, deliverables, recommended approach, and checks
without chat context. It does not mean a step-by-step operational plan and does
not authorize execution.

## Scope and non-goals

**In scope**

- Keep six stable top-level sections as the document's navigation spine.
- Rename the fifth section to `Recommended implementation approach` throughout
  the skill, template, readiness guidance, and reference example.
- Allow material task-specific subsections for sources and authority,
  requirements and invariants, decisions and rationale, risks and managed
  unknowns, and contract traceability.
- Retain a settled choice whenever omission could let a competent implementer
  choose a different compliant-looking path.
- Move substantial architecture, research, migration, risk, test-strategy, or
  similar material into linked authoritative supporting documents when that
  improves coherence; summarize each document's implementation consequence in
  the primary definition.
- Require a final whole-document synthesis and semantic readiness review that
  reconcile all material evidence and decisions into a self-contained handoff.
- Allow the agent to choose safe intermediate update timing without treating
  rewrite count or named phases as a quality measure.
- Update `skills/task-discovery/SKILL.md`,
  `assets/task-definition-template.md`,
  `references/readiness-checklist.md`, and
  `references/task-definition-example.md`. Change the discovery-record template
  only if implementation finds a concrete final-reconciliation gap.

**Not in scope**

- Reintroducing discovery questions, rejected alternatives, or chronological
  reasoning as implementation scope.
- Making every optional contract dimension a mandatory fixed section.
- Optimizing for a fixed line count, section count, question count, rewrite
  frequency, or named discovery-phase sequence.
- Copying the execution authorization and planning lifecycle from
  `phased-plan-to-goal` into a read-only discovery skill.
- Producing a separate phased implementation plan, requesting execution
  approval, or performing any implementation.

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| Refined skill guidance | Deep investigation and adaptive contract depth culminate in a coherent final synthesis. |
| Adaptable task-definition resource | Six stable top-level sections with conditional material subsections and supporting-document links. |
| Lossless record guidance | Evidence, questions, rationale, contradictions, and unknowns remain recoverable without competing with the handoff. |
| Semantic readiness guidance | Final review checks completeness, coherence, authority, material decisions, managed risk, validation, and absence of duplicated or transcript-like content. |
| Complex reference example | Replace the simple example with one coherent illustrative definition that demonstrates adaptive subsections and linked authoritative detail without becoming a template. |

## Recommended implementation approach

1. **Define the final contract standard** — adapt the useful contract dimensions
   from `phased-plan-to-goal` into materiality-driven guidance under the six
   reader-oriented sections.
2. **Align artifact responsibilities** — keep the definition as the
   self-contained implementation contract, the record as lossless support, and
   specialist files as linked authoritative detail with explicit consequences.
3. **Strengthen final synthesis and readiness** — require reconciliation of all
   material decisions, evidence, risks, unknowns, deliverables, and checks into
   a coherent whole before handoff.
4. **Validate representative complexity** — test a complex task where omitting
   authority, invariants, decisions, risk, or traceability could permit a wrong
   implementation, and confirm the final definition remains navigable. Perform
   a cold read using only the task definition, then run repository validation
   and tests under both `pwsh` and `powershell` as required by `AGENTS.md`.

The later implementation of this refinement changes documentation-generation
behavior only. The refined skill itself must stop after delivering the
implementation-ready task definition and supporting discovery documentation.

The fifth top-level section is `Recommended implementation approach`. It gives
a fresh implementer the intended approach, sequencing, dependencies, and
decision gates when material, but it is not a separate phased operational plan
and grants no execution authority.

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| Final document is coherent | A fresh implementer can explain the outcome, governing choices, boundaries, deliverables, execution approach, and completion checks without reconstructing them from the record. |
| Useful depth is preserved | Every material source, requirement, invariant, decision, risk, unknown, dependency, and validation obligation is present directly or through a clearly authoritative link. |
| Silent substitution is prevented | Settled choices that exclude reasonable alternatives are explicit beside the work or check they constrain. |
| Optional structure remains adaptive | Additional subsections exist only when omission could change implementation, authority, risk, or verification. |
| Supporting documents improve coherence | Each supporting document has one authoritative purpose and a summarized implementation consequence; truth is not duplicated or fragmented. |
| Exploration stays out of execution scope | The final definition contains conclusions and constraints, not the discovery conversation or already-completed discovery work. |
| Final synthesis is complete | Readiness review reconciles the lossless record and supporting evidence with the final definition and finds no omitted or contradictory material item. |
| Cadence does not govern quality | Intermediate update timing may vary, but final synthesis and lossless preservation remain mandatory. |
| Discovery stops at documentation | No phased implementation plan, execution authorization, or implementation occurs within `task-discovery`. |
| Example demonstrates the target | One complex reference shows useful depth, supporting-document authority, and coherent presentation without prescribing every section for every task. |
| Cold read succeeds | Using only `task-definition.md`, a fresh reader can explain the task, preserve governing choices, and reject reasonable but incorrect implementation paths. |
| Repository validation passes | Repository validation and tests succeed under PowerShell 7 and Windows PowerShell after implementation. |

The task is ready for implementation. It is complete when the four named source
resources express one coherent contract, the complex example and cold read
demonstrate the target, repository checks pass, and `task-discovery` still ends
after documentation without creating or executing a phased plan.
