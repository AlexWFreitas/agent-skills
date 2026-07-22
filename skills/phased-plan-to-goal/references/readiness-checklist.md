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
  invariants are testable and include material functional, non-functional,
  compatibility, security, operational, and data obligations.
- Affected systems and users, scope, exclusions, deliverables, constraints,
  dependencies, and assumptions have the detail needed to constrain execution.
- Material decisions preserve rationale and prohibit silent substitution of a
  different compliant-looking approach.
- Material risks have triggers, impacts, mitigations or contingencies, and a
  resolver. Every unavoidable unknown has impact, resolver, resolution step,
  and a safe contingency or gate.
- Every outcome and requirement traces to a deliverable and acceptance check;
  every deliverable and check traces back to governing authority.
- The implementation plan covers every deliverable and definition-of-done
  check with outcome-led, bounded, dependency-aware, verifiable phases, and its
  coverage synthesis agrees with the task definition.
- The mutation surface is complete. Every consequential action is named rather
  than implied.
- Supporting files improve coherence, are indexed from a canonical entry point,
  state their authoritative purpose and implementation consequence, and do not
  duplicate or fragment authoritative facts.
- Optional sections were omitted only after a materiality review, not because
  the compact source material failed to mention them.
- Remaining unknowns are non-material or have an impact, resolver, resolution
  step, and safe contingency or gate.
- The direct approval question distinguishes one phase, complete-plan
  change-sensitive, and complete-plan persistent authorization.

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
