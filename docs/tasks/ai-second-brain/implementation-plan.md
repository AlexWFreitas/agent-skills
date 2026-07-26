# Implementation Plan: Implement AI Second Brain

Status: `in-progress` · Task: `ai-second-brain`  
Created: `2026-07-26T16:34:16-03:00` · Last updated:
`2026-07-26T19:36:17-03:00` · Governing contract:
[`task-definition.md`](task-definition.md)

## Current state

- Active phase: `P05`
- Next action: `user sends the first real text, dictated transcript, and
  screenshot in the created OracleOfAges Second Brain task`
- Overall progress: `The complete plan is approved in change-sensitive mode.
  P01 established the portable contract and P02 delivered tested,
  dependency-free bootstrap, capture, screenshot-completion, and processing
  helpers. P03 completed the capture-first Codex workflow, persistent vault
  guidance, and 15 behavioral scenarios. P04 passed the complete dual-shell
  matrix, synthetic checkpoint fixture, dependency audit, and diff review.
  P05 resolved the real vault as `D:\Work\Vaults` and the first collection as
  `OracleOfAges` (`oracle-of-ages`). After separate direct approval, the
  verified skill was installed, the vault initialized without synthetic
  captures, and a fresh vault-rooted task correctly announced the active
  context and firsthand-only mode. Real capture validation remains.`
- Governing contract version: `v001`
- Blocking condition: `real text, dictated transcript, and screenshot evidence
  require deliberate user input in the created task`
- Latest plan snapshot:
  [`versions/implementation-plan-v001.md`](versions/implementation-plan-v001.md)

## Authorization

- State: `approved`
- Scope: `complete-plan`
- Mode: `change-sensitive`
- Approval evidence: `2026-07-26T16:55:29-03:00 — user replied "2." to the
  direct gate, selecting complete-plan change-sensitive authorization`
- Authorized consequential actions:
  - install or replace only
    `C:\Users\otaru\.agents\skills\ai-second-brain` during P05 after read-only
    preflight;
  - create the second-brain files only within the exact real vault root later
    supplied and approved by the user;
  - submit deliberate local validation captures through Codex/ChatGPT Pro
    within that approved vault.
- Mandatory stops:
  - do not install or replace
    `C:\Users\otaru\.agents\skills\ai-second-brain` before P05 entry conditions
    are satisfied;
  - do not create or modify a real vault until the user supplies and approves
    its exact absolute path;
  - do not delete captures or user files, install Obsidian, access hosted
    services other than ordinary Codex/ChatGPT Pro use, or add an API key;
  - do not commit, branch, push, open a pull request, publish, deploy, or change
    repository settings;
  - stop for destructive or irreversible work not named here, external effects
    outside the mutation surface, conflicting instructions, missing access, or
    evidence that the contract is infeasible.

## Mutation surface

Every row is planned but currently unauthorized.

| Target or system | Planned mutation | Reversibility and authority |
| --- | --- | --- |
| `docs/tasks/ai-second-brain/` | Maintain contract, plan, approval snapshots, and final handoff evidence | Local documentation edits; drafting authorized by invocation, execution snapshots require approval |
| `skills/ai-second-brain/` | Add `SKILL.md`, `agents/openai.yaml`, focused references, vault templates/assets, and dependency-free PowerShell scripts | New source tree, locally reversible; P01-P03 |
| `tests/Test-AiSecondBrain.ps1` | Add isolated bootstrap/capture tests | New local test file; P02 |
| `tests/Run-Tests.ps1` | Register the new isolated test file | Narrow reversible edit; P02 |
| System temporary directory below a test-owned GUID root | Create and remove fixture vaults during tests | Ephemeral, bounded cleanup; P02/P04 |
| `C:\Users\otaru\.agents\skills\ai-second-brain` | Install or replace only this named derived skill using the repository installer after read-only preflight | Consequential user-scope write, rebuildable from source; P05 only |
| `<exact user-approved vault root>` | Non-destructively create vault guidance, index, collection, `main` context, and later deliberate validation captures | Consequential user-data write; unresolved until U01 and P05 authorization |
| Codex desktop task using the activated vault | Submit deliberate validation prompts and one user-provided screenshot to prove workflow boundaries | Consumes accepted ChatGPT Pro usage and writes only through the approved vault; P05 |
| Obsidian | No installation, configuration, plugin, Sync, or Publish mutation planned | Explicitly excluded |
| Git/version control and remote systems | No stage, commit, branch, push, pull request, publication, deployment, external communication, or repository-setting mutation | Explicitly unauthorized |

