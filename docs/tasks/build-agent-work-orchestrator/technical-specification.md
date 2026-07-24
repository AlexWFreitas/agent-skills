# Workcell Technical Specification

Status: `draft`  
Task contract: [`task-definition.md`](task-definition.md)  
Verification contract:
[`verification-and-conformance.md`](verification-and-conformance.md)

## 1. Purpose, authority, and conventions

This document defines the normative, language-independent behavior of
**Workcell**, a single-node service that dispatches eligible issue-tracker work
items to isolated coding-agent subprocesses.

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHOULD**, **SHOULD NOT**,
and **MAY** are normative. “Core” means provider-neutral Workcell behavior.
“Host” means the trusted Workcell process. “Child” means a coding-agent
subprocess. “Attempt” means one agent-session execution for one item. “Worker”
means the in-memory controller for a claimed item and may perform multiple
attempts or turns.

The task definition governs product scope. This specification governs detailed
behavior. An implementation conforms only when it satisfies every applicable
MUST/MUST NOT and the mandatory cases in the verification contract. An
implementation MAY choose its language, libraries, internal types, threading
model, and agent SDK if observable behavior remains equivalent.

### 1.1 Time and comparison rules

- Serialized timestamps MUST use RFC 3339 UTC with at least millisecond
  precision.
- Durations and delay calculations MUST use monotonic time within a process
  lifetime. Wall-clock changes MUST NOT make a timeout fire early or extend it.
- Unless a field states otherwise, duration configuration values are positive
  integer seconds.
- “Case-insensitive” means trim leading/trailing Unicode whitespace, normalize
  to Unicode NFC, then apply Unicode default case folding. Implementations MUST
  document their Unicode data version. Core conformance fixtures use characters
  whose case-folding is stable across supported versions.
- Opaque IDs MUST NOT be case-folded, parsed, reordered, or otherwise assigned
  provider-independent meaning.
- Stable ordering MUST use the explicit fields in this specification; map/hash
  iteration order MUST NOT affect behavior.

### 1.2 Trust model

Tracker fields, repository content, configuration text, prompt text, hook
output, agent messages, and tool arguments are untrusted data. Configuration
file ownership and the host deployment identity are administrative trust
boundaries, but trusted ownership does not make their content safe for shell or
path interpolation. A value being logged or shown in a snapshot does not grant
it authority.

## 2. System model

Workcell consists logically of:

1. **Generation loader** — reads, validates, and atomically publishes
   `ORCHESTRATOR.yaml` plus `RUN_PROMPT.md`.
2. **Tracker adapter** — fetches candidates and refreshes named items into the
   normalized model.
3. **Scheduler** — evaluates eligibility, orders candidates, applies global and
   per-state capacity, and owns local claims.
4. **Worker/reconciler** — controls attempts, turns, cancellation,
   continuation, retry, and terminal handling for one claimed item.
5. **Workspace manager** — derives and verifies paths, creates/reuses
   workspaces, invokes hooks, and performs guarded removal.
6. **Prompt renderer** — renders an immutable prompt for an attempt.
7. **Agent session adapter** — starts and supervises a local subprocess using
   the protocol in §9.
8. **Optional tool host** — mediates explicitly enabled, scope-limited tracker
   operations without exposing credentials.
9. **Observability store** — emits structured events and exposes immutable
   runtime snapshots.
10. **CLI/host lifecycle** — validates, starts, stops, and reports on the
    service.

One process is authoritative. Workcell MUST NOT claim safety for multiple
processes sharing a tracker scope or workspace root. Startup MUST fail when the
implementation can reliably detect another owner of the same local runtime
lock. The lock is a local operator safeguard, not a distributed lease.

Core tracker operations are read-oriented. Only the tracker adapter knows
provider-specific query and refresh mechanics. Optional agent-requested writes
MUST pass through the tool host and MUST NOT be called by scheduler business
logic.

## 3. Normalized domain model

### 3.1 Work item

Every candidate or refreshed item MUST normalize to:

| Field | Type | Rules |
| --- | --- | --- |
| `id` | opaque non-empty string | Provider identity; stable within tracker scope |
| `key` | non-empty string | Human identifier; unique within configured scope |
| `title` | string | May be empty; preserved as data |
| `description` | string or null | Plain or marked-up provider text; preserved as data |
| `priority` | signed integer | Lower numeric value dispatches first |
| `created_at` | RFC 3339 timestamp | Required to implement oldest-first ordering |
| `updated_at` | RFC 3339 timestamp | Provider update version signal |
| `native_state` | non-empty string | Provider state name; compared through §1.1 normalization |
| `labels` | ordered array of strings | Adapter MUST de-duplicate case-insensitively; stable lexical order after normalization |
| `blockers` | ordered array of opaque item references | Informational to core; provider-specific blocker semantics contribute to `dispatchable` |
| `branch_hint` | string or null | Untrusted hint; does not create Git policy |
| `dispatchable` | boolean | Adapter-derived provider eligibility |

