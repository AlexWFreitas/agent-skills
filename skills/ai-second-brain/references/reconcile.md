# Reconcile the notebook

Read [vault-contract.md](vault-contract.md) and
[state-tracking.md](state-tracking.md) before reconciliation, correction, or
completion. For game-specific synthesis, also read
[game-playthrough.md](game-playthrough.md). For media descriptors, read
[visual-library.md](visual-library.md).

## Reconcile at checkpoints

Reconcile when the user asks to organize/checkpoint, before answering a query
that needs current cross-session knowledge, and when the user ends the activity
session. Outside explicit fast-intake mode, apply explicit corrections and
material state changes immediately.

1. Acquire the reconciliation lock and audit fresh source bytes. Another live
   owner blocks shared-note, tracker, state, and index writes.
2. Read pending/interpreted events, relations, trackers, and minimum supporting
   captures oldest-first; report any bounded-batch remainder.
3. Update one canonical guide home, meaningful journal chapter, short home,
   and only still-useful open questions. Unknown trivia is not automatically a task.
4. Create media descriptors and connect recurring subjects to canonical visual
   references when media is interpreted.
5. Update canonical tracker rows and append supported state relations using the
   invariants in [references/state-tracking.md](state-tracking.md).
6. Add human-labeled, clickable evidence links, classify conflicts, and append
   a truthful latest event for every capture in the processed batch. For
   Obsidian, use vault-relative `[[path|label]]` wikilinks.
7. Keep `_evidence/state.md` to current metadata and one latest checkpoint;
   put history in the ledgers or journal.
8. Audit again, report exact coverage/pending counts, rebuild the search index
   only after consistency succeeds, and release the owned lock in `finally`.

After the checkpoint files agree, read
[local-search-index.md](local-search-index.md) if search is enabled, then run
[scripts/Ensure-SecondBrainSearchIndex.ps1](../scripts/Ensure-SecondBrainSearchIndex.ps1)
with `-ForceRebuild` unless the context records search mode `off`. Automatic
mode uses the configured loopback embedding model when that model is already
installed. It falls back to lexical FTS5 or ordinary files. Never create or
refresh an index during fast intake.

Do not create empty guide taxonomies. A checkpoint may legitimately conclude
that no new guide note is justified. For an intact legacy layout, retain its
paths until the migration helper is explicitly authorized; do not create a
partial mix of `inbox` and `_evidence`.

Keep `_evidence/` visibly named as the backend by default. Do not hide it or
change a client's excluded-file settings unless the user explicitly asks.

## Correct and resolve conflicts

- **Explicit correction:** capture the correction first, update the canonical
  guide section immediately, preserve the superseded evidence, and record the
  change in the journal when it matters chronologically.
- **State transition:** preserve old and new states with applicable times.
- **Ambiguous conflict:** preserve both, mark current knowledge uncertain,
  append a `conflicted` event, and ask the user through a permitted channel.
  Offer choices only when supported by captured evidence; capture the resolution
  before applying it. Never choose by model memory, confidence, or recency alone.

In explicitly selected fast-intake mode, capture ordinary corrections and
supported relations immediately; defer multi-file synthesis until requested.
Use [lifecycle.md](lifecycle.md) for completion, archive, and deletion.
