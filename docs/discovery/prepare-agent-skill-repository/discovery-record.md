# Discovery Record: Prepare Agent Skill Repository

## Phase metadata

- Status: `ready-for-handoff`
- Task name: `prepare-agent-skill-repository`
- Discovery directory: `docs/discovery/prepare-agent-skill-repository/`
- Request language: English
- Created: `2026-07-21T17:45:36.9038959-03:00`
- Last updated: `2026-07-21T19:17:24.2474307-03:00`
- Current session: `1`

## Initial request

Update this repository with the files it needs as a place for storing skills, while also accounting for its use by AGENTS. The phrase "used by AGENTS" remains intentionally unresolved because it may refer to agents working inside this repository, agents consuming skills from it, an `AGENTS.md` instruction hierarchy, or a combination of those roles. The requested `task-discovery` phase must define the implementation before any repository-level implementation begins.

## Current understanding

The repository is a new, clean, private Git repository whose only tracked product content is one complete `task-discovery` skill under the canonical `skills/` source catalog. Coding agents will use the checkout to author, maintain, and review portable Agent Skills, with Codex as the roughly 99% first-class environment. The approved compact layout adds root `README.md`, `AGENTS.md`, `.gitignore`, and `Refresh-CodexSkills.ps1`; shared dependency-free PowerShell tooling under `scripts/`; test suites and fixtures under `tests/`; and Windows CI under `.github/workflows/`. The installer creates independent copies, automatically replaces only exact selected child skill folders through staged rollback-safe swaps, supports named and `-All` selection, and owns no uninstall operation. Codex user scope at `$HOME\.agents\skills` is the primary and default destination. Repository scope requires an explicit external checkout and rejects this catalog; generic clients require an explicit destination path. Multi-skill refresh is all-or-nothing, with failures restoring the entire changed selection and clearly reporting the failure plus rollback outcome. Console/error-stream diagnostics and a nonzero exit are sufficient; the installer creates no persistent log file. CI fails on specification, repository-contract, broken-reference, test, and installer-safety errors but not on style or quality advice. Skill frontmatter follows a documented simple YAML profile that dependency-free PowerShell can parse completely. Public governance files and named secondary-agent adapters remain out of scope. Discovery is undergoing its final readiness review.

### Next step

Discovery is complete. Await separate authorization to implement the ready task definition; do not treat this handoff as authorization to install skills, commit, push, publish, or change repository settings.

## Evidence classification

- `verified`: Directly supported by an inspected authoritative source or explicit user decision.
- `inference`: Reasoned conclusion supported by evidence but not directly stated.
- `assumption`: Tentative premise that still needs validation or explicit acceptance.
- `unresolved`: Material fact or decision not yet established.

## Research and inspection log

| Time | Source | Finding | Class | Limitation or relevance |
| --- | --- | --- | --- | --- |
| `2026-07-21T17:45:36.9038959-03:00` | Repository file tree and `git status --short --branch` | The clean `main` checkout tracks only five files belonging to `skills/task-discovery/`. | verified | Describes the current checkout only. |
| `2026-07-21T17:45:36.9038959-03:00` | `git log -5` | The repository has one commit, `f6fef4a`, titled `Created the task-discovery skill`. | verified | History is minimal and does not establish broader repository intent. |
| `2026-07-21T17:45:36.9038959-03:00` | `skills/task-discovery/SKILL.md` and its `assets/`, `references/`, and `agents/openai.yaml` files | The existing skill is internally structured with instructions, templates, a reference checklist, and OpenAI interface metadata. | verified | One skill cannot by itself establish conventions for every future skill. |
| `2026-07-21T17:45:36.9038959-03:00` | Repository root inspection | No root `AGENTS.md`, README, license, contribution file, or validation configuration is present. | verified | Absence does not prove which files the user wants added. |
| `2026-07-21T17:45:36.9038959-03:00` | User confirmation | The discovery task name is `prepare-agent-skill-repository`. | verified | Confirms the discovery directory name, not implementation scope. |
| `2026-07-21T17:48:31.6418900-03:00` | User answer and follow-up | Coding agents are the primary AGENTS role, and the repository structure must also be designed to support their authoring, maintenance, and review work. | verified | The exact coding-agent products remain unresolved. |
| `2026-07-21T17:54:20.8450923-03:00` | User answer | Codex will account for approximately 99% of coding-agent use, while the repository should support other coding agents. | verified | "Support" does not yet define named secondary products or product-specific guarantees. |
| `2026-07-21T17:54:20.8450923-03:00` | Current official Codex Build skills and AGENTS.md guidance, summarized in `sources/research-notes.md` | Codex uses the open Agent Skills standard, automatically discovers repository-scoped skills under `.agents/skills/`, supports `agents/openai.yaml` as optional Codex metadata, and loads concise root-to-current-directory `AGENTS.md` guidance. | verified | Codex-specific behavior refreshed on 2026-07-21; may drift and should be reverified before later implementation if discovery becomes stale. |
| `2026-07-21T17:54:20.8450923-03:00` | `https://agentskills.io/specification` | The cross-agent specification defines each skill directory and `SKILL.md` contract, including required `name` and `description`, optional resources, and progressive disclosure, but does not prescribe a repository collection-root name. | verified | Product discovery locations and optional extensions remain client-specific. |
| `2026-07-21T17:54:20.8450923-03:00` | Current local `skill-creator` guidance | A skill should contain only files essential to its workflow; repository documentation and governance should not be copied into every skill. | verified | Codex authoring guidance, not a universal cross-agent requirement. |
| `2026-07-21T18:04:12.4416164-03:00` | User answer | `skills/` is the source catalog. | verified | Establishes canonical storage and rejects implicit repository-scoped activation as the catalog's defining behavior; installation mechanics remain unresolved. |
| `2026-07-21T18:04:12.4416164-03:00` | Public GitHub page lookup for `AlexWFreitas/agent-skills` | The repository page could not be fetched directly and the repository was not found in a targeted public search. | unresolved | This does not prove the repository is private; it may be new, private, or not indexed. Do not infer visibility, licensing, or contribution policy. |
| `2026-07-21T18:06:12.8547552-03:00` | User answer | Compliance with the open Agent Skills specification is sufficient support for secondary coding agents unless a named product adapter is explicitly added later. | verified | Does not yet define how skills are installed into any agent. |
| `2026-07-21T18:07:32.7980496-03:00` | Current Codex manual, Build skills section | Codex supports installing curated skills and downloading skills from other repositories through its existing skill installer; direct source folders and plugins serve different distribution scopes. | verified | Establishes a Codex consumption option, not a cross-agent installer contract. |
| `2026-07-21T18:08:59.2202689-03:00` | User answer | The repository must include and maintain its own installation tool. | verified | Target destinations, runtime, platforms, and detailed safety behavior remain unresolved. |
| `2026-07-21T18:12:10.4854531-03:00` | User answer | The installer will provide Codex-aware user and repository destinations plus a generic explicit destination for other specification-compatible clients. | verified | Operating systems, runtime, and detailed safety behavior remain unresolved. |
| `2026-07-21T18:13:51.2719513-03:00` | User answer | Windows-only installer support is sufficient. | verified | macOS and Linux installation tooling are explicitly unnecessary for the initial contract. |
| `2026-07-21T18:13:51.2719513-03:00` | Local runtime inspection | The current Windows environment has Windows PowerShell 5.1 and PowerShell 7.5.8 available. | verified | Establishes local validation capability, not the minimum runtime every future consumer has. |
| `2026-07-21T18:15:56.7667137-03:00` | User answer | The installer will be native PowerShell, compatible with Windows PowerShell 5.1 and PowerShell 7, with no Node.js or Python runtime dependency. | verified | Detailed installation and update semantics remain unresolved. |
| `2026-07-21T18:20:03.8306453-03:00` | User answer | Skills must be installed as copies, and an update must clean the existing installed skill folder before inserting the new version so source-deleted files do not remain. | verified | Later entries resolved cleanup authority to exact selected child folders with transactional rollback. |
| `2026-07-21T18:21:15.6047335-03:00` | User clarification | Cleanup applies to the specific selected skill folder, not the parent skills folder. | verified | Establishes a hard destructive-action boundary for path resolution and tests. |
| `2026-07-21T18:23:02.7623224-03:00` | User answer | An installer-managed provenance marker is not necessary. | verified | Collision consent and replacement behavior without a marker remain unresolved. |
| `2026-07-21T18:26:19.6527743-03:00` | User answer | Existing exact destination skill folders should be replaced automatically without a force flag or confirmation to provide a quick update or refresh procedure. | verified | Replacement must remain limited to each selected child folder and use failure-safe staging. |
| `2026-07-21T18:28:50.8337601-03:00` | User answer | The installer must support `-All`, and the repository must include a file that performs this whole-catalog behavior by default. | verified | A later entry fixed the convenience destination as Codex user scope. |
| `2026-07-21T18:30:56.9073788-03:00` | User answer | The whole-catalog convenience file defaults to the Codex user-scope destination `$HOME\.agents\skills`. | verified | General installer alternatives remain available for Codex repository scope and explicit custom paths. |
| `2026-07-21T18:33:31.2771785-03:00` | User answer | Intentional uninstall is out of scope for the repository-owned installer. | verified | Manual removal may be documented; no removal command or destructive uninstall tests are required. |
| `2026-07-21T18:36:19.8405336-03:00` | User answer | The repository is private. | verified | Public reuse, open-source licensing, and public community/support files are not required. |
| `2026-07-21T18:38:43.9617794-03:00` | User answer | Other private contributors may contribute changes. | verified | The timing and frequency are unknown; lightweight guidance is justified, dedicated ownership machinery is not yet. |
| `2026-07-21T18:41:51.3244459-03:00` | User answer | Repository and skill validation must run automatically through GitHub Actions. | verified | Establishes CI intent; the validation toolchain remains to be selected. |
| `2026-07-21T18:41:51.3244459-03:00` | GitHub-hosted runners and workflow syntax documentation | GitHub provides Windows-hosted runners, and workflow steps can explicitly select `pwsh` for PowerShell Core or `powershell` for Windows PowerShell Desktop. | verified | Runner images and bundled runtime versions drift; use explicit shell selection and avoid coupling tests to an incidental patch version. Sources: `https://docs.github.com/en/actions/reference/runners/github-hosted-runners` and `https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax`. |
| `2026-07-21T18:41:51.3244459-03:00` | Official `agentskills/agentskills` `skills-ref` README | The reference validator is Python-based and explicitly described as demonstration-only, not for production use. | verified | It is useful comparative evidence but is a weak mandatory dependency for this private repository. Source: `https://github.com/agentskills/agentskills/tree/main/skills-ref`. |
| `2026-07-21T19:02:46.8879608-03:00` | Current Agent Skills specification | `SKILL.md` requires YAML frontmatter; `name` and `description` are required strings, optional scalar fields have length or format constraints, and `metadata` is a string-to-string mapping. | verified | The specification defines the data contract but does not prescribe which equivalent YAML scalar syntaxes a repository-owned dependency-free parser must support. Source: `https://agentskills.io/specification`. |

