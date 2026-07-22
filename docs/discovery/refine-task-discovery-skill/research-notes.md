# Research Notes: Refine Task Discovery Skill

These notes are the source-detail layer for the lossless discovery record.
They support the claims in `task-definition.md` and the canonical trail in
`discovery-record.md`.

| Time | Source | Finding | Evidence class | Limitation or relevance |
| --- | --- | --- | --- | --- |
| `2026-07-21T19:56:10.2686962-03:00` | User instruction and Git status | The prior accidental source edits were restored before discovery; the worktree was clean. | verified | Establishes the read-only discovery boundary. |
| `2026-07-21T19:56:10.2686962-03:00` | `C:\Users\otaru\.agents\skills\task-discovery\SKILL.md` | Governing discovery process requires explicit invocation, one question per turn, read-only investigation, discovery-directory writes, synchronized documents, and no execution. | verified | Governs this discovery session. |
| `2026-07-21T19:56:10.2686962-03:00` | `docs/discovery/prepare-agent-skill-repository/task-definition.md` | Representative task definition is 389 lines with about 20 headings and includes discovery work in scope. | verified | Evidence of the output that prompted this task. |
| `2026-07-21T19:56:10.2686962-03:00` | `docs/discovery/prepare-agent-skill-repository/discovery-record.md` | Representative record is 478 lines with extensive implementation-oriented history. | verified | Evidence only; user feedback establishes dissatisfaction. |
| `2026-07-21T20:06:29.4534383-03:00` | Prior scope in the representative definition | It includes determining human, coding-agent, and skill-consuming-agent roles. | verified | Concrete instance of discovery work leaking into implementation scope. |
| `2026-07-21T21:03:00-03:00` | `README.md`, `AGENTS.md` | `skills/` is canonical; bundled `assets/` and `references/` are valid resources; `agents/openai.yaml` is optional but must stay aligned when relevant. | verified | Defines later implementation and validation boundaries. |
| `2026-07-21T21:03:00-03:00` | `skills/task-discovery/SKILL.md` | Current behavior includes a broad list of applicable definition dimensions, document synchronization, snapshots, and a readiness gate. | verified | Preserve unaffected phase safeguards. |
| `2026-07-21T21:03:00-03:00` | `skills/task-discovery/assets/task-definition-template.md` | Current template predefines 16 sections, creating pressure to populate a broad catalogue despite “only applicable” wording. | verified | Primary structural source of the excessive primary handoff. |
| `2026-07-21T21:03:00-03:00` | `skills/task-discovery/assets/discovery-record-template.md` | Current template has overlapping research, session, challenge, decision, alternative, unknown, review, and history ledgers. | verified | Structural source of duplicate supporting-record presentation. |
| `2026-07-21T21:03:00-03:00` | `skills/task-discovery/references/readiness-checklist.md` | Existing checklist already treats applicability as materiality-based, but it does not explicitly check the desired six-section handoff, current synthesis, or lossless three-layer record. | verified | Target for refinement without changing semantic rules into arbitrary length linting. |

No external research was used. The positive example and potential negative
fragment are design resources to add only during the later authorized
implementation step.
