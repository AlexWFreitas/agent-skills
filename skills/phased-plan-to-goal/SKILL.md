---
name: phased-plan-to-goal
description: Build a phased plan from task material and carry authorized work to a verified outcome with resumable progress. Activate only when the user asks to use phased-plan-to-goal; discussing or reviewing the skill does not start execution.
---

# Phased plan to goal

Use the task definition as the governing contract and the plan as an adaptable
route. Carry work through implementation and verification within the user's
authorization. Skill invocation alone authorizes research and planning.

## Establish the contract and workspace

Accept files, a reference directory, or conversation material. Read applicable
project instructions and prioritize indexes, task definitions, and governing
links. Inspect code, tests, logs, and configuration when they resolve material
uncertainty; skip unrelated or generated material.

Use the explicit artifact destination, otherwise an established task-document
location, otherwise `docs/tasks/<task-name>/`. Resume a matching task. Ask only
when task identity or ownership conflicts; protect unrelated work.

If an existing task definition is sufficient, reference its exact governing
version from the plan. Do not copy or expand it just to fit this skill's
template. A discovery definition and its linked authorities can serve directly.
Record the path and version, or create an immutable snapshot in the execution
directory when the source has no stable version.

Verify governing links against their original source location. If an existing
immutable snapshot has unrebased links, preserve it and record the original
link base in the plan; ask only when the intended authority remains ambiguous.

If normalization is needed, preserve the supplied originals and write a local
`task-definition.md` using [the template](assets/task-definition-template.md).
Add only missing or conflicting material that affects implementation. Trace
its conclusions to their sources; do not promote recommendations into approved
requirements. Mark a new contract `draft` until authorized.

A sufficient contract states the outcome, verified context, scope, deliverables,
constraints, dependencies, material decisions, and observable completion checks.
Use the same six-section reading order as discovery for new definitions.
Established sufficient definitions do not need reformatting.

## Resolve material gaps

Ask only about a user-owned point that materially changes outcome, scope,
authority, significant cost, irreversible policy, or verification; evidence
cannot settle it; and an implementer cannot safely choose or defer it. Leave
ordinary algorithms, tuning, internal structure, and recoverable mechanics to
implementation. Public authorization and input/output semantics require
governing evidence or an owner decision; conservative defaults are not authority.

Distinguish verified facts, inference, assumptions, recommendations, and approval.
For a material external unknown, name its impact, resolver, resolution step,
and contingency or gate. Disclose settled operational consequences, including
delayed effects and required manual actions, without reasking settled decisions.
Avoid speculative infrastructure and recursive mitigation design.

Keep one question unanswered at a time and check existing records before asking.
Use a tool only when its live instructions permit that question type; use plain
language for required gates it cannot carry. Bounded options must expose the
actual decision. Required authorization needs an explicit answer; silence,
preselection, or an unanswered optional preference cannot grant it.

Record answers and continue immediately, including independent authorized work
while another decision is pending. Reopen a decision only for new material
evidence, explaining what changed. If the user questions the depth, reassess
which remaining issues truly need their decision.

## Plan useful phases

Create [implementation-plan.md](assets/implementation-plan-template.md) as the
single operational record. Each phase needs a bounded outcome, dependencies,
expected mutations, checks, and completion evidence. Add a recovery provision
when a consequential or high-impact mutation warrants one; ordinary reversible
work may use standard version control, retry, restore, or forward fixes.

Use the fewest phases that establish useful dependency, authorization, recovery,
or verification boundaries. Map deliverables and acceptance criteria to phases
and evidence using existing IDs or stable section references. Do not invent an
identifier system merely to copy a sufficient contract.

Name the intended local and external mutations. Commits, pushes, deployments,
database writes, destructive actions, purchases, and external communications
need authorization covering those named actions. Omission does not authorize
them. Keep substantial specialist detail in linked authoritative files.

## Establish execution authority

