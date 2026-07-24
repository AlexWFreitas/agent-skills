# Implementation Plan: Build the Workcell Agent Work Orchestrator

Status: `draft` · Task: `build-agent-work-orchestrator`  
Created: `2026-07-24T19:02:09-03:00` · Last updated:
`2026-07-24T19:21:43-03:00` · Governing contract:
[`task-definition.md`](task-definition.md)

This is a hypothetical future implementation plan produced for a
documentation-only comparison. It records no permission to execute.

## Current state

- Active phase: `none`
- Next action: `none — preserve the documentation-only boundary; any future
  implementation requires a separate direct approval gate`
- Overall progress: `The draft task contract, normative technical
  specification, conformance contract, and hypothetical plan are authored.
  No service code, test harness, configuration, installation, or external
  integration has been created or run.`
- Governing contract version: `draft`
- Blocking condition: `Execution intentionally unauthorized; U01-U04 also
  require resolution at their stated future gates`
- Latest plan snapshot: `none — snapshots begin only at initial execution
  approval`

## Authorization

- State: `not-requested`
- Scope: `none`
- Mode: `none`
- Approval evidence: `none`
- Authorized consequential actions: `none`
- Mandatory stops:
  - do not begin P01-P07;
  - do not create or modify service implementation, tests, runtime
    configuration, or integrations;
  - do not commit, push, install, publish, deploy, communicate externally,
    mutate a tracker, database, or other service, or run a coding agent;
  - do not create approval/version snapshots;
  - do not infer approval from review, praise, discussion, or this draft;
  - stop for any future conflict with the task contract, repository
    instructions, authority boundary, or safety constraint.

## Mutation surface

Every row below is a proposed future implementation mutation, **not an
authorized mutation**. Exact code paths remain unresolved until U01 selects the
implementation stack and repository layout.

| Target or system | Planned mutation | Reversibility and authority |
| --- | --- | --- |
| Future Workcell source tree | Add typed domain/configuration, tracker boundary, scheduler, workers, workspace manager, hooks, prompt renderer, agent protocol, retries, observability, CLI, and host lifecycle | Locally reversible source edits; not authorized |
| Future core test tree | Add deterministic fakes, controlled clock/filesystem/process harness, mandatory conformance cases, and report generator | Locally reversible source/test edits; not authorized |
| Future documentation tree | Add operator/configuration, adapter, protocol, deployment security, and evidence documentation derived from the normative contract | Locally reversible documentation edits; not authorized |
| Repository root fixture/example area | Add sample `ORCHESTRATOR.yaml`, `RUN_PROMPT.md`, and posture document with no real credentials | Locally reversible; not authorized |
| Isolated temporary test directories | Create/remove test repositories and workspace roots only inside a test-owned temporary root | Ephemeral and guarded; not authorized |
| Local fake subprocesses | Launch/terminate fake agent and hook processes during deterministic tests | Ephemeral process effect; not authorized |
| Optional package/dependency metadata | Add the minimum dependencies selected under U01 | Reversible but may require network/package retrieval; not authorized |
| Live tracker or coding-agent service | Optional read/integration testing after U02/U03; any write/tool action must be separately enumerated | External effect; not part of core plan authority and not authorized |
| Version control | No commit, branch creation, push, pull request, merge, or tag is included | Consequential; explicitly not authorized |
| Deployment/runtime environment | No install, service registration, container publication, deployment, or production run is included | Consequential; explicitly not authorized |
| Databases and persistent services | No database creation/mutation is planned; scheduler persistence is a non-goal | Out of scope and not authorized |
| External parties/channels | No issue comment, state change, handoff link, email, chat, purchase, or other communication is included | Consequential; explicitly not authorized |

Before any future approval request, this table MUST be reconciled to the chosen
language, exact local paths, dependency operations, and test boundaries.
Omission continues to mean not authorized.

## Supporting documents

| Document | Role | Authority and update rule |
| --- | --- | --- |
| [`task-definition.md`](task-definition.md) | Governing goal, scope, requirements, deliverables, decisions, risks, unknowns, and acceptance | Contract authority; after future approval, changes require explicit contract amendment |
| [`technical-specification.md`](technical-specification.md) | Normative portable service behavior and implementation constraints | Technical authority subordinate to task definition; update with any approved behavioral amendment |
| [`verification-and-conformance.md`](verification-and-conformance.md) | Mandatory deterministic cases, evidence model, and acceptance mapping | Verification authority; update when normative behavior changes |

## Contract coverage

