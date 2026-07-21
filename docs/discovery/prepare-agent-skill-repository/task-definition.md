# Task Definition: Prepare Agent Skill Repository

## Document metadata

- Status: `ready-for-handoff`
- Task name: `prepare-agent-skill-repository`
- Version: `v001`
- Created: `2026-07-21T17:45:36.9038959-03:00`
- Last updated: `2026-07-21T19:17:24.2474307-03:00`
- Discovery record: `discovery-record.md`

## Task statement

Define and, in a later execution phase, implement the repository structure, files, conventions, and validation needed for coding agents to author, maintain, and review agent skills reliably without weakening the integrity of individual skills.

## Objective and desired outcomes

The task should make the private repository understandable, maintainable, and safely usable for skill work by its intended human and coding-agent users. A fresh authorized coding agent should be able to navigate the directory structure and determine the repository's purpose, applicable instructions, allowed skill structure, contribution workflow, and validation expectations from repository files. Codex is the dominant first-class authoring environment, expected to account for approximately 99% of use, while the core skill and repository conventions must remain usable by other coding agents. `skills/` is the canonical source catalog and is not automatically activated merely by opening the repository. Compliance with the open Agent Skills specification is sufficient secondary-agent support unless a named adapter is explicitly added later. The repository must maintain a Windows-only, dependency-free PowerShell installer compatible with Windows PowerShell 5.1 and PowerShell 7, with Codex-aware user and repository destinations plus a generic explicit destination for other clients. It installs independent copies and non-interactively refreshes by replacing only the exact selected destination skill folder so source-deleted files do not remain stale; the parent skills directory and siblings are never cleanup targets. Installed copies require no provenance metadata, confirmation, or force flag. Replacement must stage and validate first and retain rollback capability until the swap succeeds. The installer supports explicit `-All`, and a dedicated convenience entry point refreshes all skills to Codex user scope at `$HOME\.agents\skills` by default. The tool owns list, install, and refresh behavior; uninstall is out of scope. Public/open-source governance is out of scope. Occasional private contributors are possible, so README-level contribution guidance is required while separate `CONTRIBUTING.md` and `CODEOWNERS` files are deferred. Repository and skill validation must also be dependency-free PowerShell, with no required Python, `skills-ref`, Pester, or third-party modules. A narrow Windows GitHub Actions workflow must run the same repository, skill, installer, and dual-PowerShell checks available locally. The initial manifest is root `README.md`, `AGENTS.md`, `.gitignore`, and `Refresh-CodexSkills.ps1`; canonical `skills/<skill-name>/`; shared tooling under `scripts/`; dependency-free suites and fixtures under `tests/`; and `.github/workflows/validate.yml`. Codex user scope is the expected primary global workflow and the general installer's default destination, while skill selection remains explicit. Repository scope requires an explicit external target checkout and cannot target this catalog; generic mode requires an explicit destination path. CI blocks correctness and safety errors while style and quality advice remains non-blocking. Frontmatter must follow a simple repository YAML profile that the dependency-free validator can parse completely. Multi-skill refresh is all-or-nothing and prominently reports the original failure plus rollback outcome. Console/error-stream diagnostics and nonzero exit status are sufficient; no persistent installer log is created by default.

## Background and current state