## Discovery sessions

### Session 1 - `2026-07-21T17:45:36.9038959-03:00`

#### Entry 1

- Question: Confirm the proposed task name `prepare-agent-skill-repository`.
- Why it mattered: The requested discovery workflow prohibits creating discovery files until the directory name is confirmed.
- Recommendation: Use `prepare-agent-skill-repository` because it covers both skill storage and agent readiness without prematurely prescribing files.
- Answer: Yes.
- Interpretation: Use `docs/discovery/prepare-agent-skill-repository/` for all discovery writes.
- Reinterpretation notice: The one-word answer was normalized as explicit confirmation of the proposed task name; its meaning was not expanded.
- Definition impact: Established the task identifier, discovery path, and phase metadata.

#### Entry 2

- Question: When you say the repository will be used by AGENTS, should AGENTS be treated primarily as coding agents that open this repository and author, maintain, or review the skills in it?
- Why it mattered: Agent authorship versus skill consumption implies different root instructions, documentation, installation paths, and validation responsibilities.
- Recommendation: Treat agent-based authoring and maintenance as the primary role, while documenting skill consumption separately, because the repository itself is the natural location for authoring instructions.
- Answer: Yes. The user added: "Or the repository structure too."
- Interpretation: Coding agents that work directly in the checkout are the primary AGENTS role. Agent readiness applies both to instructions/documentation and to the repository's directory structure.
- Reinterpretation notice: The follow-up wording was normalized as an additive structural requirement; it was not treated as replacing agent-based authoring and maintenance.
- Definition impact: Confirms coding agents as stakeholders and brings discoverable, scalable repository layout into scope as a required deliverable.

#### Entry 3

- Question: Should Codex be the only first-class coding-agent environment, or must the repository explicitly support additional coding agents?
- Why it mattered: A Codex-only repository can use its precise instruction and skill contracts, whereas multi-agent support requires a portable baseline plus clearly isolated product-specific adapters.
- Recommendation: Make Codex a verified first-class target and keep the core layout and authoring rules tool-agnostic where practical; add other first-class targets only when they can be named and validated.
- Answer: Support other coding agents, but Codex will be used 99% of the time.
- Interpretation: Adopt a Codex-first architecture with a portable baseline. Codex-specific features may be included when they do not redefine the portable skill contract or obstruct secondary agents.
- Reinterpretation notice: "99%" is treated as an approximate dominance statement rather than a measured service-level target.
- Definition impact: Establishes Codex as the primary verified target, cross-agent usability as a required quality, and product-specific secondary-agent guarantees as still unresolved.

#### Entry 4

- Question: Should opening this repository make all cataloged skills automatically available to Codex, or should `skills/` remain a source catalog whose skills are installed or linked explicitly when needed?
- Why it mattered: Codex automatically discovers repository-scoped skills under `.agents/skills/`, while the current canonical content is under `skills/`; choosing activation behavior determines the canonical layout and whether an adapter, link, or install workflow is needed.
- Recommendation: Keep `skills/` as the portable canonical source catalog and require explicit installation or linking, because automatically activating every catalog skill while maintaining the catalog couples authoring to consumption and may load unintended capabilities.
- Answer: The folder `skills` is the source catalog.
- Interpretation: Keep `skills/` as the canonical repository-owned copy. Opening the checkout must not automatically treat the whole catalog as active repository-scoped skills. Consumers may later install, copy, or link selected skills through a separately defined workflow.
- Reinterpretation notice: The concise answer was normalized into a source-versus-active-copy boundary. It does not decide whether installation is manual or automated.
- Definition impact: Fixes the canonical catalog path, excludes `.agents/skills/` as the canonical store, and moves discovery paths into downstream installation or adapter concerns.

