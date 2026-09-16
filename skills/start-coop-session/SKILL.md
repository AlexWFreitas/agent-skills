---
name: start-coop-session
description: Start and sustain an explicit, general-purpose cooperative work session in which the agent and user understand material, reason through decisions, edit agreed artifacts, and track durable progress together. Use only when the user explicitly invokes `$start-coop-session` or directly names `start-coop-session`; never trigger implicitly.
---

# Start Coop Session

Treat the session as shared work. Contribute analysis and perform agreed
mechanical work, but keep the user involved in substantive understanding and
decisions. Do not collapse the session into a one-shot answer.

The user's explicit instructions take precedence over this workflow's
defaults, within the host's permissions. Preserve the requested level of
participation: perform settled mechanical work without extra approval, and
keep substantive decisions with the user unless delegated. If a skill rule
requires a pause, link this `SKILL.md`, quote the rule, and explain the exact
missing decision after completing independent authorized preparation.

## Request user input

Keep at most one question unanswered, not one question per assistant turn.
Use an available user-input tool when its current instructions permit the
question type, following its live schema. Do not assume `request_user_input`
accepts approvals. Use plain text for required gates the tool cannot carry or
for open-ended discussion better expressed in the user's own words. Keep
secrets out of question cards and the session record.

For a bounded decision, offer two or three mutually exclusive choices with an
evidence-backed recommendation first and describe each choice's effect. Do not
duplicate a built-in free-form option. Preserve material answers in `session.md`.
An optional preference may use a stated reversible default; startup approval,
source expansion, substantive decisions, and closure need an explicit answer.
Silence, elapsed time, and a preselected option are not consent. While waiting,
continue only preparation that does not depend on the answer or bypass the
user's requested participation.

After an answer, apply it and continue the work it unlocks immediately. If the
next focused question is already known after the relevant explanation or work,
ask it through the permitted input channel. Do not
stop at a summary of the answer, promise to ask the known question next turn, or
require a separate "ok" to proceed.

Before asking, search the visible conversation and `session.md` for the same
decision in substance, not only identical wording. Reuse the recorded answer;
do not reask because context was compacted, tool state was lost, or the prompt
can be phrased better. Reopen a decision only when new material evidence changes
it, and explain what changed. Reuse only an answer that directly settles the
same choice; an adjacent fact or related requirement is not an implicit answer.

Keep each bounded question scoped to one decision. An option may explain its
material consequences, but do not embed a separate unconfirmed substantive
choice and later treat selection as authority for both.

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
4. If the user's request already explicitly settles the complete contract,
   record it and proceed. Otherwise ask one focused question confirming the
   proposed contract through a permitted channel before substantive work or
   artifact creation. A chosen directory name alone is not a separate gate.
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
  requesting one user action at a time. After the response, incorporate it and
  advance immediately; when another question is already material, include it
  after the transition instead of inserting a summary-only turn.
- Take a larger autonomous step only when the user explicitly requests it. Do
  not interpret that request as authority to make substantive decisions unless
  the user delegates those decisions specifically.
- Act as an analytical partner rather than a passive interviewer. Surface
  assumptions and tradeoffs, challenge weak or contradictory reasoning, and
  recommend an option when evidence supports one.
- Distinguish evidence, inference, assumption, recommendation, and unresolved
  uncertainty whenever conflating them could affect the outcome.
- Let the user redirect the route, change depth, revisit material, or revise an
  answer. Record explicit contract changes without asking the user to repeat
  them. Ask only when a material goal, scope, output, authority, or completion
  boundary remains unresolved. Answer side questions, then return to the
  current shared activity unless the user pauses or replaces it.
- If the user questions relevance or depth, expresses frustration, rejects
  added machinery, or repeatedly needs low-level alternatives explained, pause
  the current route and reassess it against the confirmed goal and completion
  criteria. Separate user-owned decisions from work the agent can safely own,
  remove speculative depth, and continue at the shallower level. Do not split
  the same technical issue into more questions.
- Use applicable specialist skills and tools for task mechanics after startup
  confirmation. Retain this skill's cadence, participation, durable-state,
  editing, pause/resume, and closure rules. Honor stricter specialist safety and
  verification requirements.

## Edit shared artifacts

For documents that require answers or decisions, discuss and settle the
substance with the user while performing the mechanical edits yourself.

- Treat a clearly settled answer or decision as authority to update only the
  working-copy content it directly settles, then report the change briefly.
- Do not convert tentative discussion into artifact content.
- Ask when unresolved meaning would change the settled decision, or a
  destructive edit needs authorization. Choose ordinary phrasing and formatting
  yourself within the agreed meaning.
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
4. Treat an explicit request to resume or continue as continuation approval
   when the contract still applies. Do not ask for a second confirmation.
5. Ask one focused question only if drift or the request leaves a material
   conflict affecting goal, scope, output, authority, or completion criteria.

When drift exists, record both the current artifact state and the fact that it
changed since the prior checkpoint. Do not describe a drifted artifact as
unchanged merely because the agent itself did not edit it.

## Complete or abandon

Propose successful closure only after checking the startup contract's
completion criteria, reconciling `session.md` with current artifacts, and
summarizing completed work, final outputs, and unresolved limitations. Use an
existing explicit closure instruction when it covers this result; otherwise
ask one focused question through a permitted channel. Keep the session `active`
unless the user confirms; then set it to `completed`. Repeat successful checks
only if artifacts changed or a remaining concern warrants another check.

If the user explicitly ends early, set the state to `abandoned`. Preserve the
progress, outputs, limitations, unmet criteria, and safe next step. Never present
an abandoned or paused session as complete. Reconcile nonterminal progress so it
is labeled unresolved or incomplete rather than implying active work continues.
