# Task Definition: Implement AI Second Brain

Status: `approved` · Task: `ai-second-brain` · Version: `v001`  
Created: `2026-07-26T16:34:16-03:00` · Last updated:
`2026-07-26T16:55:29-03:00` · Operational plan:
[`implementation-plan.md`](implementation-plan.md)

## Sources and authority

| ID | Source | Role and precedence | Supported claims | Evidence state or limitation |
| --- | --- | --- | --- | --- |
| S01 | [`../../discovery/ai-second-brain/task-definition.md`](../../discovery/ai-second-brain/task-definition.md) | Governing product and behavior definition | Goal, selected solution, requirements, non-goals, deliverables, and definition of done | Ready-for-handoff discovery contract; unchanged by this task package |
| S02 | [`../../discovery/ai-second-brain/research-notes.md`](../../discovery/ai-second-brain/research-notes.md) | Governing current external-product evidence where S01 cites it | Codex/ChatGPT Pro, image attachment, voice, Obsidian, and quota evidence | Time-sensitive; screenshot attachment-to-local-path behavior remains unverified |
| S03 | [`../../discovery/ai-second-brain/solution-comparison.md`](../../discovery/ai-second-brain/solution-comparison.md) | Supporting decision analysis | Why Codex plus optional Obsidian was selected over hosted work-management products | Contextual; S01 wins if wording differs |
| S04 | [`../../../AGENTS.md`](../../../AGENTS.md) and [`../../../README.md`](../../../README.md) | Governing repository and authoring constraints | Canonical source location, portable/Codex separation, test matrix, and consequential-action boundaries | Verified in the current checkout |
| S05 | `phased-plan-to-goal` and `skill-creator` instructions explicitly invoked or required for this work | Governing workflow and skill-package constraints | Approval lifecycle, snapshots, skill anatomy, metadata, and validation | Applied to planning and execution; repository rules remain higher precedence for this checkout |

S01 governs the intended product. S04 governs how it may be implemented in this
repository. S02 governs only the current external claims that S01 delegates to
it. When live behavior differs from S02, implementation must record the
observed limitation and use the safe fallback rather than weakening S01.

## Objective

Implement a durable, local-first AI second brain that the user can operate from
the Codex desktop app on one Windows PC using the existing ChatGPT Pro
subscription. It must capture deliberate text, screenshot, and dictated
transcript inputs into user-owned files; organize and retrieve the accumulated
record; preserve provenance and corrections across fresh chats; and default to
using only information supplied by the user.

The first activity template is a game playthrough, but the storage and behavior
core must remain domain-neutral so later activities do not require a migration.
Obsidian may open the same folder as a local Markdown vault, but normal operation
must not depend on Obsidian or any separately quota-limited hosted product.

## Problem and verified current state

The completed discovery package defines the behavior but no source skill,
bootstrap/capture tooling, installed skill, or user vault currently exists in
this checkout. The only current task-specific files are the untracked discovery
documents under `docs/discovery/ai-second-brain/`.

| Evidence | Supported current-state claim | Class and limitation |
| --- | --- | --- |
| Current repository inventory and Git status | There is no `skills/ai-second-brain/` package or `docs/tasks/ai-second-brain/` execution package before this draft | Verified in this checkout |
| S04 | `skills/` is the only editable source catalog; installed copies are derived | Verified repository invariant |
| S01 | Codex desktop plus optional Obsidian is the selected solution | Governing user decision |
| S02 | Codex accepts image attachments, but a copyable local attachment path is not established | Verified documentation gap; live check still required |
| S01 | A message Codex never accepts cannot be persisted by the agent | Accepted platform boundary |

## Desired outcomes and success measures

| ID | Outcome | Success measure or observable signal |
| --- | --- | --- |
| O01 | Low-friction, lossless deliberate capture | Every accepted text, screenshot, or voice transcript is assigned one stable capture ID and persisted before interpretation |
| O02 | Grounded and spoiler-safe assistance | Normal answers use only the active context's firsthand record and visibly state when that record is insufficient |
| O03 | Durable organization and continuity | A fresh Codex task can resume the active context from files without material dependence on prior chat history |
| O04 | Correctable, inspectable knowledge | Evidence, AI observation, inference, uncertainty, state transitions, corrections, and conflicts remain distinguishable and traceable |
| O05 | Portable multi-activity foundation | The same collection/context core supports the initial game template and future activity templates without restructuring |
| O06 | No secondary service quota | Ordinary use requires only ChatGPT Pro and local files/processes |
| O07 | Safe lifecycle operations | Context isolation, archive preservation, and guarded deletion prevent silent cross-contamination or evidence loss |

