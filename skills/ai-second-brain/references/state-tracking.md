# Durable State Tracking

Read this reference before grouping a multi-attachment input, relating a later
message to an earlier event, maintaining current state, generating an
exhaustive list, interpreting map position, reconciling shared notes, or
closing a context. Captures remain immutable evidence. This layer makes the
current state and its provenance explicit instead of relying on chat order or
semantic recall.

## Capture groups

One accepted user message is one capture group, even when it creates several
capture files. Before the first capture helper call, allocate:

```text
GRP-YYYYMMDD-HHMMSS-ffff
```

Pass the same `-CaptureGroupId` to every capture created from that accepted
message, use `-GroupOrdinal 1`, `2`, and so on in attachment order, and pass
the immediately preceding accepted message's group through
`-PreviousCaptureGroupId` when it is known. A single-capture message still has
one group; the helper derives it from the capture ID when the caller omits it.

Phrases such as "the previous message", "that Ring", or "this Nut" refer to
the durable predecessor group first. Do not jump to an older semantically
similar event. If the predecessor contains several plausible subjects, keep
the relation unresolved rather than selecting by model confidence.

## Append-only relations

Use `scripts/Add-SecondBrainRelation.ps1` after every supported cross-capture
connection. The relation ledger is `_evidence/relations.jsonl`. Common
relations are:

- `same-event` between companion capture groups or captures;
- `resolves` and `supersedes` for corrections and completed questions;
- `obtained-from` for a reward and its actual source;
- `identified-as` for an instance and its identified result;
- `harvest-of` for a collected product and its parent planting;
- `located-at` for an event and a stable map anchor;
- `candidate-link` when the evidence supports a possibility but not a merge.

Each relation records a source ID, relation type, target ID, status, detail,
and one or more evidence capture IDs. Use `active` only for a supported current
relation. Use `candidate` for unresolved alternatives. Supersede or reject an
earlier relation through a later append-only relation event; never edit the
old line.

Stable IDs may identify captures, groups, map anchors, or tracker rows. A
relation never changes immutable evidence and never turns similarity into a
fact.

## Human-readable current-state trackers

Create `trackers/` only after the context has recurring state, relations, or a
request for an exhaustive list. Trackers are the canonical human-readable
surface for current state; captures and interpretations remain its evidence.
Copy [../assets/vault/tracker.md](../assets/vault/tracker.md) when helpful and
replace its two placeholders. Use one or more natural subject files with this
frontmatter and exact table shape:

```markdown
---
tracker_schema: ai-second-brain/v1
tracker_type: game-state
---

| ID | Kind | Label | State | Quantity | Parent ID | Map anchor | Opened by | Closed by | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `RING-001` | ring-instance | Unidentified Ring from north chest | unidentified | 1 |  | `MAP-004` | `CAP-...` |  | Awaiting appraisal |
```

Use stable IDs and one row per real instance or task. Keep a batch or pool row
only when the evidence does not distinguish instances. `Opened by` and
`Closed by` contain capture IDs, not chat references. Do not duplicate one
current fact across several trackers.

Useful kinds include `task`, `item-instance`, `resource`, `planting`,
`harvest`, `secret`, and `map-anchor`. Domain-specific states are allowed, but
use the same spelling consistently. Prefer terminal states `resolved`,
`completed`, `scope-closed`, `superseded`, and `historical` when applicable.

### State invariants

- Identification and source attribution are separate. A batch appraisal can
  reduce the unidentified quantity to zero while leaving the mapping from
  names to source instances unresolved.
- A confirmed `identified-as` relation cannot coexist with an
  `unidentified` or `pending-appraisal` current state.
- A confirmed `harvest-of` relation moves its parent planting out of
  `planted` or `harvest-pending` state.
- Tracker IDs are unique. A planting, harvest, Secret, item instance, or task
  appears once in the current-state tables.
- A resolved task retains opening and closing evidence but does not remain in
  an active pending list.
- Secret discovery, recipient, handoff, challenge, reward, return password,
  and return-password use are separate lifecycle fields or tracker rows. Do
  not equate one stage with another.
