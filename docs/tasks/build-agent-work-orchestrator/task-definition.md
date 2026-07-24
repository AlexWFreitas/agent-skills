# Task Definition: Build the Workcell Agent Work Orchestrator

Status: `draft` · Task: `build-agent-work-orchestrator` · Version: `draft`  
Created: `2026-07-24T19:02:09-03:00` · Last updated:
`2026-07-24T19:02:09-03:00` · Operational plan:
[`implementation-plan.md`](implementation-plan.md)

## Sources and authority

| ID | Source | Role and precedence | Supported claims | Evidence state or limitation |
| --- | --- | --- | --- | --- |
| S01 | Conversation-supplied Workcell brief, confirmed 2026-07-24 | Governing product authority | Product purpose, required behavior, defaults, boundaries, future deliverables, and acceptance surface | Authoritative synthetic product decision; no deployed system was inspected |
| S02 | [`technical-specification.md`](technical-specification.md) | Normative technical elaboration subordinate to this task definition | Portable behavioral contract, data model, lifecycle, algorithms, interfaces, errors, security, and observability | Draft authored from S01; must not contradict this file |
| S03 | [`verification-and-conformance.md`](verification-and-conformance.md) | Normative verification authority subordinate to this task definition and S02 | Deterministic conformance cases and optional integration-test expectations | Draft; no implementation evidence exists |
| S04 | Repository `AGENTS.md` and `README.md` | Governing repository procedure | Editable boundaries, documentation placement, validation expectations, and prohibitions on unrequested consequential actions | Verified in the current checkout on 2026-07-24 |
| S05 | `skills/phased-plan-to-goal/SKILL.md`, its templates, and readiness checklist | Governing workflow procedure | Required contract/plan separation, traceability, authority recording, and draft readiness review | Verified in the current checkout on 2026-07-24 |
| S06 | [OpenAI Symphony](https://github.com/openai/symphony) | Contextual inspiration only | Example of a language-independent orchestration specification | Non-authoritative; Workcell is an original contract and does not inherit Symphony requirements |
| S07 | Read-only repository search on 2026-07-24 | Current-state evidence | No existing `Workcell` or `build-agent-work-orchestrator` implementation or task package was found | Limited to the current checkout; absence is not evidence about external systems |

Precedence is S01, this task definition, S02, S03, and then the operational
plan. S04 and S05 govern repository and workflow procedure independently of
product behavior. S06 cannot resolve a product ambiguity. If two governing
sources conflict, implementation must stop at the conflicting contract item
until this draft is amended; the plan cannot silently select a different
behavior.

## Objective

Define and, only after separate future authorization, implement **Workcell**: a
single-node, long-running, language-agnostic service that turns eligible
issue-tracker work items into isolated coding-agent runs. Workcell must make
dispatch, workspace, agent-session, retry, reconciliation, observability, and
safety behavior deterministic enough that independent implementations can
conform to the same contract.

The immediate authorized outcome is documentation only: a self-contained
implementation contract and a hypothetical phased plan. This task does not
authorize service implementation or any consequential external action.

## Problem and verified current state

The desired orchestration behavior currently exists only as the governing
synthetic brief. Without a normalized model and normative lifecycle, independent
implementers could make incompatible choices about eligibility, concurrency,
workspace identity, retry timing, tracker changes, subprocess messages, secret
handling, and terminal cleanup.

| Evidence | Supported current-state claim | Class and limitation |
| --- | --- | --- |
| S07 | The current checkout contains no Workcell implementation or existing matching task package | Verified for this checkout on 2026-07-24 |
| S01 | Required product behaviors and boundaries have been selected | Governing user-supplied decision, not runtime evidence |
| S02 and S03 | A portable implementation and verification contract can be expressed without selecting a programming language | Draft synthesis; must be reviewed before future approval |
| No implementation or runtime evidence | No requirement is implemented, tested, deployed, or operationally validated | Explicit unresolved implementation state |

## Desired outcomes and success measures

| ID | Outcome | Success measure or observable signal |
| --- | --- | --- |
| O01 | Independent implementations interpret eligible work consistently | Identical normalized inputs and configuration produce the same eligibility, ordering, and concurrency decisions |
| O02 | Each claimed item executes in a deterministic isolated workspace | Workspace-path conformance cases pass, root containment is enforced, and no two tested keys alias |
| O03 | Coding-agent sessions have a bounded, portable host contract | The request/event protocol, tool behavior, cancellation, timeout, usage, and terminal-result cases pass |
| O04 | Tracker changes and failures converge safely | Reconciliation, retry, continuation, missing-item, terminal-item, and restart cases reach the specified state without duplicate local dispatch |
| O05 | Operators can understand service and run state without mutating it | Structured logs and the read-only runtime snapshot expose the required context, counters, durations, and usage |
| O06 | Untrusted data and secrets remain within explicit safety boundaries | Secret-isolation, path-containment, hook invocation, prompt rendering, and tool-scope checks pass |
| O07 | Configuration and prompt changes are safe at runtime | Valid generations reload atomically; invalid generations retain last-known-good behavior, block only new dispatch, and expose a diagnostic |
| O08 | Service lifecycle is predictable on one node | Startup validation, polling, graceful shutdown, forced cancellation, exit status, and restart-recovery checks pass |
| O09 | The implementation remains portable and provider-neutral | Core conformance does not depend on a programming language, tracker vendor, rich UI, distributed scheduler, persistent scheduler database, or built-in Git/PR workflow |
| O10 | A fresh implementation team can execute without chat context | Every requirement traces through a deliverable and phase to a deterministic acceptance check |

## Requirements and invariants

### Service, configuration, and tracker

| ID | Type | Requirement or invariant | Source | Verification implication |
| --- | --- | --- | --- | --- |
| R01 | functional | Workcell must run as one authoritative, long-lived service instance and must not require distributed coordination or a scheduler database | S01 | A01, A12 |
| R02 | compatibility | The implementation language and concrete agent SDK are implementer-selected; all externally observable behavior in S02 must remain portable | S01 | A10, A12 |
| R03 | functional | Repository-owned `ORCHESTRATOR.yaml` must define tracker, polling, workspace/hooks, concurrency, retry, agent, observability, and safety settings | S01 | A01 |
| R04 | operational | `ORCHESTRATOR.yaml` and `RUN_PROMPT.md` must reload as one validated generation; invalid reloads retain the last-known-good generation and block only new dispatch | S01 | A01 |
| R05 | functional | Tracker adapters must fetch eligible candidates and refresh named items through a provider-neutral, read-oriented core contract | S01 | A02 |
| R06 | data | Each work item must normalize opaque identity, unique human key, title, description, priority, creation/update time, native state, labels, blockers, optional branch hint, and adapter-derived dispatchability | S01; created time derived from mandated ordering | A02 |
| R07 | invariant | Core orchestration must not embed provider-specific tracker writes; optional writes may occur only through explicitly configured, host-mediated, scope-limited agent tools | S01 | A02, A11 |
| R08 | security | Raw tracker credentials must never enter the coding-agent child environment, prompt, workspace, logs, snapshot, or tool arguments | S01 | A11 |

### Dispatch and orchestration

| ID | Type | Requirement or invariant | Source | Verification implication |
| --- | --- | --- | --- | --- |
| R09 | functional | Polling defaults to 20 seconds; global concurrency defaults to 8; configured per-state limits must be positive | S01 | A01, A06 |
| R10 | functional | Required labels and active/terminal states must compare case-insensitively using the normalization in S02 | S01 | A02, A06 |
| R11 | functional | Dispatchable candidates must be ordered by priority and then oldest creation time, with deterministic tie-breaking | S01 | A06 |
| R12 | invariant | In-memory claims must prevent duplicate dispatch within the authoritative process and must be released on every terminal worker path | S01 | A06, A07 |
| R13 | operational | Restart recovery must be tracker/filesystem driven; retry timers and in-memory claims must not be restored | S01 | A09 |
| R14 | functional | Running items must be refreshed and reconciled; ineligible runs must be cancelled, terminal items must trigger guarded cleanup, and missing items must release claims without cleanup | S01 | A07 |
| R15 | functional | A transient failure must retry exponentially from 5 seconds up to 180 seconds and must refresh the item before retry | S01 | A08 |
| R16 | functional | A normal attempt that leaves the item eligible must schedule a 2-second continuation, subject to refresh and configured limits | S01 | A08 |

### Workspace and hooks

| ID | Type | Requirement or invariant | Source | Verification implication |
| --- | --- | --- | --- | --- |
| R17 | functional | Each item must map to a deterministic workspace below the configured root using the algorithm in S02 | S01 | A03 |
| R18 | security | Workspace resolution must enforce root containment and reject traversal, symlink, junction, mount-point, and other reparse-point escapes | S01 | A04 |
| R19 | operational | Non-terminal workspaces must be reused; terminal workspaces must be cleaned only through guarded lifecycle behavior; missing items must not cause cleanup | S01 | A03, A07 |
| R20 | functional | Hooks `after_create`, `before_run`, `after_run`, and `before_remove` must use argument-safe invocation and default to a 60-second timeout | S01 | A05 |
| R21 | operational | `after_create` or `before_run` failure must abort the attempt; `after_run` or `before_remove` failure must be logged and must not suppress required cleanup | S01 | A05 |

### Prompt and agent session

| ID | Type | Requirement or invariant | Source | Verification implication |
| --- | --- | --- | --- | --- |
| R22 | functional | `RUN_PROMPT.md` must be rendered as a strict template over the allowed work-item and attempt fields; unknown variables are invalid | S01 | A01, A10 |
| R23 | functional | An implementation-selected agent session adapter must expose the request/event contract in S02 over a local subprocess transport | S01 | A10 |
| R24 | functional | The agent contract must support start, turn, cancellation, timeout, structured progress, usage, tool calls, and exactly one terminal result | S01 | A10 |
| R25 | operational | A worker lifetime must default to at most 12 turns; configured timeouts and cancellation grace must be enforced | S01 | A10 |
| R26 | invariant | Unknown tool calls must receive a structured failure and must not stall the session or consume unbounded host resources | S01 | A10 |

### Observability, lifecycle, and safety

| ID | Type | Requirement or invariant | Source | Verification implication |
| --- | --- | --- | --- | --- |
| R27 | operational | Structured logs must carry item, attempt, workspace, session, event, and error context when applicable | S01 | A11 |
| R28 | operational | A read-only runtime snapshot must expose configuration health, scheduler state, claims, workers, retry/continuation timers, aggregate run duration, and agent usage when supplied | S01 | A11 |
| R29 | compatibility | HTTP or dashboard presentation is optional; the snapshot data contract is mandatory | S01 | A11 |
| R30 | security | Tracker data, repository content, prompts, hooks, and tool arguments must be treated as untrusted and must not expand authority | S01 | A04, A05, A11 |
| R31 | security | Deployment guidance must document approval and sandbox posture; filesystem and agent-tool scope must be least-privilege | S01 | A11 |
| R32 | compatibility | Containers or VMs may be used but are not mandatory for conformance | S01 | A11 |
| R33 | operational | The CLI/host must validate before run, expose a read-only snapshot, handle termination signals, stop dispatch, cancel within grace, and return defined exit statuses | S01 | A12 |
| R34 | quality | Core behavior must have deterministic conformance tests; real tracker/agent integrations are optional and must be separated from core conformance | S01 | A13 |
| R35 | invariant | No implementation activity or consequential external action may begin under this draft plan | S01, S04, S05 | Plan authorization inspection |

## Implementation context and affected systems

| Area, user, or stakeholder | Current role or behavior | Required impact or preserved boundary |
| --- | --- | --- |
| Operator | Owns repository configuration and service lifecycle | Receives deterministic validation, diagnostics, graceful lifecycle, logs, and snapshot |
| Tracker adapter | Provider-specific read boundary | Normalizes candidates and refreshes named items without leaking provider behavior into core orchestration |
| Optional tracker-tool host | Mediates limited provider writes requested by an agent | Enforces per-tool scope and credential isolation; remains optional |
| Scheduler/orchestrator | No implementation exists | Owns polls, claims, capacity, ordering, attempts, continuations, retries, reconciliation, and cleanup decisions |
| Workspace manager | No implementation exists | Creates, validates, reuses, hooks, and safely removes per-item workspaces |
| Agent session adapter | No implementation exists | Converts local subprocess messages into the normative session contract |
| Coding-agent child | Executes untrusted repository work | Receives only scoped prompt/session data, never raw tracker credentials |
| Observability consumer | Reads logs or runtime state | Must be unable to mutate scheduler or worker state through the required snapshot |
| Repository owner | Supplies configuration, prompt, hooks, and code | Retains ownership of business workflow and Git/PR policy outside Workcell core |

Detailed behavior is authoritative in
[`technical-specification.md`](technical-specification.md). Verification
fixtures, scenario identifiers, and evidence requirements are authoritative in
[`verification-and-conformance.md`](verification-and-conformance.md).

## Scope and non-goals

**In scope**

- A provider-neutral issue-tracker read adapter and normalized work-item model.
- Single-process dispatch, bounded concurrency, local claims, attempts,
  continuations, retries, reconciliation, and restart recovery.
- Deterministic per-item workspaces, safe lifecycle hooks, and guarded cleanup.
- A strict prompt-generation contract and local subprocess agent-session
  protocol.
- Optional scope-limited tracker tools mediated by the host.
- Structured logs, metrics aggregation, and a read-only runtime snapshot.
- CLI/host lifecycle, security/deployment guidance, deterministic core
  conformance tests, and optional real-integration test seams.

**Not in scope**

- A rich user interface, mandatory HTTP server, or mandatory dashboard.
- Multi-tenancy, multi-instance coordination, leader election, or distributed
  scheduling.
- A persistent scheduler/claims/retry database.
- Built-in provider business workflows or provider-specific core writes.
- Built-in Git branch, commit, push, pull-request, review, or merge policy.
- A mandatory container, VM, or particular sandbox product.
- Selection of an implementation language, framework, tracker vendor, or
  coding-agent vendor.
- Implementation, commit, push, install, deployment, external communication,
  database action, or service execution during this documentation-only run.

## Deliverables

| ID | Deliverable | Required outcome | Governing requirements |
| --- | --- | --- | --- |
| D01 | Configuration and prompt subsystem | Load, type-check, atomically reload, diagnose, and retain last-known-good `ORCHESTRATOR.yaml` plus `RUN_PROMPT.md` | R03-R04, R22 |
| D02 | Tracker boundary | Provider-neutral candidate/refresh adapter, normalized model, and optional mediated tool seam | R05-R08 |
| D03 | Orchestrator and scheduler | Deterministic eligibility, ordering, capacity, claims, attempts, reconciliation, and shutdown | R01, R09-R16 |
| D04 | Workspace manager and hook runner | Deterministic contained paths, safe reuse/removal, and four lifecycle hooks | R17-R21, R30 |
| D05 | Agent session adapter and prompt renderer | Portable local subprocess protocol, bounded turns/timeouts, progress, usage, tools, and terminal result | R22-R26 |
| D06 | Retry, continuation, and restart subsystem | Specified delay rules, pre-retry refresh, timer handling, and tracker/filesystem recovery | R13-R16 |
| D07 | Observability subsystem | Contextual structured logs, aggregate metrics, and read-only snapshot | R27-R29 |
| D08 | CLI/host lifecycle | Validation, run, snapshot, signal handling, graceful/forced shutdown, and exit status | R33 |
| D09 | Security and deployment guidance | Untrusted-input, credential, sandbox, approval, hook, tool, and filesystem posture | R08, R18, R30-R32 |
| D10 | Deterministic conformance suite | Automated core cases covering all mandatory behavior and fault paths | R34 |
| D11 | Optional integration-test adapters | Clearly separated real tracker and agent tests that do not gate core portability | R34 |
| D12 | Implementation documentation | Operator configuration reference, adapter contract, protocol reference, lifecycle explanation, and evidence index | R02-R34 |

## Constraints, dependencies, and assumptions

| ID | Kind | Statement | Implementation consequence | Validation or resolution |
| --- | --- | --- | --- | --- |
| C01 | constraint | One service instance is authoritative | Use process-local claims; reject claims of distributed safety | A06, A09 |
| C02 | constraint | Behavior is normative and language-agnostic | Avoid language-specific wire types and undefined ordering/time semantics | A10, A13 |
| C03 | constraint | Core tracker behavior is read-oriented | Provider writes exist only behind optional host tools | A02, A11 |
| C04 | constraint | No persistent scheduler database | Recovery must derive from tracker and filesystem; timers restart from polling | A09 |
| C05 | dependency | A tracker adapter must supply normalized candidates and refreshes | Dispatch cannot start without a healthy adapter | A02, A12 |
| C06 | dependency | A local repository and workspace root are operator-controlled prerequisites | Workspace creation must fail safely if root policy cannot be established | A03, A04 |
| C07 | dependency | A coding-agent subprocess adapter must implement the session contract | An item cannot run without adapter handshake success | A10 |
| C08 | assumption | Work-item keys are unique within the configured tracker scope | Workspace identity includes a stable hash so case/filesystem normalization cannot alias distinct keys | A03 |
| C09 | assumption | Monotonic time is available within one process lifetime | Delays and timeouts use monotonic time; timestamps use UTC wall time | A08 |
| C10 | constraint | Current authorization covers documentation only | Future plan phases and all implementation mutations remain hypothetical | Plan authorization and mutation-surface review |
| C11 | constraint | Core conformance cannot depend on live external services | Use deterministic fakes and a controllable clock/filesystem | A13 |
| C12 | assumption | Filesystem primitives can inspect and reject link/reparse traversal | Unsupported roots must fail validation rather than weaken containment | A04 |

## Material decisions and rationale

| ID | Decision | Rationale and evidence | Constraint on implementation |
| --- | --- | --- | --- |
| DEC01 | Workcell is a single-node authority with process-local claims | Governing brief deliberately excludes distributed coordination | Do not introduce a database, lease service, or multi-instance correctness claim |
| DEC02 | The normalized model includes `created_at` | S01 mandates oldest-creation-time dispatch, which is impossible without it | Adapters must supply a parseable creation timestamp |
| DEC03 | Workspace leaf names always include a stable SHA-256-derived suffix | Determinism and cross-platform collision resistance must hold even for case-only or normalization collisions | Do not use key-only directories or runtime-order collision suffixes |
| DEC04 | Configuration and prompt form one reload generation | Dispatch must not pair a new policy with an old prompt or vice versa | Validate both before publishing; invalid change blocks new dispatch |
| DEC05 | Existing runs use their captured generation while reconciliation uses current tracker facts | Prevents mid-attempt policy drift while still reacting to issue state changes | Do not mutate an active attempt's prompt, limits, hooks, or agent settings after start |
| DEC06 | The portable subprocess protocol is newline-delimited JSON with explicit versioning | A concrete language-neutral wire contract enables deterministic conformance | Alternate internal SDKs are permitted only behind an adapter that preserves the wire behavior |
| DEC07 | Missing refresh is distinct from terminal refresh | S01 explicitly forbids cleanup for missing items | Release the claim and preserve workspace on `missing` |
| DEC08 | Optional tracker tools are capabilities, not embedded workflow | Preserves provider neutrality and credential isolation | Tool names/scopes must be configured; unknown or ungranted calls fail structurally |
| DEC09 | The mandatory runtime view is an immutable snapshot data contract | Allows CLI, file, HTTP, or dashboard presentations without requiring one transport | No required snapshot operation may mutate service state |
| DEC10 | The phased plan is hypothetical and unauthorized | The user requested a documentation experiment only | No phase starts and no approval snapshots are created |

## Risks and mitigations

| ID | Risk and trigger | Impact | Mitigation, contingency, or stop condition | Owner or resolver |
| --- | --- | --- | --- | --- |
| RSK01 | A malicious key or filesystem link escapes the workspace root | Arbitrary filesystem access or deletion | Stable path algorithm, component-by-component no-follow checks, guarded removal, fail closed | Implementer; A03-A04 |
| RSK02 | Reload publishes a partially valid generation | Runs execute with inconsistent policy/prompt | Parse and validate the pair before atomic publication; block new dispatch after an invalid observed generation | Implementer; A01 |
| RSK03 | Tracker changes race with attempts or retries | Duplicate, stale, or unauthorized work | Refresh before retry, periodic reconciliation, local claim invariant, cancellation, deterministic release | Implementer; A06-A09 |
| RSK04 | Agent subprocess stalls or emits malformed/unbounded output | Worker exhaustion or memory pressure | Framing/size limits, heartbeat/idle timeout, turn timeout, cancellation grace, forced termination | Implementer; A10 |
| RSK05 | Hooks or prompt content turn untrusted values into commands | Command injection or privilege expansion | Argument-array invocation, no shell interpolation by default, strict template variables, least privilege | Implementer/operator; A05, A11 |
| RSK06 | Tracker credentials leak to child process or diagnostics | Credential compromise | Host-only credential provider, environment allowlist, recursive redaction, negative conformance fixtures | Implementer; A11 |
| RSK07 | Retry/continuation loops create runaway cost | Resource exhaustion | Configured retry/turn bounds, capacity enforcement, cancellation, counters, observable timers | Operator/implementer; A06, A08, A10 |
| RSK08 | An implementation claims conformance using only happy paths | Unsafe operational divergence | Mandatory deterministic fault/concurrency/security cases and traceable evidence | Reviewer; A13 |
| RSK09 | Future implementation expands into Git/PR or provider business policy | Scope and authority expansion | Preserve non-goals and require a contract amendment for new core workflows | User/product owner |

## Managed unknowns and resolution gates

The draft intentionally leaves implementation choices open only where they do
not change observable behavior.

| ID | Unknown | Impact if unresolved | Resolver and resolution step | Safe contingency or gate |
| --- | --- | --- | --- | --- |
| U01 | Implementation language, runtime, and libraries | Affects code layout and tooling, not contract behavior | Future implementer proposes a stack compatible with S02/S03 and repository constraints | Resolve before P01 implementation; do not alter behavioral requirements |
| U02 | First concrete tracker provider | Determines the first adapter and credential mechanism | Product owner selects a provider after core fake-adapter conformance exists | P02 may implement only the provider-neutral boundary and fake |
| U03 | First coding-agent SDK/process | Determines adapter glue and vendor event mapping | Product owner selects an agent after the protocol harness exists | P04 may implement only the normative local adapter and fake process |
| U04 | Deployment-specific sandbox and approval posture | Determines host hardening and residual risk | Deployment owner records posture against the security guidance | Production deployment is prohibited until documented; no mandatory sandbox product is implied |
| U05 | Optional HTTP/dashboard presentation | Affects non-core packaging only | Product owner separately scopes it | Read-only CLI/file snapshot is sufficient for core completion |
| U06 | Repository-specific hooks and Git workflow | Affects configured behavior outside Workcell core | Repository owner supplies hooks and policy | No built-in Git/PR behavior may be inferred |

## Supporting documents

| Document | Authoritative purpose | Material implementation consequence | Update rule |
| --- | --- | --- | --- |
| [`technical-specification.md`](technical-specification.md) | Normative architecture, types, algorithms, state machines, protocols, failure semantics, security, and observability | Implementations must preserve every `MUST`/`MUST NOT`; this task definition wins on conflict | Amend with this contract when behavior changes |
| [`verification-and-conformance.md`](verification-and-conformance.md) | Normative acceptance cases and evidence | Core conformance requires all mandatory cases; optional integration cases cannot replace them | Update whenever a requirement or normative algorithm changes |
| [`implementation-plan.md`](implementation-plan.md) | Hypothetical operational sequence, mutation surface, authorization, and progress | No phase may start while authorization remains `not-requested` | Rewrite after any future approval, material replan, phase transition, blocker, resume, or closure |

## Acceptance criteria and definition of done

| ID | Criterion | Required evidence | Limitation policy |
| --- | --- | --- | --- |
| A01 | Configuration and prompt parsing/reload obey schema, defaults, atomicity, and last-known-good rules | VC-CFG mandatory cases | No limitation may be accepted for core conformance |
| A02 | Tracker normalization, eligibility inputs, case handling, refresh results, and provider-neutral boundaries conform | VC-TRK mandatory cases | No core limitation |
| A03 | Workspace paths are deterministic and collision-resistant and reuse/ownership rules conform | VC-WSP-01 through VC-WSP-07 | No core limitation |
| A04 | Traversal and reparse/link escapes fail closed; guarded removal cannot target outside/root/foreign workspaces | VC-WSP-08 through VC-WSP-15 | No security limitation |
| A05 | Hook order, argument safety, timeout, pre-run abort, post-run logging, and cleanup behavior conform | VC-HOOK mandatory cases | No security or cleanup limitation |
| A06 | Dispatch order, global/per-state concurrency, labels/states, claims, and capacity release conform | VC-SCH mandatory cases | No duplicate-dispatch or limit limitation |
| A07 | Active refresh, cancellation, terminal cleanup, missing-item handling, and claim release conform | VC-REC mandatory cases | No cleanup-on-missing or stale-run limitation |
| A08 | Transient retry, cap, limit, pre-retry refresh, and 2-second continuation conform under a fake clock | VC-RTY mandatory cases | Timing tolerance only as specified in S03 |
| A09 | Restart restores no claim/timer yet safely rediscovers tracker/filesystem state | VC-RST mandatory cases | No persistent-timer behavior may be claimed |
| A10 | Prompt rendering and agent protocol support bounded start/turn/tool/cancel/timeout/progress/usage/result behavior | VC-AGT mandatory cases | No secret or stall limitation |
| A11 | Secret isolation, untrusted-input boundaries, structured logs, metrics, and read-only snapshot conform | VC-SEC and VC-OBS mandatory cases | No credential leakage or mutating snapshot limitation |
| A12 | CLI validates, runs, snapshots, signals, drains/cancels, and exits predictably | VC-CLI mandatory cases | Platform-specific signal mapping may be documented if behavior remains equivalent |
| A13 | Deterministic core conformance runs without live services and produces a requirement-indexed evidence report | Complete mandatory matrix and report | Optional real integrations may be absent |

## Contract traceability

| Outcome or requirement | Deliverable | Supporting authority | Planned phase | Acceptance check |
| --- | --- | --- | --- | --- |
| O07 / R03-R04 / R22 | D01 | S02 §§4-5 | P01 | A01 |
| O01 / R05-R11 | D02, D03 | S02 §§3, 6-7 | P02, P05 | A02, A06 |
| O02 / R17-R21 | D04 | S02 §8 | P03 | A03-A05 |
| O03 / R22-R26 | D05 | S02 §§5, 9 | P04 | A10 |
| O04 / R12-R16 | D03, D06 | S02 §§7, 10 | P05 | A06-A09 |
| O05 / R27-R29 | D07 | S02 §11 | P06 | A11 |
| O06 / R07-R08 / R18 / R30-R32 | D02, D04, D05, D09 | S02 §12 | P02-P06 | A04-A05, A11 |
| O08 / R01 / R13 / R33 | D03, D06, D08 | S02 §§7, 10, 13 | P05-P06 | A09, A12 |
| O09 / R02 / R29 / R32 / R34 | D10-D12 | S02 §§1, 14; S03 | P07 | A13 |
| O10 / R34-R35 | D10-D12 | S03; implementation plan | P07; no execution authorized | A13 and authorization review |

No service deliverable or acceptance criterion is complete in this
documentation-only state. The future implementation task is complete only when
D01-D12 exist, A01-A13 have the required evidence, actual state is reconciled,
and all non-goals and invariants remain preserved.