## Requirements and invariants

| ID | Type | Requirement or invariant | Source | Verification implication |
| --- | --- | --- | --- | --- |
| R01 | operational | Codex desktop authenticated by ChatGPT Pro is the only hosted AI runtime; no metered API key or separately quota-limited hosted dependency may be required | S01 | Dependency and source review |
| R02 | data | Ordinary Markdown and local media are authoritative; any structured ledger is local, append-only, inspectable, and rebuildable | S01 | Inspect initialized vault and capture files |
| R03 | invariant | After Codex accepts a deliberate input, inbox persistence is the first agent action and occurs before interpretation, organization, or substantive reply | S01 | Skill cold-read and representative capture run |
| R04 | functional | Text, screenshot, and corrected voice transcript captures retain timestamp, input type, stable capture ID, original supplied content, and processing state | S01 | Automated fixture tests for all input types |
| R05 | data | A completed screenshot capture has an immutable capture-ID copy in `attachments/`; if Codex cannot expose a copyable path, the capture remains pending and directs the save-first fallback | S01, S02 | Live capability gate plus both script branches |
| R06 | functional | Screenshot user evidence, direct AI observations, and labeled AI inferences with confidence remain separate; unreadable details remain unresolved | S01 | Behavioral scenario review |
| R07 | data | Voice evidence stores the corrected transcript, timestamp, voice input type, and capture ID, but not raw microphone audio | S01 | Fixture inspection |
| R08 | operational | Reconciliation occurs on explicit checkpoint, before cross-session knowledge queries, and at session end; corrections and material state changes update current knowledge immediately | S01 | Workflow scenarios |
| R09 | functional | Explicit corrections preserve supersession, state transitions preserve chronology, and ambiguous conflicts preserve both claims until the user resolves them | S01 | Conflict scenario matrix |
| R10 | security | Firsthand-only mode is the default. The agent must not reveal, confirm, deny, hint at, or steer around outside facts, including facts present in model training | S01 | Adversarial spoiler scenarios |
| R11 | functional | Outside knowledge is used only for the explicitly requested scope, labeled by source class, stored only under `external/` when retained, and followed by an automatic return to firsthand-only mode | S01 | Scoped-override scenario |
| R12 | operational | Only urgent contradictions, safety-relevant conflicts, and explicit time-sensitive reminders may interrupt capture; non-urgent connections wait for a checkpoint | S01 | Initiative scenarios |
| R13 | data | Vault identity is `collections/<subject>/contexts/<context>/`; the first context is `main`, sibling contexts are isolated, and cross-context operations require explicit instruction with provenance | S01 | Layout and isolation tests |
| R14 | data | Each context contains `context.md`, `timeline.md`, `open-items.md`, `inbox/`, `topics/`, `attachments/`, and `external/` with the meanings defined in S01 | S01 | Bootstrap test |
| R15 | functional | A fresh task resumes the most recently active unambiguous context, announces it, and stops before substantive access if selection is ambiguous | S01 | Fresh-task scenario |
| R16 | functional | Recall and inference use compact capture/topic provenance; full evidence chains are available on request | S01 | Retrieval scenarios |
| R17 | security | Captures are never auto-deleted. Archive preserves evidence. Permanent deletion requires explicit request, impact preview, confirmation, bounded deletion, and dangling-reference repair | S01 | Lifecycle scenario and safety review |
| R18 | compatibility | The generic core and initial game-playthrough template are both delivered; game terminology must not replace core domain-neutral concepts | S01 | Package structure and non-game cold-read |
| R19 | compatibility | The implementation runs on Windows PowerShell 5.1 and PowerShell 7 without third-party modules; tool paths resolve from script location or explicit vault path | S04 | Dual-shell tests from unrelated working directories |
| R20 | invariant | Obsidian remains optional and read/write access uses the same ordinary folder; no Obsidian plugin, Sync, Publish, or database is required | S01 | Dependency review and closed-Obsidian workflow |
| R21 | operational | The catalog skill is explicit-only through `policy.allow_implicit_invocation: false`; initialized vault guidance provides the persistent local behavior boundary | S04, S05 | Metadata and initialized `AGENTS.md` review |
| R22 | security | Initialization is non-destructive: it refuses incompatible existing files rather than silently overwriting user content | S04 | Re-run and collision tests |
| R23 | scope | The agent does not fetch guides, browse for subject facts, read sibling contexts, or modify unrelated files unless the user explicitly expands scope | S01 | Adversarial scope scenarios |

