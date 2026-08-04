# Readiness and Closure Checklist

Use this semantic review at the combined approval gate, material replanning,
resume, and closure. Judge coherence and authority; do not mechanically lint
quality by file count, line count, or heading count.

## Before requesting approval

- Source provenance, precedence, freshness, conflicts, omissions, and access
  limits are recorded where material.
- No governing requirement, clarification, decision, or boundary exists only in
  chat or an unindexed source.
- The normalized task definition is self-contained without assuming a discovery
  record. It distinguishes verified current state from inference and assumption.
- Desired outcomes have observable success measures; requirements and
  invariants are testable and include the functional, non-functional,
  compatibility, security, operational, and data obligations that materially
  constrain this task. Unneeded categories were not populated mechanically.
- Affected systems and users, scope, exclusions, deliverables, constraints,
  dependencies, and assumptions have the detail needed to constrain execution.
- Material decisions preserve rationale and prohibit silent substitution of an
  approach that changes the required outcome or crosses an authority or scope
  boundary.
- Plausible significant risks have triggers, impacts, proportionate mitigations
  or contingencies, and a resolver. Remote compound failures and speculative
  future-scale concerns were not promoted into current scope.
- Every user-owned or execution-blocking unknown has impact, resolver,
  resolution step, and a safe contingency or gate. Implementer-owned choices
  use bounded latitude or evidence-backed reversible defaults.
- Every outcome and requirement traces to a deliverable and acceptance check;
  every deliverable and check traces back to governing authority.
- The definition of done requires implemented deliverables and behavior plus
  passing evidence; it does not describe contract or plan readiness as task
  completion.
- Required interface and data values trace to verified sources or to an explicit
  implementation inspection dependency and safe stop gate. Acceptance checks
  cover representative semantics, not only structural shape.
- The implementation plan covers every deliverable and definition-of-done
  check with outcome-led, bounded, dependency-aware, verifiable phases, and its
  coverage synthesis agrees with the task definition.
- The plan uses the fewest phases that create meaningful dependency,
  authorization, mutation, recovery, or verification boundaries; routine steps
  did not become separate phases.
- The mutation surface is complete. Every consequential action is named rather
  than implied.
- Supporting files improve coherence, are indexed from a canonical entry point,
  state their authoritative purpose and implementation consequence, and do not
  duplicate or fragment authoritative facts.
- Optional sections were omitted only after a materiality review, not because
  the compact source material failed to mention them.
- Every planning question was user-owned because it affected the outcome,
  scope, authority, significant cost, irreversible policy, or verification and
  could not be resolved or safely delegated.
- Every user-visible authorization rule and public input/output semantic traces
  to governing evidence or an explicit owner decision; conservative defaults
  and adjacent requirements were not treated as silent authority.
- Internal correctness mechanisms were not promoted into public ordering,
  encoding, filename, versioning, or compatibility promises without evidence.
- No decision was asked twice in substance. A reopened decision identifies the
  new evidence that made the recorded answer insufficient.
- Safety mechanisms, rollback provisions, phases, and supporting documents are
  proportionate to current evidence rather than recursively expanded around
  every conceivable failure.
- Remaining unknowns are implementer-owned, non-material, or have an impact,
  resolver, resolution step, and safe contingency or gate.
- The direct approval question distinguishes one named phase, complete-plan
  change-sensitive, and complete-plan persistent authorization. When
  `request_user_input` is available, it presents those three bounded choices,
  identifies an evidence-backed recommendation, names the exact scope, and has
  no auto-resolution timeout.

## Before starting or changing a phase

- Recorded authorization covers the phase, current mode, mutations, and named
  consequential actions.
- Entry conditions and dependencies are satisfied or explicitly managed.
- Actual state still agrees with the plan; unrelated user changes are
  protected.
- A material change in change-sensitive mode has renewed approval.
- Persistent-mode work remains inside the approved task contract and immutable
  stop boundaries.

## After a phase or failed check

- Required checks have evidence; an attempted change is not labeled complete.
- Recoverable failures were diagnosed within authority.
- A failed or blocked phase records evidence, impact, resolver, next action,
  and safe contingency.
- Any accepted limitation has explicit user evidence.
- Current-state sections were rewritten coherently and the material event was
  recorded once.

## On resume

- Applicable instructions, the task contract, plan, newest snapshots,
  supporting-file index, and material sources were reread.
- Actual state was inspected read-only before mutation and reconciled with the
  record.
- Goal, authorization, mutation surface, mode, and next action remain valid.
- Material drift caused clarification or renewed approval rather than silent
  continuation.

## Before closure

- Every phase has a justified terminal state.
- All required checks pass or each remaining limitation is explicitly accepted.
- Actual workspace and external state are reconciled and every mutation or
  consequential action is accounted for.
- The task definition remains the approved contract or has a properly approved,
  versioned amendment.
- The plan and supporting documents form a coherent, non-duplicative whole that
  a fresh agent can resume without chat context.
- Complete final snapshots exist and the handoff identifies results, evidence,
  accepted limitations, and follow-up work.
