# AI Second Brain Vault Instructions

This folder is a user-owned AI second-brain vault. Its Markdown and media files
are authoritative; Codex chat history is not.

Use the installed `$ai-second-brain` skill for capture, organization,
reconciliation, retrieval, correction, resumption, archive, or deletion work.
Treat the directory containing this file as the vault root.

## Mandatory behavior

- After Codex accepts deliberate evidence, a question, correction, decision,
  hypothesis, open item, screenshot, video, or dictated transcript, persist the
  complete input to the active context's immutable evidence backend as the
  first agent action (`_evidence` in layout version 2, or the intact `inbox` in
  an unmigrated legacy context). Interpret or answer it only after persistence
  succeeds. Pure
  initialization, context-selection, authorization, archive-confirmation, and
  deletion-confirmation commands are control inputs.
- Default to firsthand-only mode. Behave as though facts absent from the active
  context are unknown. Do not reveal, confirm, deny, hint at, or steer around
  latent model knowledge.
- Read and write only the active context unless the user explicitly requests a
  cross-context operation.
- Keep original captures and completed screenshot or video attachments
  immutable. Store interpretation, machine transcripts, processing changes,
  corrections, and synthesis separately with capture-ID provenance.
- Label AI inference and uncertainty. Do not present inference as user
  evidence.
- Use outside knowledge only for an explicit scoped request, label it, retain
  it only under `external/`, and then return to firsthand-only mode.
- Never auto-delete captures. Archive preserves evidence. Permanent deletion
  requires impact preview and explicit confirmation.
- When `$ai-second-brain` needs one bounded choice, use Codex
  `request_user_input` if available, with two or three evidence-grounded
  options and no auto-resolution for a blocking gate. Keep open-ended captures
  and questions in plain text, never leak latent knowledge through the options,
  and apply capture-first routing to the returned answer.
- Do not add a hosted service, model API, plugin, connector, or authoritative
  database.
- An optional SQLite FTS5 file under `.index/` is allowed only as a disposable,
  rebuildable retrieval cache. Keep one index per context, exclude sibling and
  outside-knowledge material by default, and open the original Markdown before
  answering. Optional local text embeddings may augment FTS5 only through an
  explicitly authorized loopback model; similarity is never evidence and may
  not merge references or resolve conflicts. The index is never evidence or
  authoritative storage.
- The initializer configures automatic local search. Initialization and later
  retrieval can use the configured loopback embedding model when that model is
  already installed, fall back to lexical FTS5, or fall back to ordinary file
  search. They must never install or pull a runtime/model automatically.
  Refresh a stale index at retrieval or after a checkpoint, never during fast
  intake.
- Treat standalone logging as fast intake: persist the accepted message and
  attachment, leave it pending, acknowledge it, and return without loading or
  rewriting the guide, journal, questions, or state. Interpret and reconcile
  when the user asks to process, answer, organize, checkpoint, or end the
  session, or when a correction or urgent contradiction requires it.

## Human-facing organization

- Treat `README.md`, `guide/`, `journal/`, and `open-questions.md` as the
  notebook people read. When visual/media material exists, treat `library/` as
  its searchable semantic catalog and reusable reference surface. Treat
  `_evidence/` as the audit and processing backend.
- In an unmigrated legacy context, keep using its existing paths until the
  migration helper is authorized. Never create a partial mix of `inbox` and
  `_evidence`.
- Keep `README.md` short and navigational. Put a subject in one canonical guide
  note and link to it instead of repeating the same paragraph in several files.
- Use natural filenames and headings. Never require a person to know a capture
  ID to find an item, character, place, puzzle, decision, or event.
- Put clickable, human-labeled source links at the end of the section they
  support. Keep capture IDs out of ordinary prose unless the user asks for the
  evidence chain.
- In an Obsidian collection, use native vault-relative `[[path|label]]` links
  and `![[path|label]]` media embeds consistently. Use relative Markdown links
  in a client-neutral vault.
- Keep `_evidence/` visible as the clearly named backend unless the user asks
  to hide or exclude it.
- Write journal entries as meaningful sessions or chapters, not one line per
  capture. Keep only useful unresolved work in `open-questions.md`; move
  resolved or scope-closed material to its canonical guide or journal note.
- Give interpreted media natural descriptor filenames, searchable aliases, and
  inline previews under `library/`. Reuse one stable reference page for the
  same object, glyph, tile, symbol, font, or other recurring visual subject;
  preserve confirmed exemplars and confusable distinctions instead of
  recognizing it from scratch on every capture.
- When a chat answer relies on an available screenshot or processed video
  frame, render a relevant image inline as well as linking the note or source.

At the start of a fresh task, read `second-brain.md`, announce the active
collection/context, and stop for clarification when selection is ambiguous.
Read only the minimum active-context human notes and `_evidence` records needed
for the current action.
