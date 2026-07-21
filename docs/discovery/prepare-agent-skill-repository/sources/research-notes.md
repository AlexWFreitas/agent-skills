# Research Notes

Accessed on `2026-07-21` during discovery for `prepare-agent-skill-repository`.

## Codex

- [Build skills](https://learn.chatgpt.com/docs/build-skills): Codex builds on the open Agent Skills format; user-scope discovery uses `$HOME/.agents/skills`; repository-scope discovery uses `.agents/skills`; `agents/openai.yaml` is optional Codex metadata for interface, policy, and dependencies.
- [AGENTS.md guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md): repository instructions load automatically, can be scoped hierarchically, and should remain concise and operational.
- Local `skill-creator` guidance at discovery time also treated `agents/openai.yaml` as recommended Codex metadata rather than part of the portable required core.

These are product-specific and drift-prone. Reverify them if implementation is materially delayed.

## Portable Agent Skills

- [Agent Skills specification](https://agentskills.io/specification): each skill requires `SKILL.md` with YAML frontmatter containing `name` and `description`; optional portable fields and resource directories are defined; the skill name must match its parent directory.
- [Official `skills-ref` reference implementation](https://github.com/agentskills/agentskills/tree/main/skills-ref): Python-based and explicitly labeled demonstration-only rather than production-ready.

The approved simple YAML syntax profile is a private repository authoring rule layered on the specification's field semantics; it is not represented as a universal Agent Skills requirement.

## GitHub Actions and local runtimes

- [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners): Windows-hosted runners are available, but labels and bundled tool versions can drift.
- [Workflow shell syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax): Windows jobs can explicitly select `pwsh` for PowerShell Core and `powershell` for Windows PowerShell Desktop.
- Local inspection found PowerShell `7.5.8` and Windows PowerShell `5.1.26100.8875`.

The later workflow should select shells explicitly and avoid depending on an incidental hosted-runner patch version.
