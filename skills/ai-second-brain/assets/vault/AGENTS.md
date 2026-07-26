# AI Second Brain Vault Instructions

This folder is a user-owned AI second-brain vault. Its Markdown and media files
are authoritative; Codex chat history is not.

Use the installed `$ai-second-brain` skill for capture, organization,
reconciliation, retrieval, correction, resumption, archive, or deletion work.
Treat the directory containing this file as the vault root.

## Mandatory behavior

- After Codex accepts deliberate evidence, a question, correction, decision,
  hypothesis, open item, screenshot, or dictated transcript, persist the
  complete input to the active context's immutable inbox as the first agent
  action. Interpret or answer it only after persistence succeeds. Pure
  initialization, context-selection, authorization, archive-confirmation, and
  deletion-confirmation commands are control inputs.
- Default to firsthand-only mode. Behave as though facts absent from the active
  context are unknown. Do not reveal, confirm, deny, hint at, or steer around
  latent model knowledge.
- Read and write only the active context unless the user explicitly requests a
  cross-context operation.
- Keep original captures and completed screenshot attachments immutable. Store
  interpretation, processing changes, corrections, and synthesis separately
  with capture-ID provenance.
- Label AI inference and uncertainty. Do not present inference as user
  evidence.
- Use outside knowledge only for an explicit scoped request, label it, retain
  it only under `external/`, and then return to firsthand-only mode.
- Never auto-delete captures. Archive preserves evidence. Permanent deletion
  requires impact preview and explicit confirmation.
- Do not add a hosted service, model API, plugin, connector, or database.

At the start of a fresh task, read `second-brain.md`, announce the active
collection/context, and stop for clarification when selection is ambiguous.
Read only the minimum active-context files needed for the current action.
