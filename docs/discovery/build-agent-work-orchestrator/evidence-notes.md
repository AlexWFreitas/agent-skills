# Evidence and Synthesis Notes: Workcell

Status: `ready-for-handoff` · Last updated:
`2026-07-24T19:13:05-03:00`

## Purpose

This note preserves provenance for the synthetic Workcell contract. It is
authoritative for evidence classification, not for runtime behavior.
[technical-contract.md](technical-contract.md) is the detailed behavioral
authority and [task-definition.md](task-definition.md) is the primary handoff.

## Evidence classes

- **Verified** — directly inspected in the current repository during this
  discovery session.
- **User-confirmed** — supplied as governing synthetic product input for this
  controlled experiment. It is authoritative for the task but does not claim
  an existing implementation.
- **Inference** — added to make a confirmed requirement deterministic,
  testable, or internally coherent. It may be implemented differently only if
  the governing outcome and every observable conformance requirement remain
  satisfied.
- **Unresolved** — cannot safely be selected in a language-agnostic contract;
  the implementer must resolve it at a recorded gate without changing the
  normative behavior.

## Source register

| Source | Evidence class | Supported claim | Freshness or limitation |
| --- | --- | --- | --- |
| User-confirmed shared Workcell brief in the current conversation | User-confirmed | Product name, single-node boundary, normalized tracker model, polling/concurrency defaults, filesystem recovery, dynamic files, hooks, agent capabilities, retry/continuation, observability, security, deliverables, non-goals, and acceptance areas | Synthetic governing input; not evidence of an existing runtime |
| `skills/task-discovery/SKILL.md` | Verified | Discovery is documentation-only; primary handoff has six ordered sections; substantial detail may live in linked authoritative documents; closure requires readiness review, cold read, and snapshot | Inspected from the current checkout on 2026-07-24 |
| `skills/task-discovery/assets/task-definition-template.md` | Verified | Required primary handoff structure and navigation spine | Inspected from the current checkout on 2026-07-24 |
| `skills/task-discovery/assets/discovery-record-template.md` | Verified | Required current-state, canonical-trail, and linked-note structure | Inspected from the current checkout on 2026-07-24 |
| `skills/task-discovery/references/readiness-checklist.md` | Verified | Semantic closure and cold-read criteria | Inspected from the current checkout on 2026-07-24 |
| `skills/task-discovery/references/task-definition-example.md` and linked illustrative contract | Verified | A complex task may keep one readable definition and place specialist normative detail in a linked contract | Illustrative presentation only; no product behavior reused |
| Repository `AGENTS.md` and `README.md` | Verified | `docs/discovery/` owns approved definitions/evidence; do not implement, install, commit, push, publish, or test against real installations without authorization | Inspected from the current checkout on 2026-07-24 |
| OpenAI Symphony repository and `SPEC.md` | Context only | Desired comparison point is implementation-grade detail | Not inspected or used as behavioral evidence in this run; Workcell is original and must not copy its text or product design |

## Governing user-confirmed decisions

The following are treated as settled:

- Workcell is a single-node, long-running service with one authoritative
  instance and no distributed coordination.
- Core tracker operations are candidate listing and named-item refresh.
  Provider mutation is not embedded in the core.
- Optional agent-facing tracker mutations are host-mediated and scope-limited;
  tracker credentials never enter the child environment.
- Normalized work items include opaque identity, unique human key, content,
  priority, native state, labels, blockers, update time, optional branch hint,
  and adapter-derived dispatchability.
- Default polling is 20 seconds; default global concurrency is 8; optional
  per-state limits are positive; labels and state comparisons are
  case-insensitive; ordering is priority then oldest creation.
- Claims and retry timers are in memory. Recovery comes from tracker and
  filesystem state.
- Workspaces are deterministic children of a configured root, must resist
  traversal/reparse escapes, are reused for non-terminal work, and are cleaned
  through guarded hooks for terminal work.
- Repository-owned `ORCHESTRATOR.yaml` and `RUN_PROMPT.md` reload dynamically.
  Invalid input preserves the last-known-good generation and blocks only new
  dispatch.
- Hooks are `after_create`, `before_run`, `after_run`, and `before_remove`,
  default to 60-second timeouts, abort attempts on pre-run failure, and do not
  let post-run/cleanup-hook failure suppress required cleanup.
- The coding-agent integration is a local subprocess session adapter with
  start, turn, cancellation, timeout, progress, usage, terminal result, and
  unknown-tool failure semantics. Default maximum turns are 12.
- Transient retry starts at 5 seconds and caps at 180 seconds. A normal eligible
  continuation waits 2 seconds. Tracker state is refreshed before retry.
- Structured logs and a read-only runtime snapshot are required. HTTP or a
  dashboard is optional.
- All external and repository-derived inputs are untrusted. Approval/sandbox
  posture must be documented; tools and filesystem access are minimal.
