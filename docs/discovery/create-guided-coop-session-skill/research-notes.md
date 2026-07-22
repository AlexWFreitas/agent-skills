# Research Notes: Guided Coop Session Skill

Last updated: `2026-07-22T00:44:38-03:00`

## Repository authoring contract

Source: repository `README.md`, inspected 2026-07-22.

- **Verified:** `skills/` is the canonical editable skill catalog; installed
  copies are derived and disposable.
- **Verified:** A skill requires a matching lowercase hyphenated directory and
  frontmatter `name`, a `description`, and an instructional body.
- **Verified:** Portable skill behavior must remain separate from optional
  Codex metadata and Windows-only installer behavior.
- **Verified:** Skill folders should contain only runtime-relevant skill
  resources; repository documentation belongs outside them.
- **Verified:** Relevant changes require repository validation and tests under
  both `pwsh` and Windows PowerShell.

Implementation consequence: implement the eventual skill only in the canonical
catalog, keep its portable behavioral contract in `SKILL.md`, add optional
product metadata deliberately, and verify it through the repository's supported
toolchains.

## Neighboring skills and overlap boundary

Sources: `skills/task-discovery/SKILL.md` and
`skills/phased-plan-to-goal/SKILL.md`, inspected 2026-07-22.

- **Verified:** `task-discovery` is an explicit, read-only phase that asks one
  question per turn and produces an implementation-ready definition; it does
  not execute the defined task.
- **Verified:** `phased-plan-to-goal` is an explicit planning and execution phase
  with a separate approval gate, coherent progress artifacts, and one focused
  question per turn when a material unknown remains.
- **Inference:** A new general cooperative-session skill could overlap both if
  it also claims task definition, planning, execution authorization, or durable
  progress management without a clear composition rule.
- **Verified user decision:** The new skill is general-purpose across task
  families. Collaboratively answering decision-heavy documentation and reading
  an entire documentation set are its first required scenarios, not its scope
  boundary.

Implementation consequence: define the new skill by its user-agent
collaboration mode, while explicitly retaining the authority and lifecycle
boundaries of neighboring phase skills.

## Validation surface

Sources: `skills/task-discovery/agents/openai.yaml`, repository validation and
test search, and `skill-creator` guidance; inspected 2026-07-22.

- **Verified:** Existing explicit-only Codex metadata uses
  `policy.allow_implicit_invocation: false`.
- **Verified:** Repository tests and validation cover skill structure, metadata,
  references, installer behavior, and safety; they do not simulate an extended
  user-agent cooperative dialogue.
- **Verified guidance:** `skill-creator` recommends realistic forward-testing
  after substantial revisions, using raw artifacts and avoiding leaked expected
  answers or diagnoses.

Implementation consequence: include aligned explicit-only Codex metadata, run
the complete repository checks, and separately gather scenario-based behavioral
evidence for the interaction contract.
