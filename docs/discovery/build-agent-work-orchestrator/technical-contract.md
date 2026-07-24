# Workcell Technical Contract

Status: `ready-for-handoff` · Contract version: `1.0` · Last updated:
`2026-07-24T19:13:05-03:00`

This document is the normative, language-agnostic behavioral contract for
Workcell. It is original to this synthetic task. It does not specify a
programming language, framework, issue-tracker provider, coding-agent product,
or deployment platform.

## 1. Conventions and conformance

The terms **MUST**, **MUST NOT**, **REQUIRED**, **SHOULD**, **SHOULD NOT**, and
**MAY** are normative.

A Workcell implementation conforms when:

1. every applicable `MUST` and `MUST NOT` in this document is satisfied;
2. the deterministic conformance matrix in section 16 passes;
3. its implementation guide documents every managed platform choice identified
   in [evidence-notes.md](evidence-notes.md);
4. optional provider, agent, dashboard, and sandbox features do not weaken the
   core contract; and
5. deviations are not hidden behind provider-specific behavior.

Time durations are wall-clock durations unless a test uses a controllable
clock. Timestamps are RFC 3339 strings with an explicit offset and are compared
as instants. Configuration and protocol text is UTF-8. Human-facing strings may
contain Unicode. Identity and enum tokens are compared exactly unless this
contract explicitly requires case folding.

`fold(value)` means Unicode NFC normalization followed by Unicode default case
folding. Required labels and native state names use `fold`. Opaque identifiers,
paths, protocol correlation identifiers, and hashes do not.

## 2. System boundary and components

Workcell is one long-running process authority over one configuration root and
one workspace root.

```text
ORCHESTRATOR.yaml + RUN_PROMPT.md
                |
                v
        Configuration Manager
                |
                v
Tracker Adapter -> Scheduler/Reconciler -> Worker -> Session Adapter -> Agent
                       |                   |
                       v                   v
                 Runtime Snapshot     Workspace Manager
                       \                  /
                        Structured Events
```

A conforming host has these logical components:

| Component | Responsibility |
| --- | --- |
| Configuration manager | Load, validate, hash, and atomically publish input generations; retain the last-known-good generation. |
| Tracker adapter | List candidates and refresh named items into the normalized model. |
| Scheduler/reconciler | Filter, order, claim, dispatch, refresh, stop, continue, retry, suppress, and release work. |
| Workspace manager | Derive and guard item paths, maintain ownership metadata, execute hooks, and clean terminal work. |
| Prompt renderer | Strictly render the captured template from normalized item and attempt data. |
| Session adapter | Translate the logical agent request/event contract to one local subprocess transport. |
| Observability service | Emit structured events and return a consistent read-only runtime snapshot. |
| Host lifecycle | Validate startup, run the control loop, handle signals, and bound shutdown. |

Components MAY share a process and data structures. These boundaries describe
behavior and test seams, not deployment units.

The core scheduler MUST NOT:

- embed provider-specific issue-state mutations;
- invoke Git, branch, commit, pull-request, merge, or release policy as a
  built-in workflow;
- export raw tracker credentials to hooks or agent subprocesses;
- rely on a persistent scheduler database; or
- claim cross-process or exactly-once coordination.

## 3. Domain model

### 3.1 Normalized work item

The tracker adapter MUST produce this logical record:

| Field | Type | Rules |
| --- | --- | --- |
| `id` | non-empty string | Opaque, stable provider identity. Exact comparison. |
| `key` | non-empty string | Human-readable unique key within the adapter scope. |
| `title` | string | May be empty only when the provider has no title; preserve content. |
| `description` | string | Plain text or provider-preserved markup. Never execute during normalization. |
| `priority` | integer or null | Lower integer sorts first; null sorts after all integers. |
| `native_state` | non-empty string | Compared with configured states using `fold`. |
| `labels` | array of strings | Preserve original spelling; membership uses `fold`; duplicate folded values collapse. |
| `blockers` | array of blocker records | Each record has non-empty `ref` and boolean `resolved`. |
| `created_at` | timestamp | Required for deterministic oldest-first ordering. |
| `updated_at` | timestamp | Provider's latest material modification time. |
| `branch_hint` | string or null | Advisory only; the core MUST NOT implement Git policy from it. |
| `dispatchable` | boolean | Adapter-derived provider eligibility after provider rules. |

An item is invalid when a required field is absent, a timestamp is invalid, two
returned records share an exact `id`, or two records share a folded `key` while
having different `id` values. The adapter MUST return item-scoped
normalization errors rather than silently inventing identity or time values.
The scheduler MUST skip invalid candidates, emit `tracker.item_invalid`, and
continue processing other candidates.

The core MUST treat an item as **eligible** only when all are true:

1. `dispatchable` is true;
2. `native_state` belongs to configured `filters.active_states`;
3. every configured required label is present after folding;
4. no blocker has `resolved: false`;
5. the item is not already locally claimed; and
6. capacity is available globally and for its folded native state.

Terminal state membership always wins over active membership. Configuration
validation MUST reject any folded state present in both sets.

### 3.2 Runtime identities

| Identity | Construction and lifetime |
| --- | --- |
| `instance_id` | Unique random identifier for one host process lifetime. |
| `generation_id` | Lowercase SHA-256 hex digest over canonical validated configuration plus exact prompt bytes. |
| `claim_id` | Unique random identifier for one process-local claim lifetime. |
| `attempt_id` | Unique random identifier for one agent subprocess/session lifetime. |
| `session_id` | Supplied by or negotiated with the session adapter; unique within the instance. |
| `workspace_id` | First 16 lowercase hexadecimal characters of SHA-256 over UTF-8 item `id`. |