## Implementation context and affected systems

| Area, user, or stakeholder | Current role or behavior | Required impact or preserved boundary |
| --- | --- | --- |
| `skills/` source catalog | Canonical Agent Skills source | Add one portable `ai-second-brain` package without changing existing skill behavior |
| Repository test harness | Validates catalog and installer under two shells | Add isolated coverage for the new skill's deterministic scripts |
| Codex desktop app | Conversational input, reasoning, and local file access | Operate through an explicit skill plus vault-local persistent guidance |
| User-owned vault | Does not yet exist at an approved path | Initialize ordinary files non-destructively and make them authoritative |
| Optional Obsidian | Optional local Markdown viewer/editor | May open the vault, but is never on the critical path |
| ChatGPT Pro | Existing permitted hosted AI subscription | Remains the only hosted AI allowance used by ordinary operation |

## Scope and non-goals

**In scope**

- A portable `ai-second-brain` Agent Skill with Codex metadata.
- A vault contract, persistent vault-level instructions, and the initial
  game-playthrough activity template.
- Dependency-free PowerShell bootstrap and lossless capture helpers.
- Text, screenshot, and transcript-only voice capture paths.
- Reconciliation, retrieval, correction, conflict, provenance, resumption,
  archive, and guarded-deletion behavior.
- Isolated automated tests and representative behavioral validation.
- Named installation to Codex user scope and non-destructive creation of a real
  user vault after its exact path is supplied and authorized.

**Not in scope**

- A custom overlay, recorder, always-on microphone, continuous screen watcher,
  phone/console relay, or cross-device synchronization.
- A model API key, local fallback model, hosted plugin/connector/MCP service,
  hosted transcription, hosted embeddings, vector database, or required SQLite.
- Obsidian installation, plugins, Sync, Publish, or Obsidian-specific storage.
- Automatic guide/web research or spoiler knowledge in firsthand-only mode.
- Supporting every future activity template in version one.
- Commit, branch, push, pull request, publication, deployment, or repository
  setting changes.

## Deliverables

| ID | Deliverable | Required outcome | Governing requirements |
| --- | --- | --- | --- |
| D01 | `skills/ai-second-brain/` package | Reusable explicit-only skill governing capture, organization, retrieval, correction, continuity, and safety | R01-R03, R06, R08-R12, R15-R18, R21, R23 |
| D02 | Portable vault templates and contract references | Self-contained generic layout, field semantics, provenance rules, persistent `AGENTS.md`, and game template | R02, R04-R18, R20-R23 |
| D03 | Local bootstrap and capture scripts | Non-destructive initialization and deterministic lossless capture for text, screenshot, and voice transcripts | R02-R05, R07, R13-R14, R19, R22 |
| D04 | Automated and behavioral validation suite | Dual-shell automated checks plus scenario evidence for agent-only boundaries | R01-R23 |
| D05 | Activated user setup | Exact catalog skill installed to Codex user scope and an approved vault initialized without overwrite | R01, R13-R15, R19-R22 |
| D06 | Coherent execution and handoff record | Approved snapshots, phase evidence, limitations, and final state remain resumable without chat | S05 |

## Constraints, dependencies, and assumptions

| ID | Kind | Statement | Implementation consequence | Validation or resolution |
| --- | --- | --- | --- | --- |
| C01 | constraint | No additional recurring fee, pay-as-you-go API, or separate hosted allowance | Use only local scripts/files and ChatGPT Pro | Dependency audit |
| C02 | constraint | Source changes belong only in this repository's `skills/` catalog and support areas | Never edit an installed copy as source | Git diff review |
| C03 | constraint | Installed copies are disposable and installation is consequential | Install only after complete-plan or explicit P05 approval names it | Authorization gate |
| C04 | dependency | Codex must have accepted the message before the skill can act | Guarantee begins at first agent action, not before submission | Document and test the accepted-message boundary |
| C05 | assumption | The user opens the real vault as the Codex project working directory | Relative discovery and persistent `AGENTS.md` can then work reliably | Confirm during P05 |
| C06 | dependency | A real vault path is not yet selected | Source and isolated validation may proceed; P05 must stop before external write | U01 |
| C07 | constraint | Existing unrelated and discovery changes must be preserved | Stage/commit nothing and inspect diffs narrowly | Status/diff review |
| C08 | dependency | Screenshot attachment local-copy behavior is unknown | Implement both direct-copy and visible save-first paths | U02 |

