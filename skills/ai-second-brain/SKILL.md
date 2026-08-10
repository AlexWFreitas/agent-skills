---
name: ai-second-brain
description: Capture, interpret, organize, reconcile, and retrieve user-provided text, screenshots, video, and dictated knowledge in a local Markdown vault while preserving provenance, context isolation, and firsthand-only behavior. Use only when the user explicitly invokes `$ai-second-brain` or works inside a vault whose AGENTS.md requires it.
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
Before processing or interpreting video, read
[references/video-processing.md](references/video-processing.md).

The Windows helpers provide optional deterministic mechanics without becoming
the portable behavioral authority:

- [scripts/Initialize-SecondBrain.ps1](scripts/Initialize-SecondBrain.ps1)
  initializes a vault and first context;
- [scripts/Add-SecondBrainCapture.ps1](scripts/Add-SecondBrainCapture.ps1)
  creates immutable evidence and its first append-only processing event.
- [scripts/Complete-SecondBrainScreenshot.ps1](scripts/Complete-SecondBrainScreenshot.ps1)
  completes a pending screenshot after the user saves it locally;
- [scripts/Complete-SecondBrainVideo.ps1](scripts/Complete-SecondBrainVideo.ps1)
  completes a pending video after the user saves it locally;
- [scripts/Process-SecondBrainVideo.ps1](scripts/Process-SecondBrainVideo.ps1)
  uses local FFmpeg and whisper.cpp executables to prepare sampled frames and
  a timestamped offline speech transcript;
- [scripts/Add-SecondBrainProcessingEvent.ps1](scripts/Add-SecondBrainProcessingEvent.ps1)
  appends later processing state without rewriting evidence.

If helpers are unavailable, reproduce the vault contract exactly with safe
local file tools. Do not introduce a hosted service or database.

## Request user input

When Codex exposes `request_user_input`, use it only for one bounded question
with two or three mutually exclusive choices, such as selecting among plausible
active contexts, resolving alternatives already supported by captured evidence,
approving a local dependency download, confirming archive, or confirming
deletion after the required impact preview. Send exactly one question per call.
When the answer returns, perform the required capture-or-control routing and
continue the unlocked operation in the same active assistant turn.

Put the evidence-backed recommendation first and suffix its label with
`(Recommended)`. Use a single-sentence prompt, a header of at most 12
characters, labels of one to five words, and a one-sentence effect description
for each choice. Do not add an `Other` option because Codex supplies the
free-form alternative. Never put latent subject knowledge, spoilers, or an
uncaptured claim into a question, label, description, or recommendation.

Do not use predefined choices for ordinary captures, open-ended subject
questions, dictated content, media-save instructions, credentials, secrets, or
answers that require the user's own words. Use concise plain text instead. If
the tool is unavailable, ask the same bounded question in plain text.

Omit `autoResolutionMs`. Context selection, conflict resolution, downloads,
archive, deletion, and every other vault gate require explicit user input. Tool
presentation never changes firsthand-only boundaries or authorization.

Do not stop after the answer with only an acknowledgement or summary, and do
not require a separate "ok" to proceed. Continue context loading, conflict
resolution, an approved download, archive, or confirmed deletion as far as the
answer safely authorizes.

Classify the returned answer exactly like any other accepted user input. A
context, authorization, archive, or deletion selection is control input. A
selection that resolves a subject-matter ambiguity, corrects a claim, or adds a
decision is deliberate evidence: persist it as the first action before updating
interpretations or synthesis.

## Non-negotiable boundaries

- After Codex accepts a deliberate input, persist it as the first agent action
  before interpretation, organization, or substantive reply.
- Firsthand-only mode is the default. Do not reveal, confirm, deny, hint at, or
  steer around facts absent from the active context, even when the model knows
  them.
- Do not read or merge a sibling context unless the user explicitly requests
  that cross-context operation.
- Original capture files and completed screenshot or video attachments are
  immutable evidence. Store later observations, machine transcripts,
  inferences, corrections, and processing changes separately with capture-ID
  provenance.
- Never auto-delete evidence. Permanent deletion requires an explicit request,
  impact preview, confirmation, bounded execution, and reference repair.
- Do not browse for subject facts or use external knowledge unless the user
  explicitly requests a scoped override.

## Classify the accepted input

Treat an accepted user message as a deliberate capture when it contains or asks
about evidence, a correction, a decision, a hypothesis, a question, an open
item, a screenshot, a video, or a dictated transcript. A pure initialization,
context-selection, authorization, archive-confirmation, or deletion-confirmation
command is control input and is not itself subject evidence.

Do not interpret capture content before persisting it. Recognizing its input
type and whether it is a pure control command is mechanical routing, not
subject-matter interpretation.

## Capture first

For every deliberate capture in an initialized vault:

1. Before the first helper call, choose one candidate capture ID in the vault
   contract format. As the first agent action, run
   [scripts/Add-SecondBrainCapture.ps1](scripts/Add-SecondBrainCapture.ps1)
   against the vault root and pass that ID through `-CaptureId`. Pass the
   complete accepted text, corrected dictated transcript, or screenshot/video
   message and caption without summarizing it.
2. For a screenshot or video, pass a local attachment path only when Codex
   exposes one. Otherwise create the capture without a path so it remains
   `pending-save-first`.