The adapter MUST reject an item with an empty `id`, empty `key`, invalid
timestamp, duplicate `id` carrying conflicting content in one fetch, or a
non-integer priority. A rejected item MUST produce a structured normalization
error and MUST NOT enter scheduling.

### 3.2 Refresh result

Refreshing a named item returns exactly one tagged result:

- `present(item)` — a valid normalized item;
- `missing` — the provider says the item does not exist or is no longer
  visible;
- `transient_error(error)` — retryable provider/transport failure;
- `permanent_error(error)` — non-retryable adapter/configuration/auth failure.

`missing` MUST NOT be represented as a terminal item. A malformed provider
response is an error, not `missing`.

### 3.3 Attempt and worker identity

- `worker_id`: random process-unique identifier assigned when a claim is
  created.
- `attempt_number`: positive integer starting at 1 for a newly claimed worker
  and increasing for each new subprocess session.
- `turn_number`: positive integer scoped to a worker lifetime.
- `session_id`: non-empty value established by the agent adapter; before the
  adapter supplies one, Workcell uses a host-generated correlation ID.
- `generation_id`: SHA-256 digest of the exact validated configuration bytes,
  one `0x00` separator, and exact prompt-template bytes.

These identifiers MUST appear in logs/snapshots when available and MUST NOT
serve as authorization.

### 3.4 Eligibility

An item is eligible at an evaluation instant only if all are true:

1. `dispatchable` is true.
2. Normalized `native_state` is in configured `tracker.active_states`.
3. Normalized `native_state` is not in `tracker.terminal_states`.
4. Every configured `tracker.required_labels` value appears in normalized
   `labels`.
5. No in-memory claim exists for its opaque `id`.
6. Global and applicable per-state capacity are available.
7. Dispatch is not blocked by invalid configuration/prompt generation,
   shutdown, or a fatal host condition.

Core MUST NOT independently reinterpret `blockers`; the adapter accounts for
provider-specific blocker meaning in `dispatchable`.

## 4. Configuration contract

### 4.1 Location and parsing

The repository root MUST contain `ORCHESTRATOR.yaml` and `RUN_PROMPT.md`.
The CLI MAY accept an explicit repository path; otherwise it uses the current
directory. Paths inside configuration resolve relative to the repository root
unless explicitly stated otherwise. The workspace root MAY be absolute.

The YAML document MUST be a mapping. Unknown keys MUST fail validation.
Duplicate keys, aliases, anchors, custom tags, non-finite numbers, and implicit
type coercion MUST be rejected. Implementations MUST publish a documented
maximum file size and nesting depth and MUST reject inputs above them before
unbounded allocation. Environment-variable interpolation is not part of the
core format.

The normative shape is:

```yaml
version: 1
tracker:
  adapter: "implementation-defined-adapter-name"
  config: {}
  active_states: ["ready", "in progress"]
  terminal_states: ["done", "cancelled"]
  required_labels: []
polling:
  interval_seconds: 20
workspace:
  root: ".workcell"
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
  max_delay_seconds: 180
  continuation_delay_seconds: 2
agent:
  command: ["agent-adapter"]
  environment_allowlist: []
  startup_timeout_seconds: 30
  turn_timeout_seconds: 900
  idle_timeout_seconds: 120
  cancellation_grace_seconds: 10
  max_turns_per_worker: 12
  max_message_bytes: 1048576
observability:
  log_level: "info"
  snapshot_path: null
safety:
  allowed_tools: []
  tracker_tool_scopes: {}
  allow_shell_hooks: false
  deployment_posture_document: "WORKCELL-SECURITY.md"
```

### 4.2 Field rules

- `version` MUST equal integer `1`.
- `tracker.adapter` MUST be a non-empty registered adapter name.
- `tracker.config` is an adapter-owned mapping. It MUST NOT contain resolved
  secret values in the published runtime snapshot.
- `active_states` and `terminal_states` MUST be non-empty arrays after
  case-insensitive de-duplication and MUST be disjoint.
- `required_labels` MAY be empty and MUST be case-insensitively de-duplicated.
- `polling.interval_seconds` defaults to 20 and MUST be positive.
- `workspace.root` is required after defaults and MUST pass §8 root checks.
- Each hook is null or a hook object defined in §8.4.
- `workspace.hook_timeout_seconds` defaults to 60 and MUST be positive.
- `concurrency.global` defaults to 8 and MUST be positive.
- `concurrency.per_state` maps a configured active state name to a positive
  integer. Unknown/duplicate normalized states are invalid. Absence means no
  state-specific limit beyond global capacity.
