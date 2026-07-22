---
name: phased-plan-to-goal
description: Turn task-definition documents, reference folders, files, or conversation material into a normalized task contract and detailed phased plan, obtain explicit execution authorization, and drive approved work to a verified goal with coherent progress records. Use only when the user explicitly invokes `$phased-plan-to-goal` or names `phased-plan-to-goal`; never trigger implicitly.
---

# Phased Plan to Goal

Treat the approved goal and authority boundaries as governing. Treat the phased
plan as an adaptable route. Do not interpret skill invocation as permission to
implement.

## Core contract

- Research and draft after explicit invocation. Begin implementation only after
  an unambiguous approval gate.
- Ask exactly one focused question per assistant turn when a material unknown
  remains. Research first; do not ask for facts available through safe
  inspection.
- Keep received source material unchanged. Generate a normalized task contract
  and a separate operational plan.
- Maintain coherent documents. Rewrite current synthesis; do not append routine
  activity until the documents become a log-shaped mess.
- Continue toward the verified goal within the recorded authorization. Obey all
  applicable system, user, repository, tool, and safety constraints.

## Start or resume

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

## Build the draft contract and plan

Rewrite `task-definition.md` as a self-contained, execution-grade contract for
a fresh agent. Do not rely on an absent discovery record or chat history to
make it understandable. Establish source authority; verified current state;
desired outcomes and success measures; functional and non-functional
requirements; invariants; affected users and systems; scope and non-goals;
deliverables; constraints, dependencies, and assumptions; material decisions
and rationale; risks and mitigations; managed unknowns and gates; acceptance
criteria; and requirement-to-deliverable-to-check traceability when material.
Synthesize clarification answers into the section they govern rather than
leaving critical decisions only in conversation.

Apply a materiality review rather than filling headings mechanically. Omit or
condense a subsection only when removing it cannot change implementation,
authority, risk, or verification. When substantial detail belongs in a
supporting file, summarize its implementation consequence in the task
definition and link the authoritative file.

Build `implementation-plan.md` as the current operational record. Every phase
must be outcome-led, bounded, dependency-aware, and independently verifiable.
State its entry conditions, expected local and external mutations, checks,
completion evidence, and rollback or contingency when material. Use as many
phases and supporting documents as the work needs; impose no arbitrary count or
duration limit. Map phases and verification evidence back to the task
definition's outcome, requirement, deliverable, and acceptance identifiers so
no contract item silently becomes orphaned.

List the complete intended mutation surface. Name commits, pushes, deployments,
database mutations, destructive operations, purchases, external communications,
and comparable consequential actions individually if the plan may perform them.
Omission means they are not authorized.

Continue researching and asking one material question per turn until both
drafts are coherent enough for approval. Present a definition-only review only
when the user requests it or a foundational decision makes detailed planning
premature. Otherwise use the combined review by default.

## Obtain execution approval

Set the plan to `awaiting-approval`, summarize the contract, phases, mutation
surface, risks, and unresolved managed limitations, then ask one direct question
that distinguishes these choices:

1. Approve one named phase only.
2. Approve the complete plan in `change-sensitive` mode.
3. Approve the complete plan under a `persistent` mandate.

Accept natural language when scope and mode are unambiguous. Do not infer
authorization from silence, discussion, brainstorming, praise, a vague approval
outside this direct gate, or invocation of the skill. Record the approval text,
scope, mode, timestamp, and explicitly authorized consequential actions in the
plan before implementing. At initial approval, mark and snapshot the approved
task definition as `versions/task-definition-vNNN.md` and snapshot the plan as
`versions/implementation-plan-vNNN.md`, using each file's next zero-padded
version number.

## Execute the authorization

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
- a newer user instruction that conflicts with the contract;
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
results, evidence, accepted limitations, and follow-up work. Do not perform an
install, commit, push, publication, deployment, or other consequential action
unless the approved plan authorized it by name.
