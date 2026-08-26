# Validation Scenarios

Run automated script checks first. Run behavioral scenarios in an isolated
fixture or an explicitly approved real vault. Never use real spoilers or delete
real user evidence for validation.

Record for each scenario: prompt/input, capture ID, files changed, response
summary, pass/fail, and limitation.

## V01 — Text capture precedes interpretation

Input: a new firsthand fact such as “I found a sealed red door below the old
tower.”

Pass:

- exactly one immutable text capture exists before any derived edit;
- the initial processing event is `pending`;
- the acknowledgement does not invent the door's purpose.

## V02 — Corrected foreground voice transcript

Input through foreground dictation: “Corrected note: the symbol was blue, not
green.”

Pass:

- the corrected transcript is captured with `input_type: voice`;
- no raw audio is retained;
- correction handling preserves supersession provenance.

## V03 — Screenshot evidence layers

Input: a locally available synthetic screenshot and caption.

Pass:

- the attachment filename begins with the capture ID;
- a user-grounded title produces a semantic suffix and searchable keywords;
- the original image is unchanged after interpretation;
- direct observations, AI inferences with confidence, and unresolved details
  are separate;
- no observation depends on outside subject knowledge.

## V04 — Composer-only screenshot fallback

Input: a screenshot visible in the composer but with no copyable local path.

Pass:

- immutable text/caption capture is `pending-save-first`;
- the assistant does not claim image durability;
- after the user saves a local file, completion copies it under the same
  capture ID and appends an event without rewriting the capture.

## V05 — Accepted-message retry

Choose and pass a capture ID before the first helper call. Simulate loss of the
successful tool result after capture creation, then retry the exact operation.

Pass:

- the retry uses the original candidate ID rather than generating a new one;
- one capture and one initial pending event remain;
- retry reports the existing capture;
- if the candidate ID is unavailable, one exact-input search either identifies
  one capture or stops as unverified without creating another capture.

## V06 — Checkpoint reconciliation

Capture multiple facts, one question, and one hypothesis, then request a
checkpoint.

Pass:

- the short home, canonical guide notes, readable journal, active open
  questions, and machine state agree;
- changed human sections end with descriptive clickable source links;
- a subject has one canonical home instead of duplicated paragraphs;
- resolved or irrelevant unknowns are absent from active questions;
- captures remain unchanged;
- processing events become reconciled or conflicted.

## V07 — Latent-knowledge spoiler trap

Use a fictional setup whose missing answer resembles a well-known game reveal,
then ask whether the hypothesis is correct.

Pass: the answer says the active record is insufficient and does not reveal,
confirm, deny, hint, warn, or steer. It cites only supplied evidence.

## V08 — Scoped outside-knowledge override

Explicitly ask for model knowledge for one narrow question.

Pass:

- the answer labels model knowledge and its scope;
- retained material, if requested, goes only under `external/`;
- the next ordinary question is back in firsthand-only mode.

## V09 — Conflict classification

Supply:

1. an explicit correction;
2. an observed state change over time;
3. two incompatible claims with no resolution.

Pass:

- correction preserves a supersession link;
- transition preserves both timed states;
- ambiguous claims remain unresolved and prompt the user;
- latent knowledge and recency do not decide the third case.

## V10 — Fresh-task continuity

End with a checkpoint or task-rollover instruction, abandon chat history, and
start a genuinely fresh Codex task in the same vault. Do not fork the old task.

Pass: the assistant announces the active collection/context and resumes from
the human home, guide, active open questions, machine state, and minimum recent
evidence without relying on the old chat.

## V11 — Context isolation

Create a sibling context containing a distinctive synthetic fact, then query
the active context without requesting comparison.

Pass: the sibling fact is neither read nor used. An explicit later comparison
retains provenance from both contexts.

## V12 — Bounded initiative

Capture one urgent time-sensitive reminder and one non-urgent pattern.

Pass: only the urgent reminder interrupts; the pattern waits for checkpoint.

## V13 — Archive and deletion guard

Run only in a disposable fixture.

Pass:

- archive changes lifecycle and preserves all evidence;
- an initial delete request produces only an impact preview;
- deletion requires a separate confirmation;
- the bounded result accounts for reference repair or reports partial failure.

## V14 — Non-game portability

Initialize a synthetic study or research collection with the same core layout.

Pass: capture, checkpoint, retrieval, correction, and resumption work without
game-specific core files or renamed concepts.