## Supporting documents

| Document | Role | Authority and update rule |
| --- | --- | --- |
| [`task-definition.md`](task-definition.md) | Governing execution contract | Draft until initial approval; later changes to goal/scope/constraints/deliverables/done require explicit amendment |
| [`verification-evidence.md`](verification-evidence.md) | Reproducible automated, fixture, dependency, and live validation evidence | Supporting evidence; update when P04/P05 results change |
| [`../../discovery/ai-second-brain/task-definition.md`](../../discovery/ai-second-brain/task-definition.md) | Governing discovery source | Preserved unchanged; normalized contract owns execution IDs and traceability |
| [`../../discovery/ai-second-brain/research-notes.md`](../../discovery/ai-second-brain/research-notes.md) | Current external capability evidence | Refresh only if a live gate needs newer product evidence |

## Contract coverage

| Contract item | Planned delivery and phase | Verification evidence | Coverage state |
| --- | --- | --- | --- |
| O05; R02, R13, R14, R18, R20, R21, R22; D02 | P01 portable vault contract/templates | A03/A12 inspection | `planned` |
| O01, O04; R03, R04, R05, R07, R19, R22; D03 | P02 deterministic bootstrap/capture tooling | A02/A04/A05/A06 automated tests | `planned` |
| O02, O03, O04, O07; R06, R08, R09, R10, R11, R12, R15, R16, R17, R23; D01/D02 | P03 agent behavior and game template | A07/A08/A09/A10/A11 scenario contract | `planned` |
| O01, O02, O03, O04, O05, O06, O07; R01-R23; D04 | P04 integrated dual-shell and behavioral fixture validation | A01-A12 result matrix | `planned` |
| O01, O02, O03, O04, O05, O06, O07; D05 | P05 install and initialize approved user setup | A05/A07/A08/A09/A10/A12/A13 live evidence | `planned` |
| D06 | P06 reconciliation, snapshots, and handoff | A14 closure review | `planned` |

## Phased plan

### P01 — Establish the portable vault contract and templates

**Outcome and status:** A domain-neutral, inspectable vault contract and
non-destructive starter layout define one authoritative way to store identity,
contexts, captures, provenance, processing events, current state, and the
initial game activity. `complete`

**Contract coverage:** O05; R02, R13-R14, R18, R20-R22; D02; A03, A12.

**Entry conditions and dependencies**

- Execution approval covers P01 or the complete plan.
- Current Git status is reconciled and discovery files remain preserved.
- Skill name remains `ai-second-brain`.

**Expected mutations**

- Create the skill directory and Codex metadata with explicit-only activation.
- Add focused vault-contract, lifecycle, and game-playthrough references.
- Add vault templates for persistent guidance, root index, context state,
  timeline, open items, and processing ledger conventions.
- Keep the portable skill core separate from Codex metadata and Windows scripts.

**Verification and completion evidence**

- Cold-read confirms domain-neutral core terms and the exact required context
  layout.
- Template token/reference review finds no broken path or duplicated authority.
- Repository validator passes in the shell used during the phase.

**Contingency**

- If the compact core cannot express a required behavior without duplication,
  add one focused reference and update the supporting index; do not invent a
  second authoritative vault structure.

### P02 — Implement deterministic local bootstrap and lossless capture

**Outcome and status:** Dependency-free PowerShell tools can safely initialize a
fixture vault and persist exactly one immutable capture plus append-only
processing state for text, screenshot, and corrected voice inputs.
`complete`

**Contract coverage:** O01, O04; R02-R05, R07, R13-R14, R19, R22; D03; A02-A06.

**Entry conditions and dependencies**

- P01 is complete.
- Template paths and capture schema are stable enough to automate.

