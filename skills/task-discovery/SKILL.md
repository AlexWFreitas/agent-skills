---
name: task-discovery
description: Run an explicit, read-only discovery phase that challenges a proposed task and produces a coherent, implementation-ready task definition plus a lossless supporting record. Use only when the user explicitly invokes `$task-discovery` or names `task-discovery`; never trigger implicitly.
---

# Task Discovery

Treat discovery as a bounded phase: investigate and challenge the task first,
then hand off a clear implementation brief. Do not execute the defined task.

The user's explicit instructions govern this workflow within the host's
permissions. Use the defaults below where the user has left room; do not turn
an example, template, or suggested technique into an additional requirement.
If a skill rule actually blocks requested work, link this `SKILL.md`, quote the
rule, and explain the specific unresolved boundary after doing the authorized
work that does not depend on it.

## Phase contract

- Keep at most one discovery question unanswered. After the answer, preserve and
  analyze it, continue the loop immediately, and ask the next user-owned
  question when one remains. This is not a one-question-per-assistant-turn
  limit.
- Research proactively in read-only mode. Ask the user only for intent,
  authority, preferences, or facts unavailable from safe inspection.
- Default to lean, outcome-level discovery. Do not make the user design internal
  algorithms, tune operational constants, or resolve speculative future
  scenarios unless the request explicitly requires that depth.
- Challenge vague claims, contradictions, risky assumptions, and premature
  conclusions. Do not make the final handoff a transcript of that exploration.
- Write only inside the selected discovery directory during discovery. Treat
  project files and external systems as read-only.
- Maintain `discovery-record.md` and `task-definition.md` from the beginning.
- Write in the request language. Preserve technical identifiers and proper names
  when translation would make them inaccurate.
- Do not execute, install, commit, push, publish, or otherwise perform the
  defined task. End discovery and wait for further instructions.

## Request user input

Ask only after applying the decision-ownership rules below. Keep one question
unanswered at a time, and continue independent read-only research while waiting.
Prefer an available user-input tool only when its current instructions permit
that question type. Follow its live schema rather than assuming fixed fields
or that `request_user_input` accepts approval requests. Use plain text when a
required question cannot use the available tool.

For a bounded choice, offer two or three mutually exclusive options and put an
evidence-backed recommendation first. Leave room for the user's own wording;
do not force exploratory answers into choices or duplicate a built-in free-form
option. Do not request secrets in question cards or discovery records.

An optional preference may use a stated reversible default if unanswered. A
user-owned blocker needs an explicit answer before dependent work proceeds;
silence, a preselected option, and elapsed time do not resolve it. Apply an
answer immediately without requesting a separate acknowledgement.

Never end after an answer with only a recap, the next unresolved point, or a
promise to ask the next question on a later turn. A concise transition may
precede the next question, but it must not replace it. Stop without the next
question only when discovery is ready to close, the user asks to pause or
discuss, or a genuine blocker prevents identifying the next question.

Sequential input calls do not justify a chain of merely interesting questions.
Reapply the decision-ownership and readiness rules below before every question.

Before asking, search the visible conversation and canonical trail for the same
decision in substance, not only identical wording. Reuse an existing answer;
do not reissue a question because context was compacted, a question-card return
was unclear, local tool state was lost, or the prompt can be phrased better. Ask
again only when no reliable answer was recorded or new evidence materially
changes the decision. In the latter case, state what changed and why the prior
answer no longer resolves it. Reuse only an answer that directly settles the
same choice; do not stretch an adjacent fact or related requirement into an
implicit answer.

## Start or resume

1. Use the user's task name or infer a concise lowercase kebab-case name.
   Naming alone does not require confirmation.
2. Use the user's explicit destination or `docs/discovery/<task-name>/` by
   default. Resume an existing directory when its task identity clearly
   matches. Ask only when ownership or task identity is ambiguous; do not
   overwrite unrelated work.
3. For a new discovery, create the two primary documents from the bundled
   templates. Set `in-progress` status and ISO 8601 timestamps with a UTC
   offset. On resume, retain the existing documents and follow step 5.
4. Put substantial research, extracts, diagrams, and examples in supporting
   files within the same discovery directory, then link them from the record.
