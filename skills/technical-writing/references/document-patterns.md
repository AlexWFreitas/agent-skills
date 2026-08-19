# Document patterns

Use this reference to choose a reader-oriented structure. These are adaptable
patterns, not mandatory templates. Include only sections that help the intended
reader complete the task or understand the subject. Preserve an established
project template when it serves the same purpose.

Do not use headings to compensate for missing content. A short document can be
better than a complete-looking shell full of empty or speculative sections.

## Common opening

Most developer documents benefit from an opening that answers three questions
without a long preamble:

1. What does this document help the reader do or understand?
2. Who is it for, and what prior knowledge or access matters?
3. What important scope, version, cost, permission, or safety boundary applies?

Use a task-based title for a task and a noun-phrase title for a concept or
reference. Put critical prerequisites and restrictions before the first action
that depends on them.

## Procedure or how-to guide

Use for a bounded task with a known goal.

Suggested structure:

1. Task-based title.
2. One- or two-sentence purpose and outcome.
3. Prerequisites and required roles, permissions, tools, supported versions,
   inputs, cost implications, or destructive effects.
4. Numbered procedure.
5. Expected result or verification.
6. Recovery, cleanup, or next step when the task creates state or can fail in a
   predictable way.

Procedure rules:

- Give one meaningful action per numbered step. Combine only tiny inseparable
  actions or a short menu path.
- Put the context and condition before the action: **In Cloud Shell, ...** or
  **If the deployment uses a private network, ...**
- Start the first sentence of each step with an imperative verb. Use complete
  sentences and parallel structure.
- Introduce a one-step procedure as one bulleted instruction, not a numbered
  list containing only `1`.
- Prefix a genuinely optional step with **Optional:**. Do not hide a required
  action behind a conditional-sounding goal phrase.
- If a step has substeps, end the parent step with a colon or period and keep
  nesting shallow.
- In a complex step, order the material as action, command, placeholder
  explanation, necessary detail, output, and result.
- State a goal before the action when it helps orientation: **To rotate the
  key, select ...**
- State a result after the action: **Select Run. The query results appear.**
- State a justification after the action unless the justification is a safety
  condition the reader must know before acting.
- Do not repeat a procedure verbatim. Link to the canonical procedure and add
  only the context that differs.
- When several supported paths exist, lead with the shortest accessible path
  for the intended audience. Separate materially different paths into clear
  headings or pages.
- Avoid interruptions, optional excursions, and background detail in the
  middle of the critical path.

Verification should name an observable signal: a returned status, file content,
resource state, UI label, log entry, or safe test. Do not write **Verify that it
worked** without the success condition.

## Tutorial or quickstart

Use for guided learning that produces a concrete result. A tutorial teaches a
path; it is not the complete product reference.

Suggested structure:

1. Task-based title and the artifact or outcome the reader creates.
2. Intended audience, learning objective, time or cost expectation when
   evidence supports it, and prerequisites.
3. Setup that uses safe example data and a disposable environment where
   practical.
4. A linear series of short sections, each with one learning goal and a
   procedure.
5. Verification after meaningful milestones.
6. Explanation of what the reader built and why the important parts work.
7. Cleanup for billable, persistent, privileged, or externally visible
   resources.
8. Focused next steps or reference links.

- Choose one representative path. Do not turn a quickstart into a catalog of
  every option.
- Keep commands directly runnable, and explain every placeholder before the
  reader needs to substitute it.
- Introduce a concept immediately before it affects the task. Move deeper
  background to a concept page or a focused link.
- Do not claim a duration, cost, or success rate without evidence and scope.
- Use milestone encouragement sparingly. Avoid exclamation points in routine
  steps.

## Concept or overview

Use to explain what something is, why it matters, how its parts relate, and
when to choose it. Do not disguise a procedure as a concept page.

Suggested structure:

1. Noun-phrase title.
2. Direct definition and the reader problem it addresses.
3. Scope, intended audience, and important non-goals.
4. Core model, components, actors, states, or lifecycle.
5. Relationships and flow, with a diagram only when it materially improves
   understanding.
6. Tradeoffs, constraints, limits, compatibility, and selection criteria.
7. A small example grounded in safe data.
8. Links to the procedures and reference pages that act on the concept.