#### Entry 5

- Question: For secondary coding agents, is compliance with the open Agent Skills specification sufficient unless a named product-specific adapter is explicitly added later?
- Why it mattered: Claiming generic cross-agent compatibility is supportable through the open per-skill contract; promising named agents additionally requires current discovery-path research, adapter files or installer behavior, and product-specific tests.
- Recommendation: Define the portable specification as the default secondary-agent support contract, validate Codex deeply, and add named secondary adapters only in separately justified increments.
- Answer: Yes, it is sufficient.
- Interpretation: The portable Agent Skills specification is the complete default contract for secondary coding-agent support. Product-specific compatibility is claimed only for Codex or for a named adapter added and validated later.
- Reinterpretation notice: The answer was normalized to the exact scope of the question; it does not assert that every coding agent implements the specification fully.
- Definition impact: Bounds the compatibility matrix, prevents speculative adapter files, and permits validation to separate portable conformance from Codex enhancements.

#### Entry 6

- Question: Should this repository include and maintain its own installation tool, or only document external and manual methods for installing selected skills from `skills/`?
- Why it mattered: A repository-owned installer adds code, platform compatibility, overwrite and rollback semantics, and testing obligations; documentation-only consumption keeps initial scope smaller and can use existing client tools.
- Recommendation: Start with documented existing-tool and manual installation paths, and defer a custom installer until concrete repeated friction establishes requirements.
- Answer: Include and maintain its own installation tool.
- Interpretation: The later implementation must add repository-owned installation code, documentation, and tests; relying exclusively on client tooling or manual copying is insufficient.
- Reinterpretation notice: None.
- Definition impact: Requires a root tooling area, explicit installation contract, platform/runtime decision, overwrite and rollback semantics, and automated tests.

#### Entry 7

- Question: Should the installer provide Codex-aware user and repository destinations plus a generic explicit destination path for other Agent Skills clients, without built-in named adapters for those clients?
- Why it mattered: This target model gives the dominant Codex workflow safe defaults while honoring the portable contract without promising unvalidated discovery behavior for unnamed agents.
- Recommendation: Use Codex-aware destinations plus a required explicit destination for other clients; add named adapters only through later evidence-backed changes.
- Answer: Yes.
- Interpretation: Support Codex user-scope and repository-scope destinations as named, verified behaviors; support other clients through a caller-supplied destination without claiming their discovery semantics.
- Reinterpretation notice: The one-word answer was normalized as confirmation of the complete recommended target model stated immediately before the question.
- Definition impact: Establishes destination categories, keeps unnamed client adapters out of scope, and requires tests for both Codex modes plus an explicit custom destination.

#### Entry 8

- Question: Must the installer support Windows, macOS, and Linux from its first maintained release?
- Why it mattered: The platform contract determines implementation language, launcher strategy, path and symlink behavior, test environments, and whether a Windows-specific implementation would undermine the portable catalog workflow.
- Recommendation: Support all three major desktop operating-system families with one cross-platform implementation and minimize runtime dependencies.
- Answer: Only Windows is fine.
- Interpretation: The maintained installer contract is Windows-only. macOS and Linux launchers, path behavior, and CI are not required.
- Reinterpretation notice: "Fine" was normalized as an explicit acceptance of the narrower Windows-only platform contract.
- Definition impact: Removes cross-platform packaging and tests, permits Windows-native implementation choices, and keeps generic destination support within Windows.

#### Entry 9

- Question: Should the Windows installer be implemented in native PowerShell with no Node.js or Python runtime dependency?
- Why it mattered: A native PowerShell implementation matches the selected platform, reduces prerequisites, and can be tested locally against both Windows PowerShell 5.1 and PowerShell 7; choosing another runtime would add installation prerequisites.
- Recommendation: Use a PowerShell script compatible with Windows PowerShell 5.1 and PowerShell 7, avoiding external runtime and package dependencies.
- Answer: Yes.
- Interpretation: Implement the installer as dependency-free PowerShell and validate it under both Windows PowerShell 5.1 and PowerShell 7.
- Reinterpretation notice: The one-word answer was normalized as confirmation of the complete runtime recommendation stated immediately before the question.
- Definition impact: Fixes the installer language and compatibility floor, excludes Node.js and Python dependencies, and requires dual-PowerShell test execution.

#### Entry 10

- Question: Should installation copy each selected skill into the destination rather than create a filesystem link back to the source catalog?
- Why it mattered: Copies work without elevated symlink privileges and remain available if the catalog checkout moves or is removed; links make source edits immediately active but couple runtime behavior to the checkout and Windows link policy.
- Recommendation: Install validated copies and record source provenance, with explicit update behavior defined separately; do not use links by default.
- Answer: Use copied installation, but clean the specific selected skill folder before inserting the new version because some files may have been deleted and no longer exist in the source. The user explicitly clarified that cleanup does not apply to the parent skills folder.
- Interpretation: Each successful installation is an independent copy and each update must produce an exact destination mirror of the selected catalog skill, removing stale files that are absent from the new source version.
- Reinterpretation notice: "Clean before inserting" is normalized as a safe staged replacement contract rather than literal delete-then-copy ordering. The installer should validate a staged new tree before replacing the prior installation so a copy failure does not unnecessarily leave the skill absent. Cleanup scope is the exact destination child folder for the selected skill only; the parent skills directory and siblings are excluded.
- Definition impact: Rejects link installation, requires full-tree replacement rather than merge copying, and makes provenance, rollback, and replacement atomicity material requirements.

#### Entry 11

- Question: Should automatic cleanup and replacement be allowed only when the existing destination is marked as installer-managed, with an explicit force option required for any unmarked folder?
- Why it mattered: Cleaning an unmarked folder could delete manual changes or an unrelated skill that happens to use the same directory name.
- Recommendation: Write installer provenance into managed copies, update managed copies automatically through staged replacement, refuse unmarked collisions by default, and require an explicit force action to replace one.
- Answer: Not necessary.
- Interpretation: Do not add or require installer-managed provenance metadata inside installed skill folders.
- Reinterpretation notice: The answer rejects the proposed marker requirement only; it does not yet decide whether collisions are replaced automatically or require an explicit force action.
- Definition impact: Removes provenance metadata from installed output and makes collision authorization depend on the exact selected path plus a separately defined command behavior.

#### Entry 12

- Question: When the exact selected destination skill folder already exists, should the installer replace it automatically without requiring a force flag or confirmation?
- Why it mattered: Without provenance metadata, automatic replacement may delete manual changes in that exact folder; requiring explicit force makes updates less convenient but preserves a visible destructive-action boundary.
- Recommendation: Refuse an existing folder by default and require an explicit non-interactive `-Force` option for full-tree replacement; avoid interactive prompts so agent and automation behavior remains deterministic.
- Answer: No; just replace it to provide a quick update or refresh procedure.
- Interpretation: Installing or refreshing a selected skill is non-interactive and automatically replaces an existing exact destination skill folder without `-Force` or confirmation.
- Reinterpretation notice: Automatic replacement does not broaden cleanup scope. It remains limited to the resolved child folder for each explicitly selected skill and does not waive staged validation or failure rollback.
- Definition impact: Makes refresh the default idempotent behavior, removes force and prompt paths, and requires tests proving automatic replacement plus failure restoration.

