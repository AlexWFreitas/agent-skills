# Readiness Checklist

Use this checklist as a materiality-based gate, not as a demand to add irrelevant sections. Mark every item `pass`, `needs-work`, or `not-applicable` in the discovery record. Explain each `not-applicable` judgment that would not be obvious to a fresh agent.

## Phase integrity

- Confirm that the skill was explicitly invoked.
- Confirm that no implementation or write occurred outside the discovery directory.
- Confirm that the documents use the request's language and agree with each other.
- Confirm that status, creation time, and last-updated time are current.

## Intent and outcomes

- State the task in one unambiguous sentence.
- Define the problem or opportunity and why the work matters.
- Identify the desired observable outcomes.
- Identify affected stakeholders or users when applicable.
- Distinguish the user's stated intent from inferred recommendations.

## Context and evidence

- Describe the relevant current state.
- Inspect available sources that could materially change the definition.
- Reference sources for material researched claims.
- Classify material claims as verified, inferred, assumed, or unresolved.
- Reconcile conflicting evidence or explicitly manage the conflict.
- Note source freshness and access limitations when relevant.

## Scope and deliverables

- Define what is in scope.
- Define material exclusions or boundaries.
- Identify each expected deliverable and its required form.
- Define applicable functional, qualitative, operational, legal, safety, or policy requirements.
- Record constraints, preferences, permissions, and prohibited actions.

## Feasibility and execution

- Identify dependencies, prerequisites, integrations, and external decisions.
- Challenge assumptions that could change scope or approach.
- Cover material failure modes, edge cases, and risks.
- Provide mitigations or decision gates for material risks.
- Define a recommended phased approach and sequencing.
- Identify points where later execution must stop for approval or new information.

## Validation and completion

- Make acceptance criteria observable and testable for the task domain.
- Define how each important outcome will be validated.
- Include negative cases or failure validation when material.
- State a clear definition of done.
- Make the task definition sufficient for a fresh agent without chat context.

## Unknowns and consistency

- Resolve every material open question that can currently be resolved.
- For each unavoidable external unknown, record impact, resolver, resolution step, contingency, and gate.
- Remove placeholder text and accidental contradictions.
- Ensure recommendations do not masquerade as requirements or verified facts.
- Ensure every readiness claim is supported by the documents rather than conversational memory.

Pass the gate only when all applicable items pass and every remaining unknown is managed. If the user insists on closing before that point, use the skill's guarded early-exit procedure and mark the result `incomplete`.

