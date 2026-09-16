---
name: technical-writing
description: Draft, revise, or review developer documentation, including procedures, concepts, API references, runbooks, troubleshooting, and architecture. Use Google developer documentation style within the user's and project's requirements. Excludes marketing and ordinary code implementation.
---

# Technical writing

Produce documentation that lets its intended reader complete a task or
understand a system. Establish technical truth before polishing the prose.

## Establish the assignment

Infer the reader, purpose, language, format, and requested action from the
request and supplied material. Distinguish drafting, editing, review, and review
with revision. Ask only when a missing decision changes meaning, scope,
audience, or publication outcome. A review-only request does not authorize edits.

Follow the user's requirements, then project templates and terminology, then
applicable platform conventions, then this skill's Google-style guidance.
Preserve commands, code, identifiers, values, requirements, public behavior,
versions, official names, literal UI labels, and stated results. Missing or
contradictory evidence stays explicit; plausible wording cannot supply a fact.

Inspect the relevant context and sources before restructuring an existing
document. A narrow edit needs only enough context to preserve meaning. Protect
unrelated work, generated boundaries, and stable link anchors.

## Choose the structure

Use the reader's task to choose the document's organization:

| Reader need | Useful structure |
| --- | --- |
| Complete an operation | Prerequisites, ordered actions, expected result, verification |
| Learn a workflow | Small useful outcome, concepts beside actions, progressive examples |
| Resolve a failure | Symptom, diagnostic evidence, likely cause, remedy, verification |
| Look up an interface | Exact contract, inputs, outputs, errors, permissions, examples |
| Understand a system | Responsibilities, boundaries, one representative end-to-end path |
| Operate a service | Entry conditions, actions, checks, escalation or recovery |

Preserve an established structure when it serves the reader. Do not add empty
sections to resemble a template. Read
[document-patterns.md](references/document-patterns.md) for the relevant
pattern when planning or repairing a substantial document.

## Draft or revise

1. Establish authoritative facts and the scope of verification. Put prerequisites
   and conditions before the actions that depend on them.
2. Draft from that evidence around the reader's purpose. Label illustrative
   examples and unresolved placeholders; never invent behavior.
3. Use clear, precise prose: active voice, present tense, consistent terminology,
   and direct instructions. Default to US English only when the user or project
   has not selected another language or locale.
4. Verify changed technical claims against their sources. Keep examples runnable
   or internally coherent within the stated verification boundary. Executing a
   documented command is a separate action, not an automatic part of editing.
5. Review missing context, incorrect meaning, ambiguous instructions, and
   accessibility before polishing editorial mechanics.

Use the smallest workflow that satisfies the request. Side questions and later
corrections steer the assignment without discarding completed work. Choose
ordinary editorial details yourself within the settled meaning.

## Load relevant guidance

- [core-style.md](references/core-style.md): substantial prose drafting,
  rewriting, or review; language, modality, headings, and mechanics.
- [technical-elements.md](references/technical-elements.md): commands, code,
  placeholders, interfaces, UI steps, links, markup, filenames, and examples.
- [review-checklist.md](references/review-checklist.md): requested reviews and
  final checks for substantial deliverables. Apply relevant items only.
- [source-map.md](references/source-map.md): locate the authoritative Google
  page for an uncommon or changing rule. This is a reviewed routing index.

Use semantic headings, lists, and tables; descriptive links; useful alt text;
and textual explanations of essential visual information. Color, position,
images, and sound must not be the only way to understand an instruction.
Keep real personal information out of examples and screenshots.

When another workflow governs discovery, execution, or cooperation, use its
existing task and authorization records. This skill governs document quality
and adds no startup, approval, or closure process. A conversational style
applies where compatible with the document's requirements.

## Verify and deliver

Run required documentation checks and verify affected claims. Prose-only work
does not require product tests. Repeat checks for new edits, failures, or a
concrete unresolved concern. Do not claim runnable examples, accessibility,
working links, or full compliance beyond the checks actually performed.

For reviews, report material findings in consequence order with locations and
actionable corrections; say when none were found. For drafts and edits, deliver
the text or artifact with a proportionate account of changes, sources, and
verification limits. A small edit normally needs only its revised text or link.

Reuse existing authorization. Publishing, committing, or changing external
systems needs authority covering those actions. If a skill requirement prevents
completion, finish independent authorized work, link this file, quote the
requirement, and explain the missing evidence or authority. An editorial
preference does not create an approval gate.