- Put the distinguishing point in the first paragraph.
- Use one term per concept and define overloaded domain terms.
- Identify the actor for each action in a flow. Avoid software
  anthropomorphism.
- Separate verified behavior from recommendations, assumptions, and planned
  behavior.
- Give a complex diagram concise alt text and an equivalent text description.

## API reference

Use for exhaustive public contract lookup. Pair it with concept and how-to
material instead of forcing long tutorials into reference entries.

Suggested levels:

### API or package overview

- Purpose, audience, supported versions, base endpoint or package, and
  authentication model.
- Core resource or type relationships.
- A minimal working example.
- Links to complete endpoint, class, or method reference.
- Versioning, compatibility, quota, and deprecation policy when authoritative.

### Endpoint or method

- Distinctive present-tense summary of what the operation does.
- Required permission, scope, state, and prerequisites.
- Signature or HTTP method and path.
- Parameters with type, requirement status, allowed values, constraints,
  behavior, and actual default.
- Request body and schema.
- Response type and schema.
- Errors, exceptions, retry or idempotency behavior, and side effects only when
  part of the contract.
- Minimal valid example and, when useful, a representative response.
- Related operations and deprecation or replacement information.

Keep generated-reference first sentences short and unique. Use the verb forms,
Boolean patterns, return-value patterns, and deprecation rules in
[technical-elements.md](technical-elements.md).

Do not invent missing API semantics from an implementation name. Inspect the
schema, source comments, generated reference, tests, or owning specification.

## CLI or configuration reference

Use for systematic lookup of commands, flags, configuration keys, environment
variables, or file formats.

Suggested structure:

1. Noun-phrase title and purpose.
2. Syntax or schema, clearly labeled as formal syntax rather than a runnable
   example when notation is present.
3. Entries organized by the lookup key readers already know.
4. For each entry: type, required or optional status, accepted values, default,
   scope, precedence, side effects, and version support as applicable.
5. Minimal examples and links to task-oriented procedures.
6. Errors, validation behavior, or exit codes when authoritative and useful.

For a command task rather than full reference, prefer this compact pattern:

1. State what the command accomplishes.
2. Show one runnable command.
3. Explain placeholders in occurrence order.
4. Explain required flags, permissions, and side effects.
5. Show only useful output.
6. State the verification signal.

Keep the complete option catalog in the reference. Do not burden a how-to with
every optional flag.

## Troubleshooting guide

Use when readers begin from an observable failure. Start with what they can
recognize, not with an internal component taxonomy.

Suggested structure for each issue:

1. Symptom or exact error text.
2. Affected scope, version, environment, and known trigger.
3. Safety note before any destructive, security-sensitive, or state-changing
   diagnostic.
4. Diagnostic steps, ordered from low cost and low risk to more invasive.
5. Cause, only when confirmed; otherwise label it as a possible cause.
6. Resolution steps.
7. Verification and expected result.
8. Recovery, escalation data, or next diagnostic when the resolution fails.

- Preserve exact errors and log text in code blocks.
- Separate multiple causes when they require different tests or fixes.
- Do not tell readers to delete caches, disable security controls, reset data,
  or retry indefinitely without explaining the consequence and recovery.
- Bound retries and make the stopping condition explicit.
- Do not present correlation as a confirmed root cause.
- State the evidence window. If logs or captures cannot cover the reported
  time, say so plainly.
- Make redaction requirements explicit before asking readers to share logs,
  screenshots, tokens, identifiers, or configuration.

## Operational runbook

Use for a controlled operational action or incident response. A runbook must be
safe under time pressure.

Suggested structure:

1. Purpose, trigger, scope, supported environment, and owner.
2. Preconditions, permissions, tooling, access, and data-sensitivity rules.
3. Risk, blast radius, irreversible effects, and explicit stop conditions.
4. Preparation or backup steps.
5. Numbered execution steps with checkpoints.
6. Verification criteria after each significant state change.
7. Rollback or recovery path that is actually supported.
8. Escalation threshold and evidence to collect.
9. Cleanup and handoff.