Identifiers used in logs and snapshots MUST be stable for their stated
lifetime. Raw secrets, full prompt content, and unbounded tracker descriptions
MUST NOT be included in identifiers.

### 3.3 Claim and attempt states

A claim has exactly one state:

```text
claimed -> preparing -> running -> reconciling
              |           |             |
              v           v             v
         waiting_retry  waiting_continuation
              |           |
              +-----> preparing

any active state -> stopping -> released
reconciling -> cleanup_pending -> released
waiting_retry -> retry_exhausted -> preparing (only after item update)
```

| State | Meaning |
| --- | --- |
| `claimed` | Atomic local ownership exists; no attempt has started. |
| `preparing` | Workspace, hooks, prompt, and subprocess are being prepared. |
| `running` | Agent session is active. |
| `reconciling` | The host is refreshing tracker truth after a result or poll observation. |
| `waiting_retry` | A transient-failure delay is pending. |
| `waiting_continuation` | A normal eligible continuation delay is pending. |
| `retry_exhausted` | Retry budget is spent; the host retains and refreshes the claim until the item changes or becomes ineligible. |
| `stopping` | Cancellation and process-tree termination are in progress. |
| `cleanup_pending` | Terminal cleanup is pending or being retried. |
| `released` | Local ownership is gone; terminal state for the claim object. |

An **attempt** begins before `before_run` and ends after `after_run` handling.
One attempt owns at most one agent subprocess and one session. A retry or
continuation creates a new `attempt_id`.

For the turn-limit requirement, one coding-agent worker lifetime is one
attempt/session lifetime. Retry and continuation create a new worker lifetime
while retaining the process-local item claim.

## 4. Configuration and dynamic generations

### 4.1 Repository-owned inputs

The host MUST read `ORCHESTRATOR.yaml` and `RUN_PROMPT.md` from one caller
selected repository configuration directory. It MUST NOT search parent
directories or silently fall back to a user-global file.

Relative configured paths resolve against the directory containing
`ORCHESTRATOR.yaml`. Resolution MUST NOT depend on the caller's current
directory.

### 4.2 Logical configuration schema

This is the required schema. Implementations MAY map it to language-specific
types but MUST preserve field names, defaults, validation, and unknown-field
behavior. Required implementation-selected values are shown as placeholders;
the displayed document is structural and is not itself a runnable
configuration.

```yaml
schema_version: 1

tracker:
  adapter: "implementation-defined-adapter-name"
  config: {}

polling:
  interval_seconds: 20

filters:
  required_labels: []
  active_states: []
  terminal_states: []

workspace:
  root: "<required-workspace-root>"
  hook_timeout_seconds: 60
  hooks:
    after_create: null
    before_run: null
    after_run: null
    before_remove: null

concurrency:
  global: 8
  per_state: {}

retry:
  max_transient_retries: 3
  initial_delay_seconds: 5
  maximum_delay_seconds: 180
  continuation_delay_seconds: 2

agent:
  command: []
  max_turns: 12
  startup_timeout_seconds: 30
  idle_timeout_seconds: 300
  run_timeout_seconds: 3600
  cancellation_grace_seconds: 10
  environment_allowlist: []

observability:
  level: "info"

safety:
  approval_posture: "documented-by-deployment"
  sandbox_posture: "documented-by-deployment"
  allowed_tools: []
  allow_shell_hooks: false
```

Rules:

- `schema_version` MUST equal integer `1`.
- Governing unknown fields MUST be rejected with a complete field path.
  Adapter-specific keys under `tracker.config` MAY be open-ended and are
  validated by the selected adapter.
- Durations MUST be finite positive numbers. `continuation_delay_seconds` MAY
  be zero only when explicitly set.
- `filters.active_states` and `filters.terminal_states` MUST each contain at
  least one non-empty value and MUST NOT overlap after folding.
- Folded required labels and state names MUST be unique.
- `concurrency.global` MUST be a positive integer.
- Every `concurrency.per_state` key MUST identify a configured active state
  after folding, and each value MUST be a positive integer. A per-state value
  MAY exceed the global limit; the global limit still caps total running and
  preparing claims.
- `retry.max_transient_retries` MUST be an integer greater than or equal to zero.
  Initial delay MUST be less than or equal to maximum delay.
- `agent.command` MUST be a non-empty argument vector. Shell text is not an
  agent command.
- `agent.max_turns` MUST be a positive integer.
- The read-only runtime snapshot is mandatory and cannot be disabled by
  configuration. Presentation remains implementation-selected.
- Each hook is null or an object containing a non-empty `argv` array and
  optional positive `timeout_seconds`. A hook may contain shell text only when
  `safety.allow_shell_hooks` is true and the deployment guide calls out the
  added risk.
- `workspace.root` MUST resolve to a directory that is not the filesystem root,
  repository root, repository parent, configuration directory, or a child of
  an item workspace.
- The selected tracker adapter MUST validate `tracker.config` before the
  generation is accepted.
- `safety.approval_posture` and `safety.sandbox_posture` MUST be replaced by
  deployment-specific non-placeholder descriptions before `run` mode starts.

### 4.3 Atomic load and reload

The configuration manager MUST treat the YAML and prompt as one candidate
generation:

1. Read stable bytes for both files. If either changes during reading, retry
   the read rather than publishing a mixed pair.
