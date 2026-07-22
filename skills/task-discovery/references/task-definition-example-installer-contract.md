# Illustrative Installer Contract

This companion document is authoritative only for installer and refresh
behavior in `task-definition-example.md`. It demonstrates how substantial
specialist detail can remain linked and authoritative without overwhelming the
primary task definition.

## Selection and destinations

- Require explicit named selection or `-All` in the general installer.
- Let the convenience refresh entry point select the full catalog and default
  to Codex user scope.
- Support Codex user scope, an explicit external Codex repository checkout, and
  an explicit generic destination.
- Reject the canonical catalog checkout as a repository destination and reject
  every resolved source/destination overlap.

## Replacement transaction

1. Resolve the canonical catalog from the script location.
2. Validate every selected source and resolved exact-child destination before
   modifying any target.
3. Stage and validate the complete selected replacement set.
4. Retain complete backups until every selected swap succeeds.
5. Replace each exact selected child tree so source-deleted files do not remain.
6. On any swap failure, restore every changed selected target to its complete
   pre-command state.

## Safety invariants

- Never delete or replace the destination root, its parent-level files, sibling
  skills, this catalog checkout, or canonical `skills/`.
- Reject traversal, invalid skill names, source reparse points, and unresolved
  or escaping targets before staging.
- Treat installed copies as derived output; same-name refresh overwrites local
  modifications without confirmation or a force flag.
- Use only Windows PowerShell 5.1 or PowerShell 7 built-ins.

## Failure behavior

- Return a nonzero exit code for every failed preflight, staging, swap, or
  rollback operation.
- Identify the failed skill or phase and the original cause.
- After a swap begins, state whether rollback succeeded or failed.
- Do not create persistent installer logs or provenance files by default.
