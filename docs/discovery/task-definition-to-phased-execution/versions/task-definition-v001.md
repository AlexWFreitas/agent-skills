# Task Definition: Phased Plan to Goal

Status: `ready-for-handoff` · Task: `task-definition-to-phased-execution` · Last updated:
`2026-07-21T22:57:15-03:00` · Snapshot: `v001` · Supporting record:
`../discovery-record.md`

## Objective

Create an explicit-invocation-only Agent Skill named `phased-plan-to-goal` that
turns supplied task material into a normalized task definition and a detailed
phased implementation plan, obtains unambiguous execution authorization, and
then drives the approved work to a verified goal. The plan may evolve, but the
approved goal and authority boundaries govern execution. Durable, coherent
documents must make long-running work safe to review and resume.

## Implementation context

The canonical skill belongs at `skills/phased-plan-to-goal/`; installed copies
are derived and must not be edited. Core behavior must remain portable Agent
Skills instructions, with optional Codex presentation metadata isolated in
`agents/openai.yaml`. The skill complements `task-discovery` but must also
accept other source material without depending on that skill.

The skill activates only when the user names or invokes it. Activation permits
read-only research and draft artifact creation, not implementation. Intake may
contain one or more local files, directories, or conversation-supplied texts;
a directory path is expected to be common. The generated definition must name
material sources and precedence. When sources materially conflict and
instructions or context do not resolve precedence, the skill asks which source
governs.

For directory input, inventory the path and applicable repository instructions
first. Prioritize task definitions, indexes, manifests, and linked documents;
expand into code, tests, logs, or other evidence only as needed. Skip VCS
metadata, dependencies, generated output, binaries, and unrelated content
unless material. Record important omissions, access limits, and unverified
areas. Research before asking the user, make only safe explicit assumptions for
non-material gaps, and ask exactly one focused question per turn when its
answer could materially change the definition, plan, authority, risk, or
verification.

Create artifacts at an explicit destination from the user or source material;
otherwise follow applicable repository instructions or established task
conventions; otherwise use `docs/tasks/<task-name>/`. Never overwrite received
source material. Use `task-definition.md` and `implementation-plan.md`, plus a
`versions/` directory for required snapshots.

The generated task definition is freely rewritten while draft. After approval
it is a versioned contract: ordinary progress and replanning do not change it.
Changing its goal, scope, constraints, deliverables, or completion criteria
requires explicit user authorization, preservation of the prior version, and
reconciliation of the implementation plan.

By default, present the draft definition and plan together for review. A
definition-only review is allowed when the user requests it or a foundational
decision makes detailed planning premature. The combined review ends with one
direct approval question that distinguishes:

- one named phase only;
- the complete plan in change-sensitive mode; or
- the complete plan under a persistent mandate.

Natural-language approval is valid when scope and mode are unambiguous; exact
command syntax is unnecessary. Silence, discussion, praise, or vague positive
feedback outside that direct approval context is not authorization.

Complete-plan approval authorizes all phases. In change-sensitive mode,
non-material adjustments remain authorized but a material change requires a
revised plan and renewed approval. Under a persistent mandate, the agent may
replan and must not voluntarily stop while safe authorized work remains and the
runtime permits progress. This is a behavioral promise, not a guarantee that
every host sustains uninterrupted wall-clock execution.

Even under a persistent mandate, stop for missing credentials or permissions,
unapproved destructive or irreversible actions, external side effects outside
scope, conflicting user instructions, or evidence that the goal is infeasible.
Single-phase approval imposes a hard stop before the next phase; the agent then
requests approval or initiates the review, debate, discussion, or brainstorming
needed to reconcile changed circumstances.

Every plan enumerates its mutation surface. Approval covers disclosed
reversible local edits and checks. Commits, pushes, deployments, database
mutations, destructive operations, purchases, external communications, and
comparable consequential actions are authorized only when explicitly named in
the approved plan; otherwise the agent stops and requests authority.

`implementation-plan.md` is an authored operational record, not a command log.
It contains a concise current plan and status, active authorization, phase
states, dependencies, checks and evidence, plus one canonical chronological
trail of material approvals, decisions, deviations, replanning, blockers, and
results. Rewrite current-state sections as a coherent whole. Update after an
approval or mode change; phase start, completion, or failure; material decision,
deviation, or replan; blocker transition; pause or resume; and closure. Omit
routine commands and transient observations unless they become material
evidence. Snapshot at initial approval, material replanning, authorization-mode
changes, and closure.

## Scope and non-goals

**In scope**

- Add the canonical `phased-plan-to-goal` skill with the complete intake,
  normalization, planning, authorization, execution, verification, update,
  resumption, and closure workflow defined above.
- Provide task-definition and implementation-plan templates that enforce the
  settled artifact roles without imposing arbitrary length or phase counts.
- Provide a semantic readiness/closure reference covering authority, document
  coherence, actual-state reconciliation, and accepted limitations.
