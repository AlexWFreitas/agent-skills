# Vault Contract

This document defines the authoritative portable data contract. The skill owns
behavior; ordinary Markdown and media files own durable knowledge. Layout
version 2 separates the notebook a person reads from the evidence machinery an
agent needs.

## Root identity and active context

The vault root contains:

```text
AGENTS.md
second-brain.md
collections/
  <collection>/
    contexts/
      <context>/
```

`second-brain.md` records one active collection and context plus the known
context index. Slugs are lowercase ASCII kebab-case. Display names retain the
user's wording. The first context is `main`; create another only when the user
requests it.

Information never crosses context boundaries automatically. Comparing,
importing, sharing, or promoting knowledge across contexts requires explicit
user instruction and provenance for every transferred claim.

## Human-facing context layout

Every layout-version-2 context contains:

```text
README.md
guide/
  index.md
  <natural-subject-name>.md
journal/
  index.md
  <date-or-session-name>.md
open-questions.md
_evidence/
  state.md
  captures/
    YYYY-MM-DD/
      <capture-id>.md
  interpretations/
    <capture-id>.md
  media-processing/
    <capture-id>/
  processing-events.jsonl
attachments/
external/
```

The primary reading surface is:

- `README.md`: a short landing page with current status, current objective or
  result, latest checkpoint, and links into the notebook;
- `guide/`: durable knowledge organized by subjects a person would search for;
- `journal/`: meaningful chronological sessions or chapters;
- `open-questions.md`: only actions, questions, conflicts, and hypotheses that
  are still useful to resolve.

Use natural filenames and headings. A person must not need a capture ID to find
an item, place, character, puzzle, decision, or event. Keep each subject in one
canonical guide note; cross-link instead of copying the same paragraph into
multiple files. Do not let `README.md` become another full knowledge dump.

Do not pre-create empty subject taxonomies. `guide/index.md` and
`journal/index.md` are the only required empty indexes. Create a guide note
when accumulated evidence justifies it.

## Evidence backend

`_evidence/` is authoritative but machine-oriented:

- `state.md` owns context identity, lifecycle, epistemic mode, compact scope,
  and latest-checkpoint metadata;
- `captures/` owns immutable original deliberate inputs;
- `interpretations/` owns derived observations and inferences;
- `media-processing/` owns reproducible video metadata, sampled frames,
  extracted audio, and machine transcripts;
- `processing-events.jsonl` is the append-only processing ledger.

`attachments/` contains immutable capture-ID media. It remains outside
`_evidence/` so existing vault-relative attachment links stay stable and human
notes can embed media. `external/` contains explicitly requested outside
knowledge with provenance.

Normal human reading and search should start in `README.md`, `guide/`, and
`journal/`. Keep `_evidence/` visible as the clearly named backend by default;
do not change client exclusion settings unless the user asks. Obsidian or any
other particular client remains optional.

## Capture identity

Use an identifier shaped like:

```text
CAP-YYYYMMDD-HHMMSS-ffff
```

The final component is random lowercase hexadecimal. Generate with local time
for readability and record an ISO 8601 timestamp with UTC offset inside the
capture. File creation must reject collisions rather than overwrite.

Each immutable capture Markdown file under
`_evidence/captures/YYYY-MM-DD/` contains:

```markdown
---
capture_id: CAP-...
captured_at: 2026-01-01T12:00:00-03:00
input_type: text
session_id: optional-stable-session-name
attachment: none
attachment_state: none
---

# Original input

Exact deliberate user text or corrected voice transcript.

# User caption

Caption supplied with a screenshot, or `None`.
```

Allowed input types are `text`, `voice`, `screenshot`, and `video`.

For `voice`, the original input is the corrected transcript. Do not retain raw
microphone audio.

For screenshot or video input, copy a readable local source to
`attachments/<capture-id><extension>` and record its vault-relative path. Use
`attachment_state: ready`. When no local source is available, use
`attachment: none` and `attachment_state: pending-save-first`. The capture is
durable but media evidence is incomplete until the user saves the file locally
and the completion helper appends a linked event.

Video derivatives stay under `_evidence/media-processing/<capture-id>/`; never
write them beside or over the attachment.

## Processing events

Append one compact JSON object per line:

```json
{"capture_id":"CAP-...","recorded_at":"2026-01-01T12:00:01-03:00","state":"pending","detail":"awaiting interpretation"}
```

Allowed normal states are `pending`, `interpreted`, `reconciled`, `conflicted`,
and `blocked`. Append transitions; never edit or delete prior lines. Retry logic
must inspect the existing capture ID and events rather than duplicating the
capture.