5. On resume, read the current state, canonical trail, task definition, and the
   newest snapshot before asking the next highest-impact question. Record the
   resumed session as a trail event.

## Decide what deserves a question

Classify each unresolved point before asking about it:

1. **User-owned blocker** — Ask only when all of these are true:
   - different answers would materially change the user-visible outcome,
     authorized scope, significant cost, permission or security boundary,
     irreversible data or operational policy, or definition of done;
   - safe inspection, governing sources, existing conventions, and explicit
     requirements do not resolve it;
   - a competent implementer cannot safely defer the choice to implementation;
   - the user is the proper decision owner.
2. **Implementer-owned decision** — Record the required outcome, constraint, or
   recommended reversible default, then leave the exact technique to
   implementation. This normally includes internal structure, algorithms,
   formatting details, timeout and retry values, batch sizes, logging cadence,
   recoverable write mechanics, and test organization.
3. **Speculative or future concern** — Defer it or state it as a non-goal when
   it depends on unestablished scale, a remote compound failure, a future
   topology, or an unrequested capability.

Treat a **resolved but consequence-bearing** point as a disclosure obligation,
not a fourth unresolved-point classification. When explicit requirements or
governing evidence settle a lifecycle, propagation, availability,
compatibility, or manual-operation boundary, do not ask for redundant
confirmation. Translate the boundary into observable behavior: when a change
takes effect, what already-running or in-flight consumers continue to see, and
whether a restart, reconnect, redeploy, or other manual action is required.
Surface a material consequence in both the task definition and concise final
handoff. Ask only if the evidence still permits materially different
user-owned outcomes.

Treat risk as material only when the scenario is plausible in the stated
context and its consequence justifies consuming user attention now. A
theoretical possibility or any change in technical risk is not enough. Once a
required safety outcome is clear, do not recursively turn every failure mode of
its proposed mitigation into another discovery gate.

A foundational technical choice may be user-owned when it commits the task to
materially different infrastructure, cost, compatibility, or operational
behavior. After that boundary is settled, do not ask the user to tune each
internal mechanism. If a question cannot briefly state why the user owns it and
what materially different delivery would result, do not ask it.

Technical feasibility, reuse of an existing mechanism, lower implementation
cost, or a conservative default may support a recommendation, but none alone
authorizes a governing choice. Classify the choice using the full tests above.
For an implementer-owned choice, keep the recommendation non-governing and
preserve latitude for a competent implementer to substitute another compliant
technique. For a user-owned foundational choice, require direct governing
evidence or an explicit answer before the definition excludes alternatives or
makes the recommendation mandatory. A schema or migration difference alone
does not make a choice user-owned.

Keep each question scoped to one decision. An option may explain its material
consequences, but do not embed a separate unconfirmed foundational choice and
later treat selection of that option as authority for both. A user's answer
settles only the decision actually asked.

Treat user-visible authorization and public input/output semantics as
user-owned when alternatives change who can act, what callers may submit, or
what users receive. Inspect established product and repository conventions
first; if they govern, record them as evidence, and if they do not, ask. A
least-privilege or otherwise conservative default may support a recommendation
but does not replace missing product authority.

Keep internal correctness separate from public compatibility. Stable traversal,
normalization, serialization, and version handling may be necessary internally,
but do not make their exact form a public ordering, encoding, filename,
versioning, or compatibility promise without governing evidence or a user-owned
decision.

If the user questions relevance or depth, expresses frustration, rejects added
machinery, or repeatedly needs low-level alternatives explained, pause the
question loop. Reassess the remaining points against the objective and
readiness gate, distinguish required decisions from implementation latitude,
remove speculative scope, and continue at the shallower depth. Do not respond
by splitting the same technical design into more questions.

## Discovery loop

Repeat until the readiness gate passes:

1. Preserve each material answer, research result, contradiction, and decision
   in the canonical trail before it could be lost. Do not append raw events to
   the task definition.
2. Reconcile reader-facing documents at meaningful checkpoints, not after every
   ordinary answer. Batch whole-document synthesis, link checks, cold reads,
   and repository-state validation unless immediate reconciliation is needed
   for safe continuation. Whenever `task-definition.md` is updated, rewrite it
   as one coherent current document rather than accumulating patches.