2. Parse and type-check YAML.
3. Resolve and validate paths without creating or removing item workspaces.
4. Validate the tracker adapter configuration.
5. Parse and validate every prompt placeholder.
6. Canonicalize the typed configuration, combine it with exact prompt bytes,
   and compute `generation_id`.
7. Publish the complete generation atomically.

The host MUST check for changed input at startup and at least once per poll
cycle. A file watcher MAY reduce latency but MUST NOT replace cycle checks.

On candidate failure:

- retain the previous valid generation for already claimed work;
- set `dispatch_ready` to false;
- block new claims;
- allow active claims, their scheduled retries, and their continuations to use
  their captured generation;
- emit one `config.reload_rejected` event per distinct failed content digest,
  with redacted diagnostics; and
- retry after a file change and on each poll cycle.

The host MUST NOT partially apply a candidate generation. On later success it
sets `dispatch_ready` true and emits `config.generation_activated`. A worker
captures one immutable generation when first claimed and keeps it until release.
Configuration changes do not migrate active workspaces or alter active timeouts.

## 5. Tracker adapter contract

### 5.1 Core read operations

Every adapter MUST implement:

```text
list_candidates(context) -> CandidateBatch
refresh_item(context, id) -> Found(Item) | Missing | AdapterError
```

`context` contains the validated adapter configuration, deadline,
correlation identifier, and cancellation signal. It does not expose scheduler
internals.

`CandidateBatch` contains normalized items, item-scoped normalization errors,
an optional provider cursor for diagnostics, and provider request timing. The
core treats the batch as a snapshot, not a transaction.

`list_candidates` SHOULD return all items that could become eligible under the
configured active-state and label filters. The core MUST still apply its own
eligibility check.

`refresh_item` MUST address the opaque `id`, not a mutable title. A provider
that cannot refresh by opaque ID MUST document its stable equivalent and prove
rename behavior in its adapter tests.

Adapter errors are:

| Class | Meaning | Scheduler behavior |
| --- | --- | --- |
| `transient` | Timeout, throttling, temporary network/provider failure | Preserve claims; retry the control operation with bounded logging and do not start stale retries. |
| `authentication` | Missing, expired, or rejected host credential | Mark tracker unhealthy and block new dispatch; active agents may be cancelled if required by deployment policy, but credentials remain host-side. |
| `configuration` | Adapter config is invalid for the provider | Reject the candidate generation. |
| `permanent_item` | Named item cannot be normalized or supported | Stop/release that claim without cleanup unless a terminal item was successfully observed. |

### 5.2 Optional host-mediated mutation tools

An adapter MAY expose tools for comments, state changes, or handoff links. Such
tools are not callable by scheduler core logic.

Every enabled tool MUST declare:

- a stable name and typed argument schema;
- allowed operation and item scope;
- whether explicit human approval is required;
- deadline and maximum input/output size;
- redaction rules;
- idempotency behavior; and
- an audit event schema.

The host MUST bind a tool call to the current claimed item unless configuration
explicitly grants narrower cross-item access. Raw provider credentials MUST
remain in the host credential store and MUST NOT appear in the prompt, hook
environment, child environment, protocol payload, logs, or snapshot.

Unknown, disabled, malformed, out-of-scope, or unapproved tool calls MUST
receive a structured failed `tool_result` within the tool-response deadline.
They MUST NOT wait indefinitely or be silently ignored.

## 6. Polling, ordering, and capacity

The control loop MUST:

1. check input generation health;
2. reconcile every existing claim that is due for refresh;
3. process due retry, continuation, and cleanup timers;
4. if `dispatch_ready`, list candidates;
5. normalize and filter candidates;
6. sort eligible unclaimed candidates;
7. claim and start candidates while capacity remains; and
8. publish one internally consistent snapshot revision.

Default poll interval is 20 seconds. The interval is measured from the start of
one scheduled poll to the next. If a cycle overruns, the next cycle starts
without adding parallel poll loops and emits `scheduler.poll_overrun`.

Eligible candidates sort by this total order:

1. non-null `priority` before null;
2. lower integer priority;
3. earlier `created_at`;
4. folded `key` ascending;
5. exact `id` ascending.

The same item ID MUST NOT have more than one local claim. Claim insertion and
capacity reservation MUST be one atomic state transition.

Global capacity counts claims in `preparing`, `running`, `reconciling`, and
`stopping`. Waiting and cleanup-only claims do not consume agent capacity.
Per-state capacity uses the captured item's folded native state and counts the
same capacity-consuming states. Both global and per-state capacity must be
available.

The scheduler MUST re-evaluate capacity after every transition. It MUST NOT
preempt a running item only because a higher-priority candidate arrives.
Fairness beyond the deterministic order is not guaranteed.

When reconciliation observes a move between two configured active states, the
claim's per-state capacity bucket changes atomically. A move that places the
new bucket above its configured limit does not preempt the existing worker but
blocks further dispatch into that bucket until usage falls below the limit.

## 7. Dispatch and worker lifecycle

### 7.1 New claim

Before creating a claim, the scheduler MUST confirm:

- an active valid generation exists and `dispatch_ready` is true;
- the candidate remains eligible in the current batch;
- no claim for exact item `id` exists;
- global and per-state capacity are available; and
- shutdown has not begun.

It then atomically creates `claim_id`, reserves capacity, captures the
generation and normalized item, and emits `claim.created`.

Before launching the first agent subprocess, the worker MUST call
`refresh_item`. If the result differs from the candidate, the refreshed item
governs. It proceeds only if the refreshed item is eligible.

