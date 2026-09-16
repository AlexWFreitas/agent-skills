# Discovery readiness

Use this semantic review before handoff. Record pass, needs-work, or
not-applicable for the relevant areas and explain non-obvious exclusions.
Length, heading count, and a fixed number of questions cannot prove readiness.

## Scope and evidence

- Discovery was requested; project implementation stayed read-only and writes
  stayed inside the selected discovery directory.
- Definition and supporting record agree, use the request language, and have
  current status and timestamps.
- Material claims have sources and evidence classes with relevant freshness,
  conflict, and access limits.
- Material questions, answers, rationale, and research are preserved once in
  the record or its linked sources, without secrets or unnecessary sensitive data.

## Definition quality

- The six core sections explain the outcome, context, scope, deliverables,
  recommended approach, and implementation completion evidence.
- Each material requirement, invariant, decision, dependency, and verification
  obligation appears directly or through a clearly authoritative link.
- Omitting no settled choice would let a competent implementer deliver a
  materially different outcome or cross an authority boundary unnoticed.
- Optional detail constrains actual work. The brief contains conclusions and
  governing rationale, not the discovery transcript or a command-level plan.
- Operational non-goals disclose observable effects and required manual actions
  when material, including effects on existing consumers.
- Public authorization and input/output semantics follow evidence or explicit
  owner decisions. Conservative recommendations and adjacent requirements
  have not silently supplied missing product authority.
- Internal ordering, normalization, encoding, naming, or versioning mechanics
  have not become unsupported public compatibility promises.
- Implementation choices remain open unless governing evidence requires them.

## Remaining uncertainty

- No unresolved user-owned blocker remains under the entry point's four-part
  ownership test. No question was repeated without material new evidence.
- Each remaining significant external unknown names impact, resolver,
  resolution step, and a safe contingency or gate.
- Unverified source data values have an implementation inspection dependency
  rather than an assumed schema.
- Acceptance checks cover meaningful behavior and representative values.
- Routine tuning, reversible mechanics, and speculative future risks are not
  mislabeled as blockers.

## Cold read and closure

Using only the definition and its governing links, verify that a fresh agent
can explain the outcome and boundaries, reject a plausible but noncompliant
approach, identify implementation latitude, and determine what evidence proves
the implementation complete.

When applicable items pass, mark ready-for-handoff and snapshot the definition.
Verify that the new snapshot's relative links resolve from its own directory;
record the source location and freeze the complete substantive content.
Do not require implementation tests during discovery. For an explicit early
closure with material gaps, record them and mark incomplete under the entry
point's closure procedure.