- **Verified:** The clean `main` checkout contains one commit and one skill, `skills/task-discovery/`.
- **Verified:** The skill contains `SKILL.md`, `agents/openai.yaml`, two reusable templates under `assets/`, and a readiness checklist under `references/`.
- **Verified:** The repository root currently has no `AGENTS.md`, README, license, contribution guide, validation configuration, or other tracked repository-level documentation.
- **Verified:** Coding agents working directly in the checkout to author, maintain, and review skills are the primary AGENTS role.
- **Verified:** The repository directory structure itself must be designed to support those coding agents.
- **Verified:** Codex is the dominant first-class authoring environment, expected to account for approximately 99% of coding-agent use.
- **Verified:** Other coding agents must be supported through a portable repository and skill baseline.
- **Verified:** Current Codex documentation states that its skills build on the open Agent Skills standard and that repository-scoped automatic discovery uses `.agents/skills/` along the path from the current directory to the repository root.
- **Verified:** The open Agent Skills specification defines the per-skill folder contract but does not prescribe a collection-root directory name.
- **Verified:** The user designated `skills/` as the canonical source catalog, separate from client-specific active-skill discovery locations.
- **Verified:** Compliance with the open Agent Skills specification is sufficient support for secondary coding agents unless a named product adapter is explicitly added and validated later.
- **Verified:** The repository must include and maintain its own installation tool for selected catalog skills.
- **Verified:** The installer must support Codex-aware user and repository destinations plus a generic explicit destination for other specification-compatible clients.
- **Verified:** Windows is the only required installer platform; macOS and Linux installation tooling are out of scope.
- **Verified:** The local validation environment provides Windows PowerShell 5.1 and PowerShell 7.5.8.
- **Verified:** The installer runtime is native PowerShell compatible with Windows PowerShell 5.1 and PowerShell 7, without Node.js or Python dependencies.
- **Verified:** Selected skills are installed as independent copies, not filesystem links.
- **Verified:** Updating a skill must replace the complete installed tree so any file removed from the catalog version is also removed from the installed copy.
- **Verified:** Cleanup and replacement are scoped to the exact selected destination skill folder; the parent skills directory and sibling skills must not be cleaned or replaced.
- **Verified:** Installed copies do not require or contain installer provenance markers.
- **Verified:** An existing exact selected destination skill folder is replaced automatically without confirmation or a force flag to support quick, idempotent refresh.
- **Verified:** Automatic replacement does not relax strict child-path containment and must retain a complete prior copy until the staged replacement succeeds.
- **Verified:** The installer supports explicit `-All` and the repository includes a dedicated convenience entry point that performs whole-catalog refresh by default.
- **Verified:** The refresh-all convenience entry point defaults to Codex user scope at `$HOME\.agents\skills`.
- **Verified:** Intentional uninstall or removal is out of scope for the installer.
- **Verified:** The repository is private and not intended for public reuse; an open-source license and public community/support files are not required.
- **Verified:** Private human collaborators may contribute occasionally; README-level contribution guidance is required.
- **Inference:** Separate `CONTRIBUTING.md` and `CODEOWNERS` files are unnecessary until collaboration becomes recurring or ownership enforcement is needed.
- **Verified:** Validation must run automatically through GitHub Actions on Windows and exercise both PowerShell 7 (`pwsh`) and Windows PowerShell (`powershell`) through the same entry points used locally.
- **Verified:** Repository and skill validation must be repository-owned, dependency-free PowerShell compatible with Windows PowerShell 5.1 and PowerShell 7; Python, `skills-ref`, Pester, and third-party modules are not required.
- **Verified:** The compact initial repository layout includes root guidance and refresh entry point, canonical `skills/`, shared `scripts/`, dependency-free `tests/`, and a Windows validation workflow; dedicated contribution, ownership, and architecture files are omitted initially.
- **Verified:** Codex user scope is expected to be the primary, effectively global workflow.
- **Verified:** Codex repository scope is secondary, requires an explicit target checkout, resolves that checkout's `.agents\skills`, and rejects this catalog checkout itself.
- **Verified:** The general installer defaults to Codex user scope when no destination mode is supplied; skill selection remains explicit, and repository or generic modes require paths.
- **Verified:** CI and local validation fail on specification, repository-contract, broken-reference, test, and installer-safety errors; style and quality recommendations remain non-blocking warnings.
- **Verified:** Catalog frontmatter uses plain or quoted single-line scalar fields and an indented string-to-string `metadata` map; unsupported advanced YAML forms are repository-contract errors.
- **Verified:** Multi-skill and `-All` refreshes are selection-level transactions that restore every changed selected target on any failure.
- **Verified:** A failed refresh must return nonzero and prominently report the original failure plus whether complete rollback succeeded.
- **Verified:** Console/error-stream diagnostics and a nonzero process exit are sufficient; no persistent installer log is created by default.

## Stakeholders and affected users

- The repository owner and human contributors.
- Coding agents that author, review, validate, or maintain skills in this checkout.
- Codex users and Codex instances as the dominant authoring group.
- Other coding agents that can use the portable Agent Skills baseline.
- Unnamed secondary agents are supported only through the portable Agent Skills contract; named product adapters are intentionally out of scope until separately requested and verified.

## Scope

### In scope

- Determine the intended roles of humans, coding agents, and skill-consuming agents.
- Define a discoverable, scalable directory layout for agent-assisted skill authoring, maintenance, and review.
- Preserve `skills/` as the sole canonical source catalog and keep installed, copied, or linked client-specific skill locations outside that source-of-truth role.
- Define the necessary repository-level documentation, instructions, metadata, ignore rules, validation tooling, and contribution conventions.
- Define how new and existing skills must be organized and validated without assuming every optional subdirectory is mandatory.
- Preserve a product-neutral skill contract based on the open Agent Skills specification while isolating Codex-specific metadata and discovery behavior.
- Define an implementation sequence and observable validation criteria for a later execution phase.

### Out of scope

- Implementing repository changes during the active discovery phase.
- Performing an actual installation, publication, or distribution as part of this repository-implementation task.
- Implementing an uninstall or removal command.
- Public distribution, open-source licensing, and public community, support, or security-policy boilerplate.
- Providing macOS or Linux installer launchers, path support, or platform-specific tests.
- Changing the behavior of the existing `task-discovery` skill unless discovery identifies a concrete compatibility or quality requirement.
- Committing, pushing, releasing, or changing remote repository settings without separate authorization.

## Deliverables

