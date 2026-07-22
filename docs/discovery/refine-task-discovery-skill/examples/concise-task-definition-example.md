# Example: Prepare Agent Skill Repository

> Illustrative only. This shows the proposed handoff shape using the earlier
> repository task; it does not replace its approved definition or authorize
> implementation.

## Goal

Make this repository a safe, understandable source catalog for Agent Skills so
contributors can author skills, install selected copies on Windows, and verify
changes consistently.

## Scope

- Add concise repository guidance and agent instructions.
- Keep `skills/` as the only editable catalog; installed copies are derived.
- Provide a Windows PowerShell installer for selected skills and full refresh.
- Add dependency-free validation, isolated installer tests, and Windows CI.
- Do not install skills, add an uninstall command, commit, push, publish, or
  add non-Windows tooling.

## Deliverables

- Root `README.md` and `AGENTS.md` describing the catalog boundary, authoring,
  validation, and installation workflows.
- PowerShell installer and refresh entry point that replace only selected skill
  folders and preserve the catalog, destination root, and sibling skills.
- Repository validator, isolated tests, and a Windows workflow that runs both
  `pwsh` and Windows PowerShell.

## Execution sequence

1. Add repository guidance and the shared validation foundation.
2. Implement the installer with strict destination containment and safe refresh
   behavior.
3. Add isolated tests for installation, stale-file removal, rollback, and path
   safety; then wire the same checks into CI.
4. Run both PowerShell suites and review the diff for scope and documentation
   consistency.

## Definition of done

- A new contributor can locate and author a valid skill from repository guidance.
- Selected skills install or refresh as independent copies without altering the
  catalog, destination root, or siblings.
- Repository validation and installer tests pass under both supported PowerShell
  runtimes.
- No installation, commit, push, publication, or repository-setting change was
  performed without separate authorization.

## Omitted discovery material

The discovery record, not this brief, retains the research sources, alternative
installation models, user-question history, rationale for Windows-only support,
and the detailed failure matrix. Include any of those here only if it directly
changes implementation work or acceptance.