| Contract item | Planned delivery and phase | Verification evidence | Coverage state |
| --- | --- | --- | --- |
| O07 / R03, R04, R22 / D01 / A01 | P01 configuration/generation and prompt validation | VC-CFG | `planned` |
| O01, O06, O09 / R05, R06, R07, R08, R10 / D02 / A02, A11 | P02 tracker contract, fake, normalization, optional tool seam | VC-TRK, VC-SEC | `planned` |
| O02, O06 / R17, R18, R19, R20, R21, R30 / D04, D09 / A03, A04, A05 | P03 workspace ownership/containment/hooks | VC-WSP, VC-HOOK | `planned` |
| O03, O06 / R22, R23, R24, R25, R26 / D05 / A10, A11 | P04 prompt rendering and agent subprocess adapter | VC-AGT, prompt cases | `planned` |
| O01, O04, O08 / R01, R09, R11, R12, R13, R14, R15, R16 / D03, D06 / A06, A07, A08, A09 | P05 scheduler, worker lifecycle, reconciliation, retry, restart | VC-SCH, VC-REC, VC-RTY, VC-RST | `planned` |
| O05, O06, O08 / R08, R27, R28, R29, R30, R31, R32, R33 / D07, D08, D09 / A11, A12 | P06 observability, security guidance, CLI/host | VC-SEC, VC-OBS, VC-CLI | `planned` |
| O09, O10 / R02, R34 / D10, D12 / A13 | P07 integrated deterministic conformance and implementation documentation | VC-CON and aggregate report | `planned` |
| R35 | All phases remain inactive under current draft | Authorization section and material-event trail | `verified` for documentation-only state |
| O09 / R34 / D11 / A13 | Optional real integrations after U02/U03, outside mandatory core completion | Separately authorized optional evidence | `planned` but non-blocking for core conformance |

No material outcome, requirement, deliverable, invariant, or acceptance
criterion is orphaned. “Planned” describes contract coverage only; it does not
mean authorized, started, or implemented.

## Phased plan

### Phase P01 — Establish the portable core and configuration generation

**Outcome and status:** A buildable language-selected core with typed domain
types, strict configuration/prompt loading, atomic reload generations, and
deterministic test infrastructure. `pending; unauthorized`

**Contract coverage:** O07; R02-R04, R09, R20, R22, R34; D01 and initial D10;
A01.

**Entry conditions and dependencies**

- Direct execution authorization exists for P01 or the complete plan.
- U01 is resolved with language, runtime, source/test paths, dependency policy,
  and supported platforms.
- Exact local mutation paths and any dependency retrieval are added to the
  authorized mutation surface.
- The normative documents pass a cold-read review.

**Expected future mutations**

- Create source/package skeleton and deterministic test harness.
- Implement normalized types, strict YAML schema/defaults, adapter-config
  validation seam, prompt parser/renderer, generation hashing, last-known-good
  state, and reload block.
- Add fake clock, filesystem, process, and event sinks without live services.

**Verification and completion evidence**

- VC-CFG-01 through VC-CFG-09 pass.
- Static/type/build checks selected under U01 pass.
- No live network or external service is required.
- Evidence report maps P01 tests to R/D/A identifiers.

**Contingency**

- If the selected YAML/template library cannot reject forbidden constructs or
  preserve strict behavior, wrap/replace it inside P01; changing the normative
  syntax requires a contract amendment.
- If platform primitives cannot support a later containment requirement, do
  not weaken it; narrow the claimed platform set before future approval.

### Phase P02 — Implement the tracker boundary and normalized work model

**Outcome and status:** Provider-neutral candidate/refresh behavior, fake
adapter conformance, normalization/eligibility inputs, safe error classes, and
optional scoped tool seam exist. `pending; unauthorized`

**Contract coverage:** O01, O06, O09; R05-R08, R10; D02; A02 and part of A11.

**Entry conditions and dependencies**

- P01 complete.
- Provider-neutral interfaces in S02 §6 are stable.
- U02 may remain unresolved for core/fake work; a real adapter requires U02
  plus separately named credentials/network effects.

**Expected future mutations**

- Add adapter registry/interface, fake adapter, normalization validation,
  pagination/batch seam, health/error model, and candidate/refresh operations.
- Add host-only credential abstraction and optional tool schema/scope
  validation without provider-specific core writes.

**Verification and completion evidence**

- VC-TRK-01 through VC-TRK-08 pass.
- Fixture secrets are absent from child-facing and observable surfaces.
- Provider-specific logic is confined to adapter/tool implementations.

**Contingency**

- If a future provider cannot supply `created_at` or reliable refresh tags, its
  adapter is non-conformant until it derives an authoritative value; core
  ordering MUST NOT silently change.

### Phase P03 — Implement workspace containment and hooks

**Outcome and status:** Per-item paths, ownership, safe reuse/removal, and four
bounded lifecycle hooks satisfy cross-platform containment behavior.
`pending; unauthorized`

**Contract coverage:** O02, O06; R17-R21, R30; D04 and part of D09; A03-A05.

