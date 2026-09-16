---
name: phased-plan-to-goal
description: Turn task-definition documents, reference folders, files, or conversation material into a normalized task contract and detailed phased plan, obtain explicit execution authorization, and drive approved work to a verified goal with coherent progress records. Use only when the user explicitly invokes `$phased-plan-to-goal` or names `phased-plan-to-goal`; never trigger implicitly.
---

# Phased Plan to Goal

Treat the approved goal and authority boundaries as governing. Treat the phased
plan as an adaptable route. Do not interpret skill invocation as permission to
implement.

## Core contract

- Research and draft after explicit invocation. Begin implementation when
  unambiguous authorization covers it, including approval already given.
- Keep at most one focused question unanswered when a user-owned blocker
  remains. After the answer, continue researching or drafting immediately and
  ask the next user-owned question when needed. This is not a
  one-question-per-turn limit. Research first; do not ask for facts available
  through safe inspection or for implementation choices the plan can safely
  own.
- Keep received source material unchanged. Generate a normalized task contract
  and a separate operational plan.
- Maintain coherent documents. Rewrite current synthesis; do not append routine
  activity until the documents become a log-shaped mess.
- Continue toward the verified goal within the recorded authorization. Obey all
  applicable system, user, repository, tool, and safety constraints.

## Request user input

Apply the decision-ownership rules below before asking. Keep one question
unanswered at a time. Continue independent authorized research and drafting
while waiting; do not perform work that depends on the missing decision.

Use an available user-input tool only when its current instructions permit the
question type. Follow its live schema; do not assume `request_user_input`
accepts approvals. Use plain text for a required gate if the tool cannot carry
it. For bounded choices, offer two or three mutually exclusive options with an
evidence-backed recommendation first and a clear scope for each option. Allow
free-form answers without duplicating a built-in alternative. Keep secrets out
of questions and records.

Approval, consequential-action consent, limitation acceptance, and contract
amendment require an explicit answer. Silence, elapsed time, a preselected
option, or an unanswered optional question cannot grant authority. An optional
preference may use a stated reversible default within the approved contract.

After an answer, record it and continue the work it authorizes or clarifies
without requesting a separate acknowledgement. If another user-owned question
is already known, ask it immediately after any necessary transition. Do not
stop with only a recap and a promise to ask that question on the next turn.

Sequential input calls do not justify a chain of optional design questions.
Reapply the decision-ownership rules below before each planning question.
Search the visible conversation and canonical trail for an answer to the same
decision in substance, not only identical wording. Do not reask because context
was compacted, tool state was lost, or the prompt can be phrased better. Reopen
a recorded decision only when new material evidence changes it, and state what
changed. Reuse only an answer that directly settles the same choice; an
adjacent fact or related requirement is not an implicit answer.

Keep each clarification question scoped to one decision. An option may explain
its material consequences, but do not embed a separate unconfirmed
foundational choice and later treat selection as authority for both. This does
not prevent direct approval of a named phase or versioned complete plan from
authorizing all contents that the preceding summary and approval option make
explicit.

## Start or resume

The user's explicit instructions take precedence over this skill's defaults,
subject to the host's permissions. Reuse authorization that already covers the
same scope and actions; neither skill activation nor context compaction resets
it. Before a skill requirement causes a pause, complete the independent work
already authorized. Link this `SKILL.md`, quote the blocking rule, and explain
the specific missing decision rather than attributing a preference to policy.

1. Accept one or more files, directories, or conversation-supplied sources. A
   folder path may be the primary input.
2. Choose the artifact directory in this order:
   - an explicit destination in the request or source material;
   - applicable repository instructions or an established task-document path;
   - `docs/tasks/<task-name>/`.
3. Use the bundled `assets/task-definition-template.md` and
   `assets/implementation-plan-template.md` as adaptable structures. The two
   generated files are canonical entry points, not a file-count limit.
4. Create as many supporting files as the material requires for coherence, such
   as architecture, research, risk, migration, API-contract, test-strategy, or
   phase-specific documents. Link them from a canonical entry point, state
   their role and authority, avoid duplicated truth, and do not fragment content
   that reads better together.
