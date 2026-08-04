# Agent Skills Catalog

Private source catalog for Agent Skills maintained primarily with Codex. The skill format follows the portable [Agent Skills specification](https://agentskills.io/specification); Codex-specific metadata and installation paths are optional layers on top of that core.

## Repository layout

| Path | Purpose |
| --- | --- |
| `skills/<skill-name>/` | Canonical source for every skill. Edit skills only here. |
| `scripts/` | Dependency-free PowerShell installer and validation tooling. |
| `tests/` | Isolated installer and validator tests plus fixtures. |
| `Refresh-CodexSkills.ps1` | Refresh the full catalog into Codex user scope. |
| `.github/workflows/validate.yml` | Run the same local checks in Windows PowerShell and PowerShell 7. |
| `docs/discovery/` | Approved task definitions and discovery evidence. |

Installed copies are disposable derived output. Never maintain a skill in `$HOME\.agents\skills`, another repository's `.agents\skills`, or a custom destination and then expect those edits to flow back into this catalog.

## Author a skill

Create a lowercase hyphenated directory under `skills/` and add `SKILL.md`. The directory name and frontmatter `name` must match.

Required frontmatter:

```yaml
---
name: example-skill
description: Explain what the skill does and when an agent should use it.
---
```

This repository deliberately supports a small, dependency-free YAML profile:

- Use plain, single-quoted, or double-quoted single-line string values.
- Use only `name`, `description`, `license`, `compatibility`, `metadata`, and `allowed-tools` at the top level.
- Write `metadata` as a two-space-indented string-to-string map.
- Do not use multiline scalars, flow maps or lists, anchors, aliases, tags, duplicate keys, or tabs.
- Quote a plain value if it contains a colon followed by whitespace or another YAML-sensitive form.

`name` and `description` are required. The remaining portable fields are optional. The body after frontmatter must contain instructions.

Optional skill resources include `scripts/`, `references/`, `assets/`, and product-specific directories such as `agents/`. Keep only files needed by the skill. Put repository documentation here at the root, not inside individual skill folders.

`agents/openai.yaml` is recommended for a polished Codex experience but is not part of the portable required core. When present, keep UI metadata aligned with `SKILL.md` and ensure referenced local assets exist.

### Codex user-input gates

`request_user_input` is an optional Codex interaction layer, not a portable
Agent Skills requirement. When a skill needs a user decision, instruct Codex to
use it when available for one bounded question with two or three mutually
exclusive choices, especially confirmations, approvals, and clearly defined
preferences. Keep a plain-language fallback so the skill remains usable in
other clients.

Do not force open-ended discovery, narrative answers, credentials, secrets, or
artifact content into predefined choices. Put an evidence-backed recommendation
first, let Codex supply the built-in free-form alternative, and never set an
auto-resolution timeout for a blocking gate, authorization, destructive action,
or other decision that requires an explicit user answer.

Interpret "one question at a time" as at most one unanswered question, never as
one question per assistant turn. After `request_user_input` returns, process the
answer and continue the same active turn. If another material question is ready,
ask it immediately in a new call. Do not insert a summary-only turn, announce
that the next question will come later, or require the user to reply "ok" merely
to continue. The same rule applies after a plain-text answer: the next assistant
response should include the next question when one is already known.

Before asking, check the visible conversation and the workflow's durable record
for an answer to the same decision in substance, not only identical wording.
Context compaction, lost tool state, or improved phrasing does not justify a
repeat. Reopen a settled decision only when new material evidence changes it,
and explain what changed. Reuse only an answer that directly settles the same
choice; an adjacent fact or related requirement is not an answer.

Sequential questions must still be user-owned gates. Do not use the interaction
loop to make the user select ordinary algorithms, tuning values, reversible
implementation mechanics, or speculative future safeguards. If the user
questions relevance or depth, reassess the remaining questions before asking
another one.

## Validate changes

Run the same commands used by CI:

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
pwsh -NoProfile -File .\tests\Run-Tests.ps1

powershell -NoProfile -File .\scripts\Test-Repository.ps1
powershell -NoProfile -File .\tests\Run-Tests.ps1
```

Errors fail validation. Style and quality recommendations are reported as warnings without failing CI. Validation and tests require only Windows PowerShell 5.1 or PowerShell 7; Python, Node.js, Pester, `skills-ref`, and third-party PowerShell modules are not required.

## Install or refresh skills

The repository-owned installer is Windows-only and requires Windows PowerShell 5.1 or PowerShell 7. Skill contents remain portable; only this installation tool has the Windows platform boundary.

List catalog skills without writing a destination:

```powershell
.\scripts\Install-Skills.ps1 -List
```

Install or refresh named skills in Codex user scope, `$HOME\.agents\skills`:

```powershell
.\scripts\Install-Skills.ps1 -Name task-discovery
```

Refresh the complete catalog in Codex user scope:

```powershell
.\Refresh-CodexSkills.ps1
```

The general installer also supports an explicit full-catalog selection:

```powershell
.\scripts\Install-Skills.ps1 -All
```

Install selected skills for another repository:

```powershell
.\scripts\Install-Skills.ps1 -Name task-discovery -RepositoryPath D:\Work\another-repository
```

This resolves `D:\Work\another-repository\.agents\skills`. The target must be an existing external Git repository; this catalog repository is rejected.

Use a caller-owned destination for another specification-compatible client:

```powershell
.\scripts\Install-Skills.ps1 -Name task-discovery -DestinationPath C:\AgentData\skills
```

A custom path is only a copy destination. It does not claim that another product automatically discovers that location.

### Refresh behavior and safety

- Skill selection is explicit through `-Name` or `-All`; the convenience script supplies `-All` for you.
- An existing same-name destination folder is replaced automatically without prompting or `-Force`.
- Refresh replaces the complete selected skill tree, so files removed from the catalog do not remain installed.
- Only exact selected child folders may be replaced. The destination root, its files, and sibling skills are preserved.
- The installer rejects traversal, source overlap, this catalog as a repository target, and source reparse points.
- Multi-skill refresh is all-or-nothing. Sources are validated and staged before swaps, and all changed selected skills are restored if any swap fails.
- Failure output identifies the skill or phase, the cause, and whether rollback succeeded. Failures return a nonzero exit code.
- If rollback fails, stop refreshing that destination and use the printed retained-backup path to compare and manually restore only the affected named skill folders. Never clean the parent skills directory during recovery.
- No persistent installer log or provenance file is created.
- Installed-copy edits are overwritten on the next refresh.

The installer intentionally has no uninstall command.

## Private contribution workflow

1. Inspect `AGENTS.md` and the relevant skill before editing.
2. Keep changes inside the canonical `skills/` folder or the repository support area that owns the behavior.
3. Preserve optional skill structure; do not copy the current skill as a mandatory skeleton.
4. Add or update isolated fixtures for every new validation or installer behavior.
5. Run repository validation and the full test suite under both supported PowerShell families.
6. Review the diff for generated files, installed copies, secrets, unrelated changes, and accidental `.agents/skills` content.

Add a separate `CONTRIBUTING.md` or `CODEOWNERS` only if recurring collaboration or ownership enforcement later makes it useful.