3. If persistence fails, report the failure immediately. Do not interpret,
   answer, or reorganize that input until durable capture succeeds.
4. Retain the candidate capture ID and returned state for every retry,
   interpretation, processing event, synthesized claim, and response citation.

Use the same candidate capture ID on the first call and every retry. If the
result is uncertain, retry the exact capture at most once with that ID; the
helper returns `existing-capture` instead of duplicating evidence. Never assign
a new ID to the same accepted input merely because tool output was lost.

If compaction obscures the candidate ID, make one bounded search in the active
context's newest capture directory for the exact unsummarized input and local
attachment basename. Adopt one exact match. If the search finds none or more
than one, report the capture as unverified and stop; do not generate another ID
or interpret the input.

If pending media is later saved locally, run the matching completion helper
with the original capture ID. Do not rewrite its capture Markdown.

### Default attached-video intent

In an active vault, treat an attached video as a request to capture, process,
interpret, and extract durable information unless the user explicitly asks to
store it without interpretation. A caption is optional. Do not ask an
uncaptioned-video sender what operation they want and do not make them send a
second message such as "interpret it."

After capture succeeds and a durable attachment is available, continue video
preparation, interpretation, any immediately justified current-state update,
and the substantive answer in the same assistant turn. The first reply to the
video should contain the interpretation or a truthful technical limitation,
not only a capture acknowledgement. A genuine `pending-save-first` attachment
still requires the user to make the media locally readable.

## Keep the Codex task bounded

Treat chat as transport and the vault as memory. Use one Codex task for one
bounded activity session, not for the lifetime of a collection.

- Read each required skill resource at most once per assistant turn. Context
  compaction inside that turn does not restart setup. Do not reread complete
  skill files, enumerate tool catalogs, or repeat completed discovery merely
  because earlier tool output left the visible context.
- Treat the first context compaction in a task as a rollover signal. Finish or
  verify only the already accepted capture, report its capture ID and actual
  processing state, then tell the user to continue in a fresh task rooted at
  the same vault. Do not fork the saturated task because a fork retains its
  completed history. Do not create a replacement task unless the user asks.
- If persistence is still uncertain after compaction, use the candidate-ID
  retry or exact-match search above once. If a second context compaction occurs
  in the same assistant turn, stop all interpretation, reconciliation, media
  processing, tool discovery, and further retries. Perform at most one minimal
  candidate-ID existence check, report `captured`, `existing-capture`, or
  `unverified` truthfully, and return the rollover instruction.
- Never describe a bridge, shell, or helper as failed unless an actual tool
  result establishes that failure. Lost working context is not a tool error.
- If the user submits another deliberate input before following the rollover
  instruction, capture it first under these same bounds, then repeat the
  rollover instruction. Never use task saturation to leave an accepted input
  only in chat.

A fresh task resumes from durable files and minimum recent evidence. It does
not require the old task, a fork, or a chat summary as authority.

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
   another subject. When two or three known contexts plausibly match, use
   `request_user_input` if available without reading their contents. Otherwise
   ask in plain text. Do not read a sibling context while selection is
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
- For a video with durable media, run
  [scripts/Process-SecondBrainVideo.ps1](scripts/Process-SecondBrainVideo.ps1)
  before interpretation. Omit Whisper path arguments when no override is
  needed; the helper reuses the active vault runtime record, the stable Codex
  local-tools installation, or `PATH`. Do not substitute a hosted
  transcription service.
- Interpret the prepared video using the required separate visual, onscreen
  text, audible speech, non-speech audio, combined timeline, inference, and
  unresolved layers in
  [references/video-processing.md](references/video-processing.md). Treat the
  offline speech transcript as fallible derived evidence, not as the user's
  direct statement.
- Before declaring the local transcription runtime/model unavailable, inspect
  the durable runtime record and the bounded stable local-tools location. This
  read-only discovery is ordinary processing and does not require a separate
  permission turn. A prior vault record that explicitly grants install/use
  permission remains authorization to reuse or repair that same local runtime
  and model unless the user revokes it.
- If installation or repair is already authorized, perform it in a stable
  local-tools directory, persist or refresh the runtime record, retry media
  processing, and continue interpretation in the same assistant turn. Do not
  redownload a working runtime/model or ask again for authorization already
  recorded in the vault or supplied in the conversation.
- Only if a video is pending save-first, or contains audio but the local
  transcription runtime/model remains genuinely unavailable after bounded
  discovery and any authorized repair, append `blocked` and do not claim
  complete interpretation. Report the exact checked locations or failed tool
  action; never describe an unperformed search as a permission problem.
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
  append a `conflicted` event, and ask the user. Use `request_user_input` when
  two or three evidence-grounded resolutions are bounded; capture the returned
  resolution before applying it. Never pick a winner from model memory,
  confidence, or recency alone.

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
until a later unambiguous confirmation names the previewed scope. Use
`request_user_input` when available for that later confirm-or-cancel gate, with
no auto-resolution. Repair dangling references in the same bounded operation
and report partial failure.

## Validate behavior

Use [references/validation-scenarios.md](references/validation-scenarios.md)
for source cold-read and activated-vault validation. Scenario success is
evidence of behavior, not proof that latent knowledge has been technically
removed.