### 7.2 Attempt sequence

For each attempt:

1. allocate `attempt_id` and capture attempt/retry/continuation counters;
2. obtain or safely create the owned workspace;
3. on first creation, run `after_create`;
4. run `before_run`;
5. render the prompt from the captured generation and latest item;
6. construct the scrubbed child environment;
7. start the session adapter subprocess and await session start;
8. conduct at most `agent.max_turns` turns while monitoring deadlines,
   cancellation, protocol events, and tracker reconciliation;
9. obtain or synthesize one terminal attempt result;
10. run `after_run`; and
11. refresh the item and select cleanup, stop, continuation, retry, suppression,
    or release.

If `after_create` or `before_run` fails, the attempt is classified as a
pre-run failure and no agent subprocess starts. `after_run` failure is logged
and cannot replace the agent's terminal classification.

### 7.3 Reconciliation while running

Every active claim MUST be refreshed at least once per poll interval and before
every retry or continuation launch.

On refresh:

| Observation | Required action |
| --- | --- |
| Item remains eligible and non-terminal | Update the worker's normalized item for the next turn/attempt; do not change its captured generation. |
| Item becomes non-terminal but ineligible | Request session cancellation, terminate within bounds, run `after_run`, release the claim, and retain the workspace. |
| Item becomes terminal | Cancel if needed, run `after_run`, transition to guarded cleanup, and release only after cleanup succeeds or is retained as `cleanup_pending`. |
| Item is missing | Cancel if needed, run `after_run`, release the claim, and do not remove the workspace or ownership metadata. |
| Refresh has a transient error | Do not launch a due retry/continuation from stale data. A currently running session MAY continue until the next refresh deadline unless deployment policy is stricter. |
| Refresh has an authentication error | Block new dispatch and expose degraded health; keep credentials host-side. |

Terminal detection uses the latest successfully normalized item. Missing is not
equivalent to terminal.

## 8. Workspace ownership, hooks, and cleanup

### 8.1 Root layout

Within configured `workspace.root`, Workcell owns:

```text
<root>/
  .workcell/
    ownership/
      <workspace_id>.json
  items/
    <safe-key>--<workspace_id>/
```

The administrative ownership record contains only version, exact item `id`,
last observed `key`, relative item path, creation timestamp,
`initialization_complete`, and last successful cleanup status. It MUST NOT
store prompts, tracker credentials, retry counters, session transcripts, or
scheduler claims. It is filesystem recovery metadata, not a scheduler
database.

The agent and hooks receive the item directory as their working directory and
MUST NOT receive access to `.workcell/ownership` unless a deployment sandbox
cannot technically separate it and documents the residual risk.

### 8.2 Deterministic basename

For a new item with no ownership record:

1. normalize `key` to Unicode NFC;
2. replace each maximal sequence outside ASCII `[A-Za-z0-9._-]` with `-`;
3. collapse repeated `-`;
4. trim leading and trailing `.`, `-`, and whitespace;
5. use `item` if the result is empty;
6. truncate the safe prefix to 64 ASCII characters without leaving a trailing
   dot or hyphen; and
7. append `--` plus `workspace_id`.

Because the identity suffix is always present, sanitization changes,
case-insensitive filesystems, truncation, and visually similar keys do not rely
on creation order for collision handling. If an ownership record already maps
the exact item `id`, its existing valid path is reused even if the human key
changed. A different item ID MUST never reuse that record or path.

### 8.3 Containment

Before create, reuse, hook execution, agent launch, or removal, the workspace
manager MUST:

- resolve the configured root to an absolute canonical path;
- reject a filesystem root and every prohibited root from section 4;
- ensure every existing ancestor from root to target is not a symbolic link,
  mount redirection, junction, reparse point, or platform equivalent that could
  escape policy;
- ensure the target's canonical location is an exact child of `<root>/items`;
- validate ownership metadata against exact item `id` and relative path;
- reject `.`/`..`, separators, device paths, alternate streams, nulls, or
  platform-reserved traversal in derived segments; and
- fail closed when the platform cannot establish the relationship.

A lexical prefix test alone is non-conforming. Cleanup MUST name the exact
validated item path; it MUST NOT recursively clean the root, `items`, ownership
directory, parent files, or sibling workspaces.

### 8.4 Hooks

Hooks execute in this order:

| Hook | When | Failure effect |
| --- | --- | --- |
| `after_create` | After a newly owned item directory is established, and again on a later attempt until it succeeds once | Abort the attempt as a pre-run failure; retain the workspace with `initialization_complete: false`. |
| `before_run` | Before every agent subprocess | Abort the attempt as a pre-run failure; retain the workspace. |
| `after_run` | After every started agent attempt, including cancellation and timeout | Log failure but preserve the agent result and continue reconciliation. |
| `before_remove` | Before each terminal cleanup attempt | Log failure and continue required exact-child removal. |

Default timeout is 60 seconds. A hook timeout MUST terminate its complete
process tree. Hook output is size-bounded, redacted, and emitted as structured
metadata rather than copied without limit.

Only successful `after_create` sets `initialization_complete: true`. Reusing a
workspace whose record is false MUST rerun `after_create` before `before_run`.
Once true, the hook does not run again for that ownership lifetime.

The default hook command form is an argument vector executed without an
intermediate shell. Hooks receive only a documented minimal environment:

- item ID, key, attempt ID when applicable, workspace path, and generation ID;
- explicitly allowlisted non-secret host variables; and
- no raw tracker credential or unredacted configuration blob.

