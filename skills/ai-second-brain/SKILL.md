---
name: ai-second-brain
description: Capture, organize, reconcile, and retrieve a user-provided body of knowledge in a local Markdown vault while preserving provenance, context isolation, and firsthand-only behavior. Use only when the user explicitly invokes `$ai-second-brain` or works inside a vault whose AGENTS.md requires it.
---

# AI Second Brain

Operate a user-owned Markdown vault as the authoritative record. Capture
deliberate inputs before interpreting them, use only the active context, and
default to acting as though no outside subject knowledge is available.

## Required resources

Read [references/vault-contract.md](references/vault-contract.md) before
initializing, capturing, reconciling, retrieving, correcting, archiving, or
deleting. For a game context, also read
[references/game-playthrough.md](references/game-playthrough.md).

The Windows helpers provide optional deterministic mechanics without becoming
the portable behavioral authority:

- [scripts/Initialize-SecondBrain.ps1](scripts/Initialize-SecondBrain.ps1)
  initializes a vault and first context;
- [scripts/Add-SecondBrainCapture.ps1](scripts/Add-SecondBrainCapture.ps1)
  creates immutable evidence and its first append-only processing event.
- [scripts/Complete-SecondBrainScreenshot.ps1](scripts/Complete-SecondBrainScreenshot.ps1)
  completes a pending screenshot after the user saves it locally;
- [scripts/Add-SecondBrainProcessingEvent.ps1](scripts/Add-SecondBrainProcessingEvent.ps1)
  appends later processing state without rewriting evidence.

If helpers are unavailable, reproduce the vault contract exactly with safe
local file tools. Do not introduce a hosted service or database.

## Non-negotiable boundaries

- After Codex accepts a deliberate input, persist it as the first agent action
  before interpretation, organization, or substantive reply.
- Firsthand-only mode is the default. Do not reveal, confirm, deny, hint at, or
  steer around facts absent from the active context, even when the model knows
  them.
- Do not read or merge a sibling context unless the user explicitly requests
  that cross-context operation.
- Original capture files and completed screenshot attachments are immutable
  evidence. Store later observations, inferences, corrections, and processing
  changes separately with capture-ID provenance.
- Never auto-delete evidence. Permanent deletion requires an explicit request,
  impact preview, confirmation, bounded execution, and reference repair.
- Do not browse for subject facts or use external knowledge unless the user
  explicitly requests a scoped override.

## Classify the accepted input

Treat an accepted user message as a deliberate capture when it contains or asks
about evidence, a correction, a decision, a hypothesis, a question, an open
item, a screenshot, or a dictated transcript. A pure initialization,
context-selection, authorization, archive-confirmation, or deletion-confirmation
command is control input and is not itself subject evidence.

Do not interpret capture content before persisting it. Recognizing its input
type and whether it is a pure control command is mechanical routing, not
subject-matter interpretation.

## Capture first

For every deliberate capture in an initialized vault:

1. As the first agent action, run
   [scripts/Add-SecondBrainCapture.ps1](scripts/Add-SecondBrainCapture.ps1)
   against the vault root. Pass the complete accepted text, corrected dictated
   transcript, or screenshot message/caption without summarizing it.
2. For a screenshot, pass a local attachment path only when Codex exposes one.
   Otherwise create the capture without a path so it remains
   `pending-save-first`.
3. If persistence fails, report the failure immediately. Do not interpret,
   answer, or reorganize that input until durable capture succeeds.
4. Retain the returned capture ID for every later interpretation, processing
   event, synthesized claim, and response citation.

When retrying after an uncertain result, reuse the reported capture ID. The
helper returns `existing-capture` instead of duplicating evidence.

If a pending screenshot is later saved locally, run
[scripts/Complete-SecondBrainScreenshot.ps1](scripts/Complete-SecondBrainScreenshot.ps1)
with the original capture ID. Do not rewrite its capture Markdown.

## Start or resume a task

After capture-first routing, or immediately for a pure control command:

1. Treat the directory containing the governing vault `AGENTS.md` and
   `second-brain.md` as the vault root.
2. Read `second-brain.md` and announce the active collection/context before
   substantive work in a fresh task.
3. Read only the selected context's `context.md`, `open-items.md`, relevant
   activity reference, processing events, and the minimum evidence needed.
4. Stop for confirmation when no active context exists, multiple contexts
   plausibly match, or the opening input is a control command indicating
   another subject. Do not read a sibling context while selection is
   ambiguous.