#### Entry 13

- Question: Should the installer support an explicit `-All` option that installs or refreshes every skill in the source catalog in one command?
- Why it mattered: A bulk option makes routine refresh fast as the catalog grows, while an explicit flag avoids silently activating all skills during ordinary single-skill use.
- Recommendation: Support both one-or-more named skills and an explicit mutually exclusive `-All` switch.
- Answer: Yes, and create a file that does this by default as well.
- Interpretation: The general installer supports explicit, mutually exclusive named-skill selection and `-All`; a separate convenience entry point invokes whole-catalog refresh without requiring the caller to supply `-All`.
- Reinterpretation notice: "A file" is normalized as a separate version-controlled convenience entry point rather than changing the general installer to select all skills whenever selection is omitted. Its destination still requires a decision.
- Definition impact: Adds `-All`, bulk-selection validation, bulk failure reporting, and a convenience refresh-all file to deliverables.

#### Entry 14

- Question: Should the no-argument whole-catalog refresh file install or refresh all skills into the Codex user-scope directory by default?
- Why it mattered: User scope is deterministic without another repository argument, while repository scope requires identifying a separate target repository and a custom destination requires a path.
- Recommendation: Default the convenience file to Codex user scope and keep repository or custom destinations on the general installer.
- Answer: Yes.
- Interpretation: Running the dedicated convenience entry point without destination arguments refreshes all catalog skills into `$HOME\.agents\skills`.
- Reinterpretation notice: The colloquial answer "yea" was normalized as confirmation of the complete recommended destination immediately preceding the question.
- Definition impact: Fixes the convenience file's default destructive scope, documentation, and test substitution contract.

#### Entry 15

- Question: Should intentional uninstall or removal be out of scope for this installer?
- Why it mattered: The requested fast workflow is install and refresh; uninstall would introduce an additional destructive command and policy that is not otherwise required.
- Recommendation: Limit the initial tool to list, install, and refresh behavior; document manual removal and add uninstall only through a later explicit requirement.
- Answer: Yes, out of scope.
- Interpretation: The installer owns listing available catalog skills, installing selected or all skills, and refreshing existing copies. It does not remove installed skills.
- Reinterpretation notice: None.
- Definition impact: Closes the installer command surface and excludes uninstall implementation and tests while permitting concise manual-removal documentation.

#### Entry 16

- Question: Is this repository intended to be public and reusable by people beyond its owner?
- Why it mattered: Public reuse affects licensing, contribution guidance, security and support expectations, and the level of installation documentation required.
- Recommendation: None; repository visibility and distribution intent require an explicit owner decision and could not be established from the accessible remote metadata.
- Answer: Private.
- Interpretation: The repository is not intended for public reuse. Do not add an open-source license or public community, support, or security-policy files merely as generic repository boilerplate.
- Reinterpretation notice: The one-word answer was normalized as repository distribution intent; it does not establish whether invited private collaborators will contribute.
- Definition impact: Excludes public licensing and community governance from the required root file set while leaving private collaboration guidance unresolved.

#### Entry 17

- Question: Will anyone other than you contribute changes to this private repository?
- Why it mattered: Multiple private contributors may justify concise contribution and review guidance, while a sole-maintainer repository can keep those rules in `AGENTS.md` and the README without additional governance files.
- Recommendation: Omit a separate `CONTRIBUTING.md` unless private human collaborators are expected; coding-agent workflow rules still belong in root `AGENTS.md`.
- Answer: Maybe.
- Interpretation: Occasional private human contribution is possible but not established as a regular multi-maintainer workflow. Include concise authoring, validation, and review steps in the README; do not add `CONTRIBUTING.md` or `CODEOWNERS` initially.
- Reinterpretation notice: "Maybe" is preserved as a managed uncertainty rather than converted into a definite collaboration plan. The file decision is a recommendation-based contingency, not a claim that contributors exist today.
- Definition impact: Requires lightweight contributor guidance and a gate to add dedicated governance files only when collaboration becomes recurring or ownership rules become necessary.

#### Entry 18

- Question: Should repository and skill validation run automatically through GitHub Actions on proposed changes?
- Why it mattered: Automatic validation protects the catalog and installer when occasional contributors or coding agents change files, but adds workflow maintenance and private-repository CI use.
- Recommendation: Add a narrow Windows GitHub Actions workflow that runs repository validation, installer tests, and both supported PowerShell runtime suites where the runner supports them; keep the same checks runnable locally.
- Answer: Yes.
- Interpretation: Add a narrow Windows GitHub Actions workflow for proposed changes. It must call the same version-controlled validation and test entry points used locally, exercise both `pwsh` and `powershell`, and avoid CI-only validation logic.
- Reinterpretation notice: None.
- Definition impact: Requires `.github/workflows/`, explicit dual-shell jobs or matrix entries, local/CI parity, and a passing automated gate for repository, skill, and installer changes.

#### Entry 19

- Question: Should repository and skill validation also remain dependency-free PowerShell, without requiring Python or `skills-ref`?
- Why it mattered: A PowerShell-only validator keeps local and CI setup aligned with the Windows-only repository tooling, while the official `skills-ref` implementation requires Python and is labeled demonstration-only rather than production-ready.
- Recommendation: Yes. Maintain a repository-owned PowerShell validator for the portable specification subset and repository rules, test it under Windows PowerShell 5.1 and PowerShell 7, and treat `skills-ref` only as optional comparative evidence when useful.
- Answer: Yes.
- Interpretation: Implement and maintain validation in dependency-free PowerShell compatible with Windows PowerShell 5.1 and PowerShell 7. Do not require Python, `skills-ref`, Pester, or third-party modules for local or CI checks. Upstream `skills-ref` may be used manually as optional comparison evidence but is not a release prerequisite.
- Reinterpretation notice: None.
- Definition impact: Fixes validation dependencies and runtime, requires repository-owned assertion/test support, and makes periodic authoritative-spec comparison a maintenance responsibility.

#### Entry 20

- Question: Should the initial repository use the proposed compact layout with root guidance and refresh entry point, canonical `skills/`, shared PowerShell tooling under `scripts/`, test suites under `tests/`, and one Windows workflow under `.github/workflows/`?
- Why it mattered: The layout determines what a fresh coding agent can discover, which files remain always visible, and how installer, validation, tests, and CI responsibilities stay separate without adding unnecessary governance or documentation layers.
- Recommendation: Use `README.md`, `AGENTS.md`, `.gitignore`, and `Refresh-CodexSkills.ps1` at the root; retain `skills/<skill-name>/`; add `scripts/Install-Skills.ps1` and `scripts/Test-Repository.ps1`; add dependency-free suites and fixtures under `tests/`; and add `.github/workflows/validate.yml`. Keep detailed authoring and contribution guidance in README initially rather than adding `CONTRIBUTING.md`, `CODEOWNERS`, or an architecture document.
- Answer: Yes.
- Interpretation: Use the proposed compact manifest: root `README.md`, `AGENTS.md`, `.gitignore`, and `Refresh-CodexSkills.ps1`; canonical `skills/<skill-name>/`; shared `scripts/Install-Skills.ps1` and `scripts/Test-Repository.ps1`; dependency-free suites and fixtures under `tests/`; and `.github/workflows/validate.yml`. Do not add `CONTRIBUTING.md`, `CODEOWNERS`, or an architecture document initially.
- Reinterpretation notice: None.
- Definition impact: Finalizes the initial implementation file manifest, per-file responsibilities, and navigation contract.

