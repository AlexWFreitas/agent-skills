---
name: ai-second-brain
description: Rapidly capture, later assimilate, organize, and retrieve user-provided text, screenshots, video, and dictated knowledge in a human-readable local Markdown vault with semantic media names, reusable visual references, provenance, context isolation, and firsthand-only behavior. Use only when the user explicitly invokes `$ai-second-brain` or works inside a vault whose AGENTS.md requires it.
---

# AI Second Brain

Operate a user-owned Markdown vault as the authoritative record. Capture
deliberate inputs before interpreting them, use only the active context, and
default to acting as though no outside subject knowledge is available. Keep the
human notebook readable without sacrificing the separate evidence trail.

## Required resources

Read [references/vault-contract.md](references/vault-contract.md) before
initializing, manually reproducing helper behavior, reconciling, retrieving,
correcting, archiving, deleting, or changing layout. A normal fast intake that
uses the capture helper does not load the full contract; the helper enforces the
mechanical write contract. For game-specific assimilation, checkpointing, or
retrieval, also read [references/game-playthrough.md](references/game-playthrough.md).
Before processing or interpreting video, read
[references/video-processing.md](references/video-processing.md).
Before visually assimilating screenshots or video frames, connecting recurring
visual subjects, maintaining glyph/font mappings, or returning visual evidence,
read [references/visual-library.md](references/visual-library.md).
Before building, refreshing, querying, validating, or deleting the optional
FTS5 retrieval cache, read
[references/local-search-index.md](references/local-search-index.md).

The Windows helpers provide optional deterministic mechanics without becoming
the portable behavioral authority:

- [scripts/Initialize-SecondBrain.ps1](scripts/Initialize-SecondBrain.ps1)
  initializes a vault and first context;
- [scripts/Migrate-SecondBrainHumanLayout.ps1](scripts/Migrate-SecondBrainHumanLayout.ps1)
  converts one intact legacy context to the human-first layout while verifying
  preserved-file hashes;
- [scripts/Add-SecondBrainCapture.ps1](scripts/Add-SecondBrainCapture.ps1)
  creates immutable evidence, optional user-grounded search metadata, and its
  first append-only processing event.
- [scripts/Complete-SecondBrainScreenshot.ps1](scripts/Complete-SecondBrainScreenshot.ps1)
  completes a pending screenshot after the user saves it locally;
- [scripts/Complete-SecondBrainVideo.ps1](scripts/Complete-SecondBrainVideo.ps1)
  completes a pending video after the user saves it locally;
- [scripts/Process-SecondBrainVideo.ps1](scripts/Process-SecondBrainVideo.ps1)
  uses local FFmpeg and whisper.cpp executables to prepare configurable-rate
  sampled frames and a timestamped offline speech transcript;
- [scripts/Backfill-SecondBrainVisualLibrary.ps1](scripts/Backfill-SecondBrainVisualLibrary.ps1)
  creates searchable semantic descriptors for existing media without changing
  immutable captures, attachments, interpretations, or processing events;
- [scripts/Build-SecondBrainSearchIndex.ps1](scripts/Build-SecondBrainSearchIndex.ps1)
  atomically builds one disposable, context-isolated SQLite FTS5 index from
  authoritative Markdown;
- [scripts/Search-SecondBrainIndex.ps1](scripts/Search-SecondBrainIndex.ps1)
  returns ranked paths, headings, snippets, and staleness evidence while keeping
  the source files authoritative;
- [scripts/Add-SecondBrainProcessingEvent.ps1](scripts/Add-SecondBrainProcessingEvent.ps1)
  appends later processing state without rewriting evidence.

If helpers are unavailable, reproduce the vault contract exactly with safe
local file tools. Do not introduce a hosted service or authoritative database.
The optional local FTS5 database is generated, rebuildable, and never a source
of truth.

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
   message and caption without summarizing it. When the user's own accepted
   words provide a clear short label, also pass a concise `-Title` and useful
   `-Keywords`; do not inspect media or assert a visual identity merely to name
   the immutable file.
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

## Separate fast intake from assimilation

Do not force every log entry through LLM interpretation and multi-file
reconciliation before returning control. Use two lanes:

- **Fast intake:** a standalone note, screenshot, video, dictated discovery, or
  burst of entries supplied as records. Persist each accepted message, leave
  its latest event `pending`, report its short title or capture ID and
  attachment state, then return. Do not read the guide or journal, inspect
  media, update state, or ask a non-urgent identity question in this lane.