For retry classification, a nonzero hook exit or timeout after a valid command
was started is transient. A command that cannot be started because its
executable or platform capability is invalid is permanent. Implementations MAY
add more specific configured exit-code classification, but it MUST be typed,
documented, and deterministic.

### 8.5 Cleanup and restart recovery

Terminal cleanup:

1. revalidate terminal tracker state;
2. validate ownership and containment;
3. cancel any active process tree;
4. run `before_remove`;
5. remove only the exact item workspace;
6. verify the exact path no longer exists;
7. remove its ownership record; and
8. emit `workspace.removed`.

`before_remove` failure does not skip step 5. Removal failure retains the claim
as `cleanup_pending`, emits an error, and retries with the configured transient
backoff capped at 180 seconds. Cleanup retries do not consume agent capacity.

At startup the host MUST inspect syntactically valid ownership records before
new dispatch. For each:

- if refresh finds a terminal item, perform guarded cleanup;
- if refresh finds an eligible or other non-terminal item, retain the workspace
  for potential reuse and do not create a claim solely because the record
  exists;
- if refresh returns missing, retain the workspace and record;
- if the record or containment is invalid, quarantine it logically by refusing
  use or removal and emit a high-severity diagnostic.

The host MUST NOT infer terminal state from age, absence from candidate listing,
or process restart.

## 9. Prompt contract

`RUN_PROMPT.md` is a strict template. The renderer MUST support these roots:

| Root | Contents |
| --- | --- |
| `work_item` | The complete normalized item except provider credentials and adapter-private data. |
| `attempt` | Claim ID, attempt ID, ordinal, retry ordinal, continuation ordinal, generation ID, maximum turns, and current timestamp. |

Implementations MUST document exact placeholder syntax. They MUST:

- reject unknown roots, unknown fields, malformed expressions, executable
  expressions, includes, file reads, environment reads, and network reads;
- render missing optional values deterministically as empty or `null` according
  to documented syntax;
- preserve prompt bytes outside placeholders;
- apply context-appropriate escaping;
- bound rendered prompt size before subprocess start; and
- validate the entire template before publishing a generation.

The renderer MUST NOT expose tracker credentials, host environment contents,
ownership metadata outside the current item, or unrelated work items.
Tracker, repository, and work-item content remains untrusted after rendering;
the prompt is data supplied to an agent, not an authorization boundary.

## 10. Agent session contract

### 10.1 Transport requirements

One attempt uses one local subprocess transport. The implementation MAY choose
JSON Lines, length-prefixed messages, or another documented framing. It MUST
provide:

- ordered, size-bounded messages;
- request/event correlation;
- protocol version negotiation or an explicit version mismatch failure;
- separate stderr handling;
- bounded startup, idle, total-run, and cancellation timers;
- cancellation of the complete process tree; and
- redaction before logs or snapshots.

Unsupported mandatory session capabilities MUST fail startup validation rather
than degrade silently.

### 10.2 Logical host requests

Every adapter implements these logical requests:

| Request | Required data and behavior |
| --- | --- |
| `start` | Protocol version, attempt/session correlation, workspace, rendered prompt metadata, allowed tools, max turns, and deadlines. Produces `session_started` or a classified error. |
| `turn` | Turn ordinal and bounded host input. Produces progress/events and exactly one `turn_complete`, `terminal`, or error outcome. |
| `cancel` | Reason and grace deadline. Idempotent; followed by terminal acknowledgement or host-forced termination. |
| `tool_result` | Correlated success/failure for one host-mediated tool call. Unknown or late correlation is a protocol error. |

The child environment MUST be newly constructed from a minimal implementation
baseline plus `agent.environment_allowlist`. It MUST NOT inherit the complete
host environment. Tracker credentials and secret configuration values are
always excluded, including when their variable names are allowlisted.

### 10.3 Logical agent events

| Event | Rules |
| --- | --- |
| `session_started` | Exactly once before turn events; includes session ID and supported protocol version. |
| `progress` | Zero or more bounded structured updates; content is untrusted and redacted before logs. |
| `usage` | Monotonic or delta usage with documented units and source; unknown fields preserved only in adapter-private diagnostics. |
| `tool_call` | Typed name, correlation ID, and bounded arguments; host validates scope and approval. |
| `turn_complete` | Exactly one outcome for a non-terminal turn. |
| `terminal` | Exactly once; classification, summary metadata, and optional usage. |
| `error` | Classified adapter/protocol/agent error with safe diagnostic. |
| `heartbeat` | Optional liveness signal; cannot reset total-run timeout. |

Message sequence numbers MUST increase within a session. Duplicate terminal
events, events before `session_started`, decreasing sequence numbers, malformed
framing, oversized messages, or silent EOF before a terminal outcome are
protocol failures.

### 10.4 Turns and timeouts

One attempt permits at most 12 turns by default. Reaching the configured maximum
causes an orderly cancel with reason `turn_limit`, then a terminal
`limit_reached` attempt result.

Defaults:

- startup: 30 seconds from spawn to `session_started`;
- idle: 300 seconds without a valid event or outstanding-tool progress;
- total run: 3,600 seconds from spawn;
- cancellation grace: 10 seconds after `cancel`.

The first expired deadline wins and is recorded. After cancellation grace the
host MUST forcibly terminate the process tree and await its confirmed exit
before releasing the workspace for another attempt.

An unknown tool call receives failed `tool_result` with code
`unsupported_tool`; it does not reset the total-run deadline. Repeated unknown
calls MAY become a permanent agent-policy failure after a documented bounded
threshold.