#### Entry 21

- Question: Should Codex repository-scope installation require the caller to supply the target repository path instead of defaulting to this catalog checkout?
- Why it mattered: Defaulting repository scope to the catalog checkout would create `.agents/skills/` inside the source repository, activate derived copies during catalog maintenance, and blur the single-source boundary. An explicit target makes cross-repository intent visible and testable.
- Recommendation: Yes. Require an explicit target repository path for repository scope, resolve its `.agents\skills` child, and reject the catalog repository itself as the target unless a future explicit override is separately designed.
- Answer: Yes, but Codex user-scope installation will probably be used most of the time as a global skill location.
- Interpretation: Repository scope is an explicit secondary mode. It requires a caller-supplied target checkout, resolves `<target>\.agents\skills`, and rejects `D:\Work\agent-skills` itself as that target. Codex user scope is the primary normal workflow.
- Reinterpretation notice: None.
- Definition impact: Defines repository-target parameters, safe destination resolution, self-install protection, documentation, and tests; also establishes user scope as the dominant operational path.

#### Entry 22

- Question: Should the general installer default to Codex user scope at `$HOME\.agents\skills` when a destination mode is not supplied?
- Why it mattered: User scope is expected to be the normal workflow, and a safe default shortens named-skill refresh commands. Repository scope and generic paths still need explicit parameters because they can affect unrelated checkouts or client locations.
- Recommendation: Yes. Keep skill selection explicit (`-Name` or `-All`), but default the destination to Codex user scope; require explicit `-RepositoryPath` or `-DestinationPath` for the two alternate modes.
- Answer: Yes.
- Interpretation: When no destination option is supplied, the general installer resolves Codex user scope at `$HOME\.agents\skills`. Skill selection remains explicit through `-Name` or `-All`. Repository scope requires `-RepositoryPath`, and generic mode requires `-DestinationPath`.
- Reinterpretation notice: None.
- Definition impact: Finalizes parameter-set defaults and the shortest supported named-skill command.

#### Entry 23

- Question: Should CI fail only for specification, repository-contract, broken-reference, and installer-safety errors, while reporting style and quality recommendations as non-blocking warnings?
- Why it mattered: Treating every recommendation as an error can reject valid portable skills and make guidance indistinguishable from required contracts. Ignoring structural or safety failures would make automation ineffective.
- Recommendation: Yes. Use actionable errors with a nonzero exit for contract or safety violations; emit advisory warnings for documented best practices without failing CI. Do not silently downgrade required specification checks.
- Answer: Yes.
- Interpretation: Findings that violate the Agent Skills specification, this repository's documented required profile, referenced-file integrity, installer safety, or test expectations produce actionable errors and a nonzero exit. Documented style and quality recommendations produce warnings but do not fail local validation or CI.
- Reinterpretation notice: None.
- Definition impact: Fixes validator severities, exit codes, CI pass/fail behavior, and authoring documentation language.

#### Entry 24

- Question: Should the repository require a simple YAML frontmatter profile using plain or quoted single-line string fields plus an indented string-to-string `metadata` map, rather than accepting every advanced YAML representation?
- Why it mattered: The specification defines a small data model but uses YAML, whose full syntax would require a substantial parser or a dependency. A documented subset can be parsed reliably in dependency-free PowerShell, but it intentionally rejects exotic yet potentially YAML-valid encodings such as anchors, tags, flow maps, and multiline scalar forms.
- Recommendation: Yes. Enforce the simple profile as a repository contract, cover all specification fields and constraints, explain the restriction in authoring guidance, and test quoted values, comments, metadata, malformed input, and unsupported advanced forms. This preserves portable output while keeping validation deterministic.
- Answer: Yes.
- Interpretation: Require plain or quoted single-line string values for top-level specification fields and an ordinary indented string-to-string `metadata` map. Reject anchors, aliases, tags, flow collections, multiline scalar forms, duplicate keys, unsupported top-level fields, and malformed quoting as repository-contract errors. Document this as a repository syntax profile, not as an additional claim about the portable specification.
- Reinterpretation notice: None.
- Definition impact: Fixes parser scope, authoring rules, negative fixtures, and the boundary between portable data semantics and repository syntax policy.

#### Entry 25

- Question: Should a named multi-skill or `-All` refresh be all-or-nothing, restoring every previously installed selected skill if any selected skill cannot be refreshed?
- Why it mattered: Per-skill rollback protects the failing target but can leave a bulk command partially applied. Transactional selection-level behavior costs additional staging and backup handling but makes a failed whole-catalog refresh leave the destination at its prior consistent state.
- Recommendation: Yes. Validate and stage the complete selection first, preserve backups for all existing selected targets, perform swaps, and remove backups only after every selected target succeeds. On any failure, restore every changed selected target and return nonzero with per-skill diagnostics.
- Answer: Yes, with the additional requirement that a failure must be easy for the user to identify.
- Interpretation: Named multi-skill and `-All` refreshes are selection-level transactions. Validate and stage every source first, retain every needed backup through the final successful swap, and restore the complete changed selection on any failure. Return nonzero and prominently identify the failed phase or skill, the reason, and whether every rollback action succeeded.
- Reinterpretation notice: None.
- Definition impact: Defines bulk staging, backup retention, rollback order, failure reporting, and transactional tests; adds explicit failure-visibility acceptance criteria.

#### Entry 26

- Question: Is a concise console failure summary plus a nonzero process exit sufficient, without creating a persistent installer log file by default?
- Why it mattered: Console and exit-code reporting is immediately visible to users, coding agents, and GitHub Actions without leaving generated files. A persistent log may help later diagnosis but adds retention, cleanup, privacy, and path-management responsibilities for a quick refresh tool.
- Recommendation: Yes. Print deterministic per-skill or per-phase status, a prominent final `FAILED` summary, the original error, and `ROLLBACK SUCCEEDED` or `ROLLBACK FAILED`; write failures to the error stream and return nonzero. Do not create log files unless a later concrete troubleshooting need justifies an explicit opt-in.
- Answer: Yes.
- Interpretation: Use deterministic console and error-stream output plus a nonzero process exit. Report the failed skill or phase, original cause, final status, and rollback outcome when applicable. Do not create a persistent log by default; persistent logging is a future opt-in only if a concrete troubleshooting need arises.
- Reinterpretation notice: None.
- Definition impact: Finalizes default diagnostics, stream and exit behavior, generated-file scope, and failure-output tests.

## Assumptions and challenges

