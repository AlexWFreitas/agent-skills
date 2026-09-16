# Decision ownership

Use this guide when a point's owner or materiality is unclear. The default
discovery workflow remains in the skill entry point.

## Ask the right owner

A question belongs to the user only when all four conditions hold:

1. Different answers materially change the user-visible outcome, authorized
   scope, significant cost, permission boundary, irreversible policy, or
   definition of done.
2. Safe inspection, governing evidence, and existing requirements do not settle it.
3. A competent implementer cannot safely choose or defer it within those boundaries.
4. The user is the proper decision owner.

Internal algorithms, timeouts, batch sizes, logging cadence, routine recovery,
formatting, and test organization normally belong to implementation. Record an
outcome or constraint and preserve freedom to choose a compliant technique.

A foundational choice can belong to the user when it commits the task to
different infrastructure, cost, compatibility, or operations. A schema or
migration difference alone does not establish that ownership.

## Preserve product authority

Technical feasibility, reuse, lower implementation cost, and conservative
defaults support recommendations; they do not supply product authority. Trace
a governing choice to existing evidence or an explicit answer before excluding
alternatives. Keep implementer recommendations adaptable.

Who may act, what callers may submit, and what users receive are material public
semantics. Inspect established conventions first; ask when they do not govern.
Least privilege can support a recommendation but cannot silently settle a
missing product policy.

Internal traversal, normalization, serialization, and version handling do not
automatically create public ordering, encoding, naming, versioning, or
compatibility promises.

Ask one decision per question. An option can explain its consequences, but
cannot hide a separate foundational choice and treat selection as approval of
both. Reuse only an answer that directly settles the same choice.

## Disclose settled consequences

When evidence settles a material lifecycle or compatibility boundary, explain
its effect instead of asking for redundant confirmation. State when a change
takes effect, what in-flight or already-running consumers see, and whether a
restart, reconnect, redeploy, or other manual action is needed.

Keep those consequences in the brief and final handoff. Ask only when materially
different user-owned outcomes remain possible.

## Bound uncertainty

A risk needs attention now when it is plausible in the stated context and its
consequence changes delivery or requires an owner decision before work proceeds.
Do not recursively turn failure modes of each mitigation into more gates.

A high-impact external unknown may remain if the definition names its impact,
resolver, resolution step, and safe contingency or gate. For required data
values whose availability is unverified, require source inspection before the
dependent implementation rather than assuming a schema.

Verify representative behavior and values, not only output shape. Never treat
the completeness of a discovery document as evidence that the implementation
works.

If a question cannot briefly explain why the user owns it and what different
delivery its answers imply, inspect further, delegate the choice to
implementation, or defer it.