## 11. Results, retry, continuation, and suppression

### 11.1 Attempt result classes

Every attempt ends in one:

| Result | Examples | Next action after tracker refresh |
| --- | --- | --- |
| `normal` | Agent terminal success, turn limit reached with a valid terminal result | Terminal item: cleanup. Eligible item: 2-second continuation. Other non-terminal: release and retain workspace. Missing: release without cleanup. |
| `transient_failure` | Temporary agent startup failure, subprocess resource exhaustion, transient hook dependency, protocol transport interruption | If eligible and budget remains: exponential retry. Otherwise follow state or suppression rules. |
| `permanent_failure` | Unsupported mandatory capability, invalid prompt at captured generation, repeated policy-invalid tool behavior | No automatic retry. Retain and refresh claim in suppression until item update or ineligibility. |
| `cancelled_by_state` | Item became ineligible, terminal, or missing | Follow the exact observation action in section 7. |
| `cancelled_by_shutdown` | Host shutdown | Retain workspace; release claim after process exit; no terminal cleanup without terminal tracker evidence. |

`after_create` and `before_run` failures are classified by the failing hook
adapter as transient or permanent. `after_run` failure is diagnostic only.

### 11.2 Transient retry

For transient retry ordinal `n`, starting at 1:

```text
delay(n) = min(maximum_delay, initial_delay * 2^(n - 1))
```

Defaults yield 5, 10, 20, 40, 80, 160, 180 seconds. No random jitter is
required in the single-instance core; an implementation MAY add bounded jitter
only if deterministic tests can disable it and the scheduled time remains
observable.

Before a due retry, `refresh_item` MUST succeed. If the refreshed item is no
longer eligible, the retry does not start. A transient refresh failure defers
the retry without consuming retry budget.

`max_transient_retries` counts launches after the original failed attempt. When
exhausted, the claim enters `retry_exhausted` and remains process-local. It does
not consume agent capacity. The host refreshes it each poll:

- a changed `updated_at` resets retry budget and allows a new attempt if
  eligible;
- ineligible or missing releases without cleanup;
- terminal triggers cleanup.

A process restart forgets suppression and retry counts. This is intentional
at-least-once behavior.

### 11.3 Normal continuation

After a normal result, the host refreshes the item. If still eligible, it
schedules a continuation after 2 seconds by default. Continuations:

- retain the same claim and workspace;
- create a new attempt/session;
- increment continuation ordinal;
- do not increment transient retry ordinal; and
- capture the claim's existing configuration generation.

A continuation refresh failure defers launch. State change rules remain
authoritative.

## 12. Structured observability

### 12.1 Event envelope

Every structured event has:

| Field | Requirement |
| --- | --- |
| `timestamp` | RFC 3339 instant |
| `level` | `debug`, `info`, `warn`, or `error` |
| `event` | Stable dotted event name |
| `instance_id` | Current host instance |
| `generation_id` | Captured/active generation when applicable |
| `item_id`, `item_key` | Present for item-scoped events |
| `claim_id`, `attempt_id`, `session_id` | Present when that scope exists |
| `workspace` | Redacted or policy-approved path for workspace events |
| `state_before`, `state_after` | Present for state transitions |
| `duration_ms` | Present for completed timed operations |
| `error` | Structured safe code, class, phase, and redacted message |
| `context` | Bounded typed event-specific fields |

Required event families include:

- `host.starting`, `host.ready`, `host.stopping`, `host.stopped`;
- `config.generation_activated`, `config.reload_rejected`;
- `tracker.poll_started`, `tracker.poll_completed`,
  `tracker.item_invalid`, `tracker.refresh_failed`;
- `claim.created`, `claim.transitioned`, `claim.released`;
- `workspace.created`, `workspace.reused`, `workspace.guard_failed`,
  `workspace.removed`, `workspace.cleanup_failed`;
- `hook.started`, `hook.completed`, `hook.failed`;
- `agent.started`, `agent.progress`, `agent.usage`,
  `agent.tool_rejected`, `agent.cancelled`, `agent.terminal`;
- `retry.scheduled`, `retry.exhausted`, `continuation.scheduled`; and
- `scheduler.poll_overrun`, `scheduler.capacity_changed`.

Secrets, raw credentials, full environment blocks, full prompts, arbitrary
repository files, and unbounded tool arguments MUST NOT be logged. Errors MUST
retain enough phase and correlation data to diagnose behavior after redaction.

### 12.2 Read-only runtime snapshot

Snapshot acquisition MUST be side-effect free and internally consistent at one
`observed_at` revision. The presentation MAY be an in-process API, CLI command,
local file, or access-controlled HTTP endpoint.

The snapshot contains:

```text
instance:
  id, started_at, lifecycle_state
configuration:
  active_generation_id, active_since, dispatch_ready,
  candidate_status, last_reload_error
tracker:
  health, last_poll_started_at, last_poll_completed_at,
  last_poll_duration_ms, candidates_seen, last_error
scheduler:
  global_limit, active_capacity, claims_by_state,
  next_poll_at, waiting_retries, waiting_continuations, cleanup_pending
workers[]:
  item id/key/state, claim/attempt/session ids, workspace,
  claim state, generation, attempt/retry/continuation ordinals,
  started_at, last_event_at, next_action_at, cancellation_reason
totals:
  attempts, normal_results, transient_failures, permanent_failures,
  cancellations, cumulative_run_duration_ms, supplied_agent_usage
```

