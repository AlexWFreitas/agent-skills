# Technical documentation review checklist

Use this checklist for a requested review and before finalizing a substantial
draft or rewrite. It is a semantic review aid, not a requirement to report
every checked box.

Review in this order so that mechanical polish does not hide a wrong or unsafe
document:

1. Technical fidelity and safety.
2. Audience, purpose, scope, and completeness.
3. Task flow and information architecture.
4. Clarity, accessibility, and global readability.
5. Technical formatting and editorial mechanics.

## Calibrate findings

Classify a finding by consequence rather than by the number of style rules it
touches:

- **Critical:** could cause data loss, a security or privacy exposure,
  financial harm, an outage, an irreversible action, or materially incorrect
  use of the product.
- **Major:** prevents the intended reader from completing the task or
  understanding a governing contract; includes incorrect facts, missing
  prerequisites, ambiguous requirements, broken examples, inaccessible
  required information, and unsupported claims.
- **Moderate:** creates a realistic risk of confusion, maintenance drift,
  translation error, or retrieval failure without directly breaking the task.
- **Minor:** a local style or consistency defect whose correction does not
  change technical meaning.

Report findings in consequence order. Combine repeated instances under one
pattern when individual locations do not need separate fixes. Do not bury a
wrong command under a list of comma and capitalization comments.

## Technical fidelity and safety

- [ ] Every command, option, API name, field, identifier, file, path, version,
  UI label, and literal matches an authoritative source.
- [ ] The document does not invent a default, permission, quota, return value,
  side effect, error, retry rule, compatibility promise, or supported version.
- [ ] Examples distinguish runnable code, syntax patterns, illustrative
  fragments, pseudocode, and output.
- [ ] A click-to-copy command can run after the documented placeholder
  substitutions; it contains no unexplained optional brackets, choice pipes,
  or omission marks.
- [ ] Shell, operating system, execution context, working location, and
  privilege assumptions are explicit where they matter.
- [ ] State-changing, destructive, billable, externally visible, privileged,
  or irreversible actions state the consequence before the action.
- [ ] Backup, rollback, recovery, and cleanup instructions exist only when the
  source supports them. The document does not imply reversibility that was not
  verified.
- [ ] Retry and polling instructions have an evidence-backed stop condition;
  they do not loop indefinitely.
- [ ] Verification steps name an observable success signal.
- [ ] The reported validation level is accurate: static review, syntax check,
  safe execution, end-to-end test, link check, UI confirmation, or
  accessibility test.
- [ ] Secrets, credentials, tokens, customer data, production identifiers,
  real personal data, and confidential details are absent or properly
  redacted.
- [ ] Screenshots obscure sensitive data with an irreversible opaque treatment,
  not a potentially reversible blur.
- [ ] Error messages, logs, and output are preserved verbatim inside literal
  formatting.
- [ ] Source contradictions and unverified gaps are visible rather than
  silently resolved.

## Audience, purpose, and scope

- [ ] The page has one primary purpose that the title and opening make clear.
- [ ] The intended reader and their role, knowledge, permissions, platform, or
  version are clear when those factors affect the outcome.
- [ ] The opening explains what the reader can do or understand without a long
  history or marketing preamble.
- [ ] Supported scope and important non-goals are explicit enough to prevent a
  materially wrong interpretation.
- [ ] Prerequisites, inputs, costs, access, and safety conditions appear before
  the first dependent action.
- [ ] Required and optional paths are distinct.
- [ ] The document contains enough context to act without forcing unnecessary
  link-following, but does not duplicate an entire external standard or
  canonical project reference.
- [ ] Time-sensitive content includes a date, release, or version reference.
- [ ] The document does not pre-announce an unapproved future feature.
- [ ] Claims about performance, cost, security, simplicity, compatibility, and
  competitors are factual, scoped, and verifiable.

## Structure and navigation

- [ ] The level-1 title is unique, descriptive, and sentence case.
- [ ] Task headings start with a base-form verb; conceptual headings use a clear
  noun phrase.
- [ ] Optional sections start with **Optional:** when that distinction helps.
- [ ] Heading levels form a logical hierarchy without skipped levels or empty
  sections.
- [ ] Headings do not use sequence numbers, links, unnecessary punctuation, or
  unexplained bare code items.
- [ ] Renamed linked headings preserve a stable anchor or known inbound links
  are updated.
- [ ] Paragraphs contain one idea, put the critical point first, and avoid
  walls of text.
- [ ] Numbered lists indicate meaningful order. Bulleted lists are visibly
  required, optional, or alternative as appropriate.
