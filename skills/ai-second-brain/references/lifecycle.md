# Vault lifecycle and recovery

Read [vault-contract.md](vault-contract.md) before initialization, resumption,
manual helper replacement, layout changes, archive, or deletion. For state,
reconciliation, or completion, also read [state-tracking.md](state-tracking.md).

## Initialize or migrate

Use [Initialize-SecondBrain.ps1](../scripts/Initialize-SecondBrain.ps1) for a new
vault and [Migrate-SecondBrainHumanLayout.ps1](../scripts/Migrate-SecondBrainHumanLayout.ps1)
only for an explicitly authorized migration. Preserve an intact legacy layout
until migration; never mix its evidence paths with the new layout.

Windows helpers provide deterministic mechanics. When unavailable, reproduce
the portable vault contract with safe local file tools. Do not substitute a
hosted service or authoritative database. Optional local search remains a
disposable cache and must not block the operation.

## Start or resume a task

For fast intake, let the capture helper resolve the active context from
`second-brain.md`; announce the selected collection/context in the brief
acknowledgement and stop. Do not hydrate the notebook merely to log another
entry.

For assimilation, retrieval, checkpointing, or a pure control command:

1. Treat the directory containing the governing vault `AGENTS.md` and
   `second-brain.md` as the vault root.
2. Read `second-brain.md` and announce the active collection/context before
   substantive work in a fresh task.
3. Stop for confirmation when no active context exists, multiple contexts
   plausibly match, or the opening input is a control command indicating
   another subject. Offer known context names through a permitted input channel
   without reading their contents. Do not ask again when the user has already
   selected the context explicitly. Do not read a sibling context while
   selection is ambiguous.
4. Read the selected context's `README.md`, `open-questions.md`, relevant guide
   and journal notes, optional `trackers/`, `_evidence/state.md`, processing and
   relation events, and only the minimum captures needed. Run
   [Test-SecondBrainContext.ps1](../scripts/Test-SecondBrainContext.ps1)
   before relying on a pending count or completeness claim. In an unmigrated
   legacy context, read the old `context.md` and `open-items.md` instead.
5. Resume from durable files. Never treat prior chat as required authority.

## Recover after context loss

Use chat as transport and durable vault files as authority. Keep each task
bounded to an activity session; do not use one task for a collection's lifetime.

After the first context compaction, perform one bounded recovery pass before
continuing dependent work:

1. Read the active context identity and minimum durable checkpoint, accepted
   capture, processing event, and relevant relations. Do not hydrate siblings or
   rediscover the complete tool catalog.
2. Establish whether the accepted input was saved. Use its candidate capture ID
   and the entry point's single idempotent retry, or its single exact-match
   recovery search when the ID is lost. A retry already used before compaction
   remains used; compaction does not reset the budget.
   If prior retry use is unknown, verify existing evidence without another
   write attempt; unresolved persistence still requires stopping.
   Verify the saved input bytes and its ledger disposition; an
   `existing-capture` helper return alone does not verify the intended content.
3. Verify the current operation, required prior decisions, actual artifact
   state, and authorization from the minimum durable records. Missing reliable
   evidence cannot be replaced by a confident chat summary.
4. Run the read-only context auditor before a completeness or pending-count
   claim. Continue the requested bounded operation only when identity,
   persistence, state, next action, and authority are established and no
   session-size warning requires rollover.

Compaction alone does not require ending a recoverable operation. If the pass
cannot establish safe continuation, report the accepted capture as
`captured`, `existing-capture`, or `unverified` as supported, preserve its
actual processing disposition, and request a fresh task rooted at the same
vault. Do not create a replacement task unless asked or fork a saturated task,
which would retain its history.

If a second compaction occurs in the same assistant turn, stop interpretation,
reconciliation, media processing, tool discovery, and further retries. Perform
at most one minimal candidate-ID existence check if needed, report actual
state, and request rollover. Do not claim completed interpretation or invent a
successful persistence result.

An auditor session-size warning still requires proactive rollover after
finishing or verifying the accepted capture. Do not bypass that warning merely
because a task still responds. A fresh task resumes from the minimum durable
state without requiring the old conversation.

Do not reread resources already available in the current context. After
compaction, reread only the operational instructions needed to recover safely;
lost context is not evidence that a helper or bridge failed. A new accepted
input before rollover must still be captured first, within the same bounded
rules, then followed by the rollover instruction.

## End, archive, or delete

At session end, reconcile, write the checkpoint, and report unresolved,
conflicted, or pending items.

Before marking a context completed, run
[scripts/Test-SecondBrainContext.ps1](../scripts/Test-SecondBrainContext.ps1) with
`-CompletionGate`. Every capture must have a truthful latest disposition.
Append `scope-closed` when the user explicitly declines processing or closes an
item; a later duplicate or summary does not silently close the original
capture. Do not claim completion or zero pending when the audit disagrees.

Archive only by changing lifecycle to `archived`; preserve evidence.

For permanent deletion, follow the impact-preview and confirmation procedure in
the vault contract. The initial request authorizes preview only. Do not delete
until a later unambiguous confirmation names the previewed scope. Use
the host's permitted approval channel, or plain text, for that later
confirm-or-cancel gate. Repair dangling references in the same bounded operation
and report partial failure.
