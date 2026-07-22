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
- It states the outcome, execution-relevant context, scope, deliverables,
  ordered work, and observable completion checks for a fresh implementer.
- It contains no discovery transcript, rejected alternative, or settled
  discovery work unless that fact directly constrains implementation.
- Every optional item passes the materiality review: removing it would change
  implementation, a boundary, or verification.
- It is current synthesis: stale or exploratory interim prose has been removed.

## Supporting record and evidence

- The record has a concise current-state summary, one canonical trail, and
  linked research notes when needed.
- Each material question, answer, evidence item, rationale, and managed unknown
  remains recoverable without duplicated ledgers.
- Material claims identify their source and evidence class; freshness, conflict,
  or access limitations are recorded when relevant.

## Execution readiness

- Scope, exclusions, deliverables, constraints, dependencies, risks, approval
  gates, validation, and definition of done are resolved or materially
  inapplicable.
- Each unavoidable external unknown records its impact, resolver, resolution
  step, and safe contingency or gate.
- The definition is sufficient for a fresh implementer without chat context.

Pass the gate only when every applicable item passes and all remaining unknowns
are managed. If the user insists on early closure, use the guarded early-exit
procedure in `SKILL.md` and mark the result `incomplete`.