- Rich UI, multi-tenancy, distributed scheduling, built-in provider workflows,
  built-in Git/PR policy, mandatory VM/container isolation, and a persistent
  scheduler database are excluded.
- This experiment creates documentation only.

## Contract-completion inferences

| Inference | Why it is needed | Observable consequence |
| --- | --- | --- |
| Add normalized `created_at`. | “Oldest creation time” cannot be implemented deterministically from `updated_at`. | Adapters must provide a valid creation timestamp; it participates in ordering. |
| Lower integer priority values sort before higher values; absent priority sorts last. | “By priority” needs a portable direction and null rule. | Fake adapters can prove a total dispatch order. |
| Use the opaque item `id` as claim identity and hash input. | Human keys can be renamed or collide by case/sanitization. | Local deduplication and workspace collision resistance do not depend on mutable display text alone. |
| Always append the first 16 lowercase hexadecimal characters of SHA-256 over UTF-8 item `id` to the sanitized key. | Conditional suffixing alone does not prevent case-insensitive or truncation collisions. | Workspace identity is stable and order-independent; implementations may use a stronger suffix but not a weaker collision guarantee. |
| Retry limit defaults to 3 transient retries. | The brief requires configurable retry limits but supplies no default. | Omitted configuration has deterministic bounded behavior. |
| Active workers capture an immutable valid input generation. | Live configuration edits cannot safely mutate a running subprocess contract mid-attempt. | Existing workers continue on their captured generation; new workers use the next valid generation. |
| A candidate input failure sets dispatch readiness false even while an older generation remains usable. | “Preserve last-known-good and block only new dispatch” requires separating runtime generation from dispatch readiness. | Snapshot and logs expose both active generation and invalid candidate status. |
| Retry counters reset on restart and processing is at-least-once. | There is no persistent scheduler database and retry timers are not restored. | Restart may redispatch an eligible item; the service must not claim exactly-once execution. |
| Hooks use an argument-vector form rather than shell text by default. | Shell parsing expands injection risk across platforms. | A shell is used only when explicitly configured and called out in security guidance. |
| Runtime snapshot acquisition is internally consistent and side-effect free. | “Read-only snapshot” otherwise permits torn or mutating reads. | A snapshot has one observation time/generation and cannot change scheduling state. |
| Conformance uses fake tracker, clock, filesystem boundary, hooks, subprocess, and signals. | Timing and external dependencies would make required evidence nondeterministic. | Core acceptance can run offline and repeatably; live tests are optional. |
| Retry exhaustion retains a process-local suppressed claim until the item changes or becomes ineligible. | Releasing an unchanged eligible item immediately would bypass the retry limit at the next poll. | Retry limits remain meaningful without adding durable scheduler storage. |
| Minimal filesystem ownership metadata records only identity and exact path. | Filesystem-driven restart cleanup cannot safely infer which directory belongs to which tracker item from a sanitized path alone. | Startup can refresh known item IDs and guard exact-child cleanup without persisting claims, timers, retries, or prompts. |

## Managed implementation choices

These remain deliberately unresolved because they do not need one portable
answer:

| Choice | Resolver and gate | Required invariant |
| --- | --- | --- |
| Implementation language and dependency framework | Implementation team before coding begins | Must support strict validation, safe subprocess trees, atomic state transitions, and deterministic tests. |
| YAML library and schema mechanism | Implementation team during configuration design | Must reject unsupported/unknown governing fields, produce actionable paths, and publish only complete valid generations. |
| Local subprocess framing (for example JSON Lines or length-prefixed messages) | Session-adapter implementer before integration | Must implement the logical request/event contract, ordering, correlation, size bounds, cancellation, and malformed-input behavior. |
| Filesystem primitives for canonicalization and reparse/symlink detection | Platform implementation owner before workspace operations | Must fail closed when containment cannot be proven and must never remove outside the exact owned child. |
| Snapshot presentation (in-process API, CLI, file, or HTTP) | Host implementer after snapshot model tests pass | Must remain read-only, access-controlled as appropriate, and presentation-neutral at the core. |
| Concrete sandbox technology | Deployment owner before enabling untrusted workloads | Approval mode, containment, network posture, credentials, and residual risk must be documented and enforced consistently. |
| Tracker provider adapters and optional mutation tools | Integration owner after core conformance | Must not weaken normalization, refresh-before-action, credential isolation, item scope, or auditability. |

## Limitations

- This is a synthetic contract; there is no current Workcell code, deployed
  service, issue tracker, agent executable, or production telemetry to verify.
- No external source was needed to settle product behavior. The external
  comparison target influenced requested depth only.
- Platform-specific filesystem and process-tree behavior must be proved by each
  supported implementation; static contract review cannot establish runtime
  safety.
- Optional real integrations require separate credentials, authority, and
  execution approval and are not part of this documentation run.
