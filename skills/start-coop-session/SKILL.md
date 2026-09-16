---
name: start-coop-session
description: Work through material and decisions with the user, apply settled edits, and preserve resumable progress. Activate only when asked to use start-coop-session; discussing or reviewing the skill does not start a cooperative session.
---

# Start coop session

Work as an analytical partner. Explain the material, contribute judgment, and
perform settled mechanical work while keeping the user involved in substantive
understanding and decisions. Preserve the participation they requested.

## Establish the shared work

Inspect supplied material read-only and infer the goal, intended output,
governing sources, working artifacts, completion criteria, and participation
rhythm. Learning together, deciding a product question, and filling a document
need different rhythms; ask only when the distinction affects the work.

Use `docs/coop/<session-name>/` by default, inferring a concise name. Propose
one compact startup contract including the record location and initial route.
If the request already settles it, record it and proceed. Otherwise confirm
the unresolved contract before substantive work or artifact creation. Naming
alone does not require a separate gate.

Create [session.md](assets/session-template.md) once the request or an explicit
reply settles the startup contract. When an existing task definition governs,
link its exact version and record only
session-specific participation, sources, working copies, and progress.
Do not duplicate requirements or manufacture another execution approval.

Supplied material is authoritative by default. Use external research
substantively only when the confirmed scope includes it. Ask to expand sources
when a material gap requires that expansion and no existing authorization
covers it.

## Collaborate

1. Explain the material needed for the next useful step.
2. Surface evidence, assumptions, tradeoffs, and contradictions. Recommend an
   option when justified instead of acting as a passive interviewer.
3. Ask for the substantive decision or user action needed now, if any.
4. Apply settled answers, perform their mechanical edits, record material
   progress, and advance immediately.

Keep at most one question unanswered. Check the conversation and session record
before asking again. Reopen a decision only when new material evidence changes
it, and explain why. An answer settles the actual decision asked; do not hide
another foundational choice inside an option.

For a bounded choice, offer two or three distinct options and a supported
recommendation. Use a tool only when its current instructions permit that
question type; use plain language otherwise. Do not force exploratory discussion
into choices, duplicate a built-in free-form option, or retain secrets.

Required startup, substantive, source-expansion, and closure decisions need an
explicit answer; silence and preselection do not settle them. An optional
preference may use a stated reversible default. While waiting, continue only
independent preparation that respects the user's participation.

Do not insert a summary-only turn after an answer. If another material question
is ready after the relevant work, ask it. Take a larger autonomous step when
requested, but distinguish delegated mechanics from delegated substantive
decisions. Do not collapse a shared session into a one-shot answer.

If the user questions relevance or depth, remove speculative detail and
reassess which decisions belong to them. Answer side questions and incorporate
corrections without discarding the shared objective. An explicit pause, stop,
or replacement takes effect immediately.

## Edit and record

Treat a settled answer as authority to update the working-copy content it
directly resolves. Choose phrasing and formatting yourself. Tentative discussion
is not final content. Preserve originals and use clearly named working copies
unless the user requests in-place edits.

Maintain `session.md` as current operational state: governing contract or link,
source and artifact states, settled decisions, progress, unresolved issues, and
exact next action. Use ISO 8601 timestamps with UTC offsets. Record material
changes once; keep transcripts and routine commands out of this synthesis.

Update affected sections when decisions, edits, coverage, route, or lifecycle
changes would leave them stale. Check the whole record for consistency rather
than rewriting unchanged text. Reading coverage belongs in the coverage table;
artifact state records preservation and edits, not a second reading ledger.

Keep the lifecycle states `active` (including paused), `completed`, and
`abandoned`. Completion requires checked criteria or accepted limitations and
the user's successful-closure confirmation.

## Track complete reading when requested

Inventory every in-scope source and divide it into meaningful units. Track
pending, in-progress, and covered units in the session record. Mark a unit
covered only after reading it, explaining what matters, and giving the user an
opportunity to question or revisit it. Do not claim full coverage with unread
units. Test understanding only when requested or when a material
misunderstanding would compromise later work.

## Pause, resume, or close

On pause, checkpoint progress, settled decisions, artifact state, the next
unresolved point, and exact next action. Leave the state `active`, provide the
session path and a concise resume instruction, and stop.

On resume, reuse the existing session, read its record, inspect relevant
artifacts, and reconcile drift. An explicit continuation request covers resuming
an unchanged contract; ask only about a material conflict. Record changed
artifacts as changed even when someone else made the edit.

Before successful closure, check completion criteria, reconcile the record,
and summarize outputs and remaining limitations. Reuse explicit closure
authorization if it covers this result; otherwise request it once. Keep
`active` until confirmed, then mark `completed`. Repeat checks only for
changed artifacts or a remaining concern.

If the user ends early, mark `abandoned` and preserve outputs, gaps, and a safe
next step. Do not imply that abandoned work continues.

## Compose with other skills

Use specialists for mechanics and document quality within the confirmed scope.
Discovery or execution may own the task contract and its authorization; this
skill owns participation and session progress. Link those records and reuse
their settled decisions. Invocation grants no consequential action beyond scope.

User instructions govern within host permissions. If a skill rule requires a
pause, finish independent authorized work, link this file, quote the rule, and
identify the actual missing decision.
