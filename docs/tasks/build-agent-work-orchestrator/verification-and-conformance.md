# Workcell Verification and Conformance Contract

Status: `draft`  
Task contract: [`task-definition.md`](task-definition.md)  
Technical authority:
[`technical-specification.md`](technical-specification.md)

## 1. Conformance model

An implementation is **core conformant** only when every mandatory case in this
document passes against the same build and a generated evidence report maps
each case to its task requirement and acceptance criterion. Optional live
integration tests do not compensate for a failed or missing mandatory case.

The core suite MUST:

- run without network access, live tracker credentials, a real coding-agent
  account, or wall-clock sleeps;
- use a fake tracker adapter, controllable monotonic/wall clock, fake agent
  subprocess, isolated temporary repository/workspace roots, and inspectable
  process/hook harness;
- run with timing jitter disabled and deterministic IDs where assertions need
  stable output;
- test supported filesystem link/reparse behavior on each claimed platform;
- preserve test artifacts only on explicit test-runner request;
- redact fixture secrets from stdout, stderr, logs, reports, and snapshots; and
- report `pass`, `fail`, or `not-supported` with evidence. `not-supported` is a
  failure for a mandatory feature on a claimed platform.

Timing assertions against a fake clock are exact. Where a platform process
boundary forces real timing, the suite MAY use a documented tolerance of the
greater of 100 ms or 5% of the configured duration, but MUST NOT weaken order
or upper-bound assertions.

## 2. Evidence record

Each case produces:

```json
{
  "case_id": "VC-CFG-01",
  "state": "pass",
  "implementation": {
    "name": "implementation-name",
    "version": "build-identity",
    "platform": "platform-identity"
  },
  "started_at": "RFC3339 UTC",
  "duration_ms": 12,
  "requirements": ["R03"],
  "acceptance": ["A01"],
  "evidence": ["safe artifact or assertion reference"],
  "limitations": []
}
```

The aggregate report MUST identify configuration, protocol, and snapshot schema
versions; list all mandatory case IDs exactly once; and fail if an expected ID
is absent, duplicated, skipped, or unsupported.

## 3. Configuration and prompt — A01

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-CFG-01 | R03, R09, R20, R25 | Load the minimum valid generation | Defaults are poll 20, global 8, hook timeout 60, retries 3/5/180, continuation 2, max turns 12, and all other S02 defaults |
| VC-CFG-02 | R03 | Exercise wrong version, unknown/duplicate key, alias/tag, coercion, invalid type, non-positive limit, overlapping states, unknown per-state key, and malformed adapter config | Each fails validation with stable safe diagnostics and no polling/mutation |
| VC-CFG-03 | R10 | Supply duplicate labels/states with case and surrounding-whitespace differences | Values normalize/de-duplicate; active and terminal collision fails |
| VC-CFG-04 | R04 | Replace valid config and prompt with another valid pair | One atomic generation publishes; new workers capture it; existing worker keeps its captured generation |
| VC-CFG-05 | R04 | Change one/both files to invalid content during an active run | Last-known-good remains; existing worker continues; new dispatch is blocked; safe failure event/snapshot appears |
| VC-CFG-06 | R04 | Repair invalid files, then present a byte-identical generation | Valid repair clears dispatch block; byte-identical reload emits no duplicate generation event |
| VC-CFG-07 | R22 | Render every allowed variable including arrays, null, markup, and template-like item text | Deterministic data rendering occurs; inserted template syntax is not reevaluated |
| VC-CFG-08 | R22 | Use an unknown variable, function/include, invalid syntax, or oversized output | Generation is invalid and no attempt starts |
| VC-CFG-09 | R08 | Put known fixture secret references in adapter config and resolved secret in host provider | Published generation/snapshot/logs contain reference/redaction only, never resolved value |

