---
name: technical-writing
description: Draft, revise, or review developer-facing technical documentation using the Google developer documentation style guide. Use for procedures, tutorials, concepts, API or CLI references, runbooks, troubleshooting, architecture docs, and release notes; do not use for marketing copy or ordinary code implementation.
---

# Technical Writing

Create technical documentation that is accurate, direct, accessible, and easy
to use. Apply Google developer documentation style without overriding the
reader's needs, the requested deliverable, project conventions, or technical
truth.

## Preserve authority and truth

Treat technical fidelity as an invariant. Do not change commands, code,
identifiers, API behavior, configuration keys, values, versions, requirements,
permissions, links, or stated results merely to improve prose. Verify them from
the supplied artifacts or authoritative project sources. If the evidence is
missing or contradictory, preserve the uncertainty and call it out.

Apply style authorities in this order:

1. The user's explicit requirements, language, audience, and deliverable.
2. The project's house style, templates, glossary, established terminology,
   and automated documentation rules.
3. Applicable platform, language, API, product, and publication conventions.
4. This skill's synthesis of the Google developer documentation style guide.
5. A project-approved dictionary or other editorial reference.

When authorities conflict, follow the higher authority and report any material
exception. Do not silently normalize an official product name, public contract,
literal UI label, or code element to match a lower-level style preference.

## Route supporting guidance

Load only the references needed for the request:

- Read [core-style.md](references/core-style.md) for a substantial draft,
  rewrite, or prose review.
- Read [technical-elements.md](references/technical-elements.md) when the
  material includes code, commands, placeholders, API reference text, UI
  instructions, links, HTML, Markdown, filenames, or example data.
- Read [document-patterns.md](references/document-patterns.md) when choosing or
  repairing the structure of a procedure, concept, reference, troubleshooting
  guide, runbook, architecture document, migration guide, or release note.
- Read [review-checklist.md](references/review-checklist.md) for a requested
  review and before finalizing a substantial deliverable.
- Use [source-map.md](references/source-map.md) to locate the exact Google page
  for an uncommon rule or a live verification. The map is a reviewed routing
  index, not a frozen replacement for the actively maintained guide.

## Establish the writing task

Infer what is clear from the request and supplied material. Ask only when a
missing decision would materially change the audience, technical meaning,
scope, format, or publication outcome.

Identify the following as needed:

- The reader, their likely knowledge, and the task or question that brought
  them to the document.
- The document's primary purpose and the action or understanding it must
  enable.
- The authoritative facts, source artifacts, supported versions, permissions,
  prerequisites, and verification boundaries.
- The requested output format, locale, terminology, and project conventions.
- Whether the user wants a draft, an in-place edit, a review, or a review plus
  revision.

For an existing document, inspect its surrounding documentation and source
material before imposing a new structure. Preserve useful established patterns
unless they conflict with a higher authority or prevent the document from
working for its readers.

## Draft and revise

Use the smallest workflow that fits the task:

1. Build a reader-oriented outline around the primary purpose. Put required
   context before the point where the reader needs it.
2. Draft or revise for technical fidelity first. Never fill factual gaps with
   plausible-sounding details.
3. Apply the writing contract below and the relevant document pattern.
4. Check every technical element against the source. Keep an example runnable
   or internally coherent; label illustrative or unverified material.
5. Run the relevant review checklist and repair material issues before
   polishing minor mechanics.

For a small wording edit, apply the same principles without forcing a full
document redesign.

## Default writing contract

Unless a higher authority says otherwise:

- Write in clear US English. Use simple, precise, globally understandable
  words and standard sentence order.
- Address the reader as **you**. Use the imperative for instructions. Use
  **user** only for a person who uses software that the reader is developing.
- Prefer active voice and present tense. Use passive voice only when the actor
  is irrelevant, intentionally de-emphasized, or unknown and the result stays
  clear.
- Put the condition, context, location, or goal before the instruction. Keep
  the actor and action explicit.
- Use a conversational, friendly, respectful tone without slang, cuteness,
  hype, humor, idioms, metaphors, or culture-specific references.