- `max_transient_retries` defaults to 3 and MUST be a non-negative integer.
- Retry delays MUST be positive, `max_delay_seconds` MUST be at least
  `initial_delay_seconds`, and defaults are 5, 180, and 2 respectively.
- `agent.command` MUST be a non-empty argument array; its first element is the
  executable. A scalar shell command is invalid.
- `environment_allowlist` is an array of exact host environment-variable
  names. A tracker-secret variable MUST be rejected from this list.
- Agent timeouts and `max_message_bytes` MUST be positive.
- `max_turns_per_worker` defaults to 12 and MUST be positive.
- `log_level` is one of `trace`, `debug`, `info`, `warn`, or `error`.
- `snapshot_path` is null or a repository-relative/absolute output path. The
  required snapshot operation remains read-only even if a presentation writes
  an atomic snapshot file.
- `allowed_tools` and every tool-specific scope are explicit allowlists.
- `allow_shell_hooks` defaults to false. Enabling it requires the posture
  document to identify the shell and injection/authority implications.
- `deployment_posture_document` MUST resolve to a readable file before
  production-mode startup. Test mode MAY use a conformance fixture.

Adapters MAY define typed validation for `tracker.config`. Adapter validation
is part of the generation transaction.

### 4.3 Generation loading and reload

At startup the loader MUST:

1. read bounded bytes for both files;
2. parse YAML and template syntax;
3. validate core configuration, adapter configuration, paths, tools, and
   posture-document existence;
4. calculate `generation_id`;
5. publish one immutable generation; and
6. only then permit polling/dispatch.

Startup with no valid generation MUST fail before service run.

While running, Workcell MUST detect changes no later than the next poll
interval. A detected pair is validated as a unit. On success, the new immutable
generation is atomically published and new workers capture it. On failure:

- the last-known-good generation remains available to existing workers;
- no new item may be claimed or dispatched;
- active workers continue using their captured generation, except tracker
  refresh/reconciliation still occurs;
- the snapshot sets `configuration.dispatch_blocked=true`;
- a structured `configuration_reload_failed` event includes safe diagnostics;
- Workcell retries loading after a later file change and at least once per poll.

A valid subsequent generation clears the block. A byte-identical valid
generation MUST NOT create a duplicate reload event.

## 5. Prompt contract

`RUN_PROMPT.md` is a strict template. Allowed expressions are simple variable
references only:

- `item.id`, `item.key`, `item.title`, `item.description`,
  `item.priority`, `item.created_at`, `item.updated_at`,
  `item.native_state`, `item.labels`, `item.blockers`,
  `item.branch_hint`;
- `attempt.number`, `attempt.turn`, `attempt.worker_id`;
- `workspace.path`;
- `service.generation_id`.

No function calls, includes, dynamic property lookup, file reads, environment
lookups, code execution, or unbounded loops are permitted. Unknown variables,
invalid syntax, or output above the implementation's documented prompt-size
limit invalidate the generation.

Values MUST be inserted as data without interpretation as template syntax.
Arrays MUST render as deterministic JSON arrays. Null renders as an empty
string unless the template uses a whole-value position documented to render
`null`. The renderer MUST preserve the template's newline form consistently
within an implementation.

The rendered prompt is captured once per attempt and MUST NOT change after
agent start. Work-item content in a prompt grants no host, filesystem, tracker,
or tool authority.

## 6. Tracker adapter and optional tools

### 6.1 Adapter operations

An adapter MUST implement:

```text
validate_config(adapter_config) -> valid | configuration_error
fetch_candidates() -> candidate_batch | transient_error | permanent_error
refresh_item(opaque_id) -> present(item) | missing |
                           transient_error | permanent_error
describe_health() -> safe_health_record
```

`fetch_candidates` MAY use provider-native filtering but MUST normalize every
returned item. A candidate batch MUST be finite, and the adapter MUST document
pagination and maximum batch behavior. Core MUST tolerate the same item
appearing in later polls.

Provider authentication is acquired by the trusted host through an
implementation-defined secret provider. Resolved secrets MUST remain outside
configuration objects exposed to children, rendered prompts, workspaces, logs,
snapshots, exception text, and diagnostic tool results.

### 6.2 Error classification

A transient error is one for which repeating the same safe read can reasonably
succeed, such as timeout, connection reset, rate limit, or provider 5xx. A
permanent error includes invalid credentials, authorization denial,
unsupported response shape, or invalid adapter configuration. Adapters MUST
attach a stable error code and retry hint without copying secret-bearing raw
responses.

Candidate-fetch transient errors delay the next poll using the retry policy but
do not affect claimed workers. A permanent fetch error blocks new dispatch and
sets adapter health unhealthy; running workers continue reconciliation attempts
subject to their safety rules.

