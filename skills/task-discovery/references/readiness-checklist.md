# Readiness Checklist

Apply this as a semantic self-review before closure. Record each area as
`pass`, `needs-work`, or `not-applicable` in the canonical decision trail.
Explain any non-obvious `not-applicable` result.

## Phase integrity

- The skill was explicitly invoked.
- No implementation or write occurred outside the discovery directory.
- Both primary documents use the request language, agree with each other, and
  have current status and timestamps.

## Primary handoff

- The task definition has the six core sections in order.
- It states the outcome, implementation-relevant context, scope, deliverables,
  recommended approach, and observable completion checks for a fresh
  implementer.
- The six sections form a clear reading sequence. Optional subsections add only
  material task-specific depth rather than behaving as a fixed checklist.
- It contains no discovery transcript, rejected alternative, or settled
  discovery work unless that fact directly constrains implementation.
- Every optional item passes the materiality review: removing it would change
  implementation, authority, risk, a boundary, or verification.
- Every settled choice that leaves a reasonable implementation alternative open
  is retained beside the scope, approach, or verification check it
  constrains.
- It is a whole-document synthesis: stale, exploratory, appended, or
  contradictory interim prose has been removed.
- It communicates governing decisions as an integrated contract, not as a list
  of accumulated requests.

## Contract depth and authority

- Every material source, requirement, invariant, decision, dependency, risk,
  managed unknown, and validation obligation appears directly or through a
  clearly authoritative link.
- Each linked supporting document has one clear purpose and authority. The task
  definition summarizes the implementation consequence without duplicating or
  fragmenting governing truth.
- Optional detail is located where a reader needs it to understand the work or
  check it constrains.
- The recommended implementation approach gives sufficient sequencing,
  dependencies, and gates without becoming a command-level plan, separate
  phased implementation plan, or execution authorization.

## Supporting record and evidence

- The record has a concise current-state summary, one canonical trail, and
  linked research notes when needed.
- Each material question, answer, evidence item, rationale, and managed unknown
  remains recoverable without duplicated ledgers.
- Material claims identify their source and evidence class; freshness, conflict,
  or access limitations are recorded when relevant.

## Implementation readiness

- Scope, exclusions, deliverables, constraints, dependencies, risks, approval
  gates, validation, and definition of done are resolved or materially
  inapplicable.
- Each unavoidable external unknown records its impact, resolver, resolution
  step, and safe contingency or gate.
- The definition is sufficient for a fresh implementer without chat context.

## Definition-only cold read

Using only `task-definition.md`, confirm that a fresh agent can:

- Explain the intended outcome, relevant current state, boundaries,
  deliverables, recommended approach, and completion evidence in a coherent
  sequence.
- Identify the governing choices and invariants that must not be silently
  substituted.
- Reject a reasonable but incorrect implementation path that conflicts with
  those choices.
- Follow every material supporting-document link and explain what that document
  governs and how it affects implementation.

Pass the gate only when every applicable item passes and all remaining unknowns
are managed. If the user insists on early closure, use the guarded early-exit
procedure in `SKILL.md` and mark the result `incomplete`.