| Deliverable | Required content or form | Completion evidence |
| --- | --- | --- |
| Repository purpose and usage guidance | Root `README.md` for human-facing purpose and workflows plus concise root `AGENTS.md` for coding-agent operations and navigation. | A fresh agent can identify purpose, supported workflows, boundaries, and navigation without chat context. |
| Lightweight private contribution guidance | A README section covering skill authoring, validation, review expectations, and the source-versus-installed-copy boundary. | An occasional private contributor can prepare a valid change without separate conversation context. |
| Agent-oriented repository structure | A justified directory layout with clear ownership, navigation, placement rules, and room for valid skill variants. | A fresh coding agent can locate existing skills and place a representative new skill without guessing or relying on chat context. |
| Source-versus-install boundary | `skills/` remains canonical; any client discovery paths are documented as derived installation targets rather than parallel editable copies. | Documentation and validation identify one source of truth and prevent accidental dual maintenance. |
| Repository-owned installer | Maintained executable tooling for listing and installing or refreshing selected skills from `skills/`, with target resolution, exact-child replacement, transactional rollback, visible failures, and tests. | Representative positive and negative scenarios pass without modifying the source catalog; documented same-name targets refresh automatically while parents and siblings remain untouched. |
| Installer usage documentation | Commands, prerequisites, target semantics, safety behavior, and recovery guidance matching the implemented tool. | A fresh user or coding agent can perform and verify a supported installation without chat context. |
| Refresh-all convenience entry point | A version-controlled PowerShell entry point that invokes whole-catalog refresh to `$HOME\.agents\skills` without requiring `-All` or destination arguments from the caller. | Running it against an isolated substituted home refreshes every catalog skill and no non-catalog sibling. |
| Agent instruction boundary | Concise root `AGENTS.md`, with detailed explanation in README and any future specialized guidance placed at the narrowest appropriate scope. | Instruction chain and scope are audited against current authoritative behavior. |
| Skill authoring convention | Required versus optional skill files, naming, metadata, references, assets, scripts, and quality expectations. | Existing and representative future skills can be checked consistently without forbidding valid variants. |
| Compatibility policy | Portable Agent Skills baseline, Codex-specific extensions, and the exact support claim for secondary coding agents. | Each requirement is classified as portable, Codex-specific, or target-specific and is backed by an applicable validation. |
| Validation approach | Proportionate automated and manual checks for repository and skill integrity. | Documented commands or checks pass on the repository and fail meaningfully on representative invalid cases. |
| Continuous validation workflow | A narrow Windows GitHub Actions workflow invoking the same local checks under `pwsh` and `powershell`. | Proposed changes automatically run repository validation and installer tests with no CI-only validation implementation. |
| Repository support files | Only files justified by the confirmed distribution, collaboration, licensing, and automation model. | Each added file traces to a requirement and contains no unresolved placeholders. |

## Requirements

### Required behavior or qualities

- Instructions must be self-contained for a fresh authorized agent.
- Repository structure must expose clear boundaries between individual skills, shared repository tooling, documentation, tests or fixtures, and generated or temporary content where those categories apply.
- Repository-level rules must distinguish mandatory skill contracts from recommendations and examples.
- Portable requirements must follow the open Agent Skills specification; Codex-only extensions such as `agents/openai.yaml` must remain optional from the portable contract's perspective.
- Secondary-agent compatibility claims must be limited to specification conformance unless a named adapter has authoritative documentation and target-specific validation.
- The repository must not expose the entire canonical catalog as active repository-scoped skills by default.
- Installer operations must select skills explicitly and preserve `skills/` as immutable input during installation.
- Public entry points must resolve the repository root and canonical catalog from `$PSScriptRoot`, not from the caller's current working directory.
- Built-in destination discovery must be limited to verified Codex user and repository scopes; other clients must supply an explicit destination path.
- Every destination mode must reject source/target overlap, including a destination root equal to or beneath the canonical `skills/` tree; generic destination mode cannot bypass catalog self-protection.
- The installer must not require Node.js, Python, or third-party PowerShell modules.
- Automatic replacement is authorized only for exact selected child skill folders after strict resolved-path checks; parent roots, siblings, and unrelated paths remain non-targets.
- An existing exact selected skill folder must be refreshed automatically and non-interactively; the installer must not expose or require `-Force` for this ordinary path.
- Updates must stage and validate the complete replacement before changing the active destination, then remove stale content by replacing the whole prior installed tree rather than merge-copying files over it.
- Before cleanup, the installer must resolve and verify that the target is exactly one named child skill folder beneath the intended destination root; it must never recursively delete or replace the destination root itself or any sibling skill.
- Skill names must pass the portable naming rules before path construction, and source trees containing symbolic links, junctions, or other reparse points must fail validation to prevent copying content outside the selected skill tree.
- Validation must protect required metadata and referenced resources while allowing legitimate skill-specific structure.
- `agents/openai.yaml` remains optional. Its absence cannot fail portable validation; when present, the validator must check the documented supported Codex metadata subset and local resource paths, while treating unrecognized drift-prone Codex fields as warnings rather than silently claiming full schema validation.
- Documentation and automated checks must agree on paths, naming, and supported workflows.
- GitHub Actions must invoke the same version-controlled validation and test entry points documented for local use, explicitly exercising PowerShell 7 and Windows PowerShell on a Windows runner.
- Repository validation and tests must run without Python, `skills-ref`, Pester, or third-party PowerShell modules.
- Validation errors must produce a nonzero exit; advisory style and quality warnings must not fail CI.
- The frontmatter validator must completely implement the documented simple YAML profile and reject malformed, duplicate, unsupported, or advanced YAML forms rather than parsing them partially.
- Multi-skill refresh must validate and stage the complete selection before swaps, retain all backups until total success, and rollback every changed selected target on any failure.
- Installer failure output must clearly identify the failed skill or phase, original error, rollback outcome, and overall failure through a nonzero process exit.
- The installer must not create persistent log files by default; future logging requires a separately justified explicit opt-in.
- The existing skill must remain behaviorally intact unless a separately justified change is included in the final task definition.

### Constraints and preferences

- During discovery, writes are permitted only under `docs/discovery/prepare-agent-skill-repository/`.
- Discovery must not implement the repository update.
- Current product-specific behavior that can drift must be verified from authoritative sources before it becomes an implementation requirement.
- No commit, push, release, installation, or remote configuration change is authorized by the discovery request.
- Root agent instructions must remain concise; specialized or explanatory material belongs in README or narrower future guidance rather than bloating always-loaded instructions. This follows current verified Codex instruction-loading behavior and must be rechecked if implementation occurs after the evidence becomes stale.

## Assumptions, dependencies, and managed unknowns

### Accepted assumptions

- Skill directories are independent packages and do not require cross-skill dependency ordering in the initial catalog.
- Version-control history is the recovery mechanism for source catalog changes; installer backups protect only an in-progress destination transaction.

