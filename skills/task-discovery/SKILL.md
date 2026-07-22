---
name: task-discovery
description: Run an explicit, read-only discovery phase that challenges a proposed task and produces a coherent, implementation-ready task definition plus a lossless supporting record. Use only when the user explicitly invokes `$task-discovery` or names `task-discovery`; never trigger implicitly.
---

# Task Discovery

Treat discovery as a bounded phase: investigate and challenge the task first,
then hand off a clear implementation brief. Do not execute the defined task.

## Phase contract

- Ask exactly one discovery question per assistant turn. Wait for the answer
  before selecting the next question.
- Research proactively in read-only mode. Ask the user only for intent,
  authority, preferences, or facts unavailable from safe inspection.
- Challenge vague claims, contradictions, risky assumptions, and premature
  conclusions. Do not make the final handoff a transcript of that exploration.
- Write only inside `docs/discovery/<task-name>/` during discovery. Treat
  project files and external systems as read-only.
- Maintain `discovery-record.md` and `task-definition.md` from the beginning.
- Write in the request language. Preserve technical identifiers and proper names
  when translation would make them inaccurate.
- Do not execute, install, commit, push, publish, or otherwise perform the
  defined task. End discovery and wait for further instructions.

## Start or resume

1. Infer a concise lowercase kebab-case name, propose it, and obtain
   confirmation before creating files.
2. Use `docs/discovery/<task-name>/` by default. If it already exists, ask
   whether to resume it or create a distinct directory.
3. Create the two primary documents from the bundled templates. Set
   `in-progress` status and ISO 8601 timestamps with a UTC offset.
4. Put substantial research, extracts, diagrams, and examples in supporting
   files within the same discovery directory, then link them from the record.
5. On resume, read the current state, canonical trail, task definition, and the
   newest snapshot before asking the next highest-impact question. Record the
   resumed session as a trail event.

## Discovery loop

Repeat until the readiness gate passes:

1. Preserve each material answer, research result, contradiction, and decision
   in the canonical trail before it could be lost. Do not append raw events to
   the task definition.
2. Reconcile the reader-facing documents when useful for safe continuation.
   Whenever `task-definition.md` is updated, rewrite it as one coherent current
   document rather than accumulating patches or question history. Intermediate
   rewrite frequency is not a quality target.
3. Identify one material unresolved point. An issue is material when it could
   change the outcome, scope, approach, permission, cost, risk, validation, or
   definition of done.
4. Explain briefly why it matters and give a recommendation when evidence
   supports one. Keep recommendations distinct from verified facts.
5. Ask one focused question about that point, then wait.

Investigate applicable intent, outcomes, current state, stakeholders, scope,
deliverables, requirements, constraints, dependencies, risks, sequencing,
validation, and completion. Omit a dimension only when it does not materially
affect execution or verification.

For every material researched claim, preserve its source, supported claim,
evidence class (`verified`, `inference`, `assumption`, or `unresolved`), and
any relevant freshness, conflict, or access limitation. Do not copy secrets or
unnecessary sensitive content.

## Artifact contracts

### Task definition: the primary handoff

Keep `task-definition.md` self-contained for a fresh implementer. Use these six
sections in this order:

1. Objective
2. Implementation context
3. Scope and non-goals
4. Deliverables
5. Recommended implementation approach
6. Verification and definition of done

Treat these sections as a stable navigation spine, not a complete fixed schema.
Add task-specific subsections for sources and authority, requirements and
invariants, decisions and rationale, risks and managed unknowns, contract
traceability, or similar dimensions only when omission could change
implementation, authority, risk, a boundary, or verification. Put a constraint
or decision beside the work or check it governs rather than collecting detached
rules.

Use `Recommended implementation approach` for outcome-level sequencing,
dependencies, and decision gates a fresh implementer needs. Do not turn it into
a command-by-command plan, a separate phased implementation plan, or execution
authorization. Task discovery creates documentation only.

Move substantial architecture, research, migration, risk, test-strategy, or
other specialist detail into a linked supporting document when that makes the
primary definition easier to understand. Give each supporting document one
clear authoritative purpose, summarize its implementation consequence in the
task definition, and avoid duplicating governing truth across files.

Never include discovery questions, rejected alternatives, chronological
reasoning, or already-completed discovery work as implementation scope. Include
only the conclusions and constraints the implementer must preserve.

Before handoff, rebuild this document as a whole from the current governing
decisions, evidence, and linked authoritative detail. Reconcile it against the
lossless record so no material requirement, invariant, decision, risk, managed
unknown, dependency, deliverable, or validation obligation is missing or
contradictory. Apply a materiality review: remove or move to the record any
optional paragraph, row, or subsection whose removal would not change
implementation, authority, risk, a boundary, or verification. A settled choice
is material when omitting it would let a fresh, competent implementer
reasonably choose another option while believing they still complied; keep that
choice beside the scope, approach, or check it constrains. Do not use an
arbitrary line, section, question, or rewrite-count limit.

### Discovery record: the lossless supporting artifact

Keep `discovery-record.md` in three layers:

1. A short current-state summary with status, settled understanding, next
   unresolved point, and links.
2. One continuous canonical chronological trail. Record each material question
   or event once with its reason, recommendation, answer or evidence, and
   resulting decision or definition impact.
3. Linked research notes for substantial source detail.

Compaction is lossless: do not delete a question, answer, evidence item,
rationale, or managed unknown. Improve navigation by keeping it once in the
canonical trail or linked note rather than repeating it in separate ledgers.

### Examples

Read `references/task-definition-example.md` when a concrete presentation model
will help calibrate the output. It is illustrative, not a template. Use its
conditional subsections and linked supporting contract only when comparable
material exists; do not mechanically reproduce its depth or headings.

## Readiness, closure, and reopening

Before closure, synthesize the complete task definition as one reader-oriented
whole, then apply `references/readiness-checklist.md`. Use the review to judge
coherence, completeness, authority, materiality, and document roles; do not try
to mechanically lint semantic quality by length, heading count, or rewrite
frequency.

Continue discovery while a material uncertainty, contradiction, unverified
dependency, missing acceptance criterion, unclear boundary, or unmanaged risk
remains. An unavoidable external unknown may remain only when its impact,
resolver, resolution step, and safe contingency or gate are recorded.

When ready:

1. Perform a definition-only cold read: using no chat or discovery record,
   confirm a fresh agent can explain the task, preserve its governing choices,
   and reject reasonable but incorrect implementation paths.
2. Set both primary documents to `ready-for-handoff`.
3. Record the readiness review and closure in the canonical trail.
4. Create `versions/` if absent and save the definition as the next zero-padded
   snapshot, such as `versions/task-definition-v001.md`.
5. Present concise links to the task definition, discovery record, supporting
   research, and snapshot. State that discovery has ended and wait.

For an early user-requested closure, run the review, explain material gaps, ask
one confirmation question, then mark both documents `incomplete` if confirmed.

For a later explicit invocation that materially changes a completed definition,
reopen the same directory, preserve snapshots, add a resumed-session trail
event, set both documents to `in-progress`, and snapshot only when that session
closes.
