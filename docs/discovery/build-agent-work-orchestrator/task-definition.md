# Task Definition: Build the Workcell Agent Work Orchestrator

Status: `ready-for-handoff` · Task: `build-agent-work-orchestrator` · Last
updated: `2026-07-24T19:13:05-03:00` · Supporting record:
`discovery-record.md`

## Objective

Define and implement Workcell, a single-node, long-running service that turns
eligible work items from a generic issue tracker into bounded coding-agent
runs. The implementation language is intentionally open, but externally
observable behavior, lifecycle rules, isolation boundaries, failure handling,
observability, and conformance obligations are normative and portable.

Success means a fresh implementation team can build one conforming service
without chat context or provider-specific assumptions. The service must
continuously reconcile tracker truth with local workers, isolate each item in a
deterministic workspace, bound concurrency and retries, expose structured
runtime state, and make its sandbox and approval posture explicit.

## Implementation context

### Sources and authority

| Source | Authority for this task | Implementation consequence |
| --- | --- | --- |
| User-confirmed synthetic product brief | Governing product, scope, safety, and acceptance decisions | Preserve the single-node model, read-oriented tracker core, dynamic configuration, retry and reconciliation behavior, isolation boundaries, and non-goals. |
| [Workcell technical contract](technical-contract.md) | Normative behavioral and conformance detail derived from the governing brief | Implement every `MUST` and satisfy the conformance matrix; a language-specific design may vary internally but not observably contradict this contract. |
| Repository `AGENTS.md` and `README.md` | Rules for this documentation experiment | Keep work under this discovery directory and do not implement, install, commit, push, publish, deploy, or contact external systems. |
| [Evidence and synthesis notes](evidence-notes.md) | Provenance and evidence classification | Distinguish user-confirmed requirements, verified repository contracts, and contract-completion inferences. |

OpenAI Symphony is contextual inspiration for the desired degree of
implementation readiness only. It is not an authority for Workcell, and its
product behavior, names, structure, and wording must not be copied.

### Current state and governing model

No Workcell service exists as part of this synthetic exercise. The required
output is one implementation contract, not an alternatives study.

The governing model is:

- One Workcell instance is authoritative for one configured tracker and
  workspace root. Distributed claims, multi-instance coordination, a
  persistent scheduler database, and multi-tenancy are excluded.
- Tracker adapters list candidates and refresh named work items. The core does
  not contain provider-specific mutation logic. Optional tracker mutations are
  available to agents only through host-mediated, scope-limited tools.
- The tracker and filesystem remain the recovery sources after restart.
  Claims, retry delays, and retry counters are process-local.
- Active workers continuously reconcile with refreshed tracker state.
  Ineligible work stops; terminal work stops and triggers guarded cleanup;
  missing work releases its claim without cleanup.
- Repository-owned `ORCHESTRATOR.yaml` and `RUN_PROMPT.md` reload dynamically.
  An invalid candidate generation preserves the last-known-good generation for
  active work and blocks only new dispatch until corrected.
- Workspaces are deterministic exact children of a configured root and are
  reused while work is non-terminal. Containment and reparse-point checks apply
  before every creation, reuse, hook, agent launch, and removal boundary.
- Coding agents run behind a local subprocess session adapter. Raw tracker
  credentials never enter the child environment.

### Normative supporting contract

[technical-contract.md](technical-contract.md) is authoritative for:

- normalized entities, state transitions, scheduling, reconciliation, retries,
  and restart behavior;
- configuration fields, defaults, validation, and reload generations;
- tracker, workspace, hook, prompt, and coding-agent contracts;
- security invariants, observability records, host lifecycle, and conformance
  tests.

If this definition and the technical contract appear to conflict, the
user-confirmed decisions summarized here govern product intent and the
technical contract governs the detailed behavior needed to realize that intent.
The documents must be reconciled before implementation rather than choosing
one silently.

## Scope and non-goals

**In scope**

- Build a language-agnostic Workcell host lifecycle and validated dynamic
  configuration loader.
- Define a provider-neutral tracker adapter that normalizes work items and
  offers read operations to the core.
- Implement deterministic dispatch, bounded global and per-state concurrency,
  local claims, active-run reconciliation, continuations, transient retries,
  cancellation, and restart recovery.
- Create, reuse, validate, and remove deterministic per-item workspaces using
  guarded lifecycle hooks.
- Render strict run prompts and drive coding agents through a documented local
  subprocess session protocol with bounded turns and timeouts.
- Expose structured logs and a read-only runtime snapshot, including aggregate
  run duration and agent usage when supplied.
- Document and enforce secret isolation, least-privilege tools and filesystem
  access, and the deployment's approval and sandbox posture.
- Provide deterministic conformance tests and separately gated optional
  real-tracker and real-agent integration tests.

**Not in scope**

