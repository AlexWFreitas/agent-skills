---
name: task-discovery
description: Investigate a proposed task and produce an implementation-ready definition with a durable supporting record. Activate only when the user asks to use task-discovery; discussing or reviewing the skill does not start discovery. Does not execute the defined task.
---

# Task discovery

Turn a proposed task into a brief a fresh implementer can act on without
inventing a missing product decision. Investigate project material read-only;
write only discovery artifacts in the selected directory.

## Start or resume

Use an explicit destination, otherwise `docs/discovery/<task-name>/`. Infer a
concise name without a naming gate. Resume a matching discovery; ask only when
task identity or ownership is ambiguous. Do not overwrite unrelated work.

For a new discovery, create [task-definition.md](assets/task-definition-template.md)
and [discovery-record.md](assets/discovery-record-template.md) from the bundled
templates, with `in-progress` status and ISO 8601 timestamps with UTC offsets.
Write in the request language. Keep substantial research in linked supporting
files within the directory.

On resume, read the current definition, record, relevant supporting sources,
and newest definition snapshot. Reconcile changed evidence and preserve settled
decisions. Record the resume once; context loss is not a reason to ask again.

## Investigate and decide

Inspect safely available sources before asking for facts. Preserve a source and
evidence class for material claims: `verified`, `inference`, `assumption`, or
`unresolved`, including freshness or access limits that affect the conclusion.
Challenge contradictions, unsupported premises, and missing acceptance criteria.

For each unresolved point, choose the appropriate action:

| Point | Action |
| --- | --- |
| A fact available through safe inspection | Investigate it |
| A material decision owned by the user | Ask one focused question |
| A reversible choice an implementer can safely make | Record the required outcome; leave the technique open |
| A speculative concern that does not constrain this task | Defer it or name the relevant non-goal |

Ask only when different answers materially change the outcome, scope, authority,
significant cost, irreversible policy, or completion standard; evidence does
not settle it; an implementer cannot safely choose or defer it; and the user
owns the decision. Read [decision-guide.md](references/decision-guide.md) when
ownership, public semantics, a foundational recommendation, or risk is unclear.

Keep at most one question unanswered. Explain what its answer changes and
recommend an option when evidence supports one. Bounded choices may use an
available input tool only when its live instructions permit that question type.
Use plain language otherwise; never put secrets in questions or records.
Required decisions need an explicit answer. Silence and preselected options
are not consent; an unanswered optional preference may use a stated reversible
default within scope.

Check the conversation and record for an answer to the same decision in
substance. Reopen it only when new material evidence makes it insufficient, and
explain the change. Each answer settles the decision actually asked.

After an answer, record it and advance immediately. Continue independent
read-only research while a question is pending. Do not insert acknowledgement
turns or turn routine implementation choices into a questionnaire. If the user
questions the relevance or depth, reassess the remaining decisions and remove
speculative detail before asking more.

## Maintain the handoff

Keep two distinct artifacts:

- `task-definition.md` is the current implementation brief: objective,
  implementation context, scope and non-goals, deliverables, recommended
  implementation approach, and verification and definition of done.
- `discovery-record.md` contains current discovery state, one chronological
  trail of material questions, answers, evidence, and decisions, and links to
  substantial research. Preserve material history losslessly without copying it
  into multiple ledgers.

Update the record before material evidence can be lost. Synthesize the
definition at meaningful checkpoints, placing each decision beside the work or
check it governs. Reconcile the whole document for consistency without
rewriting unchanged text for its own sake.

Include a constraint when omitting it would permit a materially different
outcome or an authority violation. Describe consequential operational limits
in observable terms: when a change takes effect, what existing consumers see,
and any required manual action. Do not make recommendations into requirements
without governing evidence or an explicit owner decision.

Keep a supporting document authoritative for one purpose, link it, and retain
its implementation consequence in the brief. Stable acceptance labels or
section anchors can support later planning; use IDs only when useful. A fresh
reader must not need chat history or the discovery record to understand the
contract. The recommended approach gives sequencing and dependencies, not
execution authorization. The definition of done describes implemented behavior.

Read [the example](references/task-definition-example.md) only for presentation
calibration. It does not impose its depth or supporting documents on other tasks.

## Check readiness and close

Stop questioning once no user-owned blocker remains. Apply
[readiness-checklist.md](references/readiness-checklist.md) and cold-read the
definition with its governing links, without relying on chat or the record.

A remaining material external unknown needs its impact, resolver, resolution
step, and safe contingency or gate. Routine implementation latitude and remote
risks do not block handoff. Correct material gaps; do not chase every possible
failure mode or run the defined implementation's test suite.

When ready, set both primary documents to `ready-for-handoff`, record the
review, and save a complete definition snapshot as the next
`versions/task-definition-vNNN.md`. Before freezing a new snapshot, rebase its
relative links for that directory and record its source path and timestamp.
Preserve all substantive content and verify governing links; never edit an
existing immutable snapshot to repair its navigation. Deliver links and the
material outcome,
limitations, and required manual actions. Discovery ends here; wait for an
implementation instruction.

For explicit early closure, record gaps and mark the documents `incomplete`.
Ask only if pausing versus closing is unclear. For a later requested material
change, reopen the same directory, preserve snapshots, and return to
`in-progress` until the new handoff is ready.

## Compose with other skills

Use technical-writing for document quality or a requested conversational style
for prose without adding another lifecycle. If cooperation is requested,
preserve its participation cadence while this skill owns the discovery records.
Do not silently activate execution.

User instructions govern within host permissions. This skill authorizes no
implementation, installation, commit, push, or publication. If an actual skill
rule blocks requested work, complete independent authorized preparation, link
this file, quote the rule, and identify the missing decision.