### 6.3 Optional host-mediated tracker tools

The host MAY register configured tools for comments, state changes, or handoff
links. Each tool has:

- a stable name and JSON-schema argument contract;
- an explicit provider operation;
- an allowed tracker scope;
- an allowed item target policy, normally the claimed item only;
- a timeout and result-size limit;
- audit/redaction rules; and
- idempotency behavior.

The host MUST validate the requested name, arguments, worker/item binding, and
scope before acquiring credentials. An unconfigured, malformed, out-of-scope,
or unauthorized call returns a structured tool error to the child. It MUST NOT
stall the session or invoke the provider. Core scheduler logic MUST NOT call
these tools to implement provider business workflow.

## 7. Scheduler and worker lifecycle

### 7.1 Poll cycle and dispatch order

When running and dispatch is allowed, a poll cycle:

1. obtains a candidate batch;
2. rejects invalid normalized items with diagnostics;
3. evaluates eligibility using the current generation;
4. removes already-claimed opaque IDs;
5. sorts remaining items by:
   1. ascending integer `priority`;
   2. ascending `created_at`;
   3. normalized `key` ascending;
   4. UTF-8 byte order of opaque `id`;
6. iterates in order, reserving global and normalized-state capacity
   atomically with claim insertion; and
7. starts one worker per successful reservation.

The scheduler MUST recompute available capacity after each reservation. Per-state
usage includes every claimed worker whose latest present item has that
normalized state. State change during reconciliation MUST atomically move the
worker's state accounting. If a move would exceed the new state's configured
limit, the existing worker continues; only new dispatch to that state is
blocked until usage falls below the limit.

### 7.2 Claim invariant

Claims are keyed by opaque item `id`. Claim insertion and capacity reservation
form one atomic host operation. Exactly one worker may own an ID in the
process. Every worker exit path MUST release capacity and claim in a `finally`
equivalent after required terminal handling is scheduled or completed.

Claims are not persisted. A process restart forgets all claims.

### 7.3 Worker states

Each worker is in exactly one state:

```text
claimed -> preparing -> running -> reconciling
                         |             |
                         v             v
                   cancelling      waiting
                         \             /
                          -> finalizing -> released
```

`waiting` has subtype `retry` or `continuation`. `finalizing` may perform
`after_run`, terminal cleanup, and evidence emission. Any state may move to
`released` after a missing item, fatal host condition, permanent error, or
shutdown, subject to cleanup rules.

### 7.4 Attempt sequence

For an eligible claimed item, the worker MUST:

1. capture the current immutable generation;
2. resolve and verify its workspace;
3. create it if absent and establish ownership metadata;
4. run `after_create` only after a new workspace is safely created;
5. run `before_run`;
6. render the attempt prompt;
7. start and supervise an agent session;
8. run `after_run` after every started attempt, regardless of terminal result;
9. refresh the item; and
10. apply §10 reconciliation.

If `after_create` or `before_run` fails, no agent session starts and the failure
is classified for retry. If prompt rendering fails despite a validated
generation, it is a permanent implementation/configuration failure.

### 7.5 Periodic reconciliation

While an agent is running, Workcell MUST refresh the item at least once per
poll interval. It MUST also refresh immediately after an attempt and before a
retry or continuation begins. Only one refresh per worker may be in flight.

If a running refresh says:

- **present and eligible** — update latest tracker facts and continue;
- **present and ineligible non-terminal** — request cancellation;
- **present and terminal** — request cancellation and mark terminal cleanup
  required;
- **missing** — request cancellation, release after the child stops, and do not
  clean the workspace;
- **transient error** — retain the worker and retry refresh; do not infer
  eligibility;
- **permanent error** — cancel safely, preserve workspace unless latest known
  state was terminal, expose blocker, and release.

## 8. Workspace and hooks

### 8.1 Deterministic workspace path

Let `K` be the exact Unicode work-item key:

1. Normalize `K` to NFC for the readable portion only.
2. For each Unicode scalar, retain ASCII letters, digits, `.`, `_`, and `-`;
   replace every other scalar with `_`.
3. Collapse consecutive `_`.
4. Remove leading/trailing dots, spaces, and underscores.
5. If empty, use `item`.
6. If the result case-insensitively equals a Windows reserved device name
   (`CON`, `PRN`, `AUX`, `NUL`, `COM1`-`COM9`, or `LPT1`-`LPT9`), prefix `item-`.
7. Truncate the readable UTF-8 representation without splitting a scalar so it
   is at most 80 bytes.
8. Compute lowercase hexadecimal SHA-256 over the exact UTF-8 bytes of original
   `K`; take the first 12 hex characters.