## 4. Tracker normalization and boundary — A02

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-TRK-01 | R05-R06 | Normalize a complete valid provider item | Every required field, including `created_at`, is preserved with correct portable type |
| VC-TRK-02 | R06 | Supply empty ID/key, invalid timestamps/priority, or conflicting duplicate ID | Item is rejected, normalization event emitted, scheduler never sees it |
| VC-TRK-03 | R10 | Vary state/label case, NFC form, and surrounding whitespace | Eligibility comparisons follow S02 §1.1 |
| VC-TRK-04 | R05, R14 | Return `present`, `missing`, transient error, and permanent error from refresh | Core preserves all four tags and never treats malformed/error as missing |
| VC-TRK-05 | R06 | Supply blockers while toggling adapter-derived `dispatchable` | Core treats blockers as data and uses `dispatchable`; it does not invent provider semantics |
| VC-TRK-06 | R07 | Run scheduler with no optional tools configured | No provider write operation is reachable from core orchestration |
| VC-TRK-07 | R07-R08 | Register one scope-limited fake tracker tool and request allowed/out-of-scope operations | Allowed request uses host credential; denied request never reaches provider; credential never reaches child |
| VC-TRK-08 | R05 | Repeat candidates across pages and polls | One normalized candidate per opaque ID participates in each poll; existing claim prevents duplicate worker |

## 5. Workspace identity, containment, and cleanup — A03/A04

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-WSP-01 | R17 | Derive path twice for the same ASCII key | Exact same `<readable>--<hash12>` leaf under root |
| VC-WSP-02 | R17 | Use keys differing only by case, Unicode normalization, punctuation, whitespace, or characters replaced with `_` | Every distinct exact key has a distinct stable hash suffix and no alias |
| VC-WSP-03 | R17 | Use empty-after-sanitize, Windows reserved name, and >80-byte readable key | `item`/reserved handling/truncation conforms and suffix remains correct |
| VC-WSP-04 | R17 | Verify SHA-256 suffix against exact original UTF-8 key bytes | First 12 lowercase hex characters match |
| VC-WSP-05 | R19 | Reclaim a non-terminal item with matching ownership metadata | Existing workspace is reused; `after_create` is not rerun |
| VC-WSP-06 | R19 | Encounter absent/conflicting ownership metadata | Directory is treated as foreign; no agent or cleanup action occurs |
| VC-WSP-07 | R19 | Confirm terminal item with an owned workspace | Guarded `before_remove` and removal run after child stop |
| VC-WSP-08 | R18 | Configure root/candidate using `..`, rooted key content, alternate separator, or prefix confusion | Candidate remains derived from one leaf or validation fails; no escape |
| VC-WSP-09 | R18 | Place symlink/junction/reparse component at root, leaf, or child targeted during removal | Operation fails closed and outside target is unchanged |
| VC-WSP-10 | R18 | Swap a verified directory for a link between validation and operation | Race-resistant operation refuses or remains bound to verified directory |
| VC-WSP-11 | R18-R19 | Attempt to remove root, repository root, parent, sibling, or foreign leaf | Removal is rejected in every case |
| VC-WSP-12 | R14, R19 | Refresh returns missing for an owned workspace | Claim releases; `before_remove` and removal do not occur |
| VC-WSP-13 | R18 | Run on a platform lacking required no-follow/reparse inspection | Startup validation fails; implementation does not claim containment |
| VC-WSP-14 | R19 | Terminal cleanup fails transiently | Failure is observable and guarded cleanup is retried without redispatching terminal item |
| VC-WSP-15 | R18, R30 | Agent creates a link to an outside artifact and reports it | Host refuses to access the outside target |

## 6. Hook lifecycle — A05

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-HOOK-01 | R20-R21 | Create new workspace and complete attempt | Order is `after_create`, `before_run`, agent, `after_run`; terminal adds `before_remove` then cleanup |
| VC-HOOK-02 | R21 | `after_create` exits nonzero | Attempt aborts before agent; workspace remains; failure is classified/logged |
| VC-HOOK-03 | R21 | `before_run` exits nonzero on reused workspace | Attempt aborts before agent; workspace remains; failure is classified/logged |
| VC-HOOK-04 | R21 | `after_run` fails/times out and item is terminal | Failure is logged; `before_remove` and required cleanup still occur |
| VC-HOOK-05 | R21 | `before_remove` fails/times out | Failure is logged; guarded removal still occurs |
| VC-HOOK-06 | R20, R30 | Put shell metacharacters/template syntax in item fields | Argument array is unchanged; no implicit shell/interpolation occurs |
| VC-HOOK-07 | R08, R20 | Inspect hook environment with fixture tracker secret | Minimal context is present; tracker secret is absent |
| VC-HOOK-08 | R20 | Advance fake clock past default/configured timeout | Hook process tree is terminated where supported and timeout is observable |