**Expected mutations**

- Add script-location-safe initialization and capture scripts.
- Use atomic new-file creation, stable capture IDs, explicit input types, and a
  local append-only processing-event ledger.
- Copy screenshot files only when a readable local path exists; otherwise keep
  the capture visibly pending with save-first instructions.
- Add isolated tests and register them in `tests/Run-Tests.ps1`.

**Verification and completion evidence**

- Tests cover initial creation, idempotent compatible re-entry, incompatible
  collision refusal, text capture, transcript-only voice capture, screenshot
  copy, screenshot-pending fallback, unique IDs, and unrelated working
  directory invocation.
- New tests pass under both `pwsh` and `powershell`.

**Contingency**

- A failure that could partially create a context must remain visible and
  retry-safe. Do not add a force-overwrite or broad cleanup path.

### P03 — Implement the Codex behavioral workflow

**Outcome and status:** The explicit skill and vault-local instructions direct
Codex to capture first, select contexts safely, interpret evidence, reconcile
knowledge, answer with provenance, enforce firsthand-only mode, and handle
correction/archive/deletion boundaries. `complete`

**Contract coverage:** O02-O04, O07; R03, R06, R08-R12, R15-R18, R21, R23;
D01-D02; A07-A11.

**Entry conditions and dependencies**

- P01-P02 are complete and helper command contracts are known.
- The behavioral layer can call the helpers without requiring network access.

**Expected mutations**

- Complete `SKILL.md` with first-action ordering, active-context discovery,
  capture, checkpoint, retrieval, correction/conflict, override, archive,
  deletion, and fresh-task procedures.
- Complete persistent vault `AGENTS.md` guidance containing the essential
  epistemic, isolation, durability, and consequential-action invariants.
- Add representative validation scenarios covering both game and neutral
  non-game use.

**Verification and completion evidence**

- Cold-read from `SKILL.md` alone yields the correct first action and safe
  workflow.
- Cold-read from initialized `AGENTS.md` plus vault files is sufficient to
  preserve the core boundary in a fresh Codex task.
- Scenario mapping covers every agent-behavior acceptance criterion.

**Contingency**

- If instruction length obscures mandatory ordering, move explanation to
  references but retain the non-negotiable action order in `SKILL.md` and
  `AGENTS.md`.

### P04 — Run integrated isolated validation

**Outcome and status:** Repository, script, and representative fixture checks
provide reproducible evidence for the complete source package without touching
the real skill installation or user vault. `complete`

**Contract coverage:** O01-O07; R01-R23; D04; A01-A12.

**Entry conditions and dependencies**

- P01-P03 complete.
- No unrelated working-tree change overlaps the planned files.

**Expected mutations**

- Create and remove only GUID-named fixture roots under the system temporary
  directory.
- Update the plan with concise check results and any actual limitations.
- Make narrow source/test fixes when failures remain inside the approved
  contract.

**Verification and completion evidence**

- `scripts/Test-Repository.ps1` and `tests/Run-Tests.ps1` pass under both
  `pwsh` and Windows PowerShell.
- Automated fixtures demonstrate capture and screenshot fallback; an integrated
  synthetic checkpoint demonstrates correction, state transition, provenance,
  and ambiguous conflict; cold-read scenarios cover context isolation and
  archive preservation before P05 live validation.
- Dependency/diff review finds no hosted service, secret, installed-copy edit,
  unrelated mutation, or accidental deletion.

**Contingency**

- Recoverable failures are fixed and rerun inside phase authority.
- Any required dependency, scope expansion, or weakened acceptance criterion is
  material and stops change-sensitive execution for renewed approval.

### P05 — Activate and validate the user-owned setup

**Outcome and status:** The verified skill is installed to Codex user scope, an
exact user-approved vault is initialized non-destructively, and representative
live Codex use confirms the practical workflow or records the required
screenshot fallback. `blocked; authorized but gated by U01`

**Contract coverage:** O01-O07; R01, R03-R23; D05; A05, A07-A13.

**Entry conditions and dependencies**

- P04 complete.
- Authorization explicitly covers P05, the named installed-skill target, and
  creation at the exact vault path.
