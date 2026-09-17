# Task Definition: Write Jira descriptions for developers and QA

Status: `ready-for-handoff` · Task: `jira-ticket-writing` · Last updated:
`2026-09-17T18:48:06-03:00` · Supporting record:
[discovery-record.md](discovery-record.md)

## Objective

Create a reusable skill that makes Jira descriptions understandable and
actionable for human developers and QA without relying on the agent's session
history. Readers need the problem or opportunity, intended change, scope, and
observable completion criteria.

## Implementation context

The user supplied an OD-5110 description mixing build recovery work,
investigation instructions, catalog reconciliation, and progress reports.
The user explicitly identified content quality, rather than formatting, as the
problem. The excerpt is evidence of the writing failure; its technical claims
have not been independently verified and must not become general requirements.

[README.md](../../../README.md) governs packaging: `skills/` is the canonical
catalog and installed copies are derived. The working tree was clean at
inspection. The new skill must be self-contained and compose with Jira
workflows without changing other skills' behavior or activation policies.

## Scope and non-goals

Create `jira-ticket-writing` for drafting, creating, rewriting, and updating
Jira task, story, bug, and epic descriptions, including writes within larger
workflows. Include summaries, acceptance criteria, QA verification, existing
description preservation, and examples. Allow automatic selection when the
skill is available to the host.

Do not install the skill, edit live Jira issues, modify other skills, introduce
a Jira client, or change installer behavior. Do not generalize OD-5110-specific
constraints. Formatting is a supporting delivery concern.

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| `skills/jira-ticket-writing/SKILL.md` | Reader-oriented writing process, task/epic distinctions, and semantic review before description writes. |
| Optional Codex metadata | Automatic invocation allowed, metadata aligned with the skill. |
| Linked examples | Technical task, user-facing bug, and epic; no unsupported facts or fixed universal template. |
| Validation record | Packaging checks, semantic review, and explicit verification limits. |

## Recommended implementation approach

1. Define what developers and QA need from a description.
2. Separate requirements from progress and investigation history while
   preserving consequential technical detail.
3. Add examples calibrated to different issue sizes and evidence limits.
4. Review realistic scenarios and run existing repository checks.

The user explicitly requested creation in this turn. That instruction
authorizes local implementation after discovery, but not installation or
external publication.

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| Comprehension | A reader can identify the affected workflow, reason for work, intended change, and completion conditions without chat history. |
| QA usefulness | Criteria describe observable results; checks include setup, action, and expected result where known, without invented commands or behavior. |
| Evidence and scope | Examples preserve material limits, expose unknowns, distinguish epics from tasks, and separate progress. |
| Existing issues | Instructions preserve human requirements and distinguish drafts from authorized writes. |
| Packaging | Repository validation and tests pass under both PowerShell families; bundled quick validation is attempted. |

Completion requires the skill and examples, a reviewed diff, and recorded
validation. Static review cannot prove that every future agent selects or
follows the skill.