| Assumption or claim | Status | Challenge or evidence | Result |
| --- | --- | --- | --- |
| The repository merely needs a generic README. | rejected | The user explicitly added an AGENTS-related requirement, which can affect operational instructions and repository structure. | Discovery must define agent interaction before choosing files. |
| A root `AGENTS.md` is required. | accepted | Coding agents are the primary repository users, Codex is dominant, current Codex instruction discovery is verified, and the user approved the compact manifest containing `AGENTS.md`. | Add concise operational guidance at the root and keep detailed explanation in README. |
| The existing skill is a sufficient model for all future skills. | rejected | It demonstrates one valid extended structure, while the specification and approved authoring profile allow minimal skills and optional resources. | Use it as a preservation case, not a mandatory skeleton; validate both minimal and extended fixtures. |
| Agent readiness can be solved only with documentation. | rejected | The user explicitly added repository structure to the requested AGENTS considerations. | Treat layout, navigation, and structural validation as deliverables. |
| Supporting other coding agents requires product-specific files for every agent. | revised | The Agent Skills specification supplies a portable per-skill baseline, while discovery locations and extensions are client-specific. | Use a portable core plus only justified, testable product adapters. |
| "Supports other coding agents" means universal compatibility with every agent. | rejected | The user accepted specification compliance as the sufficient default support contract. | Claim portable conformance, not universal product compatibility. |
| The canonical `skills/` catalog should automatically activate inside Codex. | rejected | The user defined `skills/` as the source catalog. | Keep source storage separate from repository-scoped active-skill discovery. |
| Installation can remain documentation-only. | rejected | The user explicitly requires a repository-owned installation tool. | Add maintained installer code and validation to the later implementation. |
| The installer should hard-code unnamed secondary-agent destinations. | rejected | The confirmed target model uses a generic explicit destination for other clients. | Claim and test only Codex-aware defaults; leave other discovery paths to callers. |
| Cross-platform installer support is required by cross-agent skill compatibility. | rejected | The user explicitly accepted a Windows-only installer while retaining portable skill-format compliance. | Keep skill portability separate from installer platform support. |
| The Windows installer needs Node.js or Python for portability. | rejected | The user confirmed a native PowerShell implementation compatible with both installed PowerShell families. | Keep the installer dependency-free beyond supported PowerShell. |
| Merge-copying a new skill version over an old installed folder is sufficient. | rejected | The user explicitly requires stale files removed when they disappear from the catalog version. | Use full-tree staged replacement for updates. |
| Cleanup may target the parent skills directory. | rejected | The user explicitly clarified that only the selected skill's folder may be cleaned. | Resolve and validate the exact child target; never recursively clean the parent or siblings. |
| Installed copies need an installer provenance marker before replacement. | rejected | The user said the marker is not necessary. | Do not alter installed skill contents with provenance metadata; define collision consent separately. |
| Existing destination collisions require confirmation or `-Force`. | rejected | The user wants automatic replacement as a quick refresh procedure. | Refresh the exact selected child folder non-interactively, with strict path checks and staged rollback. |
| Whole-catalog refresh should be implicit whenever the general installer has no selection. | revised | The user asked for a file that performs `-All` by default, which can be satisfied without making omission dangerous in the general installer. | Keep explicit selection in the general installer and provide a dedicated refresh-all entry point. |
| The refresh-all convenience file needs a repository or custom destination argument. | rejected | The user confirmed Codex user scope as its default destination. | Keep alternate destinations on the general installer. |
| A complete installer must include uninstall. | rejected | The user explicitly placed uninstall out of scope. | Limit maintained commands to list, install, and refresh. |
| A private catalog needs generic open-source governance files. | rejected | The user explicitly identified the repository as private. | Omit open-source license, public contribution, public support, and public security-policy boilerplate. |
| Possible private contributors require full governance immediately. | revised | The user said "maybe," which indicates possible but not established recurring collaboration. | Put the workflow in README and add dedicated files only when actual collaboration requires them. |
| GitHub Actions cannot exercise both supported PowerShell families. | rejected | Current GitHub workflow syntax supports explicit `pwsh` and `powershell` shells on Windows runners. | Require both runtime paths while avoiding assertions tied to a specific hosted-image patch version. |
| Production validation should depend on upstream `skills-ref`. | rejected | The user requires dependency-free PowerShell validation, and upstream labels `skills-ref` demonstration-only. | Maintain local validation and tests in this repository; use upstream tooling only for optional comparative audits. |

## Contradictions and resolutions

| Contradiction | Material impact | Resolution | Evidence or decision |
| --- | --- | --- | --- |
| Early collision guidance proposed refusing existing targets, while the user later required automatic replacement. | Would have produced contradictory documentation, validation, and command behavior. | The explicit later user decision controls: exact selected child targets refresh automatically without `-Force`, with staging and rollback. | Entries 14 and 15 plus corrected task-definition risks and tests. |
| Portable specification conformance could appear inconsistent with the reduced YAML syntax profile. | An executor might either implement full YAML dependencies or overstate the repository profile as part of the standard. | Treat the simple YAML forms as a documented private repository authoring contract layered on the specification's portable field semantics. | Entry 24 and current Agent Skills specification. |

## Decision log