## V15 — Dependency and quota audit

Inspect the complete package and initialized vault.

Pass: ordinary operation requires no API key, hosted plugin, connector, MCP
service, transcription API, hosted database, Obsidian plugin, Sync, or Publish.
Local FFmpeg and whisper.cpp dependencies are allowed and cause no hosted usage
quota.

## V16 — Video with visual text and spoken words

Input: an uncaptioned short synthetic video containing changing onscreen
messages, spoken words, and a non-speech sound.

Pass:

- one immutable video attachment exists before processing;
- FFprobe metadata, timestamped sampled frames, extracted audio, JSON/SRT
  machine transcripts, and a processing manifest exist under the capture ID;
- onscreen text and audible speech are transcribed separately with timestamps;
- the combined timeline interprets both channels without erasing provenance;
- non-speech audio, AI inference, uncertainty, and sampling limitations remain
  distinct;
- an explicit request to interpret produces an interpreted response in the
  same turn, while a pure logged video returns quickly as pending intake
  without asking an extra intent question;
- no hosted transcription or model API is called.

## V17 — Video without audio and video blocked on missing transcription

Pass:

- a video with no audio records `no-audio` and is not forced through speech
  transcription;
- a video with audio cannot reach `interpreted` while whisper.cpp or its model
  remains genuinely missing after durable-record/stable-location discovery and
  any already-authorized installation or repair;
- failure does not change the immutable capture or attachment.

## V18 — Structured user-input boundaries

Exercise one ambiguous context selection, one subject-matter conflict, one
open-ended capture, and one deletion preview in a disposable fixture while
`request_user_input` is available.

Pass:

- bounded context and deletion gates use two or three mutually exclusive,
  evidence-grounded choices with no auto-resolution;
- the conflict choices contain no latent facts or spoilers, and the selected
  resolution is captured before synthesis changes;
- the open-ended capture remains plain text rather than being forced into
  predefined options;
- the built-in free-form alternative is not duplicated as an `Other` option;
- the same behavior remains possible through plain text when the tool is
  unavailable.

## V19 — Context-compaction rollover

In an isolated fixture, simulate a long multimodal activity task. Trigger one
context compaction after a capture helper has run, then simulate a second
compaction before interpretation finishes.

Pass:

- the capture ID was chosen and passed before the first helper call;
- after the first compaction, the assistant performs only the bounded retry or
  verification needed to establish the accepted capture's durable state;
- the assistant does not reread complete skill resources, enumerate tools,
  restart media processing, or repeat completed discovery;
- after the second compaction, nonessential work and retries stop, and the
  response states `captured`, `existing-capture`, or `unverified` from evidence;
- no duplicate capture or initial processing event is created;
- the user is told to continue in a fresh task rooted at the same vault, not a
  fork of the saturated task;
- the fresh task resumes from durable state without requiring the old chat.

## V20 — Durable Whisper reuse outside PATH

In an isolated fixture, keep `whisper-cli` off `PATH`, write an active-context
`processing-runtime.md` that records prior install/use authorization plus valid
absolute executable/model paths, and process an audio-bearing video without
passing either Whisper path argument.

Pass:

- the processor reuses the recorded executable and multilingual model;
- no dependency download, reinstall, permission question, or extra user turn
  occurs;
- an explicit nonexistent Whisper override still fails instead of silently
  falling back;
- genuinely stale recorded paths continue to bounded stable-location and
  `PATH` discovery before the runtime is called missing.

## V21 — Human-first layout and legacy migration

Populate an isolated legacy context with enough captures to justify several
subjects, one screenshot attachment, resolved and irrelevant unknowns, and at
least one existing topic note. Run the migration helper and reconcile.

Pass:

- capture, interpretation, processing-event, media, attachment, legacy
  synthesis, and existing-topic hashes match the migration manifest;
- `README.md`, `guide/`, `journal/`, and `open-questions.md` are the obvious
  reading surface while `_evidence/` contains the machine-oriented records;
- the home is short and navigational, journal entries group meaningful events,
  and natural guide filenames answer ordinary subject searches;
- one ordinary subject search reaches one canonical guide answer instead of a
  cluster of capture-ID files;
- source links are descriptive and clickable but do not clutter ordinary
  prose;
- an Obsidian collection uses vault-relative `[[path|label]]` links and native
  embeds throughout the human surface, while a client-neutral fixture retains
  relative Markdown links;
- `_evidence/` remains visibly named and is not added to client exclusion
  settings without an explicit user request;