- [ ] List items are parallel and use consistent capitalization and end
  punctuation.
- [ ] A single item is not presented as a list without a publication-specific
  reason.
- [ ] Description lists are used for term-description pairs.
- [ ] Tables represent two-dimensional data; one-column or layout tables have
  been converted to more semantic structures.
- [ ] Tables are introduced in prose, use clear headers, avoid merged cells,
  and are not embedded in the middle of a procedure.
- [ ] Notes, cautions, and warnings are necessary and correctly classified.
  Prerequisites and required steps are not hidden in notices.
- [ ] Footnotes are avoided when the information can be a cross-reference,
  note, parenthetical, or normal paragraph.

## Procedures and tutorials

- [ ] The procedure has a clear outcome and an appropriate task-based title.
- [ ] Each numbered step contains one meaningful action or one tightly coupled
  action sequence.
- [ ] The first sentence of each step contains an imperative verb.
- [ ] Conditions, environment, location, and goal precede the dependent action.
- [ ] The procedure has as few steps and interruptions as practical.
- [ ] Optional steps begin with **Optional:** rather than parentheses.
- [ ] Substeps are shallow, correctly nested, and introduced with a complete
  parent step.
- [ ] Multiple procedures for the same task are separated and differentiated;
  the recommended or most accessible path appears first.
- [ ] Repeated procedures link to one canonical procedure rather than drifting
  copies.
- [ ] UI steps identify hard-to-find controls without relying on left, right,
  above, below, color, or shape alone.
- [ ] A tutorial explains each concept near the step that needs it and keeps
  deep background out of the critical path.
- [ ] Persistent or billable tutorial resources have evidence-backed cleanup
  instructions.
- [ ] Completion and verification tell the reader what observable result to
  expect.

## Concepts, architecture, and decisions

- [ ] The definition and distinguishing point appear near the beginning.
- [ ] Actors, components, states, interfaces, and flows are named explicitly.
- [ ] One consistent term maps to one concept; overloaded terms are defined.
- [ ] Current evidence, inference, assumption, recommendation, proposal,
  approval, and implementation status are not conflated.
- [ ] A recommendation is not written as an approved or implemented decision.
- [ ] Diagrams state whether they represent current, proposed, or target state.
- [ ] Diagram relationships are explained in text, not left as vague arrows.
- [ ] Alternatives are included only when their tradeoffs matter to the reader
  or decision owner.
- [ ] Constraints and quality attributes are concrete enough to verify.
- [ ] The document preserves ordinary reversible implementation latitude.

## API, CLI, and configuration reference

- [ ] Reference coverage is complete for the scope it claims.
- [ ] Each item has a short, unique, present-tense first sentence.
- [ ] Method descriptions say what the method does: **Creates**, **Gets**,
  **Returns**, or **Checks whether**, not the imperative form.
- [ ] Public types, parameters, returns, exceptions, permissions, defaults,
  side effects, and dependencies match the contract.
- [ ] Boolean parameters describe both values. Boolean returns use a consistent
  true/false pattern.
- [ ] Deprecations put the supported replacement and required migration action
  before background rationale.
- [ ] Formal syntax is clearly distinguished from a runnable command.
- [ ] Task docs show the minimal recommended command; the full option catalog
  stays in reference material.
- [ ] Placeholder names are descriptive, all uppercase with underscores unless
  syntax requires otherwise, and explained in occurrence order.
- [ ] Output appears only when useful and is labeled exact versus representative.

## UI documentation

- [ ] Instructions focus on the reader's goal and name UI mechanics only when
  they help.
- [ ] Visible labels are bold and use the correct official capitalization or
  the documented sentence-case exception.
- [ ] Product names are not bold unless they are also literal UI labels.
- [ ] Code-derived UI values use the required combined code and bold style.
- [ ] UI controls are not used as English verbs.
- [ ] Window, page, dialog, pane, panel, section, menu, command, navigation menu,
  toolbar, tab, list, box, and field are used precisely when the distinction
  matters.
- [ ] Menu paths contain only menu choices and have accessible separators.
- [ ] Icon-only controls use a tooltip or accessible name, not an invented
  visual description.
- [ ] A difficult-to-find element has named context or a useful screenshot
  instead of directional language.
- [ ] Required keyboard input is in the same step, and the primary path remains
  keyboard-accessible.

## Links and sources

- [ ] Every link resolves to the most relevant authoritative destination.
- [ ] Link text is short, unique, descriptive, and understandable out of
  context.
- [ ] The page avoids **click here**, **this document**, **read more**, and bare
  URL link text.