- Quantities and state changes are updated even when per-instance provenance
  remains uncertain. Record the uncertainty in the relation, not by leaving a
  completed action open.

## Exhaustive requests

Treat `all`, `every`, `complete`, `exhaustive`, `remaining`, `pending`, and
`checklist` as enumeration language when the request concerns a bounded set.
Do not answer such a request from top-ranked search results.

1. Run `scripts/Test-SecondBrainContext.ps1` and read every relevant tracker
   row plus the latest processing event for every capture.
2. Enumerate the full requested kind, including completed, unresolved,
   scope-closed, and superseded rows when the requested scope requires them.
3. Reconcile pending evidence capable of adding, closing, or changing a row.
4. Account for every row as included, excluded with a reason, or unresolved.
5. Report coverage, for example `10 discovered Secrets: 10 listed, 0
   excluded`. If the universe is not established, say `not verified
   exhaustive`.

Semantic or lexical search may find evidence for a row, but it cannot prove
that the enumeration is complete.

## Map anchors

When a screenshot contains a map, create or update a `map-anchor` tracker row
even when the user's prose does not call the position important. Record only
what the pixels and active context support:

- era or time state;
- visible map label;
- selected grid row/column, or normalized marker coordinates from `0` to `1`;
- viewport or crop identity when the whole map is not shown;
- stable neighboring landmarks;
- confidence and source capture.

Use a stable `MAP-*` ID. Connect events through `located-at`. Compare exact
anchors before comparing prose. Same region is not same cell; visual
similarity without a supported coordinate or landmark match stays a
`candidate-link`.

## Quick-capture corrections

An explicit user-selected fast-intake mode governs ordinary corrections too.
Capture the correction first and, when the target is mechanically known, add
an append-only `supersedes` or `resolves` relation. Do not load and rewrite the
guide, journal, trackers, state, library, or search index until the user asks
for assimilation. An urgent contradiction or safety-relevant correction may
still require immediate reconciliation.

This preserves corrected evidence promptly without turning a quick note into
a long checkpoint.

## Serialized reconciliation

Fast capture remains safe while another task reconciles. Shared human notes,
trackers, state, and generated indexes require one reconciliation owner.

1. Acquire `_evidence/reconciliation.lock.json` with
   `scripts/Manage-SecondBrainReconciliationLock.ps1 -Action acquire` and a
   stable task/session owner ID.
2. If another live owner holds the lock, stop shared-note writes. Continue
   only independent fast capture or wait for that owner.
   Reacquiring with the same owner renews its bounded lease.
3. A stale lock is not automatic takeover authority. Use `-TakeOverStale` only
   after verifying the prior task is no longer reconciling.
4. Run the context auditor before edits, reconcile from fresh source bytes,
   and run it again afterward.
5. Release the exact owned lock in a `finally` path.

## Completion and disposition

The latest processing event defines whether a capture remains in the queue.
Use `scope-closed` when the user explicitly says evidence does not need
interpretation or no longer belongs to the active objective. Do not leave an
intentionally skipped clip or resolved note `pending`.

Before declaring a checkpoint clean or a context completed, run:

```powershell
scripts/Test-SecondBrainContext.ps1 `
  -VaultPath '<vault>' `
  -CompletionGate
```

Every capture must be reconciled, conflicted, blocked with a truthful reason,
or scope-closed. Report exact remaining counts. A later capture that conveys
the same fact does not silently close the earlier capture; give each original
capture its own terminal disposition.

## Surface and session bounds

`_evidence/state.md` contains current compact metadata, never a growing
checkpoint history. Put history in the append-only ledgers or meaningful
journal chapters. Keep the home navigational, split oversized journal
chapters, and remove active-sounding index text when the context is completed.

The context auditor warns about oversized surfaces, repeated checkpoint-delta
fields, broken links, stale completed-context language, and capture sessions
with too many groups. Treat a session warning as a proactive task-rollover
signal: finish only the accepted capture, then continue in a fresh task rooted
at the same vault. Do not wait for platform compaction when durable counts
already show that the session is too large.
