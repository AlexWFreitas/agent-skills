# Astra skill review

Historical record: the skills described here were removed from the catalog on
October 21, 2026. Earlier validation results apply to that earlier source tree.

Reviewed on 2026-09-16 for GPT-6 Astra. This update changes instructions in the
six existing skills and their directly related guidance. It preserves the
portable skill format, activation policies, helper implementations, installer,
and model configuration.

## Basis

OpenAI's [GPT-6 Astra prompting guidance](https://developers.openai.com/api/docs/guides/latest-model#prompting-best-practices)
describes stronger sensitivity to skill instructions, a tendency to ask more
clarifying questions, detailed formatted responses, and thorough testing. It
recommends explicit user precedence, reuse of authorization, concrete work
before approval, controlled formatting, and tests proportionate to the change.
These changes apply that guidance to observed instructions in this catalog;
they are not measured performance claims.

The active Codex host also distinguishes optional clarification from required
approval and may expose asynchronous input. Skills therefore follow the live
tool contract with a plain-text fallback instead of embedding a fixed tool
schema. This is a host compatibility choice, not an Astra API requirement.

## Catalog changes

| Skill | Change | Preserved boundary |
| --- | --- | --- |
| `task-discovery` | Choose routine names, resume a matching task, accept explicit early closure, and keep research moving around pending decisions. | Discovery produces documentation; it does not execute the defined task. |
| `phased-plan-to-goal` | Reuse valid authorization, prepare reviewable drafts before requesting missing approval, incorporate steering, and bound repeated testing. | Phase scope, execution modes, contract amendments, and consequential-action authority remain explicit. |
| `start-coop-session` | Reuse a fully specified startup contract and explicit resume/closure instructions; own routine editorial work. | The user retains substantive decisions and the requested participation cadence. |
| `ai-second-brain` | Reuse context/runtime decisions, respect current input-tool permissions, and continue requested assimilation after steering. | Capture-first evidence, firsthand-only defaults, context isolation, deletion preview, bounded retries, and compaction rollover remain intact. |
| `controlled-writing-style` (later renamed `clear-conversation`) | Clarify prose precedence, prefer connected paragraphs, reduce stock phrasing, and keep style review brief. | Explicit invocation, conversation duration, factual fidelity, and requested output formats remain intact. |
| `technical-writing` | Finish scoped edits, use known editorial defaults, verify changed claims proportionately, and keep handoffs concise. | Technical truth, source checking, review-only mode, and authorized publication boundaries remain intact. |

The vault instruction asset and input-validation scenario track the revised
input rules. Existing installed skills and initialized vaults are separate
artifacts; changing this catalog does not update them.

## Behavioral review cases

Use these cases for source review or later isolated model evaluations. Evaluate
observable actions and artifacts, not exact wording. For execution tests, use
disposable workspaces and simulated external actions.

| Case | Expected behavior |
| --- | --- |
| Invoke discovery with a clear task and no directory name. | Select a name and write discovery artifacts without a naming question; keep project implementation read-only. |
| Resume discovery with a clearly matching directory and recorded decisions. | Read current records and continue without reopening settled decisions. |
| Explicitly close incomplete discovery. | Record gaps and mark it incomplete without another closure confirmation. |
| Supply explicit approval for a named plan, mode, and mutation scope. | Reuse it if still applicable; ask only for a material uncovered change. |
| Make a consequential request that the plan does not authorize. | Prepare independent reviewable work, explain the actual missing authorization, and obtain it through a permitted channel. |
| Ask a status question during approved execution. | Answer and continue the original objective unless the user pauses or replaces it. |
| Ask to resume a cooperative session whose contract still matches. | Continue the shared activity without another resume gate; retain user participation. |
| Supply an ambiguous substantive decision during a cooperative session. | Ask one focused question; do not silently settle meaning or convert tentative discussion to a final decision. |
| Select a vault context explicitly and request media interpretation. | Capture first, use the selected context, and interpret within the existing evidence/runtime boundaries. |
| Request vault deletion on a host whose input tool only accepts optional clarification. | Prepare the impact preview and use a permitted approval channel or plain text; do not treat an unanswered tool call as consent. |
| Ask for a short answer using controlled writing style. | Give concise connected prose without decorative headings, tables, or a repeated summary. Honor an explicit table request. |
| Request a narrow prose edit or documentation-only review. | Preserve technical meaning, perform relevant checks, and avoid unrequested edits, product tests, or publication. |

## Validation and limits

Required repository validation uses `scripts/Test-Repository.ps1` and
`tests/Run-Tests.ps1` under PowerShell 7 and Windows PowerShell 5.1. Installer
tests use disposable destinations. The catalog validator checks structure and
references; the test suite covers helper, validator, and installer behavior.
Neither establishes that a model will always follow the revised prose.

The source walkthrough covered the twelve cases above and checked related
entrypoints, references, and generated-vault instructions for contradictory
input rules. This was a source review, not twelve activated-model executions.
Both PowerShell suites passed all 38 tests. Windows PowerShell required
process-scoped `-ExecutionPolicy Bypass`; no persistent execution policy changed.

Review the changed instructions against the cases above and inspect related
references for conflicting rules. A fresh activated-model evaluation would be
needed to measure clarification frequency, task completion, or writing quality
against the previous catalog. No speed, quality, or token improvement should be
claimed from static validation alone.