## 7. Dispatch, concurrency, and claims — A06

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-SCH-01 | R09-R11 | Supply mixed priority/creation/key/ID candidates | Dispatch follows priority, oldest creation, normalized key, then opaque-ID byte order |
| VC-SCH-02 | R09 | Supply more than 8 eligible items under defaults | Exactly 8 claims/workers maximum |
| VC-SCH-03 | R09 | Configure global and positive per-state limits | Neither global nor state usage is exceeded by new dispatch |
| VC-SCH-04 | R09 | Configure zero/negative per-state limit | Configuration validation fails |
| VC-SCH-05 | R10 | Omit required label or use inactive/terminal state | Item is not claimed; equivalent case forms are recognized |
| VC-SCH-06 | R12 | Return same opaque ID twice/concurrently | Atomic claim/capacity reservation creates one worker |
| VC-SCH-07 | R12 | Complete, cancel, fail, or lose item along every worker exit path | Claim and capacity release exactly once |
| VC-SCH-08 | R09 | Running item changes to a state whose limit is already full | Existing worker continues/accounting moves; new dispatch to that state waits |
| VC-SCH-09 | R04 | Configuration becomes invalid with free capacity | No new claims occur; existing claimed worker remains controlled |

## 8. Reconciliation and cancellation — A07

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-REC-01 | R14 | Running refresh remains eligible | Worker continues; latest facts/snapshot update |
| VC-REC-02 | R14 | Running refresh becomes non-terminal ineligible | One cancel is sent; workspace is preserved; claim releases after child stop |
| VC-REC-03 | R14, R19 | Running refresh becomes terminal | Cancel, post-run finalization, guarded cleanup, and release occur in order |
| VC-REC-04 | R14 | Running refresh is missing | Cancel and release occur; workspace is preserved; no cleanup hook |
| VC-REC-05 | R14 | Running refresh has transient error | Worker is retained; eligibility is not inferred; refresh retries |
| VC-REC-06 | R14 | Running refresh has permanent error | Child cancels, blocker is visible, workspace preserved absent prior terminal confirmation, claim releases |
| VC-REC-07 | R14 | Poll interval elapses repeatedly during a long run | At most one refresh is in flight and refresh occurs at least once per interval |
| VC-REC-08 | R14 | Terminal confirmed, then refresh becomes missing/error before cleanup | Confirmed cleanup intent remains and guarded cleanup proceeds |

## 9. Retry, continuation, and restart — A08/A09

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-RTY-01 | R15 | Advance fake clock through repeated transient failures | Delays are 5, 10, 20, then capped sequence per configuration |
| VC-RTY-02 | R15 | Configure three transient retries and fail four attempts | Initial plus three retries occur; fourth failure releases with visible exhaustion |
| VC-RTY-03 | R15 | Fire retry timer | Refresh occurs immediately before agent start |
| VC-RTY-04 | R15 | Pre-retry refresh becomes terminal/ineligible/missing | No retry starts; decision table and cleanup rules apply |
| VC-RTY-05 | R16 | Successful attempt leaves item eligible | Continuation timer is exactly 2 seconds by default; refresh precedes continuation |
| VC-RTY-06 | R15-R16 | Mix transient retries and normal continuations | Retry counter increments only for transient retries; all attempts respect worker turn bound |
| VC-RTY-07 | R25 | Exhaust worker turns while item remains eligible | Worker releases visibly; no same-cycle unbounded worker recreation |
| VC-RTY-08 | R15 | Use huge retry index/configuration | Delay arithmetic saturates safely at configured maximum |
| VC-RST-01 | R13 | Restart with active claim, retry, and continuation in memory | None are restored |
| VC-RST-02 | R13, R19 | Restart with eligible tracker item and matching non-terminal workspace | Recovery refresh preserves it; poll rediscovers item and safely reuses workspace |
| VC-RST-03 | R13, R19 | Restart with terminal tracker item and owned workspace | Ownership scan plus named refresh rediscovers and performs guarded cleanup before normal dispatch |
| VC-RST-04 | R13 | Restart with owned workspace whose refresh is missing/error and item is omitted from one fetch | Workspace is preserved/reported and not automatically deleted |
| VC-RST-05 | R13 | Simulate orphan child process under documented ownership policy | Host resolves or blocks before dispatch; it never assumes process absence |
| VC-RST-06 | R12-R13 | Make recovery refresh for an ID overlap a candidate poll containing the same ID | Recovery reservation blocks duplicate dispatch until recovery resolves |

