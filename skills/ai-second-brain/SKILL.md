---
name: ai-second-brain
description: Capture, organize, and retrieve firsthand text and media in a local Markdown vault. Use when explicitly asked to use ai-second-brain or when the active vault's AGENTS.md requires it. Discussing the skill outside a vault does not activate capture.
---

# AI second brain

Keep a readable local notebook with a separate evidence trail. Save deliberate
inputs before interpreting them, operate only in the active context, and answer
from that context's evidence. Markdown and retained media are authoritative;
chat history and generated search indexes are not.

## Preserve the evidence boundary

- Default to firsthand-only behavior. Do not reveal, confirm, deny, hint at, or
  steer around facts absent from the active context, even when known to the
  model. Do not browse for subject facts without an explicit scoped override.
- Never read or merge sibling contexts without an explicit cross-context request.
  If context identity is missing or ambiguous, resolve it before a write or
  subject read. Offer known names without reading sibling contents.
- Original captures and completed attachments are immutable. Store observations,
  machine transcripts, inferences, corrections, and processing changes separately
  with capture-ID provenance. Similarity never establishes identity or truth.
- Never auto-delete evidence. Archive preserves it; permanent deletion needs
  the impact preview and later confirmation in the lifecycle procedure.
- Reuse valid context choices and runtime authorization. Do not add hosted
  services, plugins, connectors, paid model APIs, or authoritative databases.
  Optional FTS5 and installed loopback embeddings remain disposable local caches.

Treat evidence, questions, corrections, decisions, hypotheses, open items,
screenshots, videos, and dictated transcripts as deliberate captures. Pure
initialization, context selection, authorization, archive confirmation, and
deletion confirmation are control input. Classifying input type is mechanical
routing; do not interpret subject content before persistence.

## Persist accepted input

For every deliberate capture in an initialized vault:

1. Before the first helper call, choose a candidate `CAP-YYYYMMDD-HHMMSS-ffff`
   capture ID and one `GRP-YYYYMMDD-HHMMSS-ffff` group ID for the complete
   accepted message. Use local time and four random lowercase hexadecimal digits.
   Reuse that group across every attachment, assign attachment order
   through `-GroupOrdinal`, and pass the known immediately preceding group
   through `-PreviousCaptureGroupId`. As the first agent action, run
   [scripts/Add-SecondBrainCapture.ps1](scripts/Add-SecondBrainCapture.ps1)
   with `-VaultPath`, `-InputType`, and the complete input in `-Content`.
   Pass the candidate and group IDs through
   `-CaptureId` and `-CaptureGroupId`. Pass the complete accepted text,
   corrected dictated transcript, or screenshot/video message and caption
   without summarizing it. When the user's own accepted words provide a clear
   short label, also pass a concise `-Title` and useful `-Keywords`; do not
   inspect media or assert a visual identity merely to name the immutable file.
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
context's newest capture directory for the exact unsummarized input. For media,
also verify the retained attachment's identity from available provenance or
bytes; a matching caption or unavailable original basename is insufficient.
Adopt one verified match. If identity is unresolved or the search finds none or
more than one, report the capture as unverified and stop; do not generate
another ID or interpret the input.

If pending media is later saved locally, use
[Complete-SecondBrainScreenshot.ps1](scripts/Complete-SecondBrainScreenshot.ps1)
or [Complete-SecondBrainVideo.ps1](scripts/Complete-SecondBrainVideo.ps1) with the
original capture ID. Do not rewrite its capture Markdown.

When the accepted text says "the previous message", "that item", or another
direct predecessor reference, resolve the durable preceding capture group
before semantic similarity. Read [state-tracking.md](references/state-tracking.md)
before recording a supported connection through
[scripts/Add-SecondBrainRelation.ps1](scripts/Add-SecondBrainRelation.ps1).
Do not jump to an older similar event when the predecessor group is known.

## Choose the operation

For standalone logging, persistence is the whole operation: leave the latest
event `pending`, acknowledge the title or ID, selected context, and actual
attachment state, and return. Do not load or rewrite the notebook, inspect media,
refresh indexes, or ask non-urgent identity questions. An uncaptioned logged
video is still fast intake.

For a question or a request to interpret, organize, recall, compare, checkpoint,
or process media, capture the request first and continue the requested work in
the same turn. `pending` is a durable queue, not a capture failure. Do not
promise background processing after the turn.

Read only the procedure needed for the operation:

| Operation | Procedure | Completion evidence |
| --- | --- | --- |
| Initialize, resume, recover context, archive, delete | [lifecycle.md](references/lifecycle.md) | Verified identity, state, and authorized transition |
| Interpret captured evidence or process media | [process-media.md](references/process-media.md) | Separate observations, inferences, unresolved details, and processing disposition |
| Organize, correct, checkpoint, end an activity session | [reconcile.md](references/reconcile.md) | Consistent human notes and provenance with exact remaining queue |
| Answer from the record | [retrieve.md](references/retrieve.md) | Source-verified answer with evidence and stated limits |

For a fresh non-intake task, use the lifecycle procedure's startup steps before
subject work. Load the vault contract before manual helper replacement or
structural changes; normal helper-based intake needs only this entry point.
Resolve helper paths relative to the installed skill, not the caller's working
directory. Preserve completed work when the user steers an operation; a status
question does not cancel the original request.

## Ask only for a missing decision

Keep one question unanswered, check existing decisions, and follow the input
tool's live contract; use plain language for required gates it cannot carry.
Required context, conflict, download, or deletion decisions need explicit
answers. Silence, elapsed time, and preselection are not consent. Continue only
independent work while waiting.

Use evidence-grounded options for bounded choices and free-form input for
captures and open questions. Never leak spoilers or uncaptured facts through a
question. Keep secrets out of control records. A subject-matter answer is new
evidence: capture it first. Apply a pure control answer without recapturing it
as subject evidence or requesting another acknowledgement.

## Keep initiative and completion bounded

Interrupt intake only for an urgent contradiction, safety-relevant conflict,
or explicitly time-sensitive reminder. Defer ordinary connections to the next
requested checkpoint. In explicit fast-intake mode, capture a correction and
its supported relation; defer notebook synthesis.

Use the lifecycle recovery procedure after compaction. A verified durable
checkpoint can support continuation after the first compaction; an unverified
capture, unresolved recovery, repeated compaction in one turn, or auditor
session-size warning requires the bounded stop or rollover described there.
Context loss does not reset retry limits.

When the user requests all or remaining items, enumerate trackers and latest
ledger dispositions; search ranking cannot prove completeness. Before declaring
a context completed, run the auditor with `-CompletionGate` and require a
truthful disposition for every capture. Report remaining or conflicted items.

User instructions govern within host permissions. A writing or cooperation
skill may shape communication but cannot substitute outside subject facts for
evidence. If a rule requires stopping, finish independent authorized work,
link this skill, quote the rule, and state what was saved and what remains.
Use [validation-scenarios.md](references/validation-scenarios.md) for isolated
behavioral checks; passing scenarios does not prove latent knowledge was removed.