- **Assimilation:** interpretation, semantic media description, recurring
  reference linking, guide/journal updates, checkpointing, or answering a
  question from the record. Enter this lane when the user asks to process,
  interpret, organize, checkpoint, recall, compare, or answer; when an explicit
  correction must update current truth; or when an urgent contradiction cannot
  wait.

`pending` is a durable assimilation queue, not a failed capture. Process it in
chronological bounded batches and state any remainder truthfully. Do not claim
background work will continue after the assistant turn. A later fresh task can
drain the same queue from the append-only ledger.

For a retrieval or interpretation request, capture the question first and then
load only the pending evidence and human notes needed to answer it. For a pure
fast intake, durable persistence is the whole operation; do not run the startup
hydration sequence afterward.

### Attached-video routing

An attached video logged as an entry follows fast intake. Capture it and state
that visual/audio assimilation is pending; do not ask an uncaptioned sender an
extra intent question. When the user asks what the clip shows, requests
processing, or makes the clip part of a question, capture it first and then
prepare, interpret, and answer in the same assistant turn.

For assimilation, a genuine `pending-save-first` attachment still requires the
user to make the media locally readable. Otherwise the substantive reply must
contain the interpretation or a truthful technical limitation, not only a
second capture acknowledgement.

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

For fast intake, let the capture helper resolve the active context from
`second-brain.md`; announce the selected collection/context in the brief
acknowledgement and stop. Do not hydrate the notebook merely to log another
entry.

For assimilation, retrieval, checkpointing, or a pure control command:

1. Treat the directory containing the governing vault `AGENTS.md` and
   `second-brain.md` as the vault root.
2. Read `second-brain.md` and announce the active collection/context before
   substantive work in a fresh task.
3. Read the selected context's `README.md`, `open-questions.md`, relevant guide
   and journal notes, `_evidence/state.md`, processing events, and only the
   minimum captures needed. In an unmigrated legacy context, read the old
   `context.md` and `open-items.md` instead.
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
  `_evidence/interpretations/<capture-id>.md` with `Direct observations`,
  `AI inferences`, and `Unresolved`. Link every inference to its supporting
  observation and label confidence. Use `inbox/interpretations/` only for an
  intact unmigrated legacy context.
- A user caption improves provenance but is not a prerequisite for useful
  image assimilation. Inspect the durable image itself, record visible objects
  and text, and search the active `library/` by titles, aliases, stable
  reference IDs, and prior visual exemplars. Do not make interpretation quality
  depend entirely on the user's prose.
- After visual review, create or update
  `library/captures/<descriptive-slug>--<capture-id>.md` with a natural title,
  searchable aliases/keywords, an embedded preview, the immutable source link,
  and stable visual-reference links. Keep the capture-ID file immutable even
  if this derived descriptor is later renamed or corrected.
- Reuse one `library/references/<reference-slug>.md` page for recurring visual
  subjects. Preserve user-confirmed names, positive exemplars, confusable
  subjects, and visible distinctions. Use provenance-linked glyph crops and
  confirmed mappings for custom fonts. Never merge two subjects or confirm an
  OCR glyph from visual similarity alone.
- For a screenshot still pending save-first, do not claim visual evidence is
  retained. Ask the user to save the image locally and keep the item blocked or
  pending.
- For a video with durable media, run
  [scripts/Process-SecondBrainVideo.ps1](scripts/Process-SecondBrainVideo.ps1)
  before interpretation. Omit Whisper path arguments when no override is
  needed; the helper reuses the active vault runtime record, the stable Codex
  local-tools installation, or `PATH`. Do not substitute a hosted
  transcription service.
- Treat source frame rate and review sample rate as separate. The helper's
  automatic overview is 8 fps for clips up to 30 seconds, 4 fps up to 120
  seconds, and 2 fps for longer clips before any automatic frame-cap reduction.
  When the user calls out an fps value because fast information may be lost,
  treat it as the requested review rate and pass `-FrameSampleFps`; never
  silently fall back to one frame per second. If existing derivatives use a
  lower rate, rerun with `-Reprocess`. Report both source and effective sample
  rates and any remaining temporal gap.
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