### Dependencies and prerequisites

- Separate implementation authorization after discovery reaches `ready-for-handoff`.
- Windows PowerShell 5.1 and PowerShell 7 for the required local compatibility run.
- GitHub Actions enabled for the private repository when CI is exercised.
- Reverification of drift-prone Codex and GitHub runner behavior if implementation is materially delayed.

### Managed unknowns

| Unknown | Impact | Resolver | Resolution step | Contingency or gate |
| --- | --- | --- | --- | --- |
| Dedicated contribution or ownership files | May become necessary if private collaboration becomes recurring. | Repository owner | Reassess when contributors need standalone detail or enforced ownership. | Use README-level guidance initially. |
| Installer replacement lifecycle | Determines the exact replacement commit sequence. | Execution design and tests | Validate during implementation. | Retain the previous complete copy until the replacement has been staged and validated. |
| CI runner image drift | Hosted Windows image contents and default versions can change. | GitHub documentation and implementation maintenance | Select an explicit supported Windows label and explicit `pwsh`/`powershell` shells; avoid patch-version assumptions. | Reverify runner support when updating the workflow. |

## Risks, edge cases, and mitigations

| Risk or edge case | Impact | Likelihood or trigger | Mitigation or decision rule |
| --- | --- | --- | --- |
| Treating one skill's optional structure as a universal requirement | Valid future skills could be rejected. | Validation is copied mechanically from `task-discovery`. | Separate universal requirements from optional capability directories and test both minimal and extended examples. |
| Overloading root `AGENTS.md` | Instructions may consume unnecessary context or conflict with deeper rules. | All explanatory documentation is placed in always-loaded instructions. | Keep operational rules concise and link or route agents to scoped documentation where supported. |
| Claiming compatibility without target-specific validation | Agents may fail to discover or invoke skills. | Products use different metadata or installation conventions. | Name supported targets and validate each against current authoritative documentation. |
| Treating Codex discovery paths as the portable skill standard | Other agents may receive an unnecessarily Codex-shaped repository contract. | `.agents/skills/` is made canonical solely because Codex dominates usage. | Keep the per-skill contract portable and classify discovery paths as client adapters or explicit repository choices. |
| Activating the full catalog during catalog maintenance | Skills may trigger unexpectedly or crowd the available skill list while agents edit unrelated skills. | Every source skill is exposed through Codex repository discovery. | Keep `skills/` separate from `.agents/skills/`; install or link selected skills explicitly. |
| Parallel editable copies of a skill | Fixes diverge between source and installed locations. | Installation targets are treated as additional source directories. | Declare `skills/` authoritative and make derived-copy replacement behavior explicit. |
| Automatic refresh overwrites an existing same-name destination | User data or local edits inside the selected installed copy are lost. | Destination name already exists, regardless of its origin. | Treat installed destinations as disposable derived copies, document the behavior prominently, stage and validate first, and preserve only parent/sibling content; no prompt or force flag is required by user decision. |
| Installer leaves partial output | A skill appears installed but is incomplete. | Copy, link, validation, or permission failure occurs mid-operation. | Stage and validate before a destination change where the platform permits; clean only installer-owned temporary output. |
| Generic destination is mistaken for named-agent support | Documentation overstates compatibility or writes to a wrong discovery path. | A custom path is presented as auto-detected support. | State that callers own custom-path correctness and test only path-safe installation behavior. |
| Portable skill claims are confused with installer platform claims | Users expect macOS or Linux installation support. | README states cross-agent support without separating the Windows installer limitation. | State portable skill-format support and Windows-only installer support as separate contracts. |
| Runtime-specific behavior diverges | Installer passes in PowerShell 7 but fails in Windows PowerShell 5.1, or vice versa. | Unsupported syntax, encoding, or filesystem API behavior is used. | Test the same behavior suite under both runtimes and avoid edition-specific features. |
| Links make installations dependent on the checkout | Moving or removing the repository breaks installed skills; source edits affect live behavior immediately. | Installer creates junctions or symbolic links. | Prefer independent copies unless the user explicitly accepts link coupling. |
| Merge update leaves deleted files behind | Removed scripts, references, or assets remain active after an update. | New source is copied over the old folder without cleaning it. | Replace the complete installed tree from a validated staged copy. |
| Clean update deletes manual changes | Manual edits within the exact selected destination skill folder are lost. | The approved automatic refresh treats `skills/` as authoritative. | Document that installed copies are disposable derived output and that manual edits are overwritten on refresh. |
| Failed automatic refresh removes a working copy | A skill becomes unavailable after an error. | Failure occurs between removing the prior tree and completing the new tree. | Stage and validate first, keep the prior complete tree as a temporary backup, restore it on failure, and delete the backup only after success. |
| Bulk refresh unintentionally targets the wrong scope | Every catalog skill is copied to an unintended directory. | Convenience entry point has an ambiguous or context-dependent default. | Use one explicit documented default and permit alternate targets only through the general installer. |
| Cleanup resolves to the parent skills directory | Every installed skill could be deleted. | Empty, malformed, traversal, separator, or path-resolution bug collapses the child target to its parent. | Reject invalid names and paths, resolve absolute paths, prove the target is a strict child of the intended root, and prohibit equality with the root before any destructive operation. |
| Adding governance files without authority | Repository may imply unintended licensing or contribution commitments. | Generic templates are added automatically. | Require an explicit user decision for legal and publication choices. |
| Private repository receives public boilerplate | Files imply public licensing, support, or contribution expectations that do not exist. | Generic repository templates are added mechanically. | Omit public-facing governance and document only actual private workflows. |
| Lightweight private guidance becomes insufficient | Contributors miss workflow or ownership rules. | Collaboration becomes recurring or review ownership is disputed. | Promote the README section to `CONTRIBUTING.md` and add `CODEOWNERS` only when those triggers occur. |
| Validation damages skill flexibility | Authors work around checks or valid skills cannot be added. | Schema is stricter than documented requirements. | Include positive minimal, positive extended, and negative validation cases. |
| Repository layout optimizes for one current skill | Later skills with different optional resources do not fit cleanly. | The existing `task-discovery` tree is copied as a universal skeleton. | Define stable repository boundaries while allowing optional per-skill directories and representative variants. |

