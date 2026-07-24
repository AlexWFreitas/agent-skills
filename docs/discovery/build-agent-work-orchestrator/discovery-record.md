# Discovery Record: Build the Workcell Agent Work Orchestrator

Status: `ready-for-handoff` · Task: `build-agent-work-orchestrator` · Session: `1`<br>
Created: `2026-07-24T19:01:45-03:00` · Last updated:
`2026-07-24T19:16:57-03:00`

## Current state

The name `build-agent-work-orchestrator` and a single normative,
language-agnostic Workcell implementation contract are confirmed. The complete
synthetic brief has been synthesized into a self-contained task definition and
linked normative technical contract. The readiness gate and definition-only
cold read pass. Discovery has ended; no service implementation or external
action is authorized.

- Next unresolved point: None - ready for handoff
- Primary handoff: [task-definition.md](task-definition.md)
- Research notes: [evidence-notes.md](evidence-notes.md)
- Normative supporting contract: [technical-contract.md](technical-contract.md)
- Latest snapshot:
  [versions/task-definition-v001.md](versions/task-definition-v001.md)

## Canonical decision trail

| Time | Type | Question or event and why it mattered | Recommendation or evidence | Answer, decision, or definition impact |
| --- | --- | --- | --- | --- |
| `2026-07-24T19:01:45-03:00` | Session start | The user requested separate skill outputs for a controlled comparison against the implementation-readiness of an external specification. | Use an original synthetic service and preserve each skill's own artifact contract. | Start a documentation-only `task-discovery` run; do not implement the service. |
| `2026-07-24T19:01:45-03:00` | Naming gate | File creation required a confirmed concise task name. | `build-agent-work-orchestrator` accurately describes the outcome. | User confirmed the name and the directory `docs/discovery/build-agent-work-orchestrator/`. |
| `2026-07-24T19:01:45-03:00` | Product direction | A normative contract and an alternatives study would produce materially different handoffs. | Use one required behavior profile so implementations can be compared by conformance. | User confirmed one normative, language-agnostic contract for the original Workcell service. |
| `2026-07-24T19:01:45-03:00` | Governing evidence | The synthetic task has no existing product checkout or runtime to inspect. | Treat the supplied brief as governing synthetic input and label added precision as contract-completion inference. | Product behavior comes from the confirmed brief; repository files govern discovery procedure only; external inspiration is non-governing. |
| `2026-07-24T19:01:45-03:00` | Scope boundary | The comparison could accidentally become implementation or external research. | Restrict all writes to the confirmed discovery directory and use contextual inspiration only to calibrate depth. | No implementation, install, commit, push, deployment, database action, or external communication is in scope. |
| `2026-07-24T19:01:45-03:00` | Synthesis decision | Deterministic collision-resistant workspace identity requires more precision than “sanitize the key.” | Include a stable identity-derived hash suffix on every workspace basename, which also satisfies the changed-key minimum. | The technical contract uses sanitized human context plus an always-present stable hash; order-dependent collision resolution is prohibited. |
| `2026-07-24T19:01:45-03:00` | Synthesis decision | Dispatch by oldest creation time requires a normalized creation timestamp even though the brief's field list named only the update timestamp. | Add required `created_at` and record it as an inference compelled by deterministic ordering. | Tracker adapters must supply both `created_at` and `updated_at`; invalid/missing creation data prevents dispatch. |
| `2026-07-24T19:01:45-03:00` | Synthesis decision | “No persistent scheduler database” leaves restart retry semantics potentially ambiguous. | State explicitly that claims, retry counters, and timers reset on restart and dispatch is at-least-once. | Conformance must reject exactly-once or durable-retry claims and prove tracker/filesystem-driven rediscovery. |
| `2026-07-24T19:01:45-03:00` | Document-role decision | The six-section handoff would become difficult to navigate if it contained full schemas, protocols, and transition matrices. | Keep outcomes and consequences in the task definition; place detailed normative behavior in one linked technical contract. | `technical-contract.md` is authoritative for detailed behavior; `evidence-notes.md` owns provenance and evidence classes. |
| `2026-07-24T19:13:05-03:00` | Phase integrity review | Check explicit invocation, write boundary, document agreement, language, and timestamps. | `task-discovery` was explicitly assigned; all writes are under the confirmed directory; no service or external action occurred. | **Pass.** Both primary documents agree, use English as requested, and carry current status and timestamps. |
| `2026-07-24T19:13:05-03:00` | Primary handoff review | Check the six-section spine, coherent synthesis, materiality, and absence of discovery transcript or command-level planning. | The definition presents outcome, context, boundaries, deliverables, outcome-level approach, and observable completion in order; exploratory history remains here. | **Pass.** Every retained optional subsection changes implementation, authority, risk, boundary, or verification. |
| `2026-07-24T19:13:05-03:00` | Contract depth and authority review | Check that requirements, invariants, decisions, risks, unknowns, and validation are direct or authoritatively linked without fragmented truth. | One technical contract owns detailed runtime behavior; one evidence note owns provenance; the definition summarizes each consequence. | **Pass.** Document roles are explicit and no material governing area lacks a delivery and deterministic check. |
| `2026-07-24T19:13:05-03:00` | Supporting record and evidence review | Check lossless trail, source/evidence classes, limitations, and links. | The trail preserves naming, direction, scope, evidence, synthesis choices, review, and closure; source classes distinguish verified, user-confirmed, inference, unresolved, and context-only material. | **Pass.** All relative Markdown document links resolve and substantial detail is linked once. |
| `2026-07-24T19:13:05-03:00` | Implementation-readiness review | Check scope, exclusions, deliverables, constraints, dependencies, risks, gates, validation, and managed external unknowns. | The task definition and 17-section contract define 91 normative `MUST` tokens and 31 deterministic conformance scenarios across every requested acceptance area. | **Pass.** Remaining language, framing, platform primitive, presentation, sandbox, and provider choices have resolvers, gates, and invariants. |
| `2026-07-24T19:13:05-03:00` | Definition-only cold read | Read only `task-definition.md` and test whether a fresh agent can explain the task, preserve choices, reject plausible wrong paths, and follow authoritative links. | The definition identifies Workcell's outcome, current synthetic state, single-node/read-oriented boundaries, artifacts, sequencing, risks, acceptance, and linked contract authority. | **Pass.** A cold reader can reject provider writes in core, child tracker credentials, key-only paths, partial reload, persistent retry claims, mutable snapshots, and mandatory UI/sandbox substitutions. |
| `2026-07-24T19:13:05-03:00` | Closure | Reconcile the primary definition against the lossless record and save the first immutable handoff snapshot. | No material contradiction or unresolved blocker remains; structural checks and `git diff --check` passed. | Set all documents to `ready-for-handoff`; create `versions/task-definition-v001.md`; end discovery without implementation. |
| `2026-07-24T19:16:57-03:00` | Repository validation | Confirm the documentation remains compatible with repository validation boundaries. | `scripts/Test-Repository.ps1` and `tests/Run-Tests.ps1` ran under `pwsh`; they also ran under Windows PowerShell with process-scoped `-ExecutionPolicy Bypass` after the host's default policy blocked script loading. | **Pass.** Both validators reported zero warnings and both test runs reported all 14 tests passing. These are repository tests, not Workcell implementation tests. |

## Linked research notes

- [Evidence and synthesis notes](evidence-notes.md): source authority,
  user-confirmed requirements, verified repository contracts, inferences, and
  limitations.
- [Workcell technical contract](technical-contract.md): normative domain,
  lifecycle, configuration, adapter, isolation, observability, security, and
  conformance specification.

Keep this record lossless. Preserve every material question, answer, evidence
item, rationale, readiness result, and managed unknown here or in the linked
notes.