- [ ] Duplicate links are removed unless the page has distinct reader entry
  points that justify them.
- [ ] A cross-reference states why the destination matters without repeating
  the link text.
- [ ] Downloads, email actions, same-page jumps, and forced new tabs are
  disclosed.
- [ ] Punctuation and quotation marks sit outside the link where possible.
- [ ] External links use HTTPS where supported and are not explained solely by
  an icon.
- [ ] Third-party material is paraphrased and linked unless reuse rights and
  attribution requirements are known.
- [ ] Exact style questions were checked against the live guide or are reported
  as based on the skill's reviewed snapshot.

## Language and global readability

- [ ] The prose addresses the reader as **you** and reserves **user** for an end
  user of software the reader develops.
- [ ] Active voice identifies who or what performs each action.
- [ ] Present tense describes general behavior; future tense marks a genuinely
  later event.
- [ ] Conditions, context, and goals precede instructions.
- [ ] Words are simple, literal, and used in their primary sense.
- [ ] Jargon is removed, defined, or introduced once for recognition and search.
- [ ] Abbreviations are expanded only when the audience needs the expansion.
- [ ] Pronouns have clear antecedents; **this** and **these** have a noun where
  ambiguity is possible.
- [ ] Articles and helper words are present where they improve comprehension.
- [ ] One concept uses one term and one capitalization throughout.
- [ ] The prose avoids slang, idioms, metaphors, humor, culture-specific
  references, unnecessary violence, ableist terms, and gendered defaults.
- [ ] Examples are diverse without stereotypes.
- [ ] Software and hardware are not anthropomorphized.
- [ ] Requirements, recommendations, options, possibilities, and expected
  outcomes use unambiguous modality.
- [ ] Durable product docs avoid **currently**, **new**, **latest**, **soon**,
  **old**, and unsupported future language.
- [ ] Sentences are concise. Sentences over about 26 words are reviewed for
  ambiguity but not shortened at the cost of meaning.

## Accessibility and visual content

- [ ] The document remains understandable without color, position, images,
  animation, sound, or punctuation as the only cue.
- [ ] Headings, lists, tables, code, emphasis, forms, and controls use semantic
  markup.
- [ ] Required information is not present only in a screenshot, diagram, icon,
  or video.
- [ ] Informative images have concise contextual alt text; decorative or fully
  redundant images have empty alt text.
- [ ] Complex figures have an equivalent text description and, when useful, a
  concise caption.
- [ ] Images do not substitute for searchable text, code, commands, or output.
- [ ] Audio and video have captions, transcripts, or descriptions.
- [ ] Tables have semantic row and column headers and no inaccessible merged
  structure.
- [ ] Interactive content is introduced before use and works with a keyboard.
- [ ] A screen-reader or keyboard test is reported only if actually performed.
- [ ] Color contrast, reading order, magnification, and no-image/no-sound states
  were considered when the deliverable includes presentation or interaction.

## Mechanics

- [ ] Titles and headings use sentence case.
- [ ] Serial commas appear in series of three or more.
- [ ] Colons introducing lists follow a complete sentence.
- [ ] Em dashes have no surrounding spaces; en dashes are absent unless a
  higher authority requires them.
- [ ] Hyphenation follows project convention, then the Google word list, then
  the preferred dictionary.
- [ ] Semicolons, slashes, ellipses, parentheses, bold, and italics are used
  sparingly and for their intended purpose.
- [ ] Straight quotation marks and apostrophes are used in developer source.
- [ ] Code entities, exact input, and output use code font; ordinary product and
  organization names do not.
- [ ] Dates are unambiguous; numeric-only dates use ISO order.
- [ ] Number words, numerals, ranges, percentages, decimal marks, units, binary
  versus decimal quantities, and mathematical notation follow the project and
  guide conventions.
- [ ] Filenames and file types are named precisely, with exact code-formatted
  filenames and human-readable file-type names.
- [ ] Product names and trademarks use official spelling and do not become
  verbs, plurals, or possessives.
- [ ] Example domains, IP addresses, phone numbers, names, and resource IDs are
  reserved or clearly fictional.

## Final review report

For an edit or draft, report only material exceptions and verification limits.
For a review-only request, include:

1. Findings in consequence order, each with a precise location, why it matters,
   and an actionable fix.
2. Questions or assumptions only when they block a reliable conclusion.
3. A short residual-risk section that states what was not verified.
4. A concise overall assessment after the findings.

If there are no material findings, say so directly. Do not manufacture minor
style objections to make the review look busy.