9. The workspace leaf is `<readable>--<hash12>`.

The stable suffix is always present. This satisfies the requirement to add a
suffix whenever sanitization changes a key and also prevents case-only,
normalization, truncation, and reserved-name collisions.

### 8.2 Ownership metadata

Every Workcell-created directory MUST contain host-owned metadata outside
agent-writable scope if the platform permits, otherwise an atomically written
`.workcell-owner.json` containing:

- schema version;
- exact opaque item ID;
- exact item key;
- workspace leaf;
- creation timestamp;
- repository identity; and
- a random ownership nonce retained by the host.

Before reuse or removal, Workcell MUST verify metadata against the claimed
item, configured root, and expected leaf. Missing/conflicting metadata makes
the workspace foreign: dispatch and cleanup fail closed.

### 8.3 Root containment and guarded operations

At validation and before every create/reuse/remove:

1. resolve the configured root to an absolute canonical path;
2. require the root to be an existing directory owned/approved by deployment
   policy;
3. reject the root if it or any traversed component is a symlink, junction,
   mount-point escape, or reparse object not explicitly proven non-traversing;
4. join exactly one derived leaf, never an item-supplied path;
5. verify the candidate is a strict descendant of root under platform path
   comparison;
6. inspect each existing component using no-follow semantics; and
7. open/create/delete using race-resistant directory handles when supported.

Unsupported containment primitives MUST cause validation failure. Workcell MUST
NOT remove the workspace root, repository root, a parent/sibling, a foreign
directory, or any path whose ownership verification changed between check and
operation.

`branch_hint` is data passed to configured hooks or prompts. It MUST NOT affect
the workspace path.

### 8.4 Hook contract

A hook is null or:

```yaml
command: ["executable", "literal-arg"]
timeout_seconds: 60
environment:
  NAME: "literal-value"
```

`command` MUST be a non-empty argument array. Workcell MUST invoke it without a
shell when `allow_shell_hooks=false`. No item field may be interpolated into an
executable or argument by implicit syntax. If a deployment enables shell
hooks, it must explicitly name the shell in `command` and document the risk.

Hooks run with the workspace as working directory and a minimal environment.
The host MAY provide non-secret context through documented `WORKCELL_*`
variables, including item key, opaque correlation ID, attempt number, hook
name, and workspace path. Tracker credentials are forbidden.

Order and failure behavior:

| Hook | When | Failure behavior |
| --- | --- | --- |
| `after_create` | Once after safe first creation and ownership record | Abort attempt; classify failure; retain workspace |
| `before_run` | Before every attempt, after `after_create` when applicable | Abort attempt; classify failure; retain workspace |
| `after_run` | After every started agent attempt, including cancel/timeout | Log failure and continue reconciliation/required cleanup |
| `before_remove` | Immediately before guarded terminal removal | Log failure and continue required guarded removal |

Default timeout is 60 seconds. Timeout terminates the hook process tree where
supported and is a failure. Output is bounded, decoded safely, redacted, and
attached to structured diagnostics; it MUST NOT be executed or parsed as
authority.

### 8.5 Reuse and cleanup

A verified workspace is reused for non-terminal eligible work. A terminal
refresh requires, after any running child has stopped:

1. invoke `before_remove`;
2. revalidate containment and ownership;
3. remove only the owned leaf without following links; and
4. record success or a cleanup blocker.

Cleanup failure MUST be visible and retried by a guarded cleanup task while the
service runs, but MUST NOT restore item eligibility. A missing refresh MUST
release the claim and MUST NOT invoke `before_remove` or delete the workspace.

## 9. Agent subprocess protocol

### 9.1 Transport and framing

The normative transport is a local subprocess with:

- host-to-child messages on standard input;
- child-to-host messages on standard output;
- diagnostics on standard error;
- one UTF-8 JSON object per line;
- maximum encoded line size `agent.max_message_bytes`;
- no byte-order mark; and
- protocol version `1`.

The host MUST pass only an allowlisted environment plus minimal process
essentials. It MUST explicitly remove tracker credentials and other configured
secret names. The workspace is the child working directory.

Malformed JSON, invalid UTF-8, oversized messages, schema-invalid messages, a
second terminal result, or output after terminal result is a protocol error.
Standard-error text is bounded diagnostic data, not a protocol channel.

Every message contains:

```json
{
  "protocol_version": 1,
  "type": "message_type",
  "message_id": "host-or-child-unique-id",
  "session_id": "known-session-id-or-null",
  "timestamp": "2026-07-24T22:00:00.000Z",
  "payload": {}
}
```

Unknown fields MAY be ignored for forward compatibility. Unknown message
`type` values are protocol errors unless a later negotiated protocol version
defines them.

### 9.2 Host requests

