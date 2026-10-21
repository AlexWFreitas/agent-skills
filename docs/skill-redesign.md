# Skill catalog redesign

Historical record: the skills described here were removed from the catalog on
October 21, 2026. Earlier validation results apply to that earlier source tree.

This redesign implements the September 16, 2026 request to rebuild all six
skills around clearer responsibilities, focused entry instructions, and simpler
handoffs. It changes the canonical catalog only. Installed skills and existing
vault instruction files are separate artifacts and are not refreshed by this
change.

## Design

Each skill states when it applies, its outcome, its normal workflow, material
boundaries, and what establishes completion. Substantial conditional procedures
live in references with explicit loading instructions. Small skills remain
direct rather than acquiring unnecessary routing layers.

This follows OpenAI's [skill authoring guidance](https://learn.chatgpt.com/docs/build-skills)
on focused jobs, clear inputs and outputs, and progressive disclosure. The
specific decomposition and handoff choices here are repository design decisions,
not measured performance improvements or portable specification requirements.

| Skill | Responsibility | Main change |
| --- | --- | --- |
| `clear-conversation` | Conversational presentation | Compact positive principles and four conditional examples |
| `technical-writing` | Useful, accurate developer documents | Reader-task routing with detailed editorial guidance in existing references |
| `task-discovery` | Implementation brief and supporting evidence | Decision ownership drives investigation and closure; nuanced cases have a focused reference |
| `phased-plan-to-goal` | Authorized implementation and verification | Reuse a sufficient versioned contract and maintain one operational plan |
| `start-coop-session` | User participation and durable shared progress | Link governing task material and record the division of responsibility |
| `ai-second-brain` | Firsthand local notebook and evidence | Capture stays in the entry point; lifecycle, media, reconciliation, and retrieval have separate procedures |

## Composition and records

Discovery produces the task definition and lossless material discovery record.
Execution can reference that exact definition version directly. It normalizes
only when material information is missing or conflicting, preserving originals.
Both templates now use the same six-section reading order; an already sufficient
contract does not need reformatting.

The execution plan owns phase state, authority, acceptance coverage, blockers,
and its material-event trail. A cooperative session owns participation and
coverage without duplicating task requirements. Writing skills introduce no
separate startup, approval, or closure flow.

Current-state records are reconciled at material transitions. The agent edits
affected synthesis and checks the whole record for contradictions; it does not
rewrite unchanged sections merely to checkpoint. Material history, governing
versions, and required snapshots remain available.

New snapshots preserve complete substantive content and rebase relative links
before they are frozen. Existing immutable snapshots remain unchanged; when
their links were not rebased, execution records the original link base and
verifies the intended authorities from that location.

Essential rules remain inside each installable skill. There is no shared
runtime dependency on repository documentation or another installed skill.
Activation policy metadata, helper implementations, the installer, and
the portable frontmatter profile are preserved. Descriptions clarify that
discussing a skill does not activate its workflow.

After the redesign, the user renamed `controlled-writing-style` to
`clear-conversation`, displayed as
Clear Conversation and invoked as `$clear-conversation`. Its behavior and
explicit-only activation are unchanged. The rename applies to the canonical
catalog; installed copies are not refreshed by this change.

## Vault recovery change

The first context compaction now triggers one bounded recovery pass. Continuation
requires evidence of active identity, accepted-input persistence, operation,
artifact state, next action, and authority, with no session-size rollover warning.
The capture retry allowance is not reset by compaction.

Unresolved recovery, an ambiguous capture match, a second compaction within one
assistant turn, or an auditor session-size warning retains the defined stop or
rollover behavior. No new task is created without instruction. Evidence remains
immutable, scoped to the active context, and captured before interpretation.
Firsthand-only defaults and preview-plus-confirmation deletion remain intact.

The generated vault instruction asset and V19 validation scenario describe the
same recovery rule. Existing vaults are not migrated or edited by this redesign.

## Validation design

The automated suite continues to test installer rollback and path boundaries,
validation, immutable capture and idempotent retry, media preparation, local
search, provenance relations, state auditing, locks, completion, and migration.
All fixtures use disposable destinations, never real installed skills or vaults.

Four tests that only matched exact instruction sentences were removed, along
with prose assertions attached to an executable search test. No executable
behavior test was removed. Their behavioral subjects remain covered by the
vault scenarios: intake and media (V20, V22, V23), notebook and visual evidence
(V21, V24), bounded recovery (V19), source-grounded search (V26-V28), and state
and completion (V29-V36). The automated test count is consequently 34 rather
than 38. Those tests do not establish model instruction compliance.