First reuse unambiguous authorization already given for this contract, scope,
mode, and actions. Record its evidence; activation or compaction does not reset
it. If authority is missing, finish the reviewable contract and plan, set
`awaiting-approval`, and summarize outcomes, phases, mutations, material
limits, risks, and manual actions before requesting the missing approval.

Offer the applicable choices with an evidence-backed recommendation first:

| Authorization | Continue autonomously | Stop boundary |
| --- | --- | --- |
| One named phase | Implement, verify, and recover within that phase | Before another phase or a material change to the approved phase |
| Complete plan, change-sensitive | Advance phases and adjust ordinary mechanics | A material change to the approved approach, scope, risk, cost, dependencies, authority, or verification |
| Complete plan, persistent | Replan and advance within the approved task contract | Work would cross contract or authority boundaries, needs unavailable access, or is infeasible |

Accept natural language that unambiguously settles scope and mode. A named
complete-plan approval can cover its disclosed contents; a clarification answer
cannot silently approve an unrelated choice. Discussion, praise, and silence
are not execution approval.

Record approval text, timestamp, scope, mode, and consequential actions. At
initial approval, snapshot the plan and pin the exact approved contract version.
For a locally authored contract, snapshot it as
`versions/task-definition-vNNN.md`; preserve supplied versioned contracts.
Changing governing outcomes, constraints, scope, deliverables, or completion
criteria needs explicit authorization and a preserved prior version.

## Execute and checkpoint

1. Reconcile actual workspace and relevant external state with the plan before
   mutation. Confirm that the next phase is within authority.
2. Implement the next useful phase. Diagnose recoverable failures and adjust
   techniques within its boundaries.
3. Run required checks and checks justified by changed behavior. Once they pass,
   repeat or broaden them only for new changes, failures, or unresolved concerns.
4. Record the result and evidence, reconcile affected current-state sections,
   then continue to the next authorized phase.

Keep current phase, next action, authorization, acceptance coverage, and blockers
easy to find. Maintain one material-event trail for approvals, decisions,
deviations, blockers, results, and resume events. Preserve historical evidence
without making routine command output the operational record.

Update affected synthesis at material transitions and check the whole record
for contradictions. Do not rewrite unchanged sections merely to checkpoint.
Snapshot the plan at initial approval, material replanning, authorization-mode
changes, and closure.

Before freezing each new snapshot, preserve its complete substantive content,
rebase relative links for the snapshot directory, and record the source path
and timestamp. Verify the governing links. Do not rewrite existing immutable
snapshots to repair navigation.

A status question or correction steers the active objective; answer and continue
unless the user stops or replaces the work. Persistent mode permits replanning
inside the contract, not silent amendments or promises of uninterrupted runtime.

Stop for unavailable credentials or authority, uncovered destructive actions,
external effects beyond scope, a material unresolved instruction conflict, or
evidence of infeasibility. Mark a blocker only when no safe authorized path
remains; record evidence, impact, resolver, next step, and safe contingency.

## Resume and finish

Read the governing contract version, current plan, applicable instructions, and
relevant supporting sources. Inspect actual state before new writes, record
drift once, and reuse valid authorization. Ask only when drift leaves a material
conflict. Use snapshots to resolve history or recover lost state, not as a reason
to reread every historical version.

Apply [readiness-checklist.md](references/readiness-checklist.md) at approval,
material changes, and closure, checking only affected items again when possible.
Completion requires implemented outcomes and their evidence. Every phase must
have a justified terminal state; any limitation substituted for a required
check needs explicit acceptance.

Reconcile actual changes and documents, mark the plan `complete`, and preserve
final plan and locally authored contract snapshots. For an external contract,
retain its exact governing version reference. Deliver results, verification,
accepted limits, operational consequences, and follow-up work.

Use specialist skills for mechanics and writing without additional task records
or approval loops. If cooperation is requested, its participation cadence
constrains autonomous steps until the user delegates them. User instructions
govern within host permissions. If this skill requires a pause, finish independent
authorized work, link this file, quote the rule, and name the missing decision.
