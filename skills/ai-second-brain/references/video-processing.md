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
installation requires user authorization. Persist that decision in the active
context's runtime record so a later task can reuse or repair the same local
dependency without asking again. Do not download or install without
current-turn or durable recorded authorization.

Use a multilingual Whisper model unless the user explicitly chooses an
English-only model. `base` is a compact default; `small` is the preferred
accuracy upgrade when local processing time and roughly 466 MiB of model disk
are acceptable. Model choice affects accuracy, so record it when known.

## Discover and reuse the local runtime

Do not equate "not on `PATH`" with "not installed." Before reporting Whisper
as unavailable, use this bounded order:

1. explicit `-WhisperPath` and `-WhisperModelPath` overrides, when supplied;
2. `_evidence/media-processing/processing-runtime.md` in a layout-version-2
   active context (or `inbox/media-processing/processing-runtime.md` in an
   unmigrated legacy context);
3. the stable per-user Codex location `.codex/local-tools/whisper.cpp`, where
   the helper searches versioned `whisper-cli.exe` files and multilingual
   models under `models/`;
4. `whisper-cli` on `PATH` for the executable.

`Process-SecondBrainVideo.ps1` performs this discovery when path overrides are
omitted. An explicit invalid override fails rather than silently selecting a
different binary. The runtime record may contain other audit prose, but these
machine-readable Markdown fields enable deterministic reuse:

```markdown
- Install/use authorization: `granted`
- Extracted executable: `C:\absolute\path\to\whisper-cli.exe`
- Model path: `C:\absolute\path\to\ggml-small.bin`
```

A prior record that names the user's authorization, executable, and model is
durable permission to use and, when necessary, repair that same offline setup
for this vault unless revoked. Read-only checks of the record and bounded local
tool directory are normal processing; do not ask for permission merely to look
there. A platform-level sandbox approval may still be required for the actual
command, but request it immediately and continue rather than returning a
manual permission question.

If discovery finds no working setup and installation has already been
authorized, install to the stable per-user location, not a temporary folder;
record the official source, version, paths, model, and hashes; rerun the
processor; and continue interpreting the video in the same assistant turn.
Never download a duplicate before checking the recorded and stable paths.

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

Expected files under `_evidence/media-processing/<capture-id>/` are:

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

If the attachment is pending, a required tool/model remains missing after
bounded discovery and any authorized repair, extraction fails, or an audio
stream cannot be transcribed, append `blocked`. Never call the interpretation
complete or replace the missing channel with latent knowledge.

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

Create `_evidence/interpretations/<capture-id>.md` with these sections:

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