Independent forward tests use the skill entry points and small synthetic tasks
without the redesign proposal as an answer key. Record actions and artifacts,
question behavior, governing records, and verification boundaries. A simulated
recovery state is distinct from an actual host compaction event.

Representative cases include:

| Case | Observable evidence |
| --- | --- |
| Clear discovery request | A usable definition and evidence trail without naming or mechanical questions |
| Missing public behavior decision | One focused question whose answer changes the output contract |
| Approved execution after discovery | Reused governing version, implemented result, and relevant checks |
| Short conversational answer | Requested length and format with correct meaning |
| Review-only documentation request | Actionable findings without artifact edits or invented behavior |
| Cooperative reading session | Preserved original, working record, and one pending substantive decision |
| Firsthand retrieval | Source-grounded answer and explicit evidence limits |
| Lost capture return | Stable ID, bounded retry, and no duplicate evidence |
| Recoverable first compaction | Verified state before continuation |
| Ambiguous or repeated recovery | Truthful disposition and bounded stop |

## Verification evidence

The required repository validator passed with zero warnings under PowerShell 7
and Windows PowerShell 5.1. The complete executable suite passed all 34 tests
under each runtime. Windows PowerShell used process-scoped
`-ExecutionPolicy Bypass`; no persistent policy was changed. `git diff --check`
passed after replacing newly introduced Markdown trailing-space breaks.

The optional skill-creator Python validator could not start because the host
Python lacks PyYAML. No dependency was installed. The repository-owned
dependency-free validator remains the authoritative catalog check.

Three independent evaluator tasks exercised the following synthetic workflows
in separate operating-system temporary directories. The primary reviewer read
the generated records and result evidence.

| Workflow | Observed result |
| --- | --- |
| Discovery of a CSV amount report | One material question about rounding; the synthetic owner selected half-even after summing. Discovery closed with a versioned brief and no implementation files. |
| Execution of the discovered report | Reused discovery v001 directly, created no competing definition, and reused the supplied persistent authorization. Two phases completed; 25 CLI cases across five unittest methods passed, with all input hashes preserved. |
| Controlled two-sentence explanation | Exactly two sentences explaining timeout uncertainty and conditional duplicate creation, with no headings. |
| Review-only API documentation | Identified both unsupported completion and response claims against the supplied HTTP 202/jobId contract; provided a correction without source edits. |
| Cooperative design reading | Preserved the original and identical working copy, recorded the supplied startup contract, explained the first section, and stopped at one substantive pending decision without inventing an answer. |
| Vault intake and retrieval | Saved the note and question before interpretation; used only the active context; answered that the record supplies no method for opening the fictional door. |
| Known-ID recovery | One real retry returned existing-capture. Capture and ledger hashes were unchanged; audit found two captures, two groups, four events, zero pending, zero warnings, and zero errors. |

The report implementation fixture retained discovery contract SHA-256
`D64525063EB3636D94F16FCE577BF997141C9A90DFD0A1A47B0FDFE8BB19A3E8`.
The vault fixture used search mode off and created no index. No evaluation
used a real vault, external service, installation, commit, or live deployment.

## Findings and verification limits

Evaluation exposed ambiguous cooperative startup wording and relative links
whose base changed inside snapshot directories. The startup rule now explicitly
accepts either the complete request or a later reply as the settled contract.
Snapshot instructions now cover rebasing new copies and preserving old ones.

The focused follow-up created execution snapshot v003 using the revised
instructions. All eight local Markdown targets in that snapshot and all seven
in the current plan existed; the legacy contract's supporting-record link also
resolved against its recorded original base. Discovery v001 and execution v001
and v002 retained their prior hashes. No task outcome changed, and the report's
implementation tests were not repeated for this navigation-only correction.

Source review also moved context disambiguation ahead of subject reads,
clarified disabled-search routing and media responses, and required byte and
ledger verification during recovery. The existing capture helper reports
existing-capture from candidate-path existence; its code was not changed.
The executed recovery independently verified both bytes and ledger state.

The original attachment basename is not reliably retained by the capture helper.
Lost-ID media recovery therefore requires independently verified retained-media
identity from available provenance or bytes; a caption match alone is insufficient.
If that identity cannot be established, the operation stops as unverified.
This media recovery branch received source review, not a live media recovery test.

Compaction and the lost return were supplied simulation conditions; no actual
host compaction was induced. Ambiguous-ID and second-compaction branches received
source inspection. The executed text recovery already met the subsequently
clarified byte and ledger checks; the entire scenario was not rerun for those
wording changes. These checks do not prove universal instruction compliance,
technical removal of latent knowledge, or improvements over the old catalog.