- A rich user interface or mandatory HTTP/dashboard presentation.
- Multi-tenancy, high availability, distributed scheduling, or multiple
  authoritative service instances.
- Provider-specific business workflows or provider writes embedded in the core.
- Built-in Git branching, commit, pull-request, merge, or release policy.
- A mandatory container or virtual-machine sandbox.
- A persistent scheduler or retry database.
- Service implementation, installation, deployment, external communication,
  database action, commit, or push during this documentation experiment.

### Material decisions that constrain implementation

| Decision | Why it governs | Prohibited compliant-looking alternative |
| --- | --- | --- |
| Tracker truth is refreshed before retries and reconciled during active work. | Prevents stale local intent from overriding changed issue state. | Retrying or continuing solely from cached work-item data. |
| Provider mutation is outside the core and credentials remain host-side. | Keeps adapters portable and protects secrets. | Exporting tracker tokens to the coding-agent process or embedding provider workflow writes in the scheduler. |
| Invalid dynamic input blocks new dispatch but does not kill valid active work. | Preserves safety without turning an edit error into avoidable work loss. | Applying a partial invalid generation or terminating all current runs on reload failure. |
| The workspace path is derived from the item identity and always includes a stable hash suffix. | Makes paths deterministic and collision-resistant across sanitization and case-insensitive filesystems. | Using the human key alone or resolving collisions by creation order. |
| Retry state is intentionally process-local. | Preserves the no-database architecture and tracker/filesystem recovery model. | Claiming durable retry schedules or exactly-once dispatch across restarts. |
| The runtime snapshot is read-only and presentation-neutral. | Makes introspection required without mandating a web product. | Treating an HTTP dashboard as required or allowing snapshot calls to mutate scheduler state. |

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| Workflow and configuration loader | Load and validate `ORCHESTRATOR.yaml` and `RUN_PROMPT.md`, publish atomic generations, retain the last-known-good generation, and gate new dispatch on invalid reloads. |
| Tracker adapter contract | List candidates and refresh named items into the normalized model without provider writes in the core. |
| Orchestrator and state machine | Poll, filter, order, claim, dispatch, reconcile, cancel, continue, retry, release, and clean up according to the normative lifecycle. |
| Workspace manager and hooks | Produce deterministic contained paths; safely create, reuse, validate, hook, and remove exact item workspaces. |
| Agent session adapter | Implement the documented request/event semantics over a local subprocess transport with bounded turns, cancellation, timeout, progress, usage, tool failures, and terminal results. |
| Prompt renderer | Strictly render the approved work-item and attempt data without unknown placeholders or unintended secret interpolation. |
| Retry and reconciliation subsystem | Classify failures, apply bounded exponential retry or normal continuation, refresh before retry, and honor tracker state changes. |
| Observability | Emit required structured events and expose a consistent read-only runtime snapshot with worker, retry, generation, duration, and usage data. |
| CLI and host lifecycle | Validate configuration, start predictably, handle shutdown signals, drain/cancel workers within bounds, and return documented exit outcomes. |
| Security guidance | Document trust boundaries, child environment construction, tool scopes, filesystem limits, hook risks, and approval/sandbox posture. |
| Conformance suite | Deterministically cover every normative behavior; keep credentialed or nondeterministic real integrations optional and separately selected. |

## Recommended implementation approach

1. **Freeze the contracts and executable fixtures** — translate the normalized
   model, configuration schema, logical adapter protocol, lifecycle tables, and
   security invariants into types and deterministic fixtures before scheduler
   code. Keep provider extensions behind the tracker contract.
2. **Build atomic input generations** — implement strict configuration and
   prompt validation, last-known-good publication, reload health, and captured
   per-worker generations. New dispatch must remain gated while candidate
   inputs are invalid.
3. **Establish the isolation boundary** — implement deterministic workspace
   derivation, containment and reparse checks, exact-child ownership, hook
   timeouts, environment construction, and guarded cleanup before executing
   untrusted repository or agent content.
4. **Implement the worker protocol** — add prompt rendering and one session
   adapter with the normative logical messages, bounded turns and timeouts,
   explicit cancellation, unknown-tool failure, and usage/progress capture.
5. **Implement orchestration and reconciliation** — add deterministic polling,
   ordering, atomic local claims, concurrency accounting, active-item refresh,
   retry/continuation queues, state-driven cancellation, and restart recovery.
6. **Add observability and lifecycle controls** — make every material
   transition visible through structured logs and the consistent runtime
   snapshot; then add validation/run CLI behavior and bounded shutdown.
7. **Prove conformance in layers** — run deterministic fakes for tracker,
   filesystem, clock, hooks, subprocess, and signals first. Offer real tracker
   or agent integrations only as explicit, credentialed, optional suites.

Implementation must stop at a decision gate if the selected language or
platform cannot enforce the containment, subprocess cancellation, secret
isolation, or deterministic-test requirements. Internal substitutions are
allowed only when they preserve the observable contract and test evidence.

