# Task Definition: Create `start-coop-session`

Status: `ready-for-handoff` · Task: `create-guided-coop-session-skill` · Last updated:
`2026-07-22T00:49:14-03:00` · Supporting record:
`discovery-record.md`

## Objective

Create a reusable, general-purpose Agent Skill named `start-coop-session` that
lets a user deliberately enter a sustained cooperative work session with an AI
agent. The agent must help the user understand the work, contribute substantive
analysis, ask one focused question at a time, perform agreed artifact edits, and
preserve durable progress until the shared task is explicitly completed or
abandoned. It must not replace the requested collaboration with a one-shot
answer.

The first mandatory scenarios are:

1. The user works through decision-heavy documentation with the agent, makes the
   substantive decisions through discussion, and has the agent fill a safe
   working copy with the settled answers.
2. The user and agent read an entire complex documentation set with explanation,
   discussion, durable coverage tracking, and no premature completion claim.

These scenarios verify a general protocol; they do not limit the skill to
document work.

## Implementation context

### Repository and source authority

This repository is the canonical source catalog. Implement the skill only under
`skills/start-coop-session/`; the directory and frontmatter `name` must match.
Keep the portable behavioral contract in `SKILL.md`, separate from optional
Codex metadata and Windows-only catalog tooling. Repository skill-authoring
requirements in `README.md` and `AGENTS.md` govern implementation and
validation.

[research-notes.md](research-notes.md) is the discovery evidence note. It
verifies the catalog constraints, the neighboring-skill boundary, and the gap
between structural repository checks and behavioral evaluation. Its
implementation consequence is retained below; it does not replace this task
definition.

### Trigger and neighboring-skill boundary

The skill must activate only when the user explicitly invokes
`$start-coop-session` or directly names `start-coop-session`. It must never
trigger merely because a request could benefit from back-and-forth work. Encode
the same boundary in Codex metadata with
`policy.allow_implicit_invocation: false`.

The catalog's `task-discovery` skill defines a task without executing it, and
`phased-plan-to-goal` creates an execution contract and requires a separate
approval gate. `start-coop-session` must not replace or weaken either contract.
It governs the interaction lifecycle for an explicitly requested cooperative
session.

After startup confirmation, the agent may use applicable specialist skills and
tools for format- or task-specific mechanics such as `.docx` editing or
page-aware PDF reading. `start-coop-session` remains authoritative for cadence,
participation, durable state, edit authorization, pause/resume, and closure. A
specialist workflow may add stricter safety or verification requirements but
may not weaken this contract.

### Governing session contract

**Start.** Inspect safely available material without changing it. Propose a
compact startup contract containing the goal, source authority and in-scope
sources, intended output, session and working-copy locations, completion
criteria, and initial route. Obtain one user confirmation before substantive
work or artifact creation begins.

Supplied material governs by default. Use external research substantively only
when the confirmed contract includes it or after identifying a material gap and
obtaining one focused approval to expand source scope. Keep supplied and
external evidence distinguishable in analysis, decisions, and records.

**Collaborate.** Provide relevant explanation before asking at most one focused
question or requesting one user action per turn. Wait for the response unless
the user explicitly requests a larger autonomous step. Act as an analytical
partner: surface assumptions and tradeoffs, challenge weak or contradictory
reasoning, distinguish evidence from inference and recommendation, and
recommend when evidence supports a preference. Leave substantive decisions with
the user unless the confirmed contract delegates a specific decision.

**Edit.** In document-answering workflows, the user and agent settle substance
together while the agent performs the mechanical edits. A clearly settled
answer authorizes an immediate working-copy update and a brief change report.
Ask separately when wording remains ambiguous, the edit is destructive, or
materially different formulations remain viable. Preserve supplied originals
and edit a clearly named working copy by default; an in-place source edit
requires explicit instruction.

**Record.** For work expected to span multiple turns, create
`docs/coop/<session-name>/session.md` by default, plus working copies and only
the session-specific supporting files required by the contract. An established
workspace location may override this default when confirmed at startup.
`session.md` is synthesized operational state, not a transcript. It records:

- lifecycle state and confirmed startup contract;
- source and working artifacts plus their current state;
- settled decisions and authorized changes;
- progress or reading coverage;
- unresolved points, limitations, and exact next action.

Update it whenever a settled decision, artifact change, coverage change,
material route change, pause, resume, or closure would otherwise leave the
durable state stale.

**Read completely.** Inventory every source in the confirmed documentation
scope and track meaningful coverage. A unit counts as covered only after the
agent has read it, explained or analyzed what matters to the session goal, and
given the user a clear opportunity to question, discuss, or revisit it. Test the
user's understanding only when requested or when a material misunderstanding
would compromise later work or decisions. Never claim completion while an
in-scope unit remains unread.