Reading a snapshot MUST NOT refresh tracker state, change timers, acknowledge
errors, approve tools, cancel work, or rotate configuration.

Usage aggregation MUST preserve the adapter-supplied unit and source. Values
with incompatible units MUST remain separate rather than being summed.

## 13. Security and trust boundaries

Tracker content, repository files, prompt text, hooks, agent output, tool
arguments, configuration text, ownership metadata, and filesystem state are
untrusted inputs.

A deployment guide MUST state:

- host identity and privilege;
- tracker credential source and rotation process;
- child environment allowlist;
- filesystem write/read scope;
- network posture;
- hook shell posture;
- enabled tools and approval rules;
- subprocess containment mechanism;
- sandbox technology or explicit absence;
- snapshot/log access controls; and
- residual risk.

Normative invariants:

1. Tracker secrets remain in the host credential boundary.
2. Agent and hook child environments are constructed, not wholesale inherited.
3. Tool calls are schema-validated, bounded, item-scoped, approval-checked, and
   audited.
4. Workspace containment is revalidated at every destructive or executable
   boundary.
5. Cancellation covers descendants, not only the direct child.
6. Logs and snapshots redact secrets and bound attacker-controlled content.
7. Configuration and prompt reload never partially apply.
8. Cleanup never uses an unresolved variable, glob, working directory, or
   user-provided raw path as its deletion target.
9. A missing item is never treated as permission to delete its workspace.
10. Absence of a mandatory VM/container sandbox MUST be disclosed; it is not
    evidence that untrusted execution is safe.

Workcell MAY run without container or VM isolation only when the deployment's
documented posture and approvals allow it. The core contract does not claim
that filesystem checks alone sandbox arbitrary code.

## 14. Host and CLI lifecycle

The implementation MUST expose logical `validate` and `run` modes. Exact binary
naming and option syntax may be language-specific, but user documentation must
map them clearly.

### 14.1 Validate mode

Validate mode:

- reads both repository-owned inputs;
- validates schema, adapter config, prompt, paths, command capabilities, and
  deployment posture;
- performs no tracker mutation, workspace creation/removal, hook, or agent
  launch;
- prints actionable redacted diagnostics; and
- exits zero only for a valid runnable generation.

### 14.2 Run mode

Run mode:

1. validates and publishes an initial generation;
2. establishes workspace control directories without touching item
   workspaces;
3. performs ownership-record recovery;
4. initializes tracker and session adapters;
5. emits `host.ready`; and
6. begins the control loop.

It MUST fail startup before dispatch if no valid generation exists, the tracker
adapter lacks mandatory capabilities, the workspace root is unsafe, or
deployment posture remains placeholder text.

### 14.3 Shutdown

On the first termination signal:

- stop polling and creating claims;
- block new attempts, retries, and continuations;
- request cancellation of active sessions;
- allow configured cancellation grace;
- force remaining process trees to exit;
- run `after_run` for attempts that started when safely possible;
- retain non-terminal workspaces and ownership records;
- complete already-started exact-child terminal cleanup when safe; and
- emit a final snapshot and `host.stopped`.

A second termination signal MAY shorten graceful work but MUST still avoid
unvalidated deletion. Unexpected host exit makes no durability promise for
in-memory claims or timers.

Recommended stable exit classes are:

| Class | Meaning |
| --- | --- |
| `0` | Validation succeeded or run stopped cleanly. |
| `configuration` | No runnable generation or invalid CLI input. |
| `dependency` | Required adapter, workspace, or subprocess capability unavailable. |
| `runtime` | Host terminated because a non-recoverable control-loop invariant failed. |
| `forced_shutdown` | Bounded shutdown could not complete cleanly. |

Exact numeric codes MUST be documented and tested.

## 15. Reference algorithms

These algorithms define outcomes, not implementation syntax.

### 15.1 Candidate dispatch

```text
function dispatch_cycle(batch):
    candidates = []
    for raw_result in batch:
        item = normalize(raw_result)
        if item is invalid:
            emit tracker.item_invalid
            continue
        if eligible(item) and not claimed(item.id):
            candidates.append(item)

    sort candidates by:
        priority presence, priority, created_at, fold(key), id

    for item in candidates:
        if shutdown or not dispatch_ready:
            break
        if capacity_available(item.native_state):
            atomically reserve capacity and insert claim(item)
            start worker asynchronously
```

### 15.2 Due retry or continuation

```text
function launch_due(claim):
    refreshed = tracker.refresh_item(claim.item.id)
    if transient error:
        defer without consuming budget
        return
    if missing:
        stop if needed
        release without cleanup
        return
    if terminal(refreshed):
        stop if needed
        guarded_cleanup
        return
    if not eligible(refreshed):
        stop if needed
        release and retain workspace
        return
    if capacity unavailable:
        keep due and wait
        return
    start new attempt with claim generation and refreshed item
```

### 15.3 Guarded removal

```text
function remove_terminal(claim, refreshed_item):
    require terminal(refreshed_item)
    owned_path = validate_ownership(claim.item.id)
    require contained_exact_child(owned_path, root/items)
    require no redirecting ancestor
    terminate_owned_process_tree
    run before_remove, record failure but continue
    revalidate ownership and containment
    remove exact owned_path only
    verify absent
    remove exact ownership record
    release claim
```

## 16. Deterministic conformance matrix

The required suite MUST run without network access, real credentials, or a real
coding agent. It uses controllable fakes for tracker, clock, filesystem/link
boundary, hooks, session subprocess, and host signals.