**Entry conditions and dependencies**

- P01 complete.
- Supported filesystem/platform list and containment primitives are verified.
- Test destinations are isolated temporary roots, never a real user skills
  directory or repository root.

**Expected future mutations**

- Add exact sanitization/hash path algorithm, ownership metadata, canonical
  root validation, no-follow/reparse checks, race-resistant operations,
  reuse/removal, hook process runner, bounded output, and process termination.
- Add hostile-key, link/junction/reparse, ownership-conflict, and deletion-scope
  fixtures.

**Verification and completion evidence**

- VC-WSP-01 through VC-WSP-15 and VC-HOOK-01 through VC-HOOK-08 pass on every
  claimed platform.
- Temporary targets are resolved and asserted inside the test-owned root before
  cleanup.
- Outside sentinel files remain unchanged.

**Contingency**

- A platform without adequate containment primitives is unsupported and fails
  validation; implementation MUST NOT substitute string-prefix checking.
- A cleanup failure remains an observable cleanup task/blocker and does not
  authorize broader deletion.

### Phase P04 — Implement the agent session adapter

**Outcome and status:** Strict prompt execution and the versioned local JSONL
subprocess protocol support bounded sessions, turns, tools, cancellation,
timeouts, progress, usage, and terminal results. `pending; unauthorized`

**Contract coverage:** O03, O06; R22-R26; D05; A10 and part of A11.

**Entry conditions and dependencies**

- P01 and P03 complete.
- A fake subprocess is available.
- U03 may remain unresolved for normative/fake adapter work; a vendor adapter
  requires U03 and separately authorized dependency/account access.

**Expected future mutations**

- Add message framing/schema/versioning, handshake, turn controller, progress
  and usage aggregation, tool routing, output bounds, timeout/cancellation
  supervision, process-tree termination, and secret-safe environment builder.
- Add deterministic fake child behaviors for every protocol fault.

**Verification and completion evidence**

- VC-AGT-01 through VC-AGT-12 and relevant VC-CFG prompt cases pass.
- Unknown tools fail promptly without provider invocation or session stall.
- Fixture tracker secrets are absent from all child-visible channels.

**Contingency**

- A vendor SDK that cannot preserve message/timeout/tool semantics must remain
  behind a translating adapter or be rejected; the core contract does not bend
  to a vendor event model.

### Phase P05 — Implement scheduling, workers, reconciliation, and recovery

**Outcome and status:** Polling, deterministic ordering, capacity, claims,
attempts, refresh/cancel decisions, retry/continuation, terminal cleanup, and
restart rediscovery operate as one state machine. `pending; unauthorized`

**Contract coverage:** O01, O04, O08; R01, R09-R16, R19, R25; D03, D06; A06-A09.

**Entry conditions and dependencies**

- P01-P04 complete.
- Fake tracker, agent, clock, workspace, and event sink compose in one harness.
- State transitions and claim/capacity operations have a documented
  synchronization strategy.

**Expected future mutations**

- Add poll loop, candidate ordering, atomic claim/capacity reservation, worker
  controller, periodic refresh, cancellation/finalization, exponential timers,
  continuation, max-turn behavior, shutdown interaction, and restart scan.
- Add exhaustive transition and race tests with controlled interleavings.

**Verification and completion evidence**

- VC-SCH, VC-REC, VC-RTY, and VC-RST groups pass.
- Invariant assertions show at most one local worker per opaque ID, never
  exceeded new-dispatch limits, and exactly-once claim/capacity release.
- Missing items never trigger cleanup; confirmed terminal items do.

**Contingency**

- A race that cannot be made deterministic blocks phase completion. Do not
  weaken claim, containment, cleanup, or refresh-before-retry semantics.

### Phase P06 — Add observability, security guidance, and host lifecycle

**Outcome and status:** Structured event/metric/snapshot contracts, deployment
posture guidance, and predictable validate/run/snapshot lifecycle make the
service operable and inspectable without adding mutating control surfaces.
`pending; unauthorized`

**Contract coverage:** O05, O06, O08; R08, R27-R33; D07-D09; A11-A12.

**Entry conditions and dependencies**

- P01-P05 complete.
- U04 is resolved for any production claim; a safe fixture posture suffices
  for deterministic tests.
- Snapshot capture can compose with scheduler state without long-held locks.

**Expected future mutations**

- Add event schema/redaction, metrics aggregation, immutable snapshot builder
  and presentation, CLI validation/run/snapshot commands, runtime lock,
  signal/drain/force lifecycle, and deployment-security documentation.

**Verification and completion evidence**

- VC-SEC, VC-OBS, and VC-CLI groups pass.
- Snapshot reads have no instrumented side effects.
- Secret canary search across all evidence is empty.
- Deployment guidance states actual isolation and residual risks without
  implying mandatory containers/VMs.