- Distinguish observation from mutation.
- Give commands the least scope necessary and preserve literal safety flags.
- Name the environment and target before each state-changing command when
  context could drift.
- Avoid vague **repeat until fixed** loops. State the maximum attempts, elapsed
  time, or observable condition that ends the loop when the source establishes
  it.
- Never invent a rollback. If rollback is unverified or impossible, state that
  before the action.
- Keep optional background and architecture links outside the critical path.

## Architecture or design document

Use to explain a system, a decision, or a proposed design. Keep evidence,
recommendations, approval, and implementation status distinct.

Suggested structure:

1. Noun-phrase title and concise summary.
2. Context, reader, problem, scope, and non-goals.
3. Current state and source-backed constraints.
4. Requirements and quality attributes.
5. Components, ownership, interfaces, data flow, state, and trust boundaries.
6. Proposed decisions and rationale, clearly labeled as proposed or approved.
7. Alternatives and material tradeoffs.
8. Failure behavior, security, privacy, accessibility, operability, and cost to
   the depth relevant to the design.
9. Migration, compatibility, validation, and unresolved decisions.

- Do not imply that a recommendation is approved or implemented.
- State whether a diagram shows the current, proposed, or target system.
- Put interface contracts near the components they govern.
- Use concrete actors, data, and actions in flows. Avoid vague arrows and
  labels such as **processes data** without the required detail.
- Preserve implementer latitude unless an exact mechanism is a governing
  requirement.
- Do not add deployment, rollback, or fleet-management machinery that the
  product requirements do not need.

## Migration or upgrade guide

Use for a change between supported states, versions, APIs, platforms, or data
models.

Suggested structure:

1. Source and target state, supported versions, audience, and outcome.
2. Compatibility, downtime, cost, data, permission, and rollback boundaries.
3. Prerequisites and a pre-migration health check.
4. Backup or recovery preparation when supported.
5. Numbered migration stages with explicit checkpoints.
6. Validation of behavior and data after the change.
7. Rollback or forward-fix criteria.
8. Cleanup and removal of obsolete configuration.
9. Known limitations and follow-up work.

- Do not use **old**, **new**, **current**, or **latest** without a version or
  date that makes the reference point durable.
- Separate required migration steps from optional modernization.
- State which consumers continue to see the prior state and whether a restart,
  reconnect, redeploy, or reindex is required.
- Treat destructive schema, data, and compatibility changes as explicit gates.
- Do not promise zero downtime or reversibility without evidence.

## Release notes or changelog

Release notes are intentionally time-bound and can use dates and **new** when a
clear release reference makes the word meaningful.

Suggested entry:

- Release date or version.
- Reader-visible change, stated first.
- Affected product area, API, platform, or version.
- Required action, migration, opt-in, deprecation deadline, or compatibility
  impact.
- Link to the canonical task or reference documentation.

Group entries consistently as appropriate, such as added, changed, fixed,
deprecated, removed, security, or known issue. Do not force every category into
every release.

- Lead with the effect on the reader, not the internal implementation.
- Distinguish availability from announcement. Do not pre-announce an
  unapproved feature.
- Use exact versions and unambiguous dates. Avoid **recently**, **soon**, and
  **latest**.
- Do not use release notes as the only home for current product behavior.
  Update the canonical documentation as well.
- Give a deprecation a supported replacement and actionable deadline when the
  authority provides one.
- Keep security language factual and coordinate disclosure-sensitive details
  with the owning security process.

## Repository README or contributor guide

Use for repository orientation and common development workflows.

Suggested structure:

1. What the repository contains and who should use it.
2. Supported environment and prerequisites.
3. Minimal setup and one success check.
4. Common development, build, test, and validation commands.
5. Repository structure only to the depth needed for navigation.
6. Contribution, security, support, and release links.

- Keep the first successful path short and copyable.
- Do not duplicate a long canonical procedure; summarize and link.
- Separate commands from output and identify platform-specific variants.
- Never include real credentials or assume undocumented access.
- Keep badges, status claims, and version statements sourced and current.

## Choose links and next steps

End with only links that serve the next likely reader decision. Prefer a small
set of specific destinations over a generic **More resources** dump. Tell the
reader why each destination matters through descriptive link text.
