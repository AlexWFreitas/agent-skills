# Vault Contract

This document defines the authoritative portable data contract. The skill owns
behavior; these ordinary Markdown and media files own durable knowledge.

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

## Context layout

Every context contains:

```text
context.md
timeline.md
open-items.md
inbox/
  captures/
    YYYY-MM-DD/
      <capture-id>.md
  interpretations/
    <capture-id>.md
  processing-events.jsonl
topics/
attachments/
external/
```

- `context.md` owns context identity, lifecycle, epistemic mode, current-state
  synthesis, and latest checkpoint.
- `timeline.md` owns meaningful chronological developments.
- `open-items.md` owns actionable tasks, unresolved questions,
  contradictions, and hypotheses.
- `inbox/captures/` owns immutable original deliberate inputs.
- `inbox/interpretations/` owns derived observations and inferences.
- `inbox/processing-events.jsonl` is an append-only event ledger. It does not
  replace capture evidence.
- `topics/` contains notes created only when accumulated evidence justifies
  them.
- `attachments/` contains immutable capture-ID media.
- `external/` contains explicitly requested outside knowledge and provenance.

Do not create speculative empty topic categories.

## Capture identity

Use an identifier shaped like:

```text
CAP-YYYYMMDD-HHMMSS-ffff
```

The final component is random lowercase hexadecimal. Generate with local time
for readability and record an ISO 8601 timestamp with UTC offset inside the
capture. File creation must reject collisions rather than overwrite.

Each immutable capture Markdown file contains:

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

Allowed input types are `text`, `voice`, and `screenshot`.

For `voice`, the original input is the corrected transcript. Do not retain raw
microphone audio.

For `screenshot`, `attachment` is a vault-relative path only after a readable
local source has been copied to `attachments/<capture-id><extension>`. Use
`attachment_state: ready` then. When no local source is available, use
`attachment: none` and `attachment_state: pending-save-first`. The capture is
durable but screenshot evidence is incomplete until the user saves the image
locally and a new completed capture or explicitly linked completion event is
created.

## Processing events

Append one compact JSON object per line. Required properties:

```json
{"capture_id":"CAP-...","recorded_at":"2026-01-01T12:00:01-03:00","state":"pending","detail":"awaiting interpretation"}
```

Allowed normal states are `pending`, `interpreted`, `reconciled`, `conflicted`,
and `blocked`. Append transitions; never edit or delete prior lines. Retry
logic must inspect the existing capture ID and events rather than duplicating
the capture.

## Screenshot interpretation

Write `inbox/interpretations/<capture-id>.md` only after the immutable capture
exists. Keep these sections distinct:

- `Direct observations`: visible text, objects, spatial relationships, and UI
  state directly supported by the image;
- `AI inferences`: proposed meaning, each with confidence and supporting direct
  observations;
- `Unresolved`: unclear, obscured, or unreadable details.

Never convert an inference into a user observation. Never fill a visual gap
from latent subject knowledge in firsthand-only mode.

## Synthesized knowledge and provenance

Every material current-state claim, timeline entry, open item, or topic claim
links one or more capture IDs. Label inference and uncertainty. A compact
reference such as `[CAP-20260101-120000-ab12]` is sufficient in normal notes;
provide the complete chain when requested.

Chat history is working context only. No fact, correction, decision, open item,
or provenance needed for continuity may remain chat-only.

## Reconciliation checkpoints

Reconcile:

- when the user explicitly asks to organize or checkpoint;
- before a question requiring current cross-session knowledge;
- when the user ends the activity session.

Apply explicit corrections and material state changes immediately. Reconciliation
updates synthesized files and appends processing events but never destroys
captures.

## Conflict classes

- **Explicit correction:** supersede the incorrect current claim immediately,
  preserve the original capture, and link old and new claims.
- **State transition:** retain both states with their applicable times on the
  timeline.
- **Ambiguous conflict:** preserve both claims, mark current state uncertain,
  append a `conflicted` event, and ask the user. Do not choose by latent
  knowledge, confidence, or recency alone.

## Firsthand-only and external overrides

`context.md` starts with `Epistemic mode: firsthand-only`.

In this mode, the active context is the entire permitted knowledge universe.
When evidence is insufficient, say so without revealing, confirming, denying,
hinting at, or steering around the missing fact.

An outside-knowledge override must be explicit and scoped to the requested
question or boundary. Label the response as model knowledge or external
research. If retained, write it under `external/` with its provenance and never
merge it into firsthand truth. Return automatically to firsthand-only mode
after the scoped response.

## Archive and permanent deletion

Archive by setting the context lifecycle to `archived`; preserve every file.

Before permanent deletion:

1. require an explicit deletion request;
2. enumerate affected contexts, captures, attachments, derived notes, and
   inbound/outbound references;
3. present the impact and request confirmation;
4. only after confirmation, execute one bounded deletion and reference-repair
   operation;
5. report partial failure visibly and preserve recoverable state.

Never infer deletion permission from archive, cleanup, reset, or restart
language.