5. Resume from durable files. Never treat prior chat as required authority.

## Interpret a capture

Use only the active context and the captured evidence.

- For text or voice, distinguish the user's direct statement, a proposed
  interpretation, and uncertainty.
- For a screenshot with durable media, create
  `inbox/interpretations/<capture-id>.md` with `Direct observations`,
  `AI inferences`, and `Unresolved`. Link every inference to its supporting
  observation and label confidence.
- For a screenshot still pending save-first, do not claim visual evidence is
  retained. Ask the user to save the image locally and keep the item blocked or
  pending.
- Append an `interpreted`, `blocked`, or `conflicted` event through
  [scripts/Add-SecondBrainProcessingEvent.ps1](scripts/Add-SecondBrainProcessingEvent.ps1).
- Do not rewrite the immutable capture or completed attachment.

If interpretation exposes a material ambiguity that only the user can resolve,
ask one concise question. Otherwise acknowledge capture briefly and defer
non-urgent connections to the next checkpoint.

## Reconcile at checkpoints

Reconcile when the user asks to organize/checkpoint, before answering a query
that needs current cross-session knowledge, and when the user ends the activity
session. Apply explicit corrections and material state changes immediately.

1. Read pending/interpreted processing events and their captures.
2. Update `context.md` current state, `timeline.md`, `open-items.md`, and
   justified `topics/` notes as one coherent synthesis.
3. Link every material claim to capture IDs. Keep inference and uncertainty
   labeled.
4. Classify each apparent conflict as correction, state transition, or
   ambiguous conflict using the vault contract.
5. Append `reconciled` or `conflicted` processing events. Never remove prior
   events or captures.
6. Update the latest-checkpoint and last-active fields only after the
   synthesized files agree.
7. Report the checkpoint, unresolved conflicts, and pending screenshot
   evidence concisely.

Do not create empty topic taxonomies. A checkpoint may legitimately conclude
that no new topic note is justified.

## Retrieve and answer

Before cross-session recall, reconcile relevant pending evidence. Search only
the active context unless a cross-context operation was explicit.

- Lead with the direct answer supported by the record.
- Cite compact capture IDs or governing topic notes beside material claims.
- Label inference and uncertainty.
- When the active record is insufficient, say exactly that. Do not use latent
  knowledge to complete, confirm, deny, hint, warn, or steer.
- Provide the full evidence chain when requested.

Simple capture acknowledgements need not display citations unless there is a
conflict or interpretation problem.

## Correct and resolve conflicts

- **Explicit correction:** capture the correction first, update current
  synthesis immediately, preserve the superseded claim and both capture IDs,
  and append the change to the timeline.
- **State transition:** preserve old and new states with applicable times.
- **Ambiguous conflict:** preserve both, mark current knowledge uncertain,
  append a `conflicted` event, and ask the user. Never pick a winner from model
  memory, confidence, or recency alone.

## Use bounded initiative

Interrupt normal capture only for an urgent contradiction, a safety-relevant
conflict, or an explicitly time-sensitive reminder. Collect non-urgent
connections, patterns, possible contradictions, and hypotheses for the next
checkpoint. Every proactive observation must remain grounded in active-context
evidence.

## Handle outside knowledge

An override exists only when the user explicitly requests model knowledge or
external research and states or clearly implies its scope.

1. State that the response is using outside knowledge and name its source
   class.
2. Answer only the requested scope.
3. If retention is requested, write a note under `external/` with provenance
   and an explicit outside-knowledge label. Never merge it into firsthand
   current truth.
4. Return to firsthand-only mode immediately after the scoped response.

Do not add a hosted plugin, connector, MCP service, paid API, transcription
service, embedding service, or hosted database.

## End, archive, or delete

At session end, reconcile, write the checkpoint, and report unresolved,
conflicted, or pending items.

Archive only by changing lifecycle to `archived`; preserve evidence.

For permanent deletion, follow the impact-preview and confirmation procedure in
the vault contract. The initial request authorizes preview only. Do not delete
until a later unambiguous confirmation names the previewed scope. Repair
dangling references in the same bounded operation and report partial failure.

## Validate behavior

Use [references/validation-scenarios.md](references/validation-scenarios.md)
for source cold-read and activated-vault validation. Scenario success is
evidence of behavior, not proof that latent knowledge has been technically
removed.