3. Classify unresolved points using the decision rules above. Resolve safe
   inspectable facts first; preserve implementer-owned latitude and defer
   speculative concerns rather than turning them into questions. Remove any
   point already answered in substance unless new material evidence reopens it.
4. When a user-owned blocker remains, select the highest-impact one, explain
   briefly why the user owns it, and give a recommendation when evidence
   supports one. Keep recommendations distinct from verified facts.
5. Ask one focused question about that blocker using the input rules above.
   When the answer returns, restart at step 1 in the same active interaction
   rather than ending on an acknowledgement or summary.
6. When no user-owned blocker remains, stop asking questions and run the
   readiness review. Do not wait for every implementation choice or conceivable
   risk to be eliminated.

Investigate applicable intent, outcomes, current state, stakeholders, scope,
deliverables, requirements, constraints, dependencies, risks, sequencing,
validation, and completion only to the depth needed for a safe handoff. Omit a
dimension when it does not materially affect the outcome, a user-owned
boundary, implementation authority, or verification. Do not enumerate every
possible contingency.

For every material researched claim, preserve its source, supported claim,
evidence class (`verified`, `inference`, `assumption`, or `unresolved`), and
any relevant freshness, conflict, or access limitation. Do not copy secrets or
unnecessary sensitive content.

Treat a new user message as steering for the current discovery unless it
explicitly replaces or ends the task. Answer side questions briefly, preserve
settled decisions, and continue the active discovery. Validate the final
handoff once against the readiness checklist; repeat only affected checks when
new evidence or revisions warrant it. Discovery does not require running the
defined implementation's test suite.

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

State a material operational non-goal in observable terms, not only as a
technical exclusion. For example, if live refresh is excluded, also state when
saved changes reach already-running consumers and whether a restart is
required. Do not add lifecycle detail when it is immaterial to the task.

Use `Recommended implementation approach` for outcome-level sequencing,
dependencies, and decision gates a fresh implementer needs. Do not turn it into
a command-by-command plan, a separate phased implementation plan, or execution
authorization. Task discovery creates documentation only.

Make `Verification and definition of done` describe completion of the defined
implementation: required deliverables exist, governed behavior works, and the
specified checks pass in the owning systems. Never substitute readiness,
coherence, or completeness of the discovery documents for task completion;
discovery closure is governed separately below.

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
the required outcome, authority, a significant current risk, a governing
boundary, or verification. Preserve implementation latitude: specify an exact
technique or tuning value only when evidence or a user-owned decision makes it
governing. A settled choice is material when omitting it would let a fresh,
competent implementer deliver a materially different outcome or cross an
authority or scope boundary while believing they still complied. Do not use an
arbitrary line, section, question, or rewrite-count limit; use this sufficiency
test as the bound.

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
dependency, missing acceptance criterion, unclear boundary, or current risk
remains **and** it is a user-owned blocker under the rules above. A plausible,
high-impact external unknown may remain only when its impact, resolver,
resolution step, and safe contingency or gate are recorded. Implementer-owned
choices and remote risks do not block handoff.

When ready:

1. Perform a definition-only cold read: using no chat or discovery record,
   confirm a fresh agent can explain the task, preserve its governing choices,
   reject materially incorrect paths, and identify where implementation
   latitude intentionally remains.
2. Set both primary documents to `ready-for-handoff`.
3. Record the readiness review and closure in the canonical trail.
4. Create `versions/` if absent and save the definition as the next zero-padded
   snapshot, such as `versions/task-definition-v001.md`.
5. Present concise links to the task definition, discovery record, supporting
   research, and snapshot. Briefly state the primary user-visible outcome and,
   when applicable, the most important operational boundary, delayed-effect
   behavior, or required manual action. State that discovery has ended and
   wait.

For an explicit early-closure request, run the review, explain material gaps,
record the user's instruction, and mark both documents `incomplete`. Ask only
if the user has not clearly chosen between pausing and closing.

For a later explicit invocation that materially changes a completed definition,
reopen the same directory, preserve snapshots, add a resumed-session trail
event, set both documents to `in-progress`, and snapshot only when that session
closes.