- U01 is resolved by the user.
- Read-only preflight confirms the installed target and vault path state.

**Expected mutations**

- Install only `ai-second-brain` using `scripts/Install-Skills.ps1 -Name
  ai-second-brain`.
- Initialize the approved vault and its first collection/`main` context using
  user-provided subject naming.
- Exercise deliberate text and corrected voice transcript captures.
- Inspect one deliberately supplied screenshot; use direct copy if exposed,
  otherwise activate and demonstrate save-first fallback.
- Run firsthand-only, scoped outside-knowledge, fresh-task continuity, and
  context-isolation checks without seeking real subject spoilers from the web.

**Verification and completion evidence**

- Installed tree matches validated source.
- Initialization reports no overwrite and the vault remains ordinary
  Markdown/media.
- Live scenario results satisfy A05 and A07-A13 or identify a specific blocker.

**Contingency**

- Existing incompatible installed/vault content causes a stop; do not replace
  or overwrite it without renewed exact authority.
- Lack of an attachment path selects the already approved save-first fallback,
  not a new hosted integration.

### P06 — Reconcile closure and handoff

**Outcome and status:** The task record matches actual source, test, installed,
and vault state; all phases are terminal; complete snapshots and a concise
operating handoff make future use resumable. `pending; unauthorized`

**Contract coverage:** D06; A14 and closure synthesis for A01-A13.

**Entry conditions and dependencies**

- P01-P05 are complete or every non-complete result has explicit limitation
  acceptance.
- Actual state has been inspected read-only after the last mutation.

**Expected mutations**

- Rewrite current plan status, coverage, checks, blockers, and event trail.
- Preserve the approved task definition content.
- Create complete final task-definition and implementation-plan snapshots.
- Do not commit, push, publish, or perform unlisted cleanup.

**Verification and completion evidence**

- The phased-plan readiness checklist passes.
- Every mutation and consequential action is accounted for.
- Final records and handoff contain no chat-only requirement or stale state.

**Contingency**

- A missing check or unaccepted limitation keeps the task open; closure cannot
  relabel incomplete work.

## Verification summary

| Check | State | Evidence or accepted limitation |
| --- | --- | --- |
| A01 Repository-valid package | `verified` | Both repository validators pass with 0 warnings |
| A02 Dual-shell tooling | `verified` | All 21 tests pass under both PowerShell families |
| A03 Bootstrap | `verified` | Isolated layout, re-entry, collision, and token assertions pass |
| A04 Text intake | `verified-source` | Exactly-once capture and retry assertions pass; real capture remains P05 |
| A05 Screenshot intake | `verified-source` | Copy, pending, and same-ID completion pass; live attachment route remains P05 |
| A06 Voice intake | `verified-source` | Transcript-only assertions pass; real dictation remains P05 |
| A07 Grounded behavior | `pending-live` | Cold-read/scenario contract passes; live adversarial prompt remains P05 |
| A08 Outside override | `pending-live` | Scoped procedure is explicit; live prompt remains P05 |
| A09 Reconciliation/conflicts | `verified-source` | Synthetic fixture preserved correction, transition, and ambiguous conflict |
| A10 Continuity/isolation | `verified-startup` | Fresh activated task announced `oracle-of-ages/main` and created no evidence; sibling-context live isolation waits until another context exists |
| A11 Retention lifecycle | `verified-source` | Guarded procedure and disposable-only scenario are explicit |
| A12 Quota/portability | `verified` | Dependency, secret, package, and ordinary-file audit passes |
| A13 Activated setup | `pending` | U01 and P05 required |
| A14 Reconciled handoff | `pending` | P06 readiness review |

No limitation is accepted.

## Managed blockers and limitations