## Recommended execution approach

### Phase 1 - Reverify contracts and protect scope

- Purpose: Confirm that drift-prone Codex and GitHub behavior still supports the approved design and that the worktree has no conflicting user changes.
- Inputs and prerequisites: This ready-for-handoff definition, implementation authorization, current repository state, and refreshed authoritative sources if evidence is stale.
- Work: Inspect applicable instructions and Git state, preserve unrelated changes, and reverify only product-specific claims that could have drifted.
- Outputs: Confirmed implementation boundary and current compatibility evidence.
- Validation: No unresolved merge state or overlapping user changes; every current product claim is still supported or the executor stops for direction.
- Exit gate: The approved design remains feasible without scope expansion.

### Phase 2 - Implement repository contracts and tooling

- Purpose: Create the approved root guidance, authoring profile, installer, validator, test harness, and CI workflow.
- Inputs and prerequisites: Phase 1 gate and the manifest below.
- Work: Implement shared logic first, then public entry points, tests, documentation, agent guidance, ignore rules, and CI wiring.
- Outputs: The approved tracked file set with no actual user-scope or repository-scope installation performed.
- Validation: Run repository validation and the dependency-free test harness under both PowerShell families against isolated destinations.
- Exit gate: Every observable acceptance criterion passes locally.

#### Approved initial manifest

| Path | Responsibility |
| --- | --- |
| `README.md` | Purpose, catalog boundary, installation, authoring, validation, and lightweight private contribution guidance. |
| `AGENTS.md` | Concise operational rules and navigation for coding agents working in the checkout. |
| `.gitignore` | Repository-owned temporary, test, and local generated-output exclusions only. |
| `Refresh-CodexSkills.ps1` | No-argument convenience entry point for whole-catalog refresh to `$HOME\.agents\skills`. |
| `skills/<skill-name>/` | Canonical portable skill directories; existing `task-discovery` remains here. |
| `scripts/SkillCatalog.psm1` | Internal dependency-free functions shared by installer, validator, and tests; not a separate user-facing command. |
| `scripts/Install-Skills.ps1` | General list, selected install/refresh, `-All`, Codex scopes, and explicit generic destination logic. |
| `scripts/Test-Repository.ps1` | Dependency-free repository and skill validator used locally and by CI. |
| `tests/Run-Tests.ps1` | Dependency-free test entry point used locally and by CI. |
| `tests/Test-Installer.ps1` | Installer behavior, path containment, replacement, transaction, rollback, and diagnostic cases. |
| `tests/Test-RepositoryValidator.ps1` | Positive and negative repository, skill, frontmatter, metadata, and reference cases. |
| `tests/fixtures/` | Minimal valid, extended valid, stale-update, sibling-preservation, and representative invalid inputs. |
| `.github/workflows/validate.yml` | Windows CI invoking the same local entry points under `pwsh` and `powershell`. |

#### Installer command contract

- `scripts/Install-Skills.ps1 -List` lists catalog skill names and performs no destination write.
- `scripts/Install-Skills.ps1 -Name <name>[,<name>...]` installs or refreshes the explicitly named selection.
- `scripts/Install-Skills.ps1 -All` installs or refreshes the complete catalog; `-Name` and `-All` are mutually exclusive and omission of both is an error except in `-List` mode.
- With no destination parameter, install or refresh resolves `$HOME\.agents\skills` at runtime.
- `-RepositoryPath <path>` is mutually exclusive with `-DestinationPath`, requires an existing external repository root, resolves `<path>\.agents\skills`, and rejects this catalog checkout.
- `-DestinationPath <path>` is a caller-owned generic client destination and carries no auto-discovery guarantee.
- `Refresh-CodexSkills.ps1` delegates to the general installer with `-All` and the default Codex user destination.
- Every mutating command preflights the complete selection, stages and validates exact copies, proves every target is one strict child of the destination root, and performs a selection-level rollback on failure.
- Success exits `0`; validation, usage, staging, swap, or rollback problems return nonzero with deterministic console/error-stream summaries. No persistent log is written.

#### CI contract

- `.github/workflows/validate.yml` runs on pull requests, pushes to `main`, and manual dispatch.
- The Windows workflow checks out the repository and invokes `scripts/Test-Repository.ps1` plus `tests/Run-Tests.ps1` once with `pwsh` and once with `powershell`.
- CI contains no duplicate validation logic and requires no runtime installation beyond the supported shells already present on the selected runner.

### Phase 3 - Validate and hand back implementation results