## Material decisions and rationale

| ID | Decision | Rationale and evidence | Constraint on implementation |
| --- | --- | --- | --- |
| DEC01 | Codex plus ordinary local files is the operating core; Obsidian is optional | Meets the user's subscription and quota boundary while preserving ownership | Do not introduce a hosted organizer or Obsidian dependency |
| DEC02 | The core hierarchy uses collections and isolated contexts | Supports games and non-game uses without renaming core concepts | Do not hard-code game-specific storage as the authority |
| DEC03 | One immutable Markdown file represents each accepted capture; processing changes use an append-only local event ledger | Makes first-action intake simple, inspectable, retryable, and non-destructive | Never rewrite original capture content to mark it processed |
| DEC04 | Deterministic PowerShell helpers perform bootstrap and capture; the skill performs interpretation and synthesis | Scripts make the lossless boundary testable while the model handles semantic work | Scripts must remain dependency-free and dual-shell compatible |
| DEC05 | The skill is explicit-only, while an initialized vault includes persistent project guidance | Prevents unrelated Codex tasks from acquiring the behavior while keeping a vault session safe | Metadata stays explicit-only; vault guidance must contain essential invariants |
| DEC06 | The initializer refuses incompatible existing targets and does not implement cleanup | Protects user-owned notes and stays inside reversible creation authority | No force-overwrite or delete switch |
| DEC07 | Screenshot completion requires a durable local image, not only model-visible pixels | S02 cannot confirm an attachment path and S01 requires durable evidence | Pending state and save-first fallback are mandatory |

## Risks and mitigations

| ID | Risk and trigger | Impact | Mitigation, contingency, or stop condition | Owner or resolver |
| --- | --- | --- | --- | --- |
| RSK01 | Latent model knowledge leaks a spoiler or steers an inference | Violates the primary epistemic boundary | Redundant skill and vault instructions, adversarial scenarios, explicit insufficiency language; document that this is behavioral rather than technical erasure | Implementer and user validation |
| RSK02 | A screenshot is visible to Codex but cannot be copied locally | Evidence would appear retained when it is not | Keep capture pending, request save-first placement, and never claim screenshot completion without a durable file | U02 resolver |
| RSK03 | Capture persistence fails after message acceptance | User input may be lost or duplicated | Deterministic capture helper, unique IDs, atomic create, pending processing event, and visible failure | Implementer |
| RSK04 | Vault initialization collides with existing content | User files could be overwritten | Preflight every target and refuse incompatible content; do not include destructive cleanup | Implementer |
| RSK05 | Skill instructions become too large or contradictory | Agent may skip the first-action or safety boundary | Put procedural detail in focused references, keep essential invariants in `SKILL.md` and vault `AGENTS.md`, then cold-read both | Implementer |
| RSK06 | Behavioral checks are mistaken for a mathematical guarantee | False confidence about model compliance | Report scenario evidence and residual behavioral limitation explicitly | Implementer and user |
| RSK07 | Real activation writes to an unwanted folder or replaces an installed copy | External user-state impact | Resolve exact vault path, inspect existing install, and require approval covering P05 | User |

## Managed unknowns and resolution gates

| ID | Unknown | Impact if unresolved | Resolver and resolution step | Safe contingency or gate |
| --- | --- | --- | --- | --- |
| U01 | Exact real vault root | P05 cannot create the user-owned project | User supplies one absolute Windows directory before P05 | Complete source and isolated validation, then stop before external write |
| U02 | Whether the Codex desktop attachment is exposed as a copyable local file | Direct screenshot capture may not work | During P05, inspect a deliberately attached test image and attempt the documented local-copy route | Activate the documented save-first fallback and record the limitation |
| U03 | Whether the user wants the optional vault opened/configured in Obsidian immediately | Obsidian usability cannot be demonstrated | User may open the initialized directory manually after core validation | Obsidian remains optional; absence does not block completion |
| U04 | Exact degree of model compliance under adversarial prompts | Cannot be proven statically | Run representative firsthand-only and override scenarios in the activated vault | Failed scenario blocks completion; passing scenarios retain a stated behavioral limitation |

## Supporting documents

