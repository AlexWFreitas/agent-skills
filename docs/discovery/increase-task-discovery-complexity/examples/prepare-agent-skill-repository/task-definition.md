# Illustrative Task Definition: Prepare Agent Skill Repository

This is an example output, not a template or an approved replacement for the
original task definition.

Status: `illustrative` · Task: `prepare-agent-skill-repository`<br>
Supporting record: `discovery-record.md`

## Objective

Prepare the private repository as a safe, understandable source catalog for
authoring, validating, and installing agent skills. A fresh contributor or
coding agent must be able to identify the source of truth, add or review a
skill, run the same checks as CI, and refresh selected derived installations
without relying on chat context or risking unrelated files.

Success preserves portable Agent Skills compatibility while treating Codex as
the primary authoring environment and keeping Windows-only installer behavior
as a separate repository concern.

## Implementation context

### Sources and authority

| Source | Authority for this task | Implementation consequence |
| --- | --- | --- |
| User-confirmed discovery decisions | Governing product and safety choices | Preserve the approved source catalog, platform, refresh, rollback, and validation contracts. |
| Agent Skills specification | Portable per-skill contract | Do not make Codex metadata or Windows tooling mandatory for portable skills. |
| Codex documentation | Codex discovery and optional metadata behavior | Treat `.agents/skills/` installations and `agents/openai.yaml` as Codex-specific layers. |
| Repository instructions | Local editing and validation rules | Resolve tools from script location and test only against isolated destinations. |

When these sources conflict, explicit user decisions and repository safety
rules govern this private catalog, while portable claims must remain within the
Agent Skills specification.

### Current state and governing invariants

- `skills/` is the only editable canonical catalog. Installed copies are
  derived and disposable.
- Codex is the primary environment, but a portable skill must remain valid
  without `agents/openai.yaml`.
- Installer and validation tooling must run in Windows PowerShell 5.1 and
  PowerShell 7 without Python, Pester, or third-party modules.
- A refresh may replace only exact selected child skill directories. It must
  never clean the destination root, sibling skills, or canonical source.

### Material supporting document

| Document | Authority | Consequence retained here |
| --- | --- | --- |
| [installer-contract.md](installer-contract.md) | Governing installer behavior and safety contract | Implement list/install/refresh with exact-child containment, staged replacement, selection-level rollback, and visible nonzero failures. |

## Scope and non-goals

**In scope**

- Add root guidance for repository purpose, skill authoring, contribution,
  validation, installation, and source-versus-installed-copy boundaries.
- Establish a compact repository layout with canonical skills, shared scripts,
  isolated tests and fixtures, and Windows CI.
- Implement dependency-free skill and repository validation for the supported
  portable frontmatter profile and optional Codex metadata.
- Implement the approved installer and refresh behavior in
  [installer-contract.md](installer-contract.md).
- Run equivalent validation and installer tests under both supported
  PowerShell hosts locally and in GitHub Actions.

**Not in scope**

- Uninstall automation, public/open-source governance, or macOS/Linux installer
  launchers.
- Automatically exposing the entire canonical catalog as repository-scoped
  active skills.
- Product adapters beyond portable Agent Skills conformance and the confirmed
  Codex integration.
- Commit, push, release, installation into a real user directory, or remote
  repository changes without separate authorization.

### Material decisions that constrain implementation

| Decision | Why it governs | Prohibited compliant-looking alternative |
| --- | --- | --- |
| `skills/` is canonical | Prevents dual maintenance and accidental source loss | Editing `.agents/skills/` or a user installation as a second source of truth. |
| Existing selected skills refresh without confirmation | Enables quick idempotent updates of derived copies | Requiring `-Force` or preserving local edits in an installed copy. |
| Multi-skill refresh is transactional | Prevents a partially updated selected set | Leaving earlier swaps active after a later selected skill fails. |
| Validation is dependency-free PowerShell | Gives local/CI parity in the supported environment | Requiring Python, Pester, or a third-party module. |

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| Root repository guidance | `README.md` explains purpose and workflows; `AGENTS.md` gives concise coding-agent rules and navigation. |
| Canonical catalog conventions | Required and optional skill structure, portable versus Codex-specific behavior, and placement rules are unambiguous. |
| Installer and refresh entry points | Named and `-All` selection, approved destination modes, exact-tree refresh, rollback, and actionable failures follow the linked contract. |
| Validation and tests | Dependency-free checks cover repository layout, valid skill variants, invalid metadata, path safety, refresh behavior, and rollback. |
| Windows CI | The same version-controlled validation and test entry points run under `pwsh` and `powershell`. |

## Recommended implementation approach

1. **Establish repository contracts** — create root guidance, document the
   canonical-versus-derived boundary, and define the minimal portable skill
   profile plus optional Codex metadata.
2. **Build validation first** — validate repository layout, skill metadata,
   local references, and representative valid and invalid fixtures without
   external dependencies.
3. **Implement safe installation** — build list and explicit selection,
   destination resolution, staging, exact-child replacement, rollback, and
   diagnostics according to [installer-contract.md](installer-contract.md).
4. **Add isolated behavior tests** — exercise refresh, stale-file removal,
   parent and sibling preservation, source overlap, working-directory
   independence, and injected transaction failures in temporary destinations.
5. **Wire CI and reconcile documentation** — run the same checks under both
   PowerShell hosts on Windows and verify every documented command against the
   implemented entry points.

Do not test against a real user skill directory. Stop before any commit, push,
publication, or real installation unless separately authorized.

## Verification and definition of done

### Acceptance checks

| Check | Required evidence |
| --- | --- |
| Fresh-agent usability | A cold reader identifies purpose, source of truth, authoring workflow, installation behavior, and validation commands using tracked files only. |
| Portable skill compatibility | Minimal skills without Codex metadata pass; malformed or unsupported frontmatter fails clearly. |
| Exact-child safety | Tests prove refresh cannot target canonical source, destination roots, parent files, or sibling skills. |
| Refresh correctness | A same-name installed copy becomes an exact source copy, including removal of stale files, without prompting. |
| Transactional behavior | Injected multi-skill failure restores the complete pre-command selected set and reports rollback outcome. |
| Runtime parity | Repository validation and all tests pass under PowerShell 7 and Windows PowerShell 5.1. |
| Documentation parity | README, agent instructions, scripts, tests, and CI use the same paths and supported commands. |
| Scope preservation | No uninstall, non-Windows installer, public-governance, commit, push, or real-user installation behavior is introduced. |

### Contract traceability

| Governing outcome | Delivery | Verification |
| --- | --- | --- |
| One editable source of truth | Catalog conventions and root guidance | Cold-read and source-preservation checks |
| Safe repeatable refresh | Installer and refresh entry points | Exact-child, stale-file, sibling-preservation, and rollback tests |
| Portable core with optional Codex layer | Validator and authoring guidance | Minimal and extended skill fixtures |
| Local/CI parity | Dependency-free test entry points and Windows workflow | Both PowerShell hosts run the same checks |

The task is complete when all deliverables exist, the linked installer contract
is implemented without contradiction, every acceptance check passes under both
PowerShell hosts, documentation matches actual behavior, and no excluded action
or target was introduced.
