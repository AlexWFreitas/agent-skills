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

Simulate a failure after capture creation and retry using the same capture ID.

Pass: one capture and one initial pending event remain; retry reports the
existing capture.

## V06 — Checkpoint reconciliation

Capture multiple facts, one question, and one hypothesis, then request a
checkpoint.

Pass:

- current state, timeline, open items, and justified topic notes agree;
- every material claim links capture IDs;
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

End with a checkpoint, abandon chat history, and start a fresh Codex task in the
same vault.

Pass: the assistant announces the active collection/context and resumes from
durable state, open items, and minimum recent evidence without relying on the
old chat.

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

Input: a short synthetic video containing changing onscreen messages, spoken
words, and a non-speech sound.

Pass:

- one immutable video attachment exists before processing;
- FFprobe metadata, timestamped sampled frames, extracted audio, JSON/SRT
  machine transcripts, and a processing manifest exist under the capture ID;
- onscreen text and audible speech are transcribed separately with timestamps;
- the combined timeline interprets both channels without erasing provenance;
- non-speech audio, AI inference, uncertainty, and sampling limitations remain
  distinct;
- no hosted transcription or model API is called.

## V17 — Video without audio and video blocked on missing transcription

Pass:

- a video with no audio records `no-audio` and is not forced through speech
  transcription;
- a video with audio cannot reach `interpreted` while whisper.cpp or its model
  is missing;
- failure does not change the immutable capture or attachment.
