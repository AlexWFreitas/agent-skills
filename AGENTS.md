# Repository instructions

- Treat `skills/` as the only editable skill catalog. Installed copies are derived and disposable.
- Read `README.md` before changing layout, installer behavior, validation, or authoring rules.
- Preserve existing skill behavior unless the task explicitly requires a skill change.
- Keep portable Agent Skills requirements separate from optional Codex metadata and Windows-only installer behavior.
- Keep repository documentation outside individual skill folders; skill folders should contain only resources needed by that skill.
- Resolve tooling paths from script location, never assume the caller's current directory.
- Never let installer cleanup target the destination root, a sibling skill, this catalog checkout, or the canonical `skills/` tree.
- Keep PowerShell code compatible with Windows PowerShell 5.1 and PowerShell 7 without third-party modules.
- Run `scripts/Test-Repository.ps1` and `tests/Run-Tests.ps1` under both `pwsh` and `powershell` after relevant changes.
- Use isolated temporary destinations for installer tests. Never test against the real user skill directory.
- Do not commit, push, publish, install, or change repository settings unless the user explicitly requests it.
