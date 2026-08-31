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
trackers/                  # optional after recurring state exists
  <natural-subject-name>.md
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
  relations.jsonl          # new vaults; created lazily for older v2 contexts
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
- `trackers/`, when recurring state or exhaustive enumeration is justified:
  human-readable current-state tables with stable IDs, lifecycle state, and
  opening/closing evidence;
- `library/`, when visual or media evidence exists: searchable semantic capture
  descriptors and reusable reference pages for objects, symbols, glyphs, UI,
  places, and other recurring visual subjects.

Use natural filenames and headings. A person must not need a capture ID to find
an item, place, character, puzzle, decision, or event. Keep each subject in one
canonical guide note; cross-link instead of copying the same paragraph into
multiple files. Do not let `README.md` become another full knowledge dump.

Do not pre-create empty subject taxonomies. `guide/index.md` and
`journal/index.md` are the only required empty indexes. Create a guide note
when accumulated evidence justifies it. Create `library/` only when the first
semantic media descriptor or reusable reference is justified.

## Evidence backend

`_evidence/` is authoritative but machine-oriented:

- `state.md` owns context identity, lifecycle, epistemic mode, compact scope,
  and latest-checkpoint metadata;
- `captures/` owns immutable original deliberate inputs;
- `interpretations/` owns derived observations and inferences;
- `media-processing/` owns reproducible video metadata, sampled frames,
  extracted audio, and machine transcripts;
- `visual-exemplars/`, when needed, owns derived crops or comparison sheets
  used by human-facing visual reference pages;
- `processing-events.jsonl` is the append-only processing ledger.
- `relations.jsonl` is the append-only provenance-backed relation ledger for
  capture groups, corrections, item identity, source, parent/child lifecycle,
  and map anchors.

`attachments/` contains immutable capture-ID media. It remains outside
`_evidence/` so existing vault-relative attachment links stay stable and human
notes can embed media. `external/` contains explicitly requested outside
knowledge with provenance.

Normal human reading and search should start in `README.md`, `guide/`, and
`journal/`. Keep `_evidence/` visible as the clearly named backend by default;
do not change client exclusion settings unless the user asks. Obsidian or any
other particular client remains optional.

## Disposable local indexes

Optional generated search indexes live under the vault root's `.index/`
directory, never inside a context's human notebook or evidence backend. Keep
one index per context, exclude outside-knowledge material by default, and
record enough path/hash metadata to detect staleness. An index may rank and
quote candidate source sections but never owns knowledge. Delete and rebuild it
from authoritative Markdown whenever its scope or integrity is uncertain.

The initializer records search mode `auto` and embedding model `embeddinggemma`
in `_evidence/state.md`. Initialization bootstraps the disposable index when
local prerequisites are already available. Indexed retrieval automatically
creates a missing index or refreshes a stale one; fast intake never loads or
updates it. Automatic mode degrades from hybrid to lexical FTS5 to ordinary
file search without blocking capture or installing a dependency.

An automatically or explicitly enabled local semantic layer may store
normalized text embeddings beside the FTS5 rows in the same disposable
database. Embeddings are derived
retrieval metadata: model identity and dimension must be recorded, the same
model must serve indexing and querying, and similarity cannot create or alter
knowledge. Do not store visual embeddings or media bytes in this text index.

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
capture_group_id: GRP-...
group_ordinal: 1
previous_capture_group_id: null
display_title: "User-grounded short title or null"
keywords: ["searchable", "terms"]
attachment: none
attachment_state: none
---

# Original input

Exact deliberate user text or corrected voice transcript.

# User caption