| Type | Required payload | Meaning |
| --- | --- | --- |
| `start` | `worker_id`, `attempt_number`, `workspace`, `generation_id`, `capabilities`, `limits` | Begin session and negotiate registered tools |
| `turn` | `turn_number`, `prompt` | Request one agent turn |
| `tool_result` | `call_id`, `ok`, `result` or structured `error` | Resolve exactly one tool call |
| `cancel` | `reason`, `grace_seconds` | Request cooperative stop |
| `shutdown` | `reason` | End adapter after terminal exchange |

The first request MUST be `start`. The host waits for `session_started` within
`startup_timeout_seconds`, then sends the first `turn`. It MUST NOT have more
than one unresolved `turn` per session. A tool call pauses the turn timeout only
if the configured tool contract explicitly permits that; idle timeout still
applies.

### 9.3 Child events

| Type | Required payload | Meaning |
| --- | --- | --- |
| `session_started` | `session_id`, `adapter`, `capabilities` | Handshake complete |
| `progress` | `stage`, `message`, optional `percent` | Structured non-terminal progress |
| `usage` | non-negative counters and units | Cumulative or delta usage, explicitly labeled |
| `tool_call` | `call_id`, `name`, `arguments` | Request one registered host tool |
| `turn_completed` | `turn_number`, `continue` | Turn ended without final session result |
| `result` | `status`, `summary`, optional `artifacts` | Exactly one terminal success/cancelled result |
| `error` | `code`, `message`, `transient` | Exactly one terminal error |
| `heartbeat` | optional status fields | Liveness without progress semantics |

`status` is `succeeded` or `cancelled`. Artifact paths are untrusted references
and MUST be contained before host access.

Progress messages MUST NOT reset the maximum turn count. Heartbeats and valid
events reset idle timeout but not turn timeout. Usage values MUST be
non-negative; malformed usage is ignored with a protocol diagnostic unless it
makes message framing invalid.

### 9.4 Turns and terminal behavior

The worker starts with `turn_number=1`. After `turn_completed`:

- if `continue=false`, the host requests no more turns and expects a terminal
  `result` or `error`;
- if `continue=true` and the max is not reached, the host may render/send the
  next turn prompt using current attempt context;
- if the configured maximum (default 12) is reached, the host sends `cancel`
  with reason `max_turns_exceeded`.

The session terminates on one `result`, one `error`, protocol error, timeout,
process exit, or forced cancellation. Normal process exit without a terminal
message is a transient `agent_process_exited` error unless the adapter
explicitly classifies the exit code as permanent.

### 9.5 Tool calls and unknown tools

For each `tool_call`, the host MUST:

1. validate unique `call_id`, name, JSON arguments, worker binding, and scope;
2. reject unknown/unallowed calls immediately with
   `tool_result.ok=false`, code `unknown_tool` or `tool_not_allowed`;
3. invoke allowed tools with host-held credentials and bounded timeout/output;
4. redact secrets; and
5. return exactly one `tool_result`.

An unknown tool call MUST NOT terminate or stall the session by itself. Repeated
invalid calls MAY trigger cancellation under a documented abuse limit.

### 9.6 Timeout and cancellation

- Startup timeout covers process start through valid `session_started`.
- Turn timeout covers `turn` through `turn_completed` or terminal message.
- Idle timeout covers time since any valid child message.
- Cancellation grace covers `cancel` through terminal message/process exit.

On timeout or reconciliation cancellation, send `cancel` once, wait the grace
duration, then terminate the process tree. If termination fails, record a fatal
worker blocker and do not release filesystem resources that the process may
still use. Shutdown follows the same sequence.

## 10. Retry, continuation, reconciliation, and recovery

### 10.1 Failure classes

- **Transient:** retry may succeed without contract/configuration change:
  network timeout, rate limit, temporary provider/agent unavailability,
  subprocess crash, or hook exit explicitly classified transient.
- **Permanent:** retry cannot safely repair: invalid config/protocol version,
  auth denial, containment/ownership violation, template invariant failure, or
  explicitly permanent adapter error.
- **Normal eligible completion:** agent result is `succeeded`, but refreshed
  item remains eligible.
- **Ineligible/terminal/missing:** tracker fact controls release and cleanup as
  specified below.

Implementations MUST expose stable error codes and MUST NOT classify security
violations as transient.

### 10.2 Exponential retry

For zero-based retry index `i`, delay is:

```text
min(max_delay_seconds, initial_delay_seconds * 2^i)
```

Defaults yield 5, 10, 20, 40, 80, 160, 180 seconds. The first attempt is not a
retry. `max_transient_retries=3` permits at most three delayed retries after the
initial failed attempt. Integer overflow MUST saturate at the maximum.