5. If an artifact directory already contains matching documents, follow the
   resume procedure. If its ownership or task identity conflicts, ask one
   focused question before writing.

## Inspect evidence

For a directory source:

1. Inventory it and read applicable repository instructions first.
2. Prioritize task definitions, indexes, manifests, and linked documents.
3. Expand into code, tests, logs, configuration, or other evidence only when it
   changes definition or planning confidence.
4. Skip VCS internals, dependencies, generated output, binaries, secrets, and
   unrelated material unless necessary and authorized.
5. Record material sources, precedence, freshness, omissions, access limits,
   conflicts, and unverified claims. Do not copy secrets or unnecessary
   sensitive content into artifacts.

When sources materially conflict and instructions or context do not establish
precedence, explain the impact and ask which source governs. Make safe,
explicit assumptions only for non-material gaps.

## Decide what requires user input

Keep authorization, approval, consequential-action consent, contract changes,
and acceptance of limitations user-owned. For other unresolved points, ask the
user only when all of these are true:

- different answers would materially change the approved outcome, scope,
  mutation authority, significant cost, permission or security boundary,
  irreversible data or operational policy, or verification standard;
- safe inspection, governing sources, established conventions, and the current
  contract do not resolve the point;
- a competent implementer cannot safely choose or defer it within the plan;
- the user is the proper decision owner.

Treat internal architecture within an already-approved boundary, algorithms,
file formats, operational tuning, retry and timeout values, batch sizes,
logging cadence, routine error handling, test organization, and other
reversible mechanics as implementer-owned unless concrete evidence promotes
them under the test above. Select an evidence-backed default, keep it
configurable when useful, and record only the constraint or implementation
consequence needed by the plan.

Technical feasibility, reuse of an existing mechanism, lower implementation
cost, or a conservative default may support a recommendation, but none alone
authorizes a governing contract choice. Classify the choice using the full
tests above. Keep an implementer-owned default adaptable in the plan and retain
only its required outcome or constraint in the task definition. For a
user-owned foundational choice, require direct governing evidence or an
explicit answer before making it normative or excluding alternatives. A schema
or migration difference alone does not make a choice user-owned.

Treat user-visible authorization and public input/output semantics as
user-owned when alternatives change who can act, what callers may submit, or
what users receive. Inspect established conventions first; if they do not
govern, obtain the decision. Least privilege may support a recommendation but
does not silently authorize a product policy. Do not turn internal stable
traversal, normalization, serialization, or version handling into a public
ordering, encoding, filename, versioning, or compatibility promise without
governing evidence.

Treat a **resolved but consequence-bearing** point as a disclosure obligation,
not another planning question. When the contract or governing evidence settles
a lifecycle, propagation, availability, compatibility, or manual-operation
boundary, translate it into observable behavior: when a change takes effect,
what already-running or in-flight consumers continue to see, and whether a
restart, reconnect, redeploy, or other manual action is required. Surface a
material consequence in the task definition and approval summary. Ask only if
the evidence still permits materially different user-owned outcomes.

Promote a risk to a user gate only when it is plausible in the current context,
has a significant consequence, and needs a decision before authorization or
execution. Do not recursively design every failure mode of a mitigation or add
future-scale infrastructure without a current requirement. Require a special
rollback or contingency only for a consequential, destructive, irreversible,
or evidence-backed high-impact mutation; ordinary reversible work may use
standard version control, retry, restore, or forward-fix practice.

If the user questions relevance or depth, rejects added machinery, expresses
frustration, or repeatedly needs low-level alternatives explained, pause and
reassess the contract and plan. Remove speculative work, distinguish governing
decisions from implementation latitude, and resume at the shallower depth. Do
not split the same technical design into more user questions.

## Build the draft contract and plan