## 10. Agent protocol and prompt execution — A10

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-AGT-01 | R23-R24 | Complete valid start/handshake/turn/progress/usage/result exchange | Messages validate, context correlates, exactly one terminal result is accepted |
| VC-AGT-02 | R23 | Emit malformed UTF-8/JSON, oversized line, wrong version, or schema-invalid message | Protocol error, bounded diagnostics, cancellation/termination |
| VC-AGT-03 | R24 | Emit duplicate terminal result or output after result | Protocol error is recorded; no second outcome is applied |
| VC-AGT-04 | R25 | Exceed startup, turn, or idle timeout separately | One cancel, grace wait, then process-tree termination |
| VC-AGT-05 | R25 | Send heartbeats/progress during a turn beyond turn timeout | Idle remains healthy but turn timeout still fires |
| VC-AGT-06 | R25 | Request more than 12 turns under defaults | Twelfth is maximum; host cancels with `max_turns_exceeded` |
| VC-AGT-07 | R26 | Call an unknown or unallowed tool | Immediate structured failure; session can continue; provider is not invoked |
| VC-AGT-08 | R24, R26 | Make valid scoped tool call | Schema/scope validation precedes credential acquisition; exactly one result returns |
| VC-AGT-09 | R24 | Child exits without terminal message | Stable transient process-exit error unless adapter documents permanent exit |
| VC-AGT-10 | R08 | Inspect child argv/environment/stdin/workspace/logs with fixture secrets | No tracker secret appears |
| VC-AGT-11 | R24 | Supply malformed/negative usage and unknown usage unit | Malformed usage is diagnosed/ignored; valid unknown unit is retained separately |
| VC-AGT-12 | R24-R25 | Cancellation fails to terminate process tree | Fatal blocker appears; filesystem resources still in use are not removed |

## 11. Security and observability — A11

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-SEC-01 | R08, R30 | Seed a unique secret through provider and trigger all error/log/snapshot paths | Secret absent from child, prompt, workspace, logs, snapshot, diagnostics, and tool result |
| VC-SEC-02 | R30 | Put control text, markup, terminal escapes, paths, and tool instructions in all untrusted fields | Values remain data and do not broaden execution/tool/filesystem authority |
| VC-SEC-03 | R31-R32 | Validate production mode without posture document, then with complete document | Missing document blocks production start; document truthfully records sandbox/approval posture without mandating VM/container |
| VC-SEC-04 | R31 | Configure tool/filesystem scope beyond deployment policy | Validation or invocation fails closed |
| VC-OBS-01 | R27 | Exercise successful and failing lifecycle paths | Required events carry applicable item/attempt/workspace/session/event/error context |
| VC-OBS-02 | R27 | Use raw prompt, description, hook output, arguments, and repository data | Not logged by default; debug posture still redacts secrets |
| VC-OBS-03 | R28 | Accumulate polls, workers, attempts, hooks, durations, and usage | Aggregate counters/durations/units are correct under fake clock |
| VC-OBS-04 | R28-R29 | Capture snapshot during concurrent lifecycle changes | Snapshot is internally consistent and schema-valid |
| VC-OBS-05 | R28 | Read snapshot repeatedly while instrumenting adapter/scheduler | No poll, refresh, claim, cancel, retry, or reload side effect occurs |
| VC-OBS-06 | R28 | Inspect snapshot with active claims, timers, errors, and prompts | Correlation and safe state appear; secrets/raw sensitive content do not |