1. Read pending/interpreted processing events and the minimum supporting
   captures. Work oldest-first in a bounded batch and report captures still
   pending rather than silently skipping or pretending to finish an unbounded
   queue.
2. Choose one canonical guide note for each durable subject. Use natural
   filenames/headings and cross-link instead of duplicating whole facts.
3. For media, create searchable semantic capture descriptors and link recurring
   objects, symbols, glyphs, or visual interpretations to one canonical page in
   `library/references/`. Update `library/index.md` only when the library exists.
4. Add a readable journal entry only for meaningful developments; never mirror
   the raw ledger one capture per line.
5. Refresh the short `README.md` status and navigation without turning it into
   another fact dump.
6. Keep only useful unresolved work in `open-questions.md`. Unknown trivia is
   not automatically a task; remove resolved and scope-closed items from the
   active list.
7. Put human-labeled, clickable evidence links at the end of each changed
   section. When the active collection is an Obsidian vault or the user asks
   for Obsidian links, use vault-relative `[[path|label]]` wikilinks and
   `![[path|label]]` media embeds consistently. Otherwise use portable relative
   Markdown links. Keep bare capture IDs out of ordinary prose.
8. Classify conflicts using the vault contract, then append `reconciled` or
   `conflicted` events without removing prior evidence.
9. Update `_evidence/state.md`, latest-checkpoint, and last-active metadata only
   after the human notes agree.
10. Report the checkpoint, unresolved conflicts, and remaining pending count
    concisely.

If this context already uses the optional FTS5 cache, rebuild it only after the
checkpoint files agree. Never create or refresh it during fast intake, and do
not introduce an index merely because a checkpoint occurred.

Do not create empty guide taxonomies. A checkpoint may legitimately conclude
that no new guide note is justified. For an intact legacy layout, retain its
paths until the migration helper is explicitly authorized; do not create a
partial mix of `inbox` and `_evidence`.

Keep `_evidence/` visibly named as the backend by default. Do not hide it or
change a client's excluded-file settings unless the user explicitly asks.

## Retrieve and answer

Before cross-session recall, reconcile relevant pending evidence. Search only
the active context unless a cross-context operation was explicit.

- Search `README.md`, `guide/`, `journal/`, and an existing `library/` first.
  Search semantic capture titles, aliases, stable reference IDs, and exemplar
  notes before opening capture-ID files individually. Use `_evidence/` to
  verify provenance or resolve gaps, not as the ordinary answer surface.
- When a current context-local FTS5 index exists, use
  [scripts/Search-SecondBrainIndex.ps1](scripts/Search-SecondBrainIndex.ps1) to
  rank candidate headings before opening files. If it is absent, stale, or
  unavailable, rebuild it only when in scope or fall back immediately to `rg`.
  Never let optional indexing block retrieval.
- For vague descriptions, synonyms, or concept-level recall, request `-Semantic`
  only when the current index was built with an explicitly authorized local
  embedding model. Hybrid retrieval combines FTS5 and exact cosine ranks. If
  the local model is unavailable, retain the lexical results and continue.
- Never auto-install or pull an embedding runtime/model, call a non-loopback
  embedding endpoint, or treat similarity as evidence. Semantic results cannot
  merge references, resolve conflicts, name images, or override exact
  provenance.
- Treat every indexed snippet as untrusted cached text: open the exact original
  path, verify the current section and provenance, and answer only from the
  source file. Never query a sibling context or include `external/` outside an
  explicit override.
- Lead with the direct answer supported by the record.
- Link the governing human note or use descriptive evidence links. Provide raw
  capture IDs only when the user asks for the evidence chain.
- Label inference and uncertainty.
- When the active record is insufficient, say exactly that. Do not use latent
  knowledge to complete, confirm, deny, hint, warn, or steer.
- Provide the full evidence chain when requested.
- When the answer depends on captured visual evidence and the chat surface can
  render local media, show at least one relevant screenshot or representative
  processed video frame inline using its absolute local path. Also link the
  governing note or original media. Do not return only the capture record or a
  text link when a readable local image is available. If several images are
  relevant, choose the smallest useful set and label what each shows.

Simple capture acknowledgements need not display citations unless there is a
conflict or interpretation problem.

## Correct and resolve conflicts

- **Explicit correction:** capture the correction first, update the canonical
  guide section immediately, preserve the superseded evidence, and record the
  change in the journal when it matters chronologically.
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