Rewrite `task-definition.md` as a self-contained, execution-grade contract for
a fresh agent. Do not rely on an absent discovery record or chat history to
make it understandable. Establish source authority; verified current state;
desired outcomes and success measures; functional and non-functional
requirements; invariants; affected users and systems; scope and non-goals;
deliverables; constraints, dependencies, and assumptions; material decisions
and rationale; risks and mitigations; managed unknowns and gates; acceptance
criteria; and requirement-to-deliverable-to-check traceability when materially
applicable. Do not manufacture content for a dimension that does not constrain
this task.
Synthesize clarification answers into the section they govern rather than
leaving critical decisions only in conversation.

Apply a materiality review rather than filling headings mechanically. Omit or
condense a subsection when removing it cannot change the required outcome,
authority, a significant current risk, a governing boundary, or verification.
Preserve implementation latitude; an exact technique or tuning value belongs
in the contract only when governing evidence or a user-owned decision requires
it. When substantial detail belongs in a supporting file, summarize its
implementation consequence in the task definition and link the authoritative
file.

State a material operational non-goal in observable terms, not only as a
technical exclusion. Do not add lifecycle detail when it is immaterial to the
task.

Build `implementation-plan.md` as the current operational record. Every phase
must be outcome-led, bounded, dependency-aware, and independently verifiable.
State its entry conditions, expected local and external mutations, checks,
completion evidence, and rollback or contingency when material. Use as many
phases and supporting documents as the work needs, but use the fewest phases
that establish meaningful dependency, authorization, mutation, recovery, or
verification boundaries. Do not create a phase for every routine implementation
step. Map phases and verification evidence back to the task definition's
outcome, requirement, deliverable, and acceptance identifiers so no governing
contract item silently becomes orphaned.

List the complete intended mutation surface. Name commits, pushes, deployments,
database mutations, destructive operations, purchases, external communications,
and comparable consequential actions individually if the plan may perform them.
Omission means they are not authorized.

Continue researching while useful, but ask only about user-owned blockers until
both drafts are sufficient for approval. Do not withhold approval for internal
design choices, tunable defaults, ordinary recoverable mechanics, or remote
risks the implementer can own. Present a definition-only review only when the
user requests it or a foundational decision makes detailed planning premature.
Otherwise use the combined review by default.

## Obtain execution approval

First check the conversation and plan for explicit authorization covering the
current contract, mode, phases, and actions. Record and use that authorization
without asking again. If authorization is missing, prepare both reviewable
documents, set the plan to `awaiting-approval`, and summarize the contract,
phases, mutation surface, risks, managed limitations, and material operational
boundaries or required manual actions. Ask one direct question distinguishing
these choices:

1. Approve one named phase only.
2. Approve the complete plan in `change-sensitive` mode.
3. Approve the complete plan under a `persistent` mandate.

Use the permitted input channel described above. Represent the choices with
the actual named phase and plan version, put the evidence-backed recommendation
first, and make each description state the authorization boundary. A selection
grants approval only when the summary and option describe the exact scope,
mode, and consequential actions; otherwise request the missing clarification.

Accept natural language when scope and mode are unambiguous. Do not infer
authorization from silence, discussion, brainstorming, praise, a vague approval
outside this direct gate, or invocation of the skill. Record the approval text,
scope, mode, timestamp, and explicitly authorized consequential actions in the
plan before implementing. At initial approval, mark and snapshot the approved
task definition as `versions/task-definition-vNNN.md` and snapshot the plan as
`versions/implementation-plan-vNNN.md`, using each file's next zero-padded
version number.

Throughout execution, treat a change as material only when it alters the
approved outcome, scope, mutation authority, significant cost, permission or
security boundary, irreversible policy, or verification standard. Ordinary
implementation substitutions, tuning, local refactoring, and recoverable
mechanics inside those boundaries do not require renewed approval.

## Execute the authorization

Incorporate user steering without losing the active objective. A status request
or side question normally needs a brief answer followed by continued work.
Reconcile corrections with the contract, preserve completed valid work, and
ask only when the correction leaves a material authority or outcome conflict.
An explicit stop or replacement request changes the task immediately.