## 12. CLI and host lifecycle — A12

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-CLI-01 | R33 | Run `validate` against valid and invalid generations | Valid exits 0; invalid exits 2; neither polls, creates workspace, runs hook, nor starts agent |
| VC-CLI-02 | R33 | Run service with valid generation and available local lock | State reaches running only after validation/lock; polling begins |
| VC-CLI-03 | R01, R33 | Start a second local instance for same runtime identity | Second instance fails clearly without claiming distributed safety |
| VC-CLI-04 | R33 | Send first termination signal with active worker/timers | New dispatch/timers stop; child cancels; bounded finalization occurs; resources release |
| VC-CLI-05 | R33 | Send second signal during uncooperative child | Process may force-terminate but performs no unverified deletion |
| VC-CLI-06 | R33 | Exercise normal shutdown, validation failure, and host failure | Exit status is respectively 0, 2, and 1 |
| VC-CLI-07 | R33 | Read absent/present runtime snapshot | Present read is non-mutating; absent instance returns clear nonzero result |
| VC-CLI-08 | R04, R33 | Enter invalid-reload blocked state | Service remains alive for existing reconciliation/snapshot and stops new dispatch |

## 13. Aggregate conformance and optional integrations — A13

| Case | Requirements | Setup and action | Required result |
| --- | --- | --- | --- |
| VC-CON-01 | R34 | Run full core suite twice with identical seed/build | Same decisions, paths, ordering, event classes, and pass/fail states |
| VC-CON-02 | R02, R34 | Run core suite offline with fake tracker/agent/clock/filesystem | No live provider, account, network, or real-time dependency |
| VC-CON-03 | R34 | Generate aggregate report | Every mandatory ID appears once with requirement/acceptance mapping and build/platform identity |
| VC-CON-04 | R02, R34 | Review implementation-specific extensions | Core defaults remain normative; extensions are named/versioned and disabled where required |

Optional real-integration tests SHOULD cover:

- one concrete tracker adapter's pagination, authentication, rate-limit, refresh,
  missing-item, and normalization behavior;
- one concrete agent adapter's handshake, streaming events, tool mapping,
  cancellation, usage, and process-tree behavior;
- deployment filesystem containment and reparse/link semantics;
- configured hook programs and optional tracker-tool scopes; and
- any optional HTTP/dashboard authentication and redaction.

They MUST use separate credentials/configuration, identify external mutations,
and require explicit authorization before execution.

## 14. Acceptance and requirement coverage

| Acceptance | Mandatory case groups | Outcomes | Primary requirements | Planned deliverables |
| --- | --- | --- | --- | --- |
| A01 | VC-CFG | O07 | R03, R04, R09, R20, R22, R25 | D01 |
| A02 | VC-TRK | O01, O09 | R05, R06, R07, R08, R10 | D02 |
| A03 | VC-WSP-01..07 | O02 | R17, R19 | D04 |
| A04 | VC-WSP-08..15 | O02, O06 | R18, R30 | D04, D09 |
| A05 | VC-HOOK | O02, O06 | R08, R20, R21, R30 | D04, D09 |
| A06 | VC-SCH | O01, O04 | R04, R09, R10, R11, R12 | D03 |
| A07 | VC-REC | O04 | R14, R19 | D03, D06 |
| A08 | VC-RTY | O04 | R15, R16, R25 | D06 |
| A09 | VC-RST | O04, O08 | R13, R19 | D06 |
| A10 | VC-AGT and VC-CFG-07..08 | O03, O06 | R08, R22, R23, R24, R25, R26 | D05 |
| A11 | VC-SEC and VC-OBS | O05, O06 | R08, R27, R28, R29, R30, R31, R32 | D07, D09 |
| A12 | VC-CLI | O08 | R01, R04, R33 | D08 |
| A13 | VC-CON plus complete aggregate report | O09, O10 | R02, R34 | D10, D11, D12 |
| Documentation authorization inspection | Plan review | O10 | R35 | Documentation package only; no service deliverable |

The implementation plan may sequence these groups differently, but it MUST NOT
declare a covered contract item verified until its mandatory evidence exists.
