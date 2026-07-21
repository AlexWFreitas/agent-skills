---
name: task-discovery
description: Run an explicit, read-only task-discovery phase that investigates a proposed task, interviews the user one question at a time, challenges ambiguity, and maintains a discovery record plus a self-contained task definition with an execution approach and validation criteria. Use only when the user explicitly invokes `$task-discovery` or names `task-discovery`; never trigger implicitly. Apply to any task domain before execution.
---

# Task Discovery

## Establish the phase contract

Treat discovery as a bounded phase with a clear start and end. Define the task comprehensively; do not settle for a merely plausible or "good enough" description.

Follow these non-negotiable rules:

- Ask exactly one discovery question per assistant turn. Wait for the answer before selecting the next question.
- Adapt depth to the task. Use no fixed question count or artificial maximum.
- Research proactively in read-only mode before and between questions.
- Challenge vague claims, contradictions, risky assumptions, and premature conclusions.
- Write only inside `docs/discovery/<task-name>/` during the phase. Treat project files and external systems as read-only.
- Maintain `discovery-record.md` and `task-definition.md` from the beginning of the phase.
- Write the documents in the language of the user's request. Preserve technical identifiers and proper names when translation would make them inaccurate.
- Do not execute the defined task. End discovery, present the documents, and wait for further instructions.

## Start or resume discovery

1. Infer a concise lowercase kebab-case task name from the request.
2. Propose that name and obtain confirmation before creating files.
3. Use `docs/discovery/<task-name>/` relative to the current workspace by default.
4. If that directory already exists, ask whether to resume it or create a distinct directory. Do not choose silently.
5. Create or adapt the two primary documents immediately from:
   - `assets/discovery-record-template.md`
   - `assets/task-definition-template.md`
6. Set status to `in-progress` and record ISO 8601 timestamps with a UTC offset.
7. Permit supporting notes, extracts, diagrams, or evidence files only within the same discovery directory. Link them from one of the primary documents.
8. Mark the start of a new session in the continuous discovery record.

When resuming, read the full discovery record, the canonical task definition, and the latest file under `versions/` before asking a question. Record the resumed session and carry forward the highest-priority unresolved point.

## Investigate before asking

Inspect all relevant sources that are safely available in read-only mode. Depending on the task, inspect workspace instructions, source files, documentation, configuration, logs, history, supplied artifacts, connected sources, and current external references. Browse or search when current or niche facts matter and access is available.

Honor source and environment restrictions stated by the user or workspace instructions. Never use external research when the task explicitly limits evidence to local or supplied sources.

Before asking the user for a fact, determine whether it can be established through read-only inspection. Ask the user for intent, priorities, preferences, authority, or unavailable facts; do not make the user rediscover information already present in accessible sources.

For every material researched claim, record:

- the file path, URL, artifact, or source identifier;
- the access or observation time when freshness matters;
- the claim the source supports;
- one evidence class: `verified`, `inference`, `assumption`, or `unresolved`;
- any limitation, conflict, or freshness concern.

Avoid copying secrets or unnecessary sensitive content into discovery artifacts.

## Run the one-question discovery loop

Repeat this loop until the readiness gate passes:

1. Reconcile the current task definition with the latest answer and research.
2. Identify the single highest-impact unresolved point.
3. Explain briefly why that point matters.
4. Offer a recommendation when evidence supports one, distinguishing it from a verified fact.
5. Ask one focused question about one decision or information gap. Do not hide multiple questions in bullets, clauses, or subparts.
6. Wait for the user's answer.
7. Research follow-up facts in read-only mode when useful.
8. Update both primary documents immediately and refresh their `last updated` timestamps.

Explore all applicable dimensions, including intent, desired outcomes, present state, stakeholders, scope and exclusions, deliverables, requirements, quality attributes, constraints, preferences, dependencies, assumptions, risks, edge cases, permissions, sequencing, validation, acceptance criteria, and definition of done. Omit dimensions that genuinely do not apply.

Treat contradictions and ambiguous terms as unresolved until reconciled. Revisit earlier answers when new evidence changes their meaning. If the user cannot know an answer, investigate it or turn it into a managed unknown with a concrete resolution plan.

## Maintain the discovery record

Keep `discovery-record.md` as a polished chronological record rather than a raw transcript. Preserve the exact meaning of the user's statements. Explicitly note every reinterpretation, normalization, or material wording change.

Record, when applicable:

- the initial request as a polished reconstruction;
- inspected and researched sources;
- each question, why it mattered, any recommendation, and the answer;
- changes in understanding and their causes;
- assumptions challenged or accepted;
- contradictions and their resolution;
- decisions and rationale;
- discarded alternatives;
- unresolved or managed unknowns;
- readiness reviews, pauses, closures, and reopenings.

Keep one continuous record. Add a clearly separated session section whenever discovery resumes or reopens.

## Maintain the task definition

Keep `task-definition.md` as the canonical, current, self-contained definition. Make it sufficient for a fresh agent with no access to the conversation or discovery record.

Include only applicable sections. Cover as needed:

- objective, background, current state, and desired outcomes;
- stakeholders or affected users;
- scope and out of scope;
- deliverables and requirements;
- constraints, preferences, assumptions, and dependencies;
- risks, edge cases, mitigations, and managed unknowns;
- recommended execution phases, sequencing, and decision points;
- validation strategy and observable acceptance criteria;
- definition of done;
- evidence sources and traceability;
- boundaries on permitted actions and handoff notes.

Label material statements as verified facts, inferences, assumptions, or unresolved facts when the distinction affects execution. Resolve disagreement between the two documents in favor of the latest evidenced decision, then update both documents so they agree.

## Apply the readiness gate

Read and apply `references/readiness-checklist.md` before ending the phase. Record the review in `discovery-record.md`.

Continue discovery whenever an applicable material uncertainty, contradiction, unverified dependency, missing acceptance criterion, unclear boundary, or unmanaged execution risk remains. Treat an issue as material when its answer could change the outcome, scope, approach, permission boundary, cost, risk, validation, or definition of done.

Allow an unavoidable external unknown at handoff only when the documents state:

- what is unknown and why it cannot currently be resolved;
- its impact;
- who or what can resolve it;
- the concrete resolution or validation step;
- the contingency, decision rule, or gate that prevents unsafe guessing.

Decide when the readiness gate passes; do not require a fixed question count or a ceremonial user approval.

## Pause, close, and reopen

When the user pauses discovery:

1. Set status to `paused`.
2. Record the current understanding, unresolved items, and the next recommended question.
3. Update timestamps and stop without executing the task.

When the readiness gate passes:

1. Set both documents to `ready-for-handoff`.
2. Complete the readiness and closure entries.
3. Create `versions/` if absent.
4. Save the canonical definition as the next zero-padded snapshot, such as `versions/task-definition-v001.md`.
5. Present a concise completion summary and links to the two primary documents and snapshot.
6. State that discovery has ended and stop. Wait for further instructions.

When the user requests an early end before readiness passes:

1. Run the readiness review.
2. Explain the material gaps.
3. Ask one focused confirmation question about closing despite those gaps.
4. If confirmed, set status to `incomplete`, record the risks and reason for early closure, save the next versioned snapshot, and stop without executing the task.

When a later explicit invocation materially changes a completed definition, reopen the same discovery directory unless the user directs otherwise. Preserve existing snapshots, append a new session to the discovery record, set the canonical documents back to `in-progress`, and save the next snapshot only when that session closes.