**Contingency**

- Optional HTTP/dashboard work is deferred under U05; the mandatory local
  read-only snapshot remains.
- A platform-specific signal mapping may vary only if externally observable
  draining/cancellation/exit behavior remains equivalent.

### Phase P07 — Complete integrated conformance and handoff

**Outcome and status:** One offline deterministic suite proves the assembled
core, documentation describes every extension/boundary, and the aggregate
evidence report closes all mandatory traceability. `pending; unauthorized`

**Contract coverage:** O01-O10; R02, R34; D10-D12 and optional D11; A01-A13.

**Entry conditions and dependencies**

- P01-P06 complete with phase evidence.
- All normative documents and implementation docs agree.
- Any optional real integration has separate authority, isolated credentials,
  named external mutations, and U02/U03 resolved.

**Expected future mutations**

- Integrate the complete offline suite and report generator.
- Add operator/configuration reference, adapter guide, agent protocol guide,
  security posture template, lifecycle/runbook, and conformance evidence index.
- Optionally add separately gated real-adapter tests; do not make them a core
  conformance dependency.

**Verification and completion evidence**

- Every mandatory case in S03 passes twice deterministically for the same
  build/seed.
- Aggregate report includes every case once and maps every O/R/D/A item.
- Build/type/static/unit/integration checks selected under U01 pass.
- Cold-read review finds no chat-dependent requirement, orphaned contract item,
  duplicate authority, or undocumented limitation.

**Contingency**

- Failed mandatory cases keep the relevant phase/task incomplete.
- Optional integration limitations are documented separately and do not become
  silent core limitations.

## Verification summary

| Check | State | Evidence or accepted limitation |
| --- | --- | --- |
| A01 Configuration/prompt | `pending` | Planned VC-CFG evidence; no implementation |
| A02 Tracker boundary | `pending` | Planned VC-TRK evidence; no implementation |
| A03 Workspace identity | `pending` | Planned VC-WSP-01..07 evidence |
| A04 Workspace containment | `pending` | Planned VC-WSP-08..15 evidence |
| A05 Hook semantics | `pending` | Planned VC-HOOK evidence |
| A06 Dispatch/concurrency | `pending` | Planned VC-SCH evidence |
| A07 Reconciliation | `pending` | Planned VC-REC evidence |
| A08 Retry/continuation | `pending` | Planned VC-RTY evidence |
| A09 Restart | `pending` | Planned VC-RST evidence |
| A10 Agent protocol | `pending` | Planned VC-AGT evidence |
| A11 Security/observability | `pending` | Planned VC-SEC/VC-OBS evidence |
| A12 CLI lifecycle | `pending` | Planned VC-CLI evidence |
| A13 Aggregate conformance | `pending` | Planned VC-CON report |
| Documentation-only authorization state | `verified` | This plan records `not-requested`, `none`, `none`, and no consequential actions |

No limitation has been accepted.

## Managed blockers and limitations

| Item | Impact | Resolver and resolution step | Safe contingency or gate | State |
| --- | --- | --- | --- | --- |
| Execution is intentionally unauthorized | No phase may begin | User must separately initiate a direct approval process if implementation is later desired | Preserve all work as documentation only | `open` |
| U01 implementation stack/path unresolved | Exact mutation surface/build checks unknown | Future implementer proposes and user approves exact stack/paths/dependency effects | Resolve before P01 | `open` |
| U02 concrete tracker unresolved | No live adapter/integration | Product owner selects provider and separately authorizes access | Fake adapter completes core P02 | `open` |
| U03 concrete agent unresolved | No vendor adapter/account integration | Product owner selects agent and separately authorizes access/dependencies | Fake subprocess completes normative P04 | `open` |
| U04 deployment posture unresolved | No production safety/deployment claim | Deployment owner completes security posture and accepts residual risk | Production deployment remains prohibited | `open` |
| Optional HTTP/dashboard and real integrations | Optional presentation/evidence absent | Separately scope under U05/U02/U03 | Core snapshot/offline conformance remain sufficient | `managed` |

## Canonical material-event trail

| Time | Event | Evidence or reason | Plan and authorization impact |
| --- | --- | --- | --- |
| 2026-07-24T19:02:09-03:00 | Draft package created | Governing conversation brief, repository procedure, and phased-plan workflow | Task definition, technical specification, conformance contract, and hypothetical plan created; authorization remains `not-requested`; no snapshot |
| 2026-07-24T19:02:09-03:00 | Documentation-only boundary recorded | User explicitly prohibited implementation and consequential actions | P01-P07 remain pending and unauthorized; scope/mode `none`; consequential actions `none` |

Routine document-authoring activity is intentionally omitted. The next material
event would require a new user instruction; this plan does not request it.