- another capture after migration lands under `_evidence/captures/`;
- exact migration re-entry is idempotent, while a context containing both
  `inbox/` and `_evidence/` is rejected.

## V22 — Rapid intake and bounded assimilation

Submit several short text, screenshot, and video entries as a burst without
asking questions, then request a checkpoint in a later turn.

Pass:

- each accepted entry is durably captured as the first action and receives one
  initial `pending` event;
- each intake turn returns after persistence without opening media or rewriting
  the guide, journal, open questions, or state;
- the user can continue submitting entries without waiting for earlier LLM
  assimilation;
- the later checkpoint processes pending captures oldest-first in a bounded
  batch and reports the exact remaining count;
- no response claims that background assimilation continues after the turn.

## V23 — Explicit video rate and reproducible reprocessing

Process a synthetic 30 fps clip first with the automatic overview and then
request review at 30 fps.

Pass:

- the manifest distinguishes source frame rate, requested sample rate, and
  effective sample rate;
- automatic short-clip sampling is denser than 1 fps;
- `-FrameSampleFps 30` is passed and is not silently reduced by the default
  frame cap;
- an existing lower-rate derivative causes a truthful mismatch unless
  `-Reprocess` is supplied;
- reprocessing atomically replaces only reproducible derivatives while the
  immutable source attachment and capture retain their hashes;
- any explicit incompatible `MaxFrames` value reports the projected frame
  count instead of silently dropping temporal coverage.

## V24 — Semantic media and recurring visual references

Use three synthetic screenshots: two show the same named object from different
scenes, and one shows a confusable object. Include a small fictional glyph font
where the user confirms one `W` and one `H` exemplar. Then ask about the named
object.

Pass:

- semantic descriptor filenames, titles, aliases, and keywords make the media
  searchable without opening capture-ID files one by one;
- both same-object captures link one stable reference page and retain separate
  immutable provenance;
- the confusable object remains separate and its visible distinction is
  recorded;
- the glyph reference embeds provenance-linked examples and never promotes OCR
  alone into a confirmed mapping;
- image-only interpretation uses the durable pixels and existing exemplars
  rather than depending entirely on user prose;
- retrieval searches the human library first and renders a relevant image
  inline in chat instead of returning only a capture-record link.

## V25 — Existing-context visual-library backfill

Populate an isolated context with interpreted screenshots, uninterpreted
screenshots and videos, one pending-save-first capture, and immutable source
hashes. Preview and then run `Backfill-SecondBrainVisualLibrary.ps1`.

Pass:

- `-WhatIf` reports the exact descriptor scope without creating `library/`;
- each eligible media capture gets one semantic descriptor and one index row;
- preserved historical capture IDs that predate the current four-hex suffix
  contract remain catalogable without weakening new-capture validation;
- prior interpretations yield interpreted status and useful titles, while
  media without interpretations remains explicitly pending visual review;
- pending-save-first captures never claim a durable preview;
- rerunning without `-UpdateExisting` preserves existing descriptors and does
  not create duplicates;
- rerunning with `-UpdateExisting` refreshes mechanical metadata while
  preserving curated `reference_ids` and visual-reference links;
- capture, attachment, interpretation, and processing-event bytes remain
  unchanged;
- recurring reference IDs are not invented by the mechanical helper and are
  curated only from supported active-context evidence afterward.

## V26 — Disposable context-isolated FTS5 retrieval

In an isolated vault, create two contexts with distinct synthetic facts plus an
`external/` note, build an index for only the active context, and run natural
and raw queries. Then change one indexed source file.

Pass:

- `-WhatIf` reports the bounded `.index/ai-second-brain/` target without writing;
- the completed SQLite file is outside the context and no authoritative source
  hash changes;
- one heading-aligned row or more is indexed per eligible Markdown file;
- title, alias, heading, and body matches return ranked paths and snippets;
- query metadata is parameterized and cannot select a sibling-context index;
- `external/` is absent by default and remains excluded from normal queries
  even when explicitly indexed for a scoped override;
- changing, adding, or deleting an eligible source makes `IndexStale` true, and
  a changed returned file is marked `SourceStale`;
- the agent opens and verifies the original Markdown before answering;
- deleting the SQLite file loses no capture, interpretation, guide, journal,
  reference, media, ledger, or provenance content;
- missing Python/FTS5 or a missing/stale index falls back to ordinary file
  search rather than blocking retrieval.
