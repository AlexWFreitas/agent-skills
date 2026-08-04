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
  the required outcome, authority, a significant current risk, a governing
  boundary, or verification.
- Every settled choice whose omission would permit a materially different
  outcome or an authority or scope violation is retained beside the scope,
  approach, or verification check it constrains.
- Exact algorithms, operational tuning values, recoverable mechanics, and
  future-scale provisions appear only when governing evidence or an explicit
  user-owned decision makes them requirements.
- It is a whole-document synthesis: stale, exploratory, appended, or
  contradictory interim prose has been removed.
- It communicates governing decisions as an integrated contract, not as a list
  of accumulated requests.
- Its definition of done requires implemented deliverables and behavior plus
  passing completion evidence; it does not describe discovery-document or
  handoff readiness as completion of the task.

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

## Decision discipline

- Every discovery question was a user-owned blocker: it changed a material
  outcome, scope, authority, significant cost, irreversible policy, or
  completion rule; evidence could not resolve it; implementation could not
  safely defer it; and the user was the proper owner.
- Every user-visible authorization rule and public input/output semantic traces
  to governing evidence or an explicit user-owned decision. A conservative
  default was not used as silent product authority.
- Reusing an earlier answer required that it directly settle the same decision;
  adjacent facts and related requirements were not treated as implicit answers.
- Implementer-owned choices use bounded latitude, evidence-backed constraints,
  or reversible defaults instead of user interrogation.
- Risks are promoted to discovery gates only when plausible in the stated
  context and significant enough to justify a decision now. Speculative future
  scale and remote compound failures are deferred or excluded.
- A selected safety mechanism did not recursively expand into questions about
  every internal failure mode or tuning value.
- No decision was asked twice in substance. A reopened decision identifies the
  new evidence that made the recorded answer insufficient.
- Any user concern about relevance, excessive depth, added machinery, or
  repeated low-level confusion triggered an immediate depth and scope review.

## Supporting record and evidence

- The record has a concise current-state summary, one canonical trail, and
  linked research notes when needed.
- Each material question, answer, evidence item, rationale, and managed unknown
  remains recoverable without duplicated ledgers.
- Material claims identify their source and evidence class; freshness, conflict,
  or access limitations are recorded when relevant.

## Implementation readiness

- Scope, exclusions, deliverables, governing constraints, dependencies,
  user-owned risks, approval gates, validation, and definition of done are
  resolved or materially inapplicable.
- Each plausible high-impact external unknown records its impact, resolver,
  resolution step, and safe contingency or gate.
- When a required interface, report, or data contract names values whose source
  availability or semantics are not verified, the definition records an
  implementation inspection dependency, resolver, and safe stop gate rather
  than assuming the values exist.
- Acceptance checks verify representative semantic behavior and data values,
  not only structural shape, headers, field presence, or documentation.
- Internal correctness mechanisms such as deterministic traversal or
  normalization are not presented as public ordering, encoding, filename,
  versioning, or compatibility promises without governing authority.
- Remaining internal design choices, tunable defaults, and ordinary
  recoverable mechanics are intentionally delegated rather than mislabeled as
  unresolved task blockers.
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
- Identify where a competent implementer retains freedom to choose techniques,
  defaults, and routine error handling.
- Explain what implemented evidence, rather than document readiness, proves the
  task complete.
- Follow every material supporting-document link and explain what that document
  governs and how it affects implementation.

Pass the gate when every applicable item passes and no user-owned blocker
remains. Do not require every implementation choice or conceivable risk to be
resolved. If the user insists on early closure while a user-owned blocker
remains, use the guarded early-exit procedure in `SKILL.md` and mark the result
`incomplete`.