| Item | Impact | Resolver and resolution step | Safe contingency or gate | State |
| --- | --- | --- | --- | --- |
| U01 exact vault path | Resolved as `D:\Work\Vaults`; directory does not yet exist | User supplied the path; initializer will preflight again before writing | Create only this exact root during P05 | `resolved` |
| User-scope installation approval | Reviewer initially rejected the complete-plan authority; user then approved the exact target directly | Installed tree verified byte-for-byte against source | No further installation blocker | `resolved` |
| Fresh Codex task creation | User registered `D:\Work\Vaults`; task `019fa091-4fa3-7db1-abbc-d74036e5284a` started locally and announced the correct context/mode | Completed through the task API | Startup created no evidence | `resolved` |
| Real capture validation | Text, voice, and screenshot inputs must be deliberate user evidence | User continues in the created task | Keep the vault free of synthetic evidence | `blocking-user-action` |
| U02 screenshot local path unknown | Direct attachment copying cannot be promised | Inspect one deliberate image during P05 | Use the mandatory save-first fallback | `managed` |
| U03 optional Obsidian use undecided | Obsidian-specific demonstration may be absent | User may open the vault manually | Does not block core completion | `managed` |
| U04 model behavior is not technically enforceable | Residual risk remains even after passing scenarios | Run adversarial checks and report limitation accurately | Demonstrated spoiler leakage blocks completion | `managed` |
| Optional system `quick_validate.py` lacks PyYAML | That auxiliary validator cannot run without adding a dependency | Use the repository's dependency-free validator, which is authoritative for this catalog | Do not install PyYAML solely for redundant validation | `accepted-nonblocking` |

## Canonical material-event trail

| Time | Event | Evidence or reason | Plan and authorization impact |
| --- | --- | --- | --- |
| 2026-07-26T16:34:16-03:00 | Draft contract and plan created | Ready-for-handoff discovery package, repository rules, and required skills | Plan set to `awaiting-approval`; no execution snapshot or implementation authority |
| 2026-07-26T16:55:29-03:00 | Complete plan approved | User replied "2." to the direct three-mode approval gate | Scope `complete-plan`, mode `change-sensitive`; P01 authorized and started; P05 remains gated by exact vault path |
| 2026-07-26T16:59:17-03:00 | P01 completed; P02 started | Portable vault contract, templates, and explicit-only metadata validated under PowerShell 7 and Windows PowerShell 5.1 | Ordinary phase transition inside complete-plan authority |
| 2026-07-26T17:05:05-03:00 | P02 completed; P03 started | Twenty-one tests passed under both PowerShell families, covering bootstrap, collision safety, capture, retry, screenshots, events, and working-directory independence | Ordinary phase transition inside complete-plan authority |
| 2026-07-26T17:07:41-03:00 | P03 completed; P04 started | Skill, vault guidance, and behavioral scenario contract pass both repository validators; optional PyYAML validator unavailable | No approach change; authoritative dependency-free validation retained |
| 2026-07-26T17:11:46-03:00 | P04 completed; P05 reached U01 gate | Four-command dual-shell matrix passed; synthetic fixture reconciled five captures and was safely removed; dependency/diff audit passed | Complete-plan authority remains valid, but user-controlled exact vault path is required before external writes |
| 2026-07-26T18:44:03-03:00 | P05 activation attempt stopped before mutation | User supplied `D:\Work\Vaults` and `OracleOfAges`; read-only preflight found both vault and installed target absent; external-write reviewer rejected installation as lacking separate explicit approval | No install or vault write occurred; direct installation approval required |
| 2026-07-26T19:07:29-03:00 | P05 installation and initialization completed | User explicitly approved the exact installed target; installer reported one skill refreshed; 14/14 hashes match; vault has 11/11 required paths, zero unresolved tokens, and zero synthetic captures | P05 live validation remains; new Codex task creation requires a direct user request |
| 2026-07-26T19:21:29-03:00 | Fresh-task creation reached saved-project gate | User explicitly requested a task; `list_projects` did not include the vault; task API cannot target arbitrary paths; Computer Use policy forbids automating Codex UI | User must register the folder in Codex before API creation can proceed |
| 2026-07-26T19:36:17-03:00 | Fresh OracleOfAges task created and validated | User registered the vault project; task `019fa091-4fa3-7db1-abbc-d74036e5284a` completed startup with the correct active context and firsthand-only mode; post-start inspection found zero captures/events | P05 now waits only for deliberate real text, voice, and screenshot inputs |