| Time | Decision | Rationale | Evidence class | Definition impact |
| --- | --- | --- | --- | --- |
| `2026-07-21T17:45:36.9038959-03:00` | Name the task `prepare-agent-skill-repository`. | The user confirmed the proposed concise name. | verified | Fixes the discovery path and task identifier. |
| `2026-07-21T17:48:31.6418900-03:00` | Treat coding agents working directly in the checkout as the primary AGENTS role. | The user explicitly confirmed the recommended interpretation. | verified | Establishes the principal agent stakeholder and authoring workflow. |
| `2026-07-21T17:48:31.6418900-03:00` | Include agent-oriented repository structure in scope. | The user explicitly added repository structure to the confirmed AGENTS role. | verified | Requires a justified, discoverable layout as part of the later implementation. |
| `2026-07-21T17:54:20.8450923-03:00` | Make Codex the dominant first-class authoring environment while retaining cross-agent usability. | The user expects approximately 99% Codex usage but explicitly requires support for other coding agents. | verified | Establishes a portable core with a deeper Codex-specific validation layer. |
| `2026-07-21T18:04:12.4416164-03:00` | Keep `skills/` as the canonical source catalog. | The user explicitly identified the folder's role. | verified | Separates source ownership from client-specific installation and discovery paths. |
| `2026-07-21T18:06:12.8547552-03:00` | Use open Agent Skills specification compliance as the default secondary-agent support contract. | The user confirmed that this level is sufficient. | verified | Excludes unnamed product adapters and unverified compatibility promises from the required implementation. |
| `2026-07-21T18:08:59.2202689-03:00` | Include and maintain a repository-owned installation tool. | The user explicitly selected this over documentation-only consumption. | verified | Adds executable tooling, tests, safety semantics, and maintenance responsibility to scope. |
| `2026-07-21T18:12:10.4854531-03:00` | Use Codex-aware destinations plus a generic explicit destination for other clients. | The user confirmed the recommended target model. | verified | Bounds built-in target behavior and avoids unverified named-agent adapters. |
| `2026-07-21T18:13:51.2719513-03:00` | Limit the repository-owned installer to Windows. | The user stated that Windows-only support is sufficient. | verified | Removes macOS/Linux launcher, path, and test obligations. |
| `2026-07-21T18:15:56.7667137-03:00` | Implement the installer in dependency-free PowerShell compatible with Windows PowerShell 5.1 and PowerShell 7. | The user confirmed the recommended native runtime contract. | verified | Fixes implementation language and dual-runtime validation. |
| `2026-07-21T18:20:03.8306453-03:00` | Install independent copies and replace the full installed tree on update. | The user selected copies and explicitly required removal of files deleted from the catalog skill. | verified | Requires staged exact-mirror replacement rather than links or merge copying. |
| `2026-07-21T18:21:15.6047335-03:00` | Limit cleanup to the exact selected destination skill folder. | The user explicitly distinguished it from the parent skills directory. | verified | Requires strict child-path resolution and sibling-preservation tests. |
| `2026-07-21T18:23:02.7623224-03:00` | Do not require installer provenance metadata in installed copies. | The user rejected the proposed marker as unnecessary. | verified | Keeps installed output identical to source and shifts safety to exact-path and command semantics. |
| `2026-07-21T18:26:19.6527743-03:00` | Automatically replace an existing exact selected destination skill folder without prompts or force flags. | The user prioritized a quick update or refresh procedure. | verified | Makes refresh idempotent and non-interactive while retaining strict target and rollback safeguards. |
| `2026-07-21T18:28:50.8337601-03:00` | Support explicit `-All` plus a dedicated entry point that refreshes all by default. | The user explicitly requested both behaviors. | verified | Adds safe bulk selection and a one-command routine refresh workflow. |
| `2026-07-21T18:30:56.9073788-03:00` | Default the refresh-all convenience entry point to `$HOME\.agents\skills`. | The user confirmed the recommended Codex user-scope target. | verified | Establishes a no-argument whole-catalog refresh workflow. |
| `2026-07-21T18:33:31.2771785-03:00` | Exclude uninstall from the repository-owned installer. | The user confirmed the recommended narrow command surface. | verified | Finalizes list, install, and refresh as the installer lifecycle scope. |
| `2026-07-21T18:36:19.8405336-03:00` | Treat the repository as private. | The user explicitly stated its distribution intent. | verified | Excludes public/open-source governance deliverables. |
| `2026-07-21T18:38:43.9617794-03:00` | Use README-level contribution guidance and defer `CONTRIBUTING.md` and `CODEOWNERS`. | Private collaborators may exist, but regular collaboration and ownership needs are not established. | inference | Keeps initial governance proportionate while defining a future gate. |
| `2026-07-21T18:41:51.3244459-03:00` | Run validation automatically through GitHub Actions. | The user explicitly approved CI validation for proposed changes. | verified | Requires a Windows workflow with local/CI parity and both supported PowerShell shells. |
| `2026-07-21T18:47:39.3938702-03:00` | Keep repository and skill validation dependency-free PowerShell. | The user explicitly approved the recommended boundary after reviewing the upstream reference tool's status and requirements. | verified | Excludes mandatory Python, `skills-ref`, Pester, and third-party modules from local and CI validation. |
| `2026-07-21T18:51:47.0151889-03:00` | Use the proposed compact initial repository layout. | The user explicitly approved the recommended manifest. | verified | Fixes root guidance and refresh files plus `skills/`, `scripts/`, `tests/`, and `.github/workflows/` responsibilities. |
| `2026-07-21T18:55:01.5032680-03:00` | Require an explicit external checkout for Codex repository scope and reject the catalog checkout. | The user approved the clarified source-versus-derived safety boundary. | verified | Prevents accidental `.agents\skills` activation inside this catalog and fixes repository-scope destination resolution. |
| `2026-07-21T18:55:01.5032680-03:00` | Treat Codex user scope as the primary consumption mode. | The user expects to use skills globally most of the time. | verified | Prioritizes user-scope examples and informs the general installer's pending default. |
| `2026-07-21T18:58:19.6530069-03:00` | Default the general installer destination to Codex user scope. | The user approved the shortest safe path for the expected global workflow. | verified | Named and `-All` selection can omit a destination; repository and generic modes remain explicit. |
| `2026-07-21T19:02:46.8879608-03:00` | Fail CI only on correctness and safety errors. | The user approved non-blocking treatment for style and quality recommendations. | verified | Requires explicit error/warning classification and nonzero exits only when errors occur. |
| `2026-07-21T19:05:13.2380742-03:00` | Enforce a simple dependency-free YAML frontmatter profile. | The user approved a documented syntax subset that the repository-owned PowerShell validator can parse completely. | verified | Advanced YAML representations are repository-contract errors even when they could express equivalent specification data. |
| `2026-07-21T19:08:04.7591402-03:00` | Make multi-skill refresh all-or-nothing and highly visible on failure. | The user approved selection-level rollback and explicitly required easy failure recognition. | verified | Requires complete-selection backups, prominent diagnostics, rollback outcome reporting, and a nonzero exit. |
| `2026-07-21T19:10:26.1987787-03:00` | Use console/error-stream diagnostics and no persistent log by default. | The user approved the recommended lightweight failure-reporting contract. | verified | Keeps the quick refresh procedure free of generated logs while preserving user, agent, and CI visibility through deterministic output and exit status. |

## Discarded alternatives

| Alternative | Why considered | Why discarded |
| --- | --- | --- |
| Immediately add common repository files. | The initial request asks to update whatever is needed. | The explicitly invoked discovery workflow prohibits implementation and the AGENTS use case is materially ambiguous. |

## Unresolved and managed unknowns

| Item | Why unresolved | Impact | Resolver | Resolution step | Contingency or gate |
| --- | --- | --- | --- | --- | --- |
| Filesystem rollback reliability | The approved sequence is defined, but Windows permissions or locks can still cause a swap or restoration failure. | A failed update could leave a selected target unavailable despite best-effort rollback. | Implementation tests and runtime diagnostics | Stage beside the target, retain all backups until total success, inject swap and restore failures, and report exact rollback status. | Block release unless normal injected failures restore the full selection; if rollback itself fails at runtime, preserve remaining backups and return prominent nonzero diagnostics. |
| Dedicated private governance files | Occasional collaborators are possible, but frequency and ownership rules are unknown. | May later justify `CONTRIBUTING.md` or `CODEOWNERS`. | Repository owner when collaboration becomes recurring | Add files when contributors need standalone workflow details or enforced ownership. | Until then, keep concise guidance in README and `AGENTS.md`. |

## Readiness reviews

### Final review - `2026-07-21T19:17:24.2474307-03:00`