Retry timers are in memory and use monotonic time. Immediately before starting
a retry, the worker MUST refresh the item. The retry proceeds only if present
and eligible. Terminal, ineligible, missing, and refresh-error behavior follows
§10.4. No jitter is applied in core conformance; an implementation MAY add
documented jitter only as an opt-in extension disabled in conformance mode.

### 10.3 Continuation

After a normal successful attempt, refresh the item. If it remains eligible and
the worker has not exhausted `max_turns_per_worker`, schedule a continuation
after exactly `continuation_delay_seconds` (default 2). Refresh again before the
continuation. A continuation is not a transient retry and does not increment
the transient-retry counter, but it does increment attempt/turn accounting as
defined by the adapter lifecycle.

If max turns are exhausted while the item remains eligible, release the claim
with a visible `worker_turn_limit_reached` result; do not create an unbounded
new worker in the same poll cycle. A later poll may reclaim the still-eligible
item, starting a new worker lifetime.

### 10.4 Post-attempt decision table

| Refresh result | Latest item status | Action |
| --- | --- | --- |
| `present` | terminal | Stop child, run post-run if applicable, guarded cleanup, release |
| `present` | ineligible non-terminal | Stop child, preserve workspace, release |
| `present` | eligible; attempt succeeded | Schedule 2-second continuation within turn limit |
| `present` | eligible; transient attempt failure | Schedule exponential retry within retry limit |
| `present` | eligible; permanent attempt failure | Preserve workspace, record blocker/error, release |
| `missing` | any prior state | Stop child, preserve workspace, release |
| `transient_error` | after attempt | Retry refresh with bounded delay while retaining claim; do not start agent |
| `permanent_error` | after attempt | Preserve workspace unless terminal was already confirmed; record blocker, release |

Once a terminal item is confirmed, cleanup intent persists in memory even if a
subsequent refresh is unavailable. Within one process, a later missing response
MUST NOT cancel already-confirmed cleanup.

### 10.5 Restart recovery

On restart:

- no claims, workers, retry timers, continuation timers, sessions, or turn
  counts are restored;
- configuration and root are revalidated;
- orphan child processes are handled according to deployment-specific process
  ownership policy before dispatch;
- before normal dispatch, Workcell enumerates only immediate workspace-root
  children without following links, validates ownership metadata, and refreshes
  each recorded opaque item ID;
- a `present` non-terminal workspace is preserved for later candidate dispatch;
  a `present` terminal workspace receives guarded cleanup; `missing` or
  refresh-error workspaces are preserved and reported;
- an unresolved recovery entry temporarily blocks dispatch of the same opaque
  item ID, preventing a recovery/dispatch race;
- after the bounded recovery scan, candidate polling rediscovers eligible
  items and a verified non-terminal workspace is reused;
- unreferenced workspaces are not deleted automatically merely because no item
  appears in one fetch.

Workcell MAY run an operator-invoked read-only orphan audit. Automated orphan
deletion requires a separately specified retention/authority policy and is not
core behavior.

## 11. Observability contract

### 11.1 Structured events

Each log event MUST be one structured record with:

- `timestamp`, `level`, `event`, `service_instance_id`, `generation_id`;
- `item_id`, `item_key`, `worker_id`, `attempt_number`, `turn_number`,
  `workspace`, and `session_id` when applicable;
- `duration_ms` when an operation completes;
- `error.code`, `error.class`, `error.message`, and safe causal context on
  failure; and
- event-specific fields.

Required event families include configuration load/reload, tracker poll/refresh,
claim acquire/release, capacity decision, workspace create/reuse/remove, hook
start/result, agent start/event/result, tool call/result, retry/continuation
schedule/fire, reconciliation decision, cancellation, shutdown, and blocker
transition.

Logs MUST redact configured secrets and credential-like adapter fields before
serialization. Raw prompts, descriptions, hook output, tool arguments, and
repository contents MUST NOT be logged by default. Debug exposure requires an
explicit documented posture and still may not expose secrets.

### 11.2 Aggregate metrics

At minimum, Workcell tracks process-lifetime:

- poll count/errors and refresh count/errors;
- claims acquired/released;
- active workers and capacity by normalized state;
- attempts and terminal results by class;
- retry and continuation counts;
- hook duration/failures by hook;
- agent run duration;
- workspace create/reuse/remove/failure counts; and
- agent usage totals grouped by unit when supplied.

Unknown usage units MUST be retained separately, not converted or silently
combined. Counter overflow behavior MUST be safe and documented.

### 11.3 Read-only runtime snapshot

The snapshot is one immutable observation with schema version and capture time:

