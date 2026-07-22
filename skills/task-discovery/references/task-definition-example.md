# Illustrative Complex Task Definition

This is a reference output, not a template. It demonstrates adaptive depth,
material decisions, and a linked authoritative contract. Simpler tasks should
omit subsections they do not need.

# Task Definition: Prepare an Agent Skill Repository

Status: `ready-for-handoff` · Supporting record: `discovery-record.md`

## Objective

Prepare a private repository as a safe, understandable source catalog for
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
| User-confirmed discovery decisions | Governing product and safety choices | Preserve the approved source-catalog, platform, refresh, rollback, and validation contracts. |
| Agent Skills specification | Portable per-skill contract | Do not make Codex metadata or Windows tooling mandatory for portable skills. |
| Codex documentation | Codex discovery and optional metadata behavior | Treat repository installations and `agents/openai.yaml` as Codex-specific layers. |
| Repository instructions | Local editing and validation rules | Resolve tools from their script location and test only against isolated destinations. |

When sources conflict, explicit user decisions and repository safety rules
govern this private catalog, while portable claims must remain within the Agent
Skills specification.

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
| [Illustrative installer contract](task-definition-example-installer-contract.md) | Governing installer behavior and safety contract | Implement list, install, and refresh with exact-child containment, staged replacement, selection-level rollback, and visible nonzero failures. |

## Scope and non-goals

**In scope**

- Add root guidance for repository purpose, skill authoring, contribution,
  validation, installation, and source-versus-installed-copy boundaries.
- Establish a compact repository layout with canonical skills, shared scripts,
  isolated tests and fixtures, and Windows CI.
- Implement dependency-free skill and repository validation for the supported
  portable frontmatter profile and optional Codex metadata.
- Implement the approved behavior in the
  [installer contract](task-definition-example-installer-contract.md).
- Run equivalent validation and installer tests under both supported
  PowerShell hosts locally and in CI.

**Not in scope**

- Uninstall automation, public/open-source governance, or macOS/Linux installer
  launchers.
- Automatically exposing the canonical catalog as active repository-scoped
  skills.
- Product adapters beyond portable Agent Skills conformance and the confirmed
  Codex integration.
- Commit, push, release, real-user installation, or remote repository changes
  without separate authorization.

### Material decisions that constrain implementation

| Decision | Why it governs | Prohibited compliant-looking alternative |
| --- | --- | --- |
| `skills/` is canonical | Prevents dual maintenance and accidental source loss | Editing an installed copy as a second source of truth. |
| Selected skills refresh without confirmation | Enables quick idempotent updates of derived copies | Requiring `-Force` or preserving local edits in an installed copy. |
| Multi-skill refresh is transactional | Prevents a partially updated selected set | Leaving earlier swaps active after a later selected skill fails. |
| Validation is dependency-free PowerShell | Gives local and CI parity in the supported environment | Requiring Python, Pester, or a third-party module. |

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| Root repository guidance | Explain purpose, workflows, source of truth, and the canonical-versus-derived boundary. |
| Catalog conventions | Make required and optional skill structure, portable behavior, and Codex-specific behavior unambiguous. |
| Installer and refresh entry points | Follow the linked contract for selection, destinations, exact-tree refresh, rollback, and failures. |
| Validation and tests | Cover repository layout, valid skill variants, invalid metadata, path safety, refresh behavior, and rollback without external dependencies. |
| Windows CI | Run the same version-controlled checks under `pwsh` and `powershell`. |

## Recommended implementation approach

1. **Establish repository contracts** — create root guidance and define the
   canonical-versus-derived boundary, portable skill profile, and optional
   Codex layer.
2. **Build validation first** — validate repository layout, skill metadata,
   local references, and representative valid and invalid fixtures without
   external dependencies.
3. **Implement safe installation** — build explicit selection, destination
   resolution, staging, exact-child replacement, rollback, and diagnostics
   according to the
   [installer contract](task-definition-example-installer-contract.md).
4. **Add isolated behavior tests** — exercise refresh, stale-file removal,
   parent and sibling preservation, source overlap, working-directory
   independence, and injected transaction failures in temporary destinations.
5. **Wire CI and reconcile documentation** — run the same checks under both
   PowerShell hosts and verify every documented command against the implemented
   entry points.

Do not test against a real user skill directory. Stop before any commit, push,
publication, or real installation unless separately authorized.

### Risks and managed unknowns

| Item | Implementation impact | Treatment or gate |
| --- | --- | --- |
| A transaction can fail after one selected skill is swapped. | Partial refresh would leave the selected set inconsistent. | Retain complete backups until all swaps succeed and test restoration with an injected later-swap failure. |
| Optional Codex metadata behavior may change independently of the portable specification. | Stale assumptions could make Codex guidance inaccurate while portable validation still passes. | Verify current Codex documentation before changing metadata rules; if unavailable, preserve existing behavior and record the unresolved claim rather than guessing. |

## Verification and definition of done

### Acceptance checks

| Check | Required evidence |
| --- | --- |
| Fresh-agent usability | A cold reader identifies purpose, source of truth, authoring workflow, installation behavior, and validation commands using tracked files only. |
| Portable compatibility | Minimal skills without Codex metadata pass; malformed or unsupported frontmatter fails clearly. |
| Exact-child safety | Tests prove refresh cannot target canonical source, destination roots, parent files, or sibling skills. |
| Refresh correctness | A same-name installed copy becomes an exact source copy, including stale-file removal, without prompting. |
| Transactional behavior | An injected multi-skill failure restores the complete pre-command selected set and reports rollback outcome. |
| Runtime parity | Validation and all tests pass under PowerShell 7 and Windows PowerShell 5.1. |
| Scope preservation | No uninstall, non-Windows installer, commit, push, or real-user installation behavior is introduced. |

### Contract traceability

| Governing outcome | Delivery | Verification |
| --- | --- | --- |
| One editable source of truth | Catalog conventions and root guidance | Cold-read and source-preservation checks |
| Safe repeatable refresh | Installer and refresh entry points | Exact-child, stale-file, sibling-preservation, and rollback tests |
| Portable core with optional Codex layer | Validator and authoring guidance | Minimal and extended skill fixtures |
| Local and CI parity | Dependency-free test entry points and Windows workflow | Both PowerShell hosts run the same checks |

The task is complete when all deliverables exist, the linked installer contract
is implemented without contradiction, every acceptance check passes under both
PowerShell hosts, documentation matches actual behavior, and no excluded action
or target was introduced.