### One phase

Execute and verify only the named phase. Iterate on recoverable failures inside
that phase when recovery remains within its authority. Stop when a material
change would alter the approved phase. After completion, failure, or material
change, do not begin another phase; ask for approval or open the review, debate,
discussion, or brainstorming that the new state needs.

### Complete plan, change-sensitive

Manage ordinary phase transitions without stopping. Make non-material
implementation adjustments autonomously. Pause, revise the plan, and obtain
renewed approval when new information materially changes the approved approach,
scope, risk, cost, dependencies, mutation surface, or verification standard.

### Complete plan, persistent

Replan and manage phase transitions autonomously inside the approved task
contract. Do not voluntarily stop while safe authorized work remains and the
host runtime permits progress. Use durable checkpoints and available host
continuation mechanisms for long work; do not promise uninterrupted wall-clock
runtime.

Even in persistent mode, stop for:

- missing credentials, permissions, authority, or required user-controlled
  access;
- destructive or irreversible action not already authorized by name;
- external effects outside the approved scope or mutation surface;
- an unresolved material conflict between a newer user instruction and the
  contract after applying the user's explicit change;
- evidence that the approved goal is infeasible.

Persistent authorization permits replanning, not silent amendment of the task
contract.

## Maintain coherent records

Treat `implementation-plan.md` as an authored operational record, not a command
log. Keep its current state, authorization, phase table, dependencies, mutation
surface, checks, evidence, blockers, supporting-file index, and next action
internally consistent. Preserve one concise canonical chronological trail for
material approvals, decisions, deviations, replans, blockers, and results.

Rewrite the document as a coherent whole after:

- approval or authorization-mode change;
- phase start, completion, or failure;
- material decision, deviation, or replan;
- blocker creation or resolution;
- pause, resume, or closure.

Omit routine commands and transient observations unless they become material
evidence. Snapshot the plan at initial approval, material replanning,
authorization-mode change, and closure. A snapshot is a complete copy, not a
summary.

Rewrite the task definition freely while it is a draft. After approval, treat
it as a versioned contract. Changing its goal, scope, constraints, deliverables,
or completion criteria requires explicit user authorization. Preserve the prior
version, update and approve the contract, then reconcile and snapshot the plan.

## Handle checks, blockers, and replanning

Keep a phase incomplete until its required checks pass or the user explicitly
accepts a documented limitation. Diagnose and retry recoverable failures within
the active authorization. In change-sensitive mode, pause only when recovery is
a material change. In persistent mode, replan and continue within immutable
boundaries.

Run the contract's required checks and checks justified by the changed behavior.
Do not add tests that only mirror wording or implementation. Once checks pass,
broaden or repeat them only for new changes, failures, or an unresolved concern;
an ordinary phase transition does not justify rerunning every successful check.

Mark work blocked only when no safe authorized path remains. Record the failed
evidence, impact, resolver, resolution step, safe contingency or gate, and next
action. Do not label attempted work as completed.

## Resume safely

1. Reread applicable instructions, `task-definition.md`,
   `implementation-plan.md`, the newest snapshots, indexed supporting files,
   and material source references.
2. Inspect actual workspace and external state in read-only mode before new
   mutations. Protect unrelated user changes.
3. Reconcile drift and record one resume event.
4. Preserve existing authorization only if the goal, mutation surface, mode,
   and next action remain valid.
5. Ask one focused question or obtain renewed approval when recorded and actual
   state materially conflict.

## Close

Before closure, read and apply `references/readiness-checklist.md`. Close only
when every phase has a terminal state, required checks pass or every limitation
is explicitly accepted, actual state is reconciled, all mutations and
consequential actions are accounted for, and the current documents read
coherently without chat context.

Set the plan to `complete`, leave the approved task-contract content unchanged,
create complete final snapshots, and provide a concise handoff covering
results, evidence, accepted limitations, material operational behavior or
manual action, and follow-up work. Do not perform an install, commit, push,
publication, deployment, or other consequential action unless the approved
plan authorized it by name.