| Document | Authoritative purpose | Material implementation consequence | Update rule |
| --- | --- | --- | --- |
| [`implementation-plan.md`](implementation-plan.md) | Current authorization, phases, mutation surface, evidence, and blockers | No implementation phase starts until its approval state permits it | Rewrite after every material lifecycle event |
| [`verification-evidence.md`](verification-evidence.md) | Automated, isolated-fixture, dependency, and live validation evidence | Acceptance state must cite reproducible results and distinguish source from live behavior | Update after P04 and P05 evidence changes |
| S01 discovery definition | Product behavior and boundaries | Implementation must satisfy it through this normalized traceability | Remains unchanged; amend this contract through approval if needed |
| S02 research notes | Current product-capability evidence | Controls screenshot capability claim and external product assumptions | Refresh only when a capability gate needs current evidence |

## Acceptance criteria and definition of done

| ID | Criterion | Required evidence | Limitation policy |
| --- | --- | --- | --- |
| A01 | Repository-valid skill package | `scripts/Test-Repository.ps1` passes under `pwsh` and `powershell` | No accepted limitation |
| A02 | Dual-shell deterministic tooling | New tests and full `tests/Run-Tests.ps1` pass under both shells from isolated temporary roots | No accepted limitation |
| A03 | Correct bootstrap | Fixture contains the generic hierarchy, `main` context, required files/directories, persistent guidance, and no overwrite on collision | No accepted limitation |
| A04 | Exactly-once lossless text intake | One accepted text produces one immutable capture and pending processing event before semantic work | No accepted limitation |
| A05 | Durable screenshot intake | Direct local copy is proven or the save-first fallback is activated; completed evidence has capture-ID attachment and separated observation/inference fields | Direct-copy absence may be accepted only with the required fallback |
| A06 | Correct voice intake | Corrected transcript persists with voice type, timestamp, and capture ID and no raw audio | No accepted limitation |
| A07 | Grounded behavior | Adversarial firsthand-only queries refuse unsupported facts without reveal, confirmation, denial, hint, or steering | Residual model-behavior limitation must be reported; a demonstrated leak is not acceptable |
| A08 | Scoped outside override | Explicit outside use is labeled, isolated under `external/` if retained, and mode returns to firsthand-only | No accepted limitation |
| A09 | Reconciliation and conflict safety | Checkpoint, correction, transition, and ambiguous-conflict scenarios preserve evidence and current truth correctly | No accepted limitation |
| A10 | Fresh-task continuity and context isolation | Activated vault resumes the active context from files and does not read a sibling context without instruction | No accepted limitation |
| A11 | Retention lifecycle safety | Archive preserves evidence and deletion behavior requires preview plus confirmation and accounts for references | No destructive test against user data; fixture evidence is sufficient |
| A12 | Quota and portability boundary | Dependency audit finds no additional hosted allowance and the vault remains ordinary Markdown/media usable without Obsidian | No accepted limitation |
| A13 | Activated setup | Approved installed copy matches source and the approved real vault initializes non-destructively | User may explicitly defer D05, but the overall task then remains incomplete or records an accepted limitation |
| A14 | Reconciled handoff | Final task/plan snapshots, status, mutations, checks, and limitations agree with actual state | No accepted limitation |

## Contract traceability

| Outcome or requirement | Deliverable | Supporting authority | Planned phase | Acceptance check |
| --- | --- | --- | --- | --- |
| O05; R02, R13, R14, R18, R20, R21, R22 | D02 | S01, S04 | P01 | A03, A12 |
| O01, O04; R03, R04, R05, R07, R13, R14, R19, R22 | D03 | S01, S04 | P02 | A02, A04, A05, A06 |
| O02, O03, O04, O07; R06, R08, R09, R10, R11, R12, R15, R16, R17, R23 | D01, D02 | S01 | P03 | A07, A08, A09, A10, A11 |
| O01, O02, O03, O04, O05, O06, O07; R01-R23 | D04 | S01-S05 | P04 | A01-A12 |
| O01, O02, O03, O04, O05, O06, O07; R01, R13, R14, R15, R19, R20, R21, R22 | D05 | S01, S04 | P05 | A05, A07, A08, A09, A10, A12, A13 |
| Execution lifecycle | D06 | S05 | P01-P06 | A14 |

The task is complete only when all six deliverables exist, P01-P06 have
justified terminal states, A01-A14 pass or have an explicitly accepted
limitation, actual source/install/vault state agrees with the records, and the
non-goals and invariants remain preserved.