Caption supplied with a screenshot, or `None`.
```

Allowed input types are `text`, `voice`, `screenshot`, and `video`.

One accepted message has one `GRP-YYYYMMDD-HHMMSS-ffff` capture-group ID.
Every attachment created from that message reuses the group and receives a
unique ordinal in attachment order. When known, record the immediately
preceding accepted message's group so deictic phrases such as "the previous
message" have a durable target. Old captures without group fields remain
valid.

For `voice`, the original input is the corrected transcript. Do not retain raw
microphone audio.

For screenshot or video input, copy a readable local source to
`attachments/<capture-id>--<semantic-slug><extension>` when a short title can
be grounded in the user's accepted words without inspecting the media.
Otherwise use `attachments/<capture-id><extension>`. The capture ID always
leads the immutable filename. Record the vault-relative path and use
`attachment_state: ready`. A title and keywords are search metadata, not
evidence that the named object is visually present. Never inspect or interpret
media before the immutable copy merely to invent a filename. When no local
source is available, use
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
`blocked`, and `scope-closed`. `scope-closed` is terminal for evidence the user
explicitly declines to process or removes from the active objective. Append
transitions; never edit or delete prior lines. Retry logic must inspect the
existing capture ID and events rather than duplicating the capture.

The latest event per capture defines the assimilation queue. `pending` means
the input is durable but still awaits any needed interpretation, semantic media
description, reference linking, or checkpoint reconciliation. A fast intake
may intentionally stop in this state; pending is not a failed capture.

## Capture relations and current state

Follow [state-tracking.md](state-tracking.md) whenever chat order, item state,
quantity, source attribution, parent/child lifecycle, map position, or an
exhaustive list matters.

Relations are append-only JSON objects shaped like:

```json
{"relation_id":"REL-...","recorded_at":"2026-01-01T12:00:01-03:00","source_id":"RING-001","relation":"obtained-from","target_id":"CHEST-004","status":"active","evidence_capture_ids":["CAP-..."],"supersedes_relation_id":null,"detail":"Directly stated source"}
```

Use stable current-state tracker rows under `trackers/` only when recurring
state or bounded enumeration justifies them. Trackers have one canonical row
per instance or task, unique IDs, explicit state and quantity, optional parent
and map-anchor IDs, and capture-backed opening/closing evidence. They are
ordinary Markdown and are indexed as human notes. Do not create a second
AI-only prose copy of the same current state.

Identity and source attribution are independent. A batch may resolve an item
count without assigning each result to its source. Likewise, a confirmed
harvest updates its parent planting even when the reward remains unidentified.
The relation and tracker invariants are validated by the read-only context
auditor.

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

When media contains a map, record a stable `map-anchor` tracker row from the
visible era, label, selected grid cell or normalized marker position, viewport,
landmarks, confidence, and source capture even when the caption does not call
the position important. Same area without a supported cell or landmark match
does not establish the same location.

## Semantic media library

Use the optional human-facing `library/` for descriptive capture names,
previews, aliases, recurring visual subjects, confusable examples, and
confirmed font or glyph mappings. Derived visual crops belong under
`_evidence/visual-exemplars/`; immutable sources remain in `attachments/`.
Follow [visual-library.md](visual-library.md) whenever assimilating, connecting,
or retrieving visual evidence.

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
Outside an explicitly selected fast-intake mode, apply explicit corrections
and material state changes immediately.

1. Acquire the cooperative reconciliation lock. Another live owner may
   continue independent fast capture but prevents shared-note, tracker, state,
   and index writes.
2. Run `scripts/Test-SecondBrainContext.ps1`, then read pending/interpreted
   events, relations, trackers, and the minimum supporting captures.
3. Choose one canonical guide home for each durable subject and update it.
4. Add a meaningful journal entry when the evidence advances the activity;
   never mirror the raw capture ledger line by line.
5. Refresh the short `README.md` status and navigation.
6. For interpreted media, create or refresh semantic capture descriptors and
   link recurring subjects to their canonical visual reference pages.
7. Update the canonical tracker row and append supported relations for every
   current-state or lifecycle change.
8. Keep only genuinely useful unresolved work in `open-questions.md`. Unknown
   trivia is not automatically an open task, and resolved or scope-closed items
   leave this file.
9. Put human-labeled source links at the end of each changed section.
10. Append `reconciled`, `conflicted`, `blocked`, or `scope-closed` processing
   events for every capture in the processed batch. Never remove prior events
   or captures.
11. Keep `_evidence/state.md` compact and current. Historical checkpoint deltas
   belong in the ledgers or journal. Update it and the root index only after the
   human notes and trackers agree.
12. Rerun the auditor, report exact coverage and pending counts, rebuild the
   disposable search index after consistency succeeds, and release the exact
   owned reconciliation lock in a `finally` path.

At completion, use the auditor's completion gate. A completed lifecycle cannot
silently retain pending captures or pending-save-first attachments. A later
summary or duplicate capture does not terminally disposition an earlier source.

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