- Purpose: Prove the implementation and prepare a bounded handoff.
- Inputs and prerequisites: Phase 2 outputs.
- Work: Run both PowerShell suites, inspect the instruction/documentation chain, verify fixtures and CI syntax, and review Git diff for scope.
- Outputs: Repository changes and evidence only; no commit, push, release, or installation unless separately requested.
- Validation: All defined checks pass, the existing skill remains behaviorally intact, and the diff contains only approved files.
- Exit gate: All acceptance criteria pass and residual limitations are documented.

### Sequencing and decision points

`skills/` is fixed as the canonical source catalog. Implement the shared module and tests before wrappers and documentation so behavior and examples are evidence-backed. Codex-specific conveniences may layer on the portable Agent Skills baseline but cannot become portable requirements. Do not add a license, public governance, named secondary-agent adapters, non-Windows tooling, uninstall behavior, persistent logs, or actual installation without new authority. Stop if current authoritative behavior invalidates a target path, if the worktree contains overlapping user changes, or if satisfying the tests requires expanding these boundaries.

## Validation strategy

| Outcome or requirement | Validation method | Expected evidence | Failure handling |
| --- | --- | --- | --- |
| Fresh-agent usability | Review from repository root using only tracked instructions and documentation. | The reviewer correctly identifies purpose, workflows, boundaries, and validation commands. | Revise ambiguous or duplicated guidance. |
| Structural discoverability | Ask a fresh coding agent to locate a skill, identify repository-level versus skill-level resources, and place a representative new skill using only tracked guidance. | Correct paths and boundaries are chosen without conversational context. | Revise layout or navigation guidance and repeat the scenario. |
| Single source of truth | Exercise the repository installer against an isolated test destination. | `skills/` is unchanged and remains the only editable source; installed targets are documented as derived copies and do not require parallel maintenance. | Remove ambiguous aliases or revise installer behavior. |
| Working-directory independence | Invoke every public script from the repository root, a sibling directory, and an unrelated temporary directory. | Catalog, module, validator, and wrapper paths resolve identically from `$PSScriptRoot`. | Remove current-directory assumptions. |
| Source/destination non-overlap | Try user, repository, and generic parameter sets with destinations equal to or nested beneath the catalog and with relative traversal forms. | Every overlapping or escaping target fails before any write and identifies the rejected resolved path. | Block release and strengthen canonical-path checks. |
| Authorized same-name replacement | Pre-create a destination with the selected skill name plus stale and locally changed files, then run refresh. | The exact selected child becomes an exact source copy without prompting; stale/local files disappear, while parent and siblings remain unchanged. | Block release if replacement is partial, interactive, or escapes the exact child boundary. |
| Installer failure atomicity | Inject or simulate a failure after staging starts but before completion. | No incomplete target is presented as installed; installer-owned temporary output is safely handled. | Redesign staging and replacement sequence. |
| Automatic refresh rollback | Inject a failure during the destination swap. | The prior complete installed skill is restored and the command reports failure without touching parent or siblings. | Block release and correct the swap or restoration sequence. |
| Explicit versus convenience bulk selection | Test the general installer with named skills, `-All`, omitted selection, and conflicting selection; test the convenience entry point separately. | Named and `-All` modes work; conflicting or omitted general selection fails; convenience mode refreshes all using its approved default. | Fix parameter sets or wrapper delegation. |
| Bulk transaction failure | Stage at least two selected fixture skills and inject a swap failure after one target changes. | The final destination matches its complete pre-command state and the command reports the failing skill plus rollback outcome. | Block release and correct selection-level backup or rollback logic. |
| Failure visibility | Inject preflight, staging, swap, and rollback failures and capture output plus exit status. | Each failure returns nonzero, identifies the failed skill or phase and cause, and states `ROLLBACK SUCCEEDED` or `ROLLBACK FAILED` where a swap began. | Block release if a failure can appear successful or rollback status is ambiguous. |
| Stale-file removal | Install a fixture containing an extra file, update from a source version without that file, and inspect the destination. | The extra file is absent after the successful update and all current source files are present. | Reject merge-copy behavior and fix full-tree replacement. |
| Parent and sibling preservation | Install at least two sibling fixture skills, update one, and compare the parent plus untouched sibling before and after. | Only the selected skill folder changes; parent-level files and sibling trees remain byte-for-byte unchanged. | Block release and fix target resolution or replacement scope. |
| Dual-PowerShell compatibility | Run the installer test suite under Windows PowerShell 5.1 and PowerShell 7. | Identical supported behavior and actionable failures under both runtimes. | Remove incompatible constructs or narrow the contract only through a new explicit decision. |
| Existing skill preservation | Compare its declared behavior and referenced resources before and after implementation; run applicable checks. | No broken paths, metadata, or behavior contract. | Revert or narrow unjustified skill edits. |
| Skill convention flexibility | Validate a minimal conforming structure, the existing extended structure, and invalid cases. | Both valid forms pass and invalid forms fail with actionable diagnostics. | Relax undocumented restrictions or strengthen missing checks. |
| Agent instruction scope | Measure and inspect the applicable instruction chain for the root and skill directories. | Rules are concise, non-conflicting, and scoped to their consumers. | Move explanation to documentation or reconcile overlapping rules. |
| Product compatibility | Check each named target against current authoritative contract documentation and, where safe, a local discovery/invocation test. | Traceable evidence for every supported target. | Remove or qualify unsupported compatibility claims. |
| Portable versus Codex-specific contract | Classify every structural and metadata rule, then validate a skill without Codex-only optional metadata. | A conforming portable skill remains valid; Codex-enhanced skills receive additional checks. | Move unintended Codex requirements out of the portable baseline. |
| Reparse-point containment | Place a symlink or junction inside a fixture skill when the test environment permits. | Validation rejects the source before staging and does not read or copy the linked target. | Block release; if CI cannot create the fixture, retain a guarded local test and explicit skipped-test diagnostic. |