| ID | Area | Required scenario and evidence |
| --- | --- | --- |
| CFG-001 | Defaults | Minimal valid configuration yields poll 20s, global 8, hook 60s, retries 3 with 5/180s bounds, continuation 2s, and max turns 12. |
| CFG-002 | Validation | Unknown governing fields, overlapping folded states, duplicate folded labels, nonpositive limits, missing command, and unsafe root fail with field paths. |
| CFG-003 | Atomic reload | A mixed or invalid YAML/prompt pair never publishes; active workers retain their generation; dispatch blocks; later valid pair activates once. |
| TRK-001 | Normalization | Valid items preserve fields; missing identity/time, duplicate IDs, folded key collisions, and malformed blockers are item-scoped errors. |
| TRK-002 | Eligibility | Active state, required labels, dispatchable flag, unresolved blockers, and terminal precedence are proven with case variants. |
| TRK-003 | Refresh | Named refresh uses opaque identity and drives eligible, ineligible, terminal, missing, transient, authentication, and permanent-item paths. |
| DSP-001 | Ordering | Mixed null/integer priorities, creation times, folded keys, and IDs produce the specified total order. |
| DSP-002 | Capacity | Atomic claims never exceed global or per-state limits under concurrent completions and dispatch cycles. |
| DSP-003 | Poll timing | Default interval, overrun behavior, and absence of overlapping poll loops are proven with a fake clock. |
| WSP-001 | Path derivation | Safe, Unicode, traversal-like, empty, reserved, long, case-colliding, and sanitization-colliding keys produce deterministic contained collision-resistant paths. |
| WSP-002 | Ownership | Exact item ownership reuses a renamed item's existing path and rejects a different ID, corrupt record, or path mismatch. |
| WSP-003 | Containment | Lexical-prefix traps, symlinks, junction/reparse equivalents, alternate streams, root selection, parent targets, and sibling targets fail closed. |
| WSP-004 | Cleanup | Terminal cleanup runs hook then exact deletion, preserves parent/siblings, continues after hook failure, retries removal failure, and never cleans a missing item. |
| HOK-001 | Lifecycle | Hook order, retry-until-success `after_create`, item working directory, allowlisted environment, output bound, default/override timeout, and process-tree termination are deterministic. |
| PRM-001 | Strict prompt | All approved fields render; unknown/executable/file/environment expressions and oversized output reject the generation. |
| AGT-001 | Handshake | Start/session version, ordered sequence, correlation, stderr separation, and exactly-one terminal semantics are enforced. |
| AGT-002 | Turns/timeouts | Defaults and overrides for startup, idle, run, max turns, cancel grace, and forced descendant termination are proven. |
| AGT-003 | Tools | Allowed, malformed, unknown, out-of-scope, unapproved, late, and duplicate calls receive bounded correlated outcomes without exposing credentials. |
| AGT-004 | Usage/progress | Structured progress and compatible usage aggregate; incompatible units remain separate; attacker-controlled content is bounded/redacted. |
| REC-001 | Active reconciliation | Eligible update, ineligible state, terminal state, missing item, and transient refresh failure cause the exact required action. |
| RTY-001 | Backoff | Retry ordinals produce 5, 10, 20, 40, 80, 160, and capped 180-second delays under relevant configuration. |
| RTY-002 | Retry gate | Every due retry refreshes first; transient refresh defers without budget use; exhaustion suppresses until item update. |
| CNT-001 | Continuation | Normal eligible completion schedules 2 seconds, retains claim/workspace/generation, and creates a new attempt without incrementing retry ordinal. |
| RST-001 | Restart | Claims, timers, counters, and suppression reset; ownership recovery refreshes records; terminal cleans; missing retains; eligible workspace is reusable. |
| OBS-001 | Event schema | Every lifecycle and failure path emits required scoped fields without secrets, prompt bodies, whole environments, or unbounded content. |
| OBS-002 | Snapshot | One revision is internally consistent and reading it has no scheduler, tracker, tool, timer, approval, or reload side effect. |
| SEC-001 | Secret isolation | Sentinel tracker secrets never enter prompt, hooks, agent environment, tool payloads, logs, snapshots, or ownership metadata. |
| SEC-002 | Deployment posture | Run rejects placeholder approval/sandbox posture and documentation identifies privileges, network, filesystem, tools, redaction, and residual risk. |
| CLI-001 | Validate | Validate mode performs complete checks and no tracker mutation, workspace item change, hook, or agent launch. |
| CLI-002 | Lifecycle | Startup gates, first/second signals, bounded drain/cancel, process exit, workspace retention, final event, and exit classes are proven. |
| SCP-001 | Non-goals | Static and behavioral review confirms no distributed coordinator, persistent scheduler DB, provider workflow engine, built-in Git/PR policy, rich UI requirement, or mandatory VM/container. |

Optional real-integration suites MUST be separately named, explicitly enabled,
credential-scoped, and safe to skip. They do not replace deterministic core
conformance.

## 17. Definition of a conforming release

A release is conforming only when:

- its implementation documentation maps every logical component and managed
  choice to concrete code and deployment behavior;
- all deterministic matrix cases pass on every claimed supported platform;
- adapter-specific tests prove normalization and refresh semantics;
- security guidance describes actual rather than aspirational posture;
- observability schemas are versioned and usable without enabling a UI;
- optional tools are individually scoped and audited;
- known deviations are resolved rather than relabeled as provider behavior; and
- no claim of distributed coordination, durable retry, exactly-once execution,
  or complete sandboxing exceeds the evidence.
