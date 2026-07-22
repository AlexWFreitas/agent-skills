---
name: start-coop-session
description: Start and sustain an explicit, general-purpose cooperative work session in which the agent and user understand material, reason through decisions, edit agreed artifacts, and track durable progress together. Use only when the user explicitly invokes `$start-coop-session` or directly names `start-coop-session`; never trigger implicitly.
---

# Start Coop Session

Treat the session as shared work. Contribute analysis and perform agreed
mechanical work, but keep the user involved in substantive understanding and
decisions. Do not collapse the session into a one-shot answer.

## Start a new session

1. Inspect safely available task material without changing it. Apply an
   applicable specialist skill when required to inspect a format, but keep this
   stage read-only.
2. Infer a concise lowercase kebab-case session name.
3. Propose one compact startup contract containing:
   - goal;
   - source authority and in-scope sources;
   - intended output;
   - session-record and working-copy locations;
   - completion criteria;
   - initial route.
4. Ask one focused question requesting confirmation of the complete contract.
   Do not begin substantive work or create artifacts before confirmation.
5. After confirmation, create `docs/coop/<session-name>/` by default. Copy
   [assets/session-template.md](assets/session-template.md) to `session.md`,
   create clearly named working copies when needed, and populate the confirmed
   contract. Use another established workspace location only when the contract
   confirms it.

Treat supplied material as authoritative by default. Use external research
substantively only when the confirmed contract includes it. When a material gap
requires new sources, explain the gap and ask one focused question for approval
to expand scope. Keep supplied and external evidence distinguishable.

## Collaborate turn by turn

- Explain relevant material before asking at most one focused question or
  requesting one user action per turn. Wait for the response before advancing.
- Take a larger autonomous step only when the user explicitly requests it. Do
  not interpret that request as authority to make substantive decisions unless
  the user delegates those decisions specifically.
- Act as an analytical partner rather than a passive interviewer. Surface
  assumptions and tradeoffs, challenge weak or contradictory reasoning, and
  recommend an option when evidence supports one.
- Distinguish evidence, inference, assumption, recommendation, and unresolved
  uncertainty whenever conflating them could affect the outcome.
- Let the user redirect the route, change the desired depth, revisit covered
  material, or revise a tentative answer. Reconfirm the startup contract when a
  change materially affects its goal, scope, output, authority, or completion
  criteria.
- Use applicable specialist skills and tools for task mechanics after startup
  confirmation. Retain this skill's cadence, participation, durable-state,
  editing, pause/resume, and closure rules. Honor stricter specialist safety and
  verification requirements.

## Edit shared artifacts

For documents that require answers or decisions, discuss and settle the
substance with the user while performing the mechanical edits yourself.

- Treat a clearly settled answer or decision as authority to update the working
  copy immediately, then report the change briefly.
- Do not convert tentative discussion into artifact content.
- Ask separately when wording remains ambiguous, an edit is destructive, or
  materially different formulations remain viable.
- Preserve supplied originals and edit a clearly named working copy by default.
  Edit an original in place only after explicit instruction.
- Do not treat skill invocation or contract confirmation as authority for
  consequential actions outside the confirmed task.

## Maintain durable state

Maintain `session.md` for work expected to span multiple turns. Keep it as
synthesized operational state, not a chat transcript. Update it whenever a
settled decision, authorized edit, coverage change, material route change,
pause, resume, or closure would otherwise leave it stale.

Use ISO 8601 timestamps with a UTC offset for creation and every last-updated
checkpoint.

Rewrite the affected synthesis as current truth; do not append a new status
while leaving an older claim elsewhere. Before saving, reconcile the complete
record so its current state, progress or coverage, artifact states, unresolved
points, limitations, and next action agree. Keep reading coverage authoritative
only in the progress-or-coverage table; the artifacts table records preservation
and mutation state, not reading status.

Keep these items current:

- lifecycle state and confirmed startup contract;
- source and working artifacts plus their current state;
- settled decisions and authorized changes;
- progress or reading coverage;
- unresolved points, limitations, and the exact next action.

Use exactly three lifecycle states:

- `active` for ongoing or paused work;
- `completed` only after the checks pass or their limitations are explicitly
  accepted and the user confirms successful closure;
- `abandoned` when the user explicitly ends early.

## Read complete documentation

When the contract requires reading an entire documentation set:

1. Inventory every in-scope source and divide it into meaningful coverage
   units.
2. Track each unit in `session.md` as pending, in progress, or covered.
3. Mark a unit covered only after reading it, explaining or analyzing what
   matters to the goal, and giving the user a clear opportunity to question,
   discuss, or revisit it.
4. Test the user's understanding only when requested or when a material
   misunderstanding would compromise later work or decisions.
5. Never claim completion while an in-scope unit remains unread.
6. After every coverage transition, remove or rewrite stale current-state,
   artifact, unresolved-point, limitation, and next-action claims.

## Pause and resume

When the user pauses, immediately checkpoint progress or coverage, the last
settled decision, artifact state, next unresolved point, and exact next action.
Report the session path and a concise invocation for resuming. Leave the state
`active` and stop.

When an invocation identifies an existing session:

1. Resume it rather than creating or replacing a session.
2. Read `session.md`, inspect the current source and working artifacts, and
   reconcile drift.
3. Summarize the current state and proposed next action.
4. Ask one focused question confirming continuation before substantive work.
5. Resolve any conflict affecting goal, scope, output, authority, or completion
   criteria through that confirmation rather than silently merging it.

When drift exists, record both the current artifact state and the fact that it
changed since the prior checkpoint. Do not describe a drifted artifact as
unchanged merely because the agent itself did not edit it.

## Complete or abandon

Propose successful closure only after checking the startup contract's
completion criteria, reconciling `session.md` with current artifacts, and
summarizing completed work, final outputs, and unresolved limitations. Ask one
focused question for explicit closure confirmation. Keep the session `active`
unless the user confirms; then set it to `completed`.

If the user explicitly ends early, set the state to `abandoned`. Preserve the
progress, outputs, limitations, unmet criteria, and safe next step. Never present
an abandoned or paused session as complete. Reconcile nonterminal progress so it
is labeled unresolved or incomplete rather than implying active work continues.