## Acceptance criteria

- [ ] Codex is documented as the dominant authoring environment without making Codex-only extensions mandatory for portable skills.
- [ ] The support level for secondary coding agents and downstream consumers is explicit and does not imply unverified universal compatibility.
- [ ] `skills/` is consistently treated as the canonical source catalog and is not automatically activated wholesale in Codex.
- [ ] The repository-owned installer installs explicitly selected skills without modifying the source catalog.
- [ ] Every public script behaves identically regardless of the caller's current working directory.
- [ ] Successful updates leave the destination as an exact copy of the current catalog skill without installer-added provenance files.
- [ ] Re-running installation for an existing selected skill refreshes it without prompting or requiring `-Force`.
- [ ] The general installer supports an explicit `-All` switch, while the dedicated convenience entry point refreshes all without requiring that switch.
- [ ] The convenience entry point defaults to `$HOME\.agents\skills`, while tests substitute an isolated home or destination and never touch the real user skill directory.
- [ ] The installer exposes no uninstall command and documentation does not imply one.
- [ ] Cleanup can affect only the exact selected destination skill folder; tests prove the destination root and sibling skills are unchanged.
- [ ] User, repository, and generic destination modes reject every resolved source/destination overlap before any write.
- [ ] The installer resolves Codex user and repository destinations correctly and accepts a safe explicit destination for other clients without claiming auto-discovery.
- [ ] Repository scope requires an explicit external target checkout and refuses to target this catalog repository.
- [ ] With no destination option, the general installer targets `$HOME\.agents\skills`; alternate modes require explicit repository or destination paths.
- [ ] Installer destinations, runtime prerequisites, collision behavior, and recovery path are documented and validated.
- [ ] The installer requires only Windows PowerShell 5.1 or PowerShell 7 and passes the same behavior suite under both.
- [ ] Repository and skill validation require only Windows PowerShell 5.1 or PowerShell 7 and no third-party modules.
- [ ] GitHub Actions runs the same local validation and installer test entry points explicitly under `pwsh` and `powershell` on Windows.
- [ ] Required validation failures return nonzero under both runtimes; advisory warnings remain visible but do not fail either local execution or CI.
- [ ] The validator accepts every documented simple-profile frontmatter form and rejects unsupported advanced YAML forms with actionable repository-policy errors.
- [ ] Multi-skill and `-All` refreshes are all-or-nothing across the selected set, with injected-failure tests proving full restoration.
- [ ] Every installer failure is prominent and actionable, returns nonzero, and reports rollback success or failure when applicable.
- [ ] Installer runs create no persistent log files by default.
- [ ] Documentation clearly distinguishes portable Agent Skills conformance from the Windows-only installer platform contract.
- [ ] The repository layout gives coding agents unambiguous locations for skills, repository-level support files, and any shared validation resources.
- [ ] Every implemented root file is justified by a documented requirement.
- [ ] A fresh authorized agent can author or review a skill without relying on conversation context.
- [ ] Required and optional skill structure are clearly distinguished.
- [ ] A portable skill without `agents/openai.yaml` passes; when the file exists, supported Codex fields and referenced local assets are checked without claiming universal schema coverage.
- [ ] Source symlinks, junctions, and other reparse points are rejected before staging.
- [ ] The existing `task-discovery` skill remains valid and behaviorally intact except for separately approved changes.
- [ ] Validation covers minimal valid, extended valid, and representative invalid skill cases.
- [ ] Product-specific claims are verified against current authoritative sources.
- [ ] Documentation, instructions, and validation commands agree.
- [ ] Implementation diff contains no unrelated changes and no unapproved commit, push, release, installation, or remote mutation.

## Definition of done

The later implementation is done when the approved repository files and conventions are present, every acceptance criterion is evidenced, the existing skill remains valid, product-specific limitations are explicit, and all residual conditions or approval gates are documented.

## Evidence and traceability