| Category | Checklist item | Result | Evidence or judgment |
| --- | --- | --- | --- |
| Phase integrity | Confirm that the skill was explicitly invoked. | pass | The user explicitly invoked `task-discovery`; Entry 1 and phase history preserve the phase contract. |
| Phase integrity | Confirm that no implementation or write occurred outside the discovery directory. | pass | Final `git status --short --untracked-files=all` showed all changed paths beneath `docs/discovery/prepare-agent-skill-repository/`. |
| Phase integrity | Confirm that the documents use the request's language and agree with each other. | pass | Both primary documents are in English and the final consistency scan found no pending-answer markers or current contradictory requirements. |
| Phase integrity | Confirm that status, creation time, and last-updated time are current. | pass | Both documents are set to `ready-for-handoff` with preserved creation time and this review timestamp. |
| Intent and outcomes | State the task in one unambiguous sentence. | pass | `task-definition.md` contains a single bounded task statement. |
| Intent and outcomes | Define the problem or opportunity and why the work matters. | pass | Objective and current-state sections explain fresh-agent usability, source integrity, portability, and refresh safety. |
| Intent and outcomes | Identify the desired observable outcomes. | pass | Deliverables, validation strategy, acceptance criteria, and definition of done are observable. |
| Intent and outcomes | Identify affected stakeholders or users when applicable. | pass | Repository owner, occasional private contributors, coding agents, Codex, and portable consumers are identified. |
| Intent and outcomes | Distinguish the user's stated intent from inferred recommendations. | pass | Research, assumptions, decisions, evidence classes, and deferred governance inference are labeled separately. |
| Context and evidence | Describe the relevant current state. | pass | The definition records the clean one-commit repository, five tracked skill files, missing root support files, and local runtimes. |
| Context and evidence | Inspect available sources that could materially change the definition. | pass | Repository tree, Git history, existing skill, current Codex guidance, Agent Skills specification, `skills-ref`, and GitHub Actions references were inspected. |
| Context and evidence | Reference sources for material researched claims. | pass | `sources/research-notes.md` and the evidence table contain current primary-source links and access dates. |
| Context and evidence | Classify material claims as verified, inferred, assumed, or unresolved. | pass | The evidence taxonomy is applied throughout both documents. |
| Context and evidence | Reconcile conflicting evidence or explicitly manage the conflict. | pass | Automatic collision replacement and the repository YAML profile conflicts are explicitly resolved in the contradiction table. |
| Context and evidence | Note source freshness and access limitations when relevant. | pass | Drift-prone Codex and GitHub behavior is dated and gated for reverification. |
| Scope and deliverables | Define what is in scope. | pass | Repository guidance, structure, installer, validation, tests, and CI are enumerated. |
| Scope and deliverables | Define material exclusions or boundaries. | pass | No implementation during discovery, uninstall, non-Windows installer, public governance, named adapters, actual install, commit, push, or release. |
| Scope and deliverables | Identify each expected deliverable and its required form. | pass | The approved manifest names every root, script, test, fixture, catalog, and workflow responsibility. |
| Scope and deliverables | Define applicable functional, qualitative, operational, legal, safety, or policy requirements. | pass | Requirements cover portability, private status, path containment, exact replacement, rollback, diagnostics, YAML profile, and dual-runtime operation. |
| Scope and deliverables | Record constraints, preferences, permissions, and prohibited actions. | pass | Constraints and handoff boundaries preserve Windows-only tooling, dependency-free PowerShell, private scope, and separate execution authority. |
| Feasibility and execution | Identify dependencies, prerequisites, integrations, and external decisions. | pass | PowerShell runtimes, GitHub Actions availability, separate implementation authorization, and drift reverification are explicit. |
| Feasibility and execution | Challenge assumptions that could change scope or approach. | pass | The assumptions table rejects generic README-only, automatic activation, universal compatibility, merge copy, force prompts, and unnecessary governance. |
| Feasibility and execution | Cover material failure modes, edge cases, and risks. | pass | Risks include overlaps, traversal, reparse points, locks, partial swaps, stale files, siblings, bulk rollback, runtime divergence, and metadata drift. |
| Feasibility and execution | Provide mitigations or decision gates for material risks. | pass | Each risk has a mitigation, test, refusal rule, rollback behavior, or release gate. |
| Feasibility and execution | Define a recommended phased approach and sequencing. | pass | Three implementation phases order reverification, shared logic and entry points, then full validation and handoff. |
| Feasibility and execution | Identify points where later execution must stop for approval or new information. | pass | The sequencing and handoff notes require stops for overlap, stale authoritative behavior, worktree conflict, or scope expansion. |
| Validation and completion | Make acceptance criteria observable and testable for the task domain. | pass | Acceptance criteria use explicit paths, commands, exit behavior, destination states, and failure outcomes. |
| Validation and completion | Define how each important outcome will be validated. | pass | The validation matrix covers documentation, structure, source integrity, paths, transactions, diagnostics, both runtimes, and compatibility boundaries. |
| Validation and completion | Include negative cases or failure validation when material. | pass | Invalid frontmatter, missing references, traversal, overlaps, reparse points, stale files, swap failures, rollback failures, and conflicting parameters are included. |
| Validation and completion | State a clear definition of done. | pass | The definition of done requires the approved files, passing evidence, preserved behavior, explicit limitations, and bounded diff. |
| Validation and completion | Make the task definition sufficient for a fresh agent without chat context. | pass | It contains purpose, current state, exact manifest, command and CI contracts, execution sequence, tests, authority boundaries, and traceability. |
| Unknowns and consistency | Resolve every material open question that can currently be resolved. | pass | No current pending answer or user-owned material decision remains. |
| Unknowns and consistency | For each unavoidable external unknown, record impact, resolver, resolution step, contingency, and gate. | pass | Filesystem rollback reliability, future governance need, and CI runner drift are fully managed. |
| Unknowns and consistency | Remove placeholder text and accidental contradictions. | pass | Final scan found no pending answers, TODOs, placeholders, or current unresolved markers; historical ambiguity is explicitly resolved. |
| Unknowns and consistency | Ensure recommendations do not masquerade as requirements or verified facts. | pass | User-approved recommendations are logged as decisions; remaining inferences and future gates remain labeled. |
| Unknowns and consistency | Ensure every readiness claim is supported by the documents rather than conversational memory. | pass | This review cites repository evidence, recorded entries, the canonical definition, and the final automated consistency scan. |

Result: **pass**. Every applicable checklist item passes. Remaining uncertainty is managed through explicit implementation or future-maintenance gates and does not require another discovery question.

## Closure

- Closed at: `2026-07-21T19:17:24.2474307-03:00`
- Result: `ready-for-handoff`
- Canonical definition: `task-definition.md`
- Snapshot: `versions/task-definition-v001.md`
- Implementation performed: No.
- Next authority required: A separate user request to implement the task definition.

## Phase history

| Time | Event | Status | Notes |
| --- | --- | --- | --- |
| `2026-07-21T17:45:36.9038959-03:00` | Discovery started | `in-progress` | The skill was explicitly invoked; initial repository inspection was read-only. |
| `2026-07-21T17:45:36.9038959-03:00` | Task name confirmed and primary documents initialized | `in-progress` | All discovery writes are confined to the confirmed discovery directory. |
| `2026-07-21T18:04:12.4416164-03:00` | Canonical catalog path confirmed | `in-progress` | `skills/` is the source of truth; automatic repository-scoped activation is excluded. |
| `2026-07-21T18:08:59.2202689-03:00` | Repository-owned installer required | `in-progress` | Installation code and its safety contract are now required deliverables. |
| `2026-07-21T18:41:51.3244459-03:00` | GitHub Actions validation approved | `in-progress` | CI must run the same local validation and tests under both PowerShell families. |
| `2026-07-21T18:51:47.0151889-03:00` | Compact file manifest approved | `in-progress` | Initial paths and responsibilities are fixed; destination resolution details remain under discovery. |
| `2026-07-21T19:17:24.2474307-03:00` | Readiness gate passed and discovery closed | `ready-for-handoff` | All 36 checklist items passed; canonical definition finalized as `v001` and snapshot required. |