- Add optional Codex UI metadata aligned with explicit-only activation.
- Make only narrowly required repository test or documentation changes.

**Not in scope**

- Altering the behavior of `task-discovery` or creating a hard dependency on it.
- Guaranteeing uninterrupted execution beyond host runtime capabilities.
- Inferring implementation approval from skill invocation or vague feedback.
- Installing, committing, pushing, publishing, or changing repository settings.
- Adding mechanical rules that pretend document coherence can be validated by
  length, heading count, or append-only logging.

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| `skills/phased-plan-to-goal/SKILL.md` | Portable, explicit-only instructions implementing the settled lifecycle and safety boundaries. |
| `skills/phased-plan-to-goal/assets/task-definition-template.md` | Draft and approved-contract structure with source provenance, objective, boundaries, deliverables, and observable completion criteria. |
| `skills/phased-plan-to-goal/assets/implementation-plan-template.md` | Coherent current-state, authorization, phased plan, verification evidence, and canonical material-event trail structure. |
| `skills/phased-plan-to-goal/references/readiness-checklist.md` | Semantic checks for draft review, execution start, phase completion, resumption, replanning, and closure. |
| `skills/phased-plan-to-goal/agents/openai.yaml` | Optional Codex display metadata and explicit implicit-invocation prohibition, aligned with `SKILL.md`. |
| Focused repository support changes | Only tests, fixtures, or root documentation materially required for the new catalog entry. |

## Execution plan

1. **Author the portable lifecycle contract** — create `SKILL.md` with explicit
   activation, evidence-guided intake, one-question clarification, artifact
   placement, combined review, three authorization choices, immutable stops,
   and consequential-action rules.
2. **Create coherent artifact resources** — add the two templates and readiness
   checklist. Keep the task definition contract-focused and the implementation
   plan operational; encode material update events and snapshot rules without
   encouraging append-only clutter.
3. **Add optional Codex presentation metadata** — create `agents/openai.yaml`
   with a clear display name, invocation prompt, and
   `allow_implicit_invocation: false`.
4. **Review representative control flows** — walk through incomplete or
   conflicting folder input, combined approval, single-phase execution,
   change-sensitive replanning, persistent long-running execution, failed
   checks, consequential actions, interruption and resume, contract amendment,
   and closure with an accepted limitation. Revise ambiguous instructions.
5. **Validate the catalog** — run `scripts/Test-Repository.ps1` and
   `tests/Run-Tests.ps1` under both `pwsh` and `powershell`; inspect the diff for
   unrelated or derived installed-copy changes.

Each implementation phase must itself be outcome-led, bounded,
dependency-aware, and independently verifiable. It states entry conditions,
expected local or external mutations, checks, completion evidence, and rollback
or contingency guidance when material. Use as many phases as the work requires
without arbitrary count or duration targets.

When checks fail, keep the phase incomplete and diagnose and retry recoverable
failures within its authority. Persistent mode may replan within immutable
boundaries; change-sensitive mode pauses only for a material recovery change.
Mark blocked only when no safe authorized path remains, recording failed
evidence, blocker, resolver, and next action. A limitation satisfies a required
check only when the user explicitly accepts it.

On resume, reread applicable instructions, the generated definition, current
plan, latest snapshot, and material sources; inspect actual state read-only;
reconcile drift; and record a resume event before mutations. Preserve existing
authorization only when the goal, mutation surface, execution mode, and next
action remain valid. Material conflict requires clarification or renewed
approval.

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| Explicit activation and approval are distinct | Scenario review shows invocation permits drafts only and no implementation begins without unambiguous recorded scope and mode. |
| Intake is reliable and bounded | File, directory, multi-source, and conversational inputs preserve provenance; conflicts, omissions, and access limits are handled as specified. |
| Authorization modes behave correctly | Single-phase stops before the next phase; change-sensitive mode stops on material replanning; persistent mode continues until a mandatory stop, verified completion, or forced runtime interruption. |
| Consequential actions remain controlled | Scenario review proves unnamed commit, push, deploy, database, destructive, purchase, and communication actions require separate authority. |
| Documents remain coherent and resumable | Repeated lifecycle updates rewrite current synthesis, preserve one material-event trail, create required snapshots, and allow a fresh agent to reconcile actual state without chat context. |
| Failure and closure are honest | Failed checks cannot become completion without explicit accepted limitations; blockers name evidence and resolver; closure accounts for every phase, check, mutation, limitation, and follow-up. |
| Skill remains portable | Required behavior is in portable resources; Codex-specific metadata is optional and aligned. |
| Repository checks pass | Both repository scripts pass under Windows PowerShell 5.1 and PowerShell 7. |
| Scope remains controlled | No existing skill behavior changes, and no install, commit, push, publish, or repository-setting change occurs. |

The implementation is done when every deliverable exists, representative flows
are semantically coherent, all four validation commands pass, and the final
diff contains only the approved canonical skill and narrowly necessary
repository support changes.