| Claim or decision | Evidence class | Source | Freshness or limitation |
| --- | --- | --- | --- |
| The task name is `prepare-agent-skill-repository`. | verified | User confirmation in this discovery session | Current. |
| The tracked repository contains one skill and five files. | verified | `git ls-tree -r --name-only HEAD` and repository inspection | Current checkout at discovery start. |
| The checkout is clean on `main` and tracks `origin/main`. | verified | `git status --short --branch` | Current at discovery start. |
| The existing skill has instructions, interface metadata, templates, and a reference checklist. | verified | `skills/task-discovery/` | Current tracked content. |
| Coding agents are the primary AGENTS role and repository structure is part of agent readiness. | verified | User decisions in this discovery session | Current. |
| Codex will account for approximately 99% of use, but other coding agents must be supported. | verified | User decision in this discovery session | The percentage is an approximate priority signal, not a measured target. |
| Codex builds on the Agent Skills standard, discovers repository skills under `.agents/skills/`, supports optional `agents/openai.yaml`, and loads hierarchical `AGENTS.md` guidance. | verified | Official sources summarized in `sources/research-notes.md` | Refreshed 2026-07-21; Codex-specific and potentially drift-prone. |
| The Agent Skills specification defines per-skill structure but not the repository collection root. | verified | `https://agentskills.io/specification` | Accessed 2026-07-21; product discovery paths remain client-specific. |
| `skills/` is the canonical source catalog. | verified | User decision in this discovery session | Current; destination copies are derived and disposable. |
| Open Agent Skills specification compliance is sufficient default support for secondary coding agents. | verified | User decision in this discovery session | Named product support requires a separately explicit adapter and validation. |
| A repository-owned installation tool is required. | verified | User decision in this discovery session | Command, destination, replacement, rollback, and diagnostic contracts are defined above. |
| Installer destinations are Codex user scope, Codex repository scope, and a caller-supplied generic path. | verified | User decision in this discovery session | Other clients receive no named adapter by default. |
| Installer platform support is Windows-only. | verified | User decision in this discovery session | Skill-format portability is unaffected; non-Windows installation tooling is out of scope. |
| Installer runtime is dependency-free PowerShell compatible with Windows PowerShell 5.1 and PowerShell 7. | verified | User decision plus local runtime inspection | Both runtimes are locally available for validation. |
| Installation uses copies and update removes files absent from the new catalog version. | verified | User decision in this discovery session | Exact-child automatic replacement and selection-level rollback are explicitly authorized. |
| Cleanup scope is the selected destination skill folder, never the parent skills directory. | verified | User clarification in this discovery session | Requires strict resolved-path containment checks. |
| Installed copies require no provenance marker. | verified | User decision in this discovery session | Collision safety must come from path and command behavior. |
| Existing exact selected skill folders are automatically refreshed without confirmation or force. | verified | User decision in this discovery session | Manual changes in derived installed copies are intentionally overwritten. |
| Explicit `-All` and a dedicated refresh-all-by-default entry point are required. | verified | User decision in this discovery session | Both default to Codex user scope unless the general installer receives an explicit alternate target. |
| The refresh-all convenience entry point defaults to Codex user scope at `$HOME\.agents\skills`. | verified | User decision in this discovery session | Alternate destinations remain on the general installer. |
| Uninstall is out of scope. | verified | User decision in this discovery session | Manual removal may be documented without repository-owned automation. |
| The repository is private. | verified | User decision in this discovery session | Public/open-source governance files are out of scope. |
| Occasional private contributors are possible. | verified | User answer in this discovery session | Frequency and ownership needs remain unknown. |
| README-level contribution guidance is initially proportionate. | inference | Private status plus possible but unconfirmed recurring collaboration | Reassess when collaboration patterns become concrete. |
| Automatic GitHub Actions validation is required. | verified | User decision in this discovery session | Use a narrow Windows workflow with local/CI parity. |
| GitHub Actions can explicitly run both supported PowerShell families. | verified | `https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax` | Accessed 2026-07-21; select `pwsh` and `powershell` explicitly. |
| GitHub-hosted Windows runners are available. | verified | `https://docs.github.com/en/actions/reference/runners/github-hosted-runners` | Accessed 2026-07-21; image labels and bundled versions may drift. |
| Upstream `skills-ref` is Python-based and marked demonstration-only. | verified | `https://github.com/agentskills/agentskills/tree/main/skills-ref` | Accessed 2026-07-21; useful as reference evidence, not automatically suitable as a production dependency. |
| Validation must remain dependency-free PowerShell. | verified | User decision in this discovery session | Applies to repository checks, skill checks, tests, and CI entry points. |
| The compact initial file manifest is approved. | verified | User decision in this discovery session | Root, catalog, tooling, test, and CI paths are fixed for implementation. |
| Repository scope requires an explicit target checkout and rejects the catalog checkout. | verified | User decision in this discovery session | Preserves the canonical-versus-derived boundary. |
| Codex user scope is the expected primary global workflow. | verified | User statement in this discovery session | It is the approved default destination and primary documentation path. |
| The general installer defaults to Codex user scope. | verified | User decision in this discovery session | Skill selection remains explicit; alternate destinations require paths. |
| CI fails only on correctness and safety errors, not style advice. | verified | User decision in this discovery session | Validator messages and exits require explicit severity classification. |
| Agent Skills frontmatter has a small defined data model expressed as YAML. | verified | `https://agentskills.io/specification` | Accessed 2026-07-21; the specification does not define a reduced YAML syntax profile. |
| The catalog enforces a simple dependency-free YAML frontmatter profile. | verified | User decision in this discovery session | This is a repository syntax contract layered on portable field semantics. |
| Multi-skill refresh is transactional and failures must be easy to identify. | verified | User decision in this discovery session | Requires full-selection rollback, prominent diagnostics, and nonzero exit. |
| Console and error-stream diagnostics are sufficient without a default log file. | verified | User decision in this discovery session | Persistent logging is out of initial scope. |
| A concise, scoped root instruction model is required. | verified | User-approved manifest plus refreshed Codex instruction behavior | Reverify only if implementation is materially delayed and product behavior may have drifted. |

## Execution boundaries and handoff notes

Discovery may inspect repository and authoritative external sources read-only and may write only inside its discovery directory. It must not implement this definition. A later executing agent may change repository files only after discovery reaches `ready-for-handoff` and the user separately authorizes execution. Preserve unrelated work, do not infer a license, and do not commit, push, publish, install, or change remote settings unless explicitly requested.

## Revision history

| Version | Time | Status | Summary |
| --- | --- | --- | --- |
| `working` | `2026-07-21T19:10:26.1987787-03:00` | `in-progress` | Finalized console/error-stream failure reporting with no persistent logs and began the readiness review. |
| `v001` | `2026-07-21T19:17:24.2474307-03:00` | `ready-for-handoff` | Passed the full readiness gate; finalized the implementation manifest, command and CI contracts, safety semantics, validation strategy, and managed external gates. |
