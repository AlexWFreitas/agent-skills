# Research Notes

Last updated: `2026-07-21T22:57:15-03:00`

## Canonical catalog and neighboring skill

- Source: repository `README.md` and `skills/task-discovery/` inspected on
  2026-07-21.
- Supported claim: canonical skills are authored only under `skills/`; optional
  Codex metadata belongs in `agents/openai.yaml`; `task-discovery` is an
  explicit-only, read-only producer of a self-contained task definition.
- Evidence class: `verified`.
- Limitation: this describes the current local repository, not every external
  Agent Skills host.

## Repository validation surface

- Source: `scripts/` and `tests/` PowerShell search plus repository `README.md`,
  inspected on 2026-07-21.
- Supported claim: relevant changes must pass `scripts/Test-Repository.ps1` and
  `tests/Run-Tests.ps1` under both `pwsh` and `powershell`; current installer
  tests mention `task-discovery`, but the new skill should require test changes
  only where its addition exposes a real uncovered contract.
- Evidence class: `verified` for current commands and references; `inference`
  for whether implementation will require test changes.
- Limitation: no implementation or test execution occurred during discovery.

## Portable long-running execution boundary

- Source: settled user requirement and portable skill design analysis.
- Supported claim: a skill can require an agent not to stop voluntarily while
  authorized work remains, but cannot guarantee uninterrupted wall-clock
  runtime across all hosts.
- Evidence class: `inference` grounded in the distinction between portable
  instructions and host runtime control.
- Safe contingency: material checkpoints, snapshots, and actual-state
  reconciliation preserve progress across forced interruptions.
