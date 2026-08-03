# Video Processing

Use this contract for every `video` capture. The original attachment is the
immutable evidence. Frames, extracted audio, transcripts, and interpretations
are derived evidence tied to the same capture ID.

## Architecture and dependencies

Keep orchestration in `ai-second-brain`. Use local command-line tools, not a
separate skill or MCP service:

- FFmpeg and FFprobe inspect the container, extract reviewable frames, and
  convert the first audio stream to 16 kHz mono PCM;
- whisper.cpp transcribes speech locally and emits timestamped JSON and SRT;
- Codex reviews the prepared still frames and transcript, then writes the
  interpretation.

Ordinary video processing must not require an API key, hosted transcription
service, plugin allowance, metered account, or network request. Tool and model
installation may require a one-time explicit user-approved download. Do not
silently download or install them while processing a capture.

Use a multilingual Whisper model unless the user explicitly chooses an
English-only model. `base` is a compact default; `small` is the preferred
accuracy upgrade when local processing time and roughly 466 MiB of model disk
are acceptable. Model choice affects accuracy, so record it when known.

## Prepare derived evidence

After durable capture succeeds, run
`scripts/Process-SecondBrainVideo.ps1`. The helper:

1. verifies exactly one immutable video attachment;
2. records FFprobe stream/container metadata;
3. samples reviewable frames with timestamps, increasing the interval when
   needed to respect the frame cap;
4. extracts the first audio stream without changing the source;
5. requires offline speech transcription whenever audio exists;
6. publishes the completed derivative directory atomically and appends a
   processing event.

Expected files under `inbox/media-processing/<capture-id>/` are:

```text
manifest.json
ffprobe.json
frames.json
frames/
  frame-000001.jpg
audio.wav                 # only when audio exists
audio-transcript.json     # only when audio exists
audio-transcript.srt      # only when audio exists
```

If the attachment is pending, a required tool/model is missing, extraction
fails, or an audio stream cannot be transcribed, append `blocked`. Never call
the interpretation complete or replace the missing channel with latent
knowledge.

## Review visual coverage

`frames.json` describes sampled coverage, not every source frame. Review frames
in chronological order. Use a denser, bounded extraction when text appears only
briefly, a dialogue transition falls between samples, or the user asks for
verbatim coverage that sampling cannot support. State any remaining coverage
limitation explicitly.

For long videos, work in chronological batches. Do not summarize early frames
and silently ignore later ones. Retain the batch boundaries and reviewed time
ranges in the interpretation.

## Transcribe onscreen text

Transcribe all legible dialogue, messages, captions, menus, labels, and other
material text found in the reviewed frames.

- Preserve wording, line order, punctuation, and capitalization when legible.
- Give a timestamp or bounded time range for each entry.
- Use `[unclear]` for an uncertain fragment and `[unreadable]` when text cannot
  be recovered. Never guess from subject knowledge.
- Record materially changed or reappearing text again; do not repeat an
  unchanged message for every sampled frame.
- Distinguish text visible in the video from text supplied in the user's
  caption.

## Transcribe audible speech

Treat `audio-transcript.json` and `.srt` as a fallible machine transcript.
Listen or inspect further when the available surface permits and the transcript
is suspicious, but never invent missing words.

- Preserve timestamped spoken words in the language heard; translate only when
  the user asks.
- Mark uncertain words `[unclear]` and missing speech `[inaudible]`.
- Use `Speaker 1`, `Speaker 2`, and so on unless identity is supported by the
  active evidence. Do not assign a known character/person name from latent
  knowledge.
- Include spoken words even when subtitles are absent.
- Keep audible speech separate from onscreen dialogue text. If subtitles and
  speech match, the combined timeline may link them as corroborating sources,
  but the two source transcripts remain distinct.

## Interpret sound and action

Describe material visible actions, scene changes, UI changes, music cues,
sound effects, silence, and other non-speech audio only to the precision
supported by the evidence. Separate direct observations from proposed meaning.
Do not identify an unseen sound source as fact.

## Write the interpretation

Create `inbox/interpretations/<capture-id>.md` with these sections:

1. `Media and coverage` — duration, streams, sampled ranges, model/tool facts,
   and limitations;
2. `Timestamped visual observations` — visible actions and state changes;
3. `Onscreen text transcript` — verbatim visible dialogue and messages;
4. `Audible speech transcript` — timestamped spoken words from audio;
5. `Non-speech audio observations` — music, effects, silence, and uncertainty;
6. `Combined timeline` — synchronized visual/audio account without collapsing
   source provenance;
7. `AI inferences` — proposed meanings, confidence, and supporting observation
   IDs or timestamps;
8. `Unresolved` — unreadable text, inaudible speech, sampling gaps, conflicts,
   and unanswered questions.

Append `interpreted` only when every present channel was processed and the
interpretation names its coverage. Otherwise append `blocked` or `conflicted`.