```json
{
  "schema_version": 1,
  "service": {
    "instance_id": "...",
    "state": "running",
    "started_at": "...",
    "generation_id": "..."
  },
  "configuration": {
    "healthy": true,
    "dispatch_blocked": false,
    "last_reload_error": null
  },
  "tracker": {"healthy": true, "last_poll_at": "..."},
  "scheduler": {
    "global_limit": 8,
    "active": 1,
    "per_state": {},
    "claims": []
  },
  "workers": [],
  "timers": [],
  "metrics": {},
  "blockers": []
}
```

Claim and worker entries carry required correlation fields and state, but no
raw prompt, tracker description, credentials, hook output, or unrestricted tool
arguments. Reading the snapshot MUST NOT poll, refresh, cancel, retry, reload,
or otherwise mutate runtime state. Implementations MUST make a consistent copy
without holding scheduler locks during slow presentation.

HTTP/dashboard exposure is optional. If exposed, authentication, network
binding, and data classification are deployment concerns documented in the
posture file.

## 12. Security and deployment requirements

### 12.1 Credential isolation

- Tracker credentials remain in a host secret provider.
- Child environments are constructed from an allowlist, not inherited then
  redacted.
- Configuration snapshots expose secret references or redacted markers, never
  resolved values.
- Credentials MUST NOT be written to workspace files, prompt text, logs,
  metrics labels, snapshots, exception messages, or agent tool responses.
- Tool calls acquire credentials only after scope validation and discard
  request-local handles after use.

### 12.2 Filesystem and process authority

The deployment posture document MUST identify:

- host operating identity and repository/workspace permissions;
- whether and how child processes are sandboxed;
- network access available to host, hooks, and child;
- approval policy for agent tool use;
- configured host tools and tracker scopes;
- hook trust and shell posture;
- process-tree termination guarantees and limitations;
- secret provider and redaction strategy; and
- residual risks accepted by the deployment owner.

Conformance does not mandate a container or VM, but the document MUST not imply
isolation stronger than deployment provides. Workcell SHOULD run with the
minimum permissions needed for the configured root, repository, adapter, and
tools.

### 12.3 Untrusted content

Tracker/repository/prompt content MUST NOT:

- become a filesystem path except through the specified key algorithm;
- select an executable or add shell syntax;
- grant a tool or broaden tool scope;
- change configuration;
- bypass turn, timeout, output, or concurrency limits; or
- be rendered into an HTML/terminal context without presentation escaping.

Agent-supplied artifact paths MUST pass the same root-containment principles
before host access. Symbolic links created by an agent do not grant access
outside the workspace.

## 13. CLI and host lifecycle

The implementation MUST provide behavior equivalent to:

```text
workcell validate [--repository PATH]
workcell run [--repository PATH]
workcell snapshot [--repository PATH]
```

Names MAY adapt to platform packaging, but documentation and conformance
fixtures MUST map them unambiguously.

### 13.1 Validate

`validate` reads and validates configuration, prompt, adapter settings,
workspace root, command shape, and posture-document presence without polling,
creating a workspace, invoking hooks, or starting an agent. Exit `0` means
valid; exit `2` means validation failure; exit `1` means host/internal failure.
Diagnostics are structured or machine-readable on request and secret-safe.

### 13.2 Run

`run` validates before acquiring the local runtime lock and before polling.
Lifecycle states are:

```text
starting -> running -> draining -> stopped
             |
             -> blocked (dispatch stopped; reconciliation may continue)
```

On the first termination signal, Workcell:

1. enters `draining`;
2. stops new polls/claims and cancels pending retry/continuation timers;
3. requests cancellation for running children;
4. waits configured cancellation grace plus bounded finalization time;
5. performs only already-required terminal cleanup that remains safe; and
6. releases claims, lock, and process resources.

A second termination signal MAY force process-tree termination but MUST NOT
perform unverified filesystem deletion. Normal operator shutdown exits `0`;
startup/validation failure exits `2`; unrecovered host or cleanup-safety failure
exits `1`. Agent attempt failure alone does not require service exit.

### 13.3 Snapshot

`snapshot` reads an implementation-defined local read-only presentation of the
running instance or a configured atomic snapshot file. It MUST NOT start a new
service or mutate it. Absence of a running/readable snapshot exits nonzero with
a clear diagnostic.

## 14. Extension and compatibility rules

Implementations MAY add adapters, optional tracker tools, HTTP/dashboard
presentations, sandbox integrations, metrics exporters, and extra structured
fields if:

- defaults preserve core behavior;
- unknown optional fields do not change required semantics;
- extensions are namespaced or versioned;
- conformance mode disables timing jitter and live dependencies;
- no extension weakens a MUST/MUST NOT; and
- documentation distinguishes core conformance from extension behavior.

Built-in provider business workflow, Git/PR policy, distributed coordination,
multi-tenancy, and persistent scheduler state require an amended task contract;
they are not extensions to infer under this specification.