- Use one consistent term for one concept. Define unfamiliar terms and
  abbreviations where the target audience needs them. Resolve ambiguous
  pronouns by naming the entity.
- Do not anthropomorphize hardware or software. Describe what a component
  detects, returns, stores, rejects, or performs.
- Prefer factual, verifiable claims. Avoid unsupported superlatives,
  guarantees, comparisons, and absolute security or performance promises.
- Describe the current supported behavior. Avoid **currently**, **new**,
  **latest**, **soon**, and speculative future features unless the deliverable
  is explicitly time-bound and the information is authorized.
- Distinguish requirements, recommendations, options, and possibilities. Use
  **must** or an imperative for a requirement, **We recommend** for a genuine
  recommendation, **can** for permission or an option, and **might** for a
  possible outcome. Avoid ambiguous **should**.
- Use common contractions where they improve a natural tone, especially
  negative forms such as **don't** and **can't**. Avoid invented or complex
  contractions.
- Use complete articles and helper words when they remove ambiguity. Do not
  drop **a**, **an**, **the**, **that**, or **then** merely for brevity.
- Keep paragraphs focused on one idea, put the most important point first, and
  split walls of text. Prefer short sentences; treat 26 words as a review
  signal, not a mechanical limit.

## Organize for scanning and action

- Use a unique, descriptive, sentence-case page title. Use base-form verbs for
  task headings and noun phrases for conceptual headings.
- Keep a logical heading hierarchy, do not skip levels, and do not use heading
  levels merely for visual styling. Preserve stable anchors when renaming
  linked headings.
- Use numbered lists when sequence matters, bulleted lists for nonsequential
  items, and description lists for term-description pairs. Keep list items
  parallel and make it clear whether unordered items are required or optional.
- Introduce a list, table, code sample, output block, or image when the heading
  alone does not provide enough context. Use a complete introductory sentence.
- Use tables only for genuinely two-dimensional data. Avoid merged cells,
  layout tables, one-column tables, and tables embedded in procedures.
- Use notices sparingly. Put prerequisites, required actions, results, and
  essential success information in the main flow instead of hiding them in a
  note.
- Use footnotes only when a cross-reference, note, parenthetical, or in-flow
  explanation cannot work.

## Make the document accessible

- Make the meaning survive without color, position, punctuation, images,
  animation, or sound as the only cue.
- Use semantic headings, lists, tables, code, emphasis, and native controls.
- Write descriptive link text that makes sense out of context. Explain
  downloads, mail links, same-page jumps, and other unexpected behavior.
- Provide useful alt text for informative images and empty alt text for purely
  decorative images. Explain complex diagrams in surrounding text.
- Do not use images of text, code, commands, or terminal output when real text
  works. Never expose real personally identifiable information in screenshots
  or examples.
- Avoid directional instructions such as **above**, **below**, **left**, and
  **right**. Name the section, control, field, or preceding/following item.
- For interactive content, ensure the intended flow is usable with a keyboard
  and understandable with a screen reader. Report when this was not tested.

## Handle writing modes

### Draft or rewrite

Deliver a coherent document, not a collection of isolated improvements. Keep
facts and scope traceable to the source material. If important information is
missing, use an explicit placeholder or an unresolved note instead of inventing
content.

### Edit files

Preserve unrelated work, local formatting conventions, anchors, and generated
boundaries. Change only the documentation in scope. Do not run examples,
publish, commit, or alter external systems unless the user separately
authorizes those actions.

### Review

When the user asks only for review, do not edit the artifact. Prioritize
incorrect, unsafe, incomplete, ambiguous, or inaccessible content over minor
punctuation preferences. Give each finding enough location and replacement
guidance to act on it. If no material issue exists, say so and state what was
not verified.

## Finish transparently

For substantial work, report:

- What was drafted, changed, or reviewed.
- Which technical sources, project conventions, and style references governed
  the result.
- Which commands, examples, links, UI paths, or accessibility behaviors were
  actually verified.
- Any conflicts, deliberate style exceptions, assumptions, or unresolved
  technical gaps.

Do not claim that a document is correct, accessible, runnable, or fully style
compliant beyond the checks actually performed.