## Screenshot and video interpretation

Write `_evidence/interpretations/<capture-id>.md` only after the immutable
capture exists. For screenshots, keep `Direct observations`, `AI inferences`,
and `Unresolved` distinct. Link every inference to its supporting observation
and label confidence.

For video, follow [video-processing.md](video-processing.md). Preserve onscreen
text and audible speech as separate sources, retain timestamps and uncertainty,
and treat sampled frames and machine speech recognition as fallible. Do not
complete interpretation while an audio stream has not been checked for speech.

Never convert an inference into a user observation or fill an evidence gap from
latent subject knowledge in firsthand-only mode.

## Human synthesis and clickable provenance

Every material human-facing section links its evidence at the end of that
section. Use descriptive labels instead of bare capture IDs in prose.

When the active collection is an Obsidian vault (a containing `.obsidian/`
directory exists) or the user requests Obsidian links, use native wikilinks for
every internal note/evidence reference and embed:

```markdown
### Music room

Play the directions in the order recorded here.

Sources: [[contexts/main/_evidence/captures/2026-01-01/CAP-...|Music Box discovery]] ·
[[contexts/main/_evidence/captures/2026-01-01/CAP-...|working sequence confirmed]]
```

Resolve wikilink paths from the Obsidian vault root, keep a human-readable alias,
omit `.md` for notes, and use `![[path|label]]` for media embeds. Otherwise use
portable relative Markdown links. Do not mix internal link styles within one
human note. Record the selected style in `_evidence/state.md`.

The capture ID remains in the target filename for exact provenance. A full
evidence chain is available on request. Chat history is working context only;
no fact, correction, decision, open item, or provenance needed for continuity
may remain chat-only.

## Reconciliation checkpoints

Reconcile when the user asks to organize or checkpoint, before a question that
needs current cross-session knowledge, and when the activity session ends.
Apply explicit corrections and material state changes immediately.

1. Read pending/interpreted events and the minimum supporting captures.
2. Choose one canonical guide home for each durable subject and update it.
3. Add a meaningful journal entry when the evidence advances the activity;
   never mirror the raw capture ledger line by line.
4. Refresh the short `README.md` status and navigation.
5. Keep only genuinely useful unresolved work in `open-questions.md`. Unknown
   trivia is not automatically an open task, and resolved or scope-closed items
   leave this file.
6. Put human-labeled source links at the end of each changed section.
7. Append `reconciled` or `conflicted` processing events. Never remove prior
   events or captures.
8. Update `_evidence/state.md` and the root index only after the human notes
   agree.

## Conflict classes

- **Explicit correction:** supersede the incorrect current claim immediately,
  preserve the original capture, and link old and new claims.
- **State transition:** retain both states with their applicable times in the
  journal or relevant guide history.
- **Ambiguous conflict:** preserve both claims, mark current knowledge
  uncertain, append `conflicted`, and ask the user. Do not choose by latent
  knowledge, confidence, or recency alone.

## Firsthand-only and external overrides

`_evidence/state.md` starts with `Epistemic mode: firsthand-only`. In this mode,
the active context is the entire permitted knowledge universe. When evidence is
insufficient, say so without revealing, confirming, denying, hinting at, or
steering around the missing fact.

An outside-knowledge override must be explicit and scoped. Label the response
as model knowledge or external research. If retained, write it under
`external/` with provenance and never merge it into firsthand truth. Return to
firsthand-only mode after the scoped response.

## Layout-version-1 migration

Legacy contexts use `context.md`, `timeline.md`, `open-items.md`, `topics/`, and
`inbox/`. Helpers continue to recognize an intact legacy `inbox`, but do not
mix `inbox` and `_evidence` in one context.

Use `scripts/Migrate-SecondBrainHumanLayout.ps1` for migration. It:

- renames the intact `inbox` backend to `_evidence`;
- preserves legacy synthesis files under `_evidence/legacy-synthesis/`;
- promotes existing `topics/` to `guide/`;
- creates the human home, guide/journal indexes, and open-questions page;
- verifies hashes for captures, interpretations, media derivatives,
  attachments, legacy syntheses, and topic notes;
- writes `_evidence/migration-manifest.json`.

The script refuses partial or ambiguous layouts and attempts rollback on
failure. Do not manually perform only part of this move.

## Archive and permanent deletion

Archive by setting lifecycle to `archived`; preserve every file.

Before permanent deletion, require an explicit request, enumerate affected
contexts/evidence/media/references, present the impact, obtain a later explicit
confirmation, execute one bounded deletion and reference-repair operation, and
report partial failure. Never infer deletion permission from archive, cleanup,
reset, or restart language.