### Risks and managed unknowns

| Item | Impact | Required treatment or gate |
| --- | --- | --- |
| Filesystem containment differs by operating system. | A lexical check alone can permit symlink or reparse escapes and destructive cleanup. | Provide platform-specific canonicalization and link checks behind one normative contract; fail closed where the platform cannot prove containment. |
| Agent subprocesses may leave descendants after cancellation. | Timed-out or ineligible work could continue mutating files. | Use a process-group/job-object equivalent, bounded cancellation grace, forced tree termination, and a conformance test. |
| A process restart resets claims and retry budgets. | The same eligible item may run again sooner than before restart. | Document at-least-once dispatch, re-list tracker truth, reuse the contained workspace, and never claim durable retry timing. |
| Optional host tools can mutate tracker state. | Overbroad tools could defeat the read-oriented core and expose credentials. | Declare each tool's operations, item scope, argument validation, approval rule, and audit event; keep credentials exclusively in the host. |
| Hook commands and repositories are untrusted. | They can exfiltrate data or escape intended scope. | Document deployment sandboxing, pass a minimal environment, enforce working-directory containment, bound runtime, and log redacted outcomes. |
| Agent implementations expose different native protocols. | Adapters could silently weaken progress, cancellation, usage, or terminal semantics. | Require a conformance adapter over the normative logical contract and fail unsupported capabilities at startup. |

## Verification and definition of done

### Acceptance checks

| Check | Required evidence |
| --- | --- |
| Configuration and reload | Valid fixtures produce typed generations; invalid YAML, values, hooks, or template placeholders preserve the previous generation, mark reload unhealthy, block new dispatch, and leave active workers intact. |
| Normalization and filtering | Fake adapters prove required fields, case-insensitive labels/states, dispatchability, blocker handling, and deterministic priority/creation/key ordering. |
| Workspace identity and safety | Tests prove deterministic collision-resistant paths, sanitization, length handling, root containment, link/reparse rejection, non-terminal reuse, exact-child cleanup, and parent/sibling preservation. |
| Hook semantics | Controlled hooks prove order, working directory, minimal environment, 60-second default timeout, pre-run abort, post-run logging, and cleanup continuation after `before_remove` failure. |
| Dispatch and concurrency | A controllable clock and tracker prove 20-second default polling, global limit 8, positive per-state limits, atomic local claims, deterministic ordering, and capacity release. |
| Cancellation and reconciliation | State changes, terminal transitions, missing items, and shutdown prove the required stop, cleanup, no-cleanup, and claim-release paths. |
| Retry and continuation | Transient failures use 5-second exponential delay capped at 180 seconds and respect limits; normal eligible completion continues after 2 seconds; every retry refreshes tracker truth. |
| Restart behavior | Restart fixtures prove no durable claim/timer/counter promise, tracker-driven rediscovery, contained workspace reuse, and no automatic cleanup for a missing item. |
| Agent protocol and timeouts | Fake subprocesses prove start/turn/cancel, progress, usage, terminal result, max 12 turns by default, startup/idle/run timeouts, process-tree termination, malformed messages, and unknown-tool failure without stalls. |
| Secret and trust boundaries | Child-environment capture proves tracker secrets are absent; tool and filesystem fixtures prove minimal scoped access and redacted logs. |
| Structured observability | Every lifecycle path emits required context; snapshots are internally consistent, read-only, and expose generations, workers, waits, counters, durations, and supplied usage. |
| CLI lifecycle | Validate and run modes, startup failures, signal handling, bounded drain/cancel, and documented exit statuses are deterministic. |
| Scope preservation | No rich UI, distributed coordination, provider workflow engine, Git/PR policy, mandatory VM/container, persistent scheduler database, or documentation-time external mutation is introduced. |

### Contract traceability

| Governing outcome | Delivery | Verification |
| --- | --- | --- |
| Portable tracker-to-agent orchestration | Tracker adapter, orchestrator, session adapter | Normalization, dispatch, agent protocol, and reconciliation suites |
| Bounded and recoverable local execution | Claims, retry queue, workspace manager, host lifecycle | Concurrency, retry, restart, cancellation, and containment suites |
| Safe dynamic operation | Generation loader, prompt renderer, security controls | Reload, secret-isolation, hook, and scoped-tool suites |
| Inspectable behavior | Structured logger and runtime snapshot | Event-schema and snapshot-consistency suites |
| Provider and language independence | Logical contracts and conformance fixtures | At least one implementation plus fake adapters passes the complete deterministic matrix |

The task is complete when every deliverable exists, all applicable `MUST`
requirements in [technical-contract.md](technical-contract.md) trace to
deterministic passing evidence, security guidance describes the actual
deployment posture, optional real-integration tests are clearly separated, and
none of the stated non-goals or documentation-only prohibitions has been
absorbed into implementation.
