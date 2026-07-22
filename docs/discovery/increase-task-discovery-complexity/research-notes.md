# Research Notes: Increase Task Discovery Complexity

| Time | Source | Supported claim | Evidence class and limitation |
| --- | --- | --- | --- |
| `2026-07-21T23:27:06.7037180-03:00` | `C:\Users\otaru\.agents\skills\task-discovery\SKILL.md` | The current loop updates both primary documents immediately after every answer while requiring the definition to remain current synthesis. | `verified`; establishes current behavior but does not prove it caused the prior failure. |
| `2026-07-21T23:27:06.7037180-03:00` | `skills/phased-plan-to-goal/SKILL.md` | The comparison skill separates canonical event capture from coherent rewrites at material lifecycle events. | `verified`; its execution-phase events require adaptation for discovery. |
| `2026-07-21T23:27:06.7037180-03:00` | `skills/phased-plan-to-goal/SKILL.md` | Its definition is freely rewritten while draft, then becomes a versioned contract after approval; snapshots occur at approval, material change, and closure. | `verified`; task discovery has no execution-approval boundary. |
| `2026-07-21T23:27:06.7037180-03:00` | `skills/phased-plan-to-goal/assets/task-definition-template.md` | The richer contract preserves sources, outcomes, requirements, material decisions, risks, unknowns, supporting documents, acceptance, and traceability when material. | `verified`; copying every fixed section would conflict with the anti-bloat goal. |
| `2026-07-21T23:27:06.7037180-03:00` | `skills/phased-plan-to-goal/references/readiness-checklist.md` | Readiness is semantic and coherence-oriented; material decisions prevent silent substitution. | `verified`; aligns with the current task-discovery materiality safeguard. |
| `2026-07-21T23:47:17.3551781-03:00` | `skills/task-discovery/SKILL.md` and bundled resources | The current source consistently uses a six-section definition, lossless record, materiality review, readiness gate, and illustrative example. The fifth section is named `Execution plan`. | `verified`; the section name may imply the phased planning behavior the user explicitly excluded. |
| `2026-07-21T23:47:17.3551781-03:00` | `skills/task-discovery/assets/task-definition-template.md` | The current template gives minimal guidance for adaptive sources, requirements, decisions, risks, unknowns, supporting documents, and traceability. | `verified`; these are the bounded areas where useful contract depth may be restored. |

The transferable pattern is lifecycle separation: preserve continuous evidence
in a canonical trail, but regenerate reader-oriented synthesis only at material
review points. The exact discovery milestones remain unresolved.