**Pause and resume.** A pause keeps the session `active`. Before stopping,
checkpoint progress or coverage, the last settled decision, artifact state,
next unresolved point, and exact next action; then report the session path and a
concise resume invocation. When an invocation identifies an existing session,
resume rather than replace it: reread `session.md`, inspect current artifacts,
reconcile drift, summarize current state and the proposed next step, and obtain
one confirmation before continuing. Resolve any conflict affecting goal, scope,
outputs, or completion criteria through that confirmation.

**End.** Use exactly three lifecycle states: `active` for ongoing or paused
work; `completed` only after completion checks pass or their limitations are
explicitly accepted and the user confirms successful closure; and `abandoned`
when the user explicitly ends early. Before proposing completion, reconcile the
contract, record, and artifacts and summarize completed work, outputs, and
limitations. Preserve progress, outputs, and unmet criteria when abandoned;
never present them as completed.

## Scope and non-goals

**In scope**

- Add the explicit-only `start-coop-session` skill and its aligned Codex UI
  metadata.
- Implement the complete startup, collaboration, editing, durable-state,
  reading-coverage, pause/resume, completion, and abandonment contract above.
- Bundle a concise reusable `session.md` template.
- Compose safely with applicable specialist skills and tools.
- Validate the catalog structure and forward-test the two mandatory scenarios
  using disposable artifacts.

**Not in scope**

- Implicitly activating the skill for ordinary requests.
- Replacing `task-discovery`, `phased-plan-to-goal`, or specialist artifact
  skills.
- Treating skill invocation as authority for destructive edits, in-place source
  changes, external source expansion, or consequential actions outside the
  confirmed contract.
- Automatically making substantive user decisions or finishing the shared task
  without the required cooperative interaction.
- Installing, committing, pushing, or publishing the implementation unless the
  user separately authorizes that action.

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| `skills/start-coop-session/SKILL.md` | Concise portable instructions implementing the governing session contract and explicit-only trigger description. |
| `skills/start-coop-session/assets/session-template.md` | Reusable, transcript-free structure for startup terms, current state, artifacts, decisions, progress or coverage, unresolved points, limitations, and next action. |
| `skills/start-coop-session/agents/openai.yaml` | Aligned display name, short description, default invocation prompt, and `policy.allow_implicit_invocation: false`. |
| Repository validation evidence | Results from repository validation and tests under both supported PowerShell families. |
| Behavioral evaluation evidence | Independent forward-test results for both mandatory scenarios using fresh agents and disposable raw artifacts without leaked expected answers or design rationale. |

Do not add scripts, references, examples, or other resources unless
implementation reveals a reusable requirement that cannot be expressed clearly
and concisely in the three artifacts above.

## Recommended implementation approach

1. **Author the portable lifecycle** — create `SKILL.md` around the governing
   start, collaborate, edit, record, read, pause/resume, and end contract, with
   explicit composition and authority boundaries.
2. **Provide durable-state scaffolding** — add the minimal session template and
   ensure every required state transition and artifact relationship has one
   canonical place without turning the record into a transcript.
3. **Align the Codex surface** — add explicit-only UI metadata whose name,
   description, and default prompt accurately invoke the portable contract.
4. **Validate structure and behavior** — run the catalog checks in both
   PowerShell environments, then forward-test the decision-document and
   complete-reading scenarios with fresh agents and disposable raw artifacts.
   Revise and repeat if either agent rushes ahead, becomes a passive
   questionnaire, mutates an original, loses durable state, misstates coverage,
   or closes without user confirmation.

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| Explicit triggering | Explicit invocation and direct naming activate the skill; comparable ordinary requests do not. `openai.yaml` disables implicit invocation. |
| Startup authority | A fresh session performs read-only inspection, proposes every required startup-contract field, and waits for one confirmation before substantive work or artifact creation. |
| Cooperative cadence | Forward-test traces show active explanation and challenge, no more than one focused question or requested action per turn by default, and no premature one-shot completion. |
| Safe co-authoring | The decision-document test preserves the original, updates a named working copy after settled answers, reports edits, and asks separately for ambiguous or destructive changes. |
| Durable lifecycle | `session.md` remains coherent through decisions, edits, pause, drift-aware resume, successful closure, and an abandonment case; it contains synthesized state rather than a chat transcript. |
| Complete reading | The reading test inventories the confirmed sources, substantively covers every unit, offers discussion opportunities, distinguishes source authority, and makes no premature completion claim or compulsory quiz. |
| Skill composition | Representative specialist tooling handles artifact mechanics without displacing the cooperative cadence, record, authority, or closure rules. |
| Boundary compatibility | The skill does not weaken or duplicate the governing roles of `task-discovery` and `phased-plan-to-goal`, and invocation does not broaden consequential authority. |
| Catalog validity | `scripts/Test-Repository.ps1` and `tests/Run-Tests.ps1` pass under both `pwsh` and `powershell`. |
| Independent behavior | Both disposable forward-tests pass without giving the fresh agents expected answers, diagnoses, or hidden design rationale beyond the skill itself. |

The task is complete only when every deliverable exists, all applicable checks
pass, the required forward-tests demonstrate the intended cooperative behavior,
and no non-goal has been absorbed into implementation.
