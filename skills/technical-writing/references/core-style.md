# Core Google-style guidance

Use this reference for a substantial draft, rewrite, or prose review. It
distills the parts of the Google developer documentation style guide that
change ordinary writing decisions. For code, commands, APIs, UI text, links,
markup, filenames, and example data, also read
[technical-elements.md](technical-elements.md).

The source guide is an actively maintained house style, not an objective or
complete industry standard. Prefer the reader's clarity and the higher
authorities in `SKILL.md` when a local exception works better. Apply an
exception consistently and disclose it when it materially affects the result.

## Voice, audience, and tone

- Identify the intended reader and the problem they need to solve. Make the
  audience explicit near the start when their role or knowledge matters.
- Address the reader as **you** and assume that the reader performs the
  documented actions. Use an imperative such as **Select Save** for an
  instruction.
- Use **user** for the person who uses the software that the reader is
  developing, not as a substitute for **you**.
- Use **we**, **our**, and **us** only when the named authoring organization is
  the clear antecedent. Do not use **we** to lead the reader through steps.
- Write conversationally, naturally, and respectfully. Aim for a knowledgeable
  colleague: neither promotional and pushy nor detached and bureaucratic.
- Use common contractions when natural. Negative contractions such as
  **don't**, **isn't**, and **can't** are often easier to scan than a separated
  **not**. Avoid nonstandard or three-word contractions.
- Do not add **please** to routine instructions. Direct, respectful phrasing is
  polite without it.
- Avoid slang, cuteness, jokes, rhetorical theatrics, buzzwords, idioms,
  metaphors, and culture-specific references. A friendly tone still needs
  literal and precise language.
- Avoid exclamation points in concept, reference, and procedural documentation.
  They are acceptable only where syntax or a literal requires them, or
  sparingly for a genuine learning milestone in tutorial content.

## Write for a global audience

- Use US English unless a higher authority selects another locale. Keep the
  language understandable to readers who use English as an additional
  language and to human or machine translation.
- Prefer simple, familiar words: **use** instead of **utilize**, **start**
  instead of **commence**, and **so** instead of **consequently**, unless the
  less common term conveys a necessary technical distinction.
- Prefer a single word to an equivalent wordy phrase. Avoid phrasal verbs when
  a precise single verb works, but retain established phrases such as **set
  up**, **sign in**, and **log in** when no clearer replacement exists.
- Keep the subject and verb near the beginning and use standard
  subject-verb-object order. Avoid stacks of noun modifiers; rephrase when more
  than two nouns modify another noun.
- Place a modifier next to what it modifies. **Only**, in particular, can
  change the meaning depending on its position.
- Use words in their primary sense. Do not use one word for multiple concepts
  in the same context.
- Repeat a word when the repetition removes ambiguity. Compactness is not a
  reason to omit a required actor, condition, noun, article, pronoun, or helper
  word.
- Include helper words such as **that**, **then**, and **of** where they make a
  relationship explicit. Include relative pronouns rather than relying on
  compressed conversational grammar.
- Avoid culture-specific holidays, sports, geography, seasons, and humor.
  Express time periods through months, dates, quarters, or the actual
  conditions.
- Keep terminology, capitalization, phrasing, and formatting consistent. A
  synonym can look like a distinct technical concept to a reader or
  translator.

## Write inclusively

- Use literal terms that describe the actual technical behavior. Avoid
  unnecessarily gendered, ableist, graphically violent, socially charged, or
  dehumanizing language.
- Use singular **they**, **their**, and **theirs** for an unspecified person.
  Do not use **he/she**, **(s)he**, or gendered pronouns as a default.
- Do not describe people without disabilities as **normal** or **healthy** in
  contrast with people with disabilities. Use neutral and relevant terms.
- Research how a community prefers to be identified. Person-first language is
  often useful, but some communities explicitly prefer identity-first
  language; do not impose one universal formula.
- Avoid euphemistic, patronizing, or judgmental language about disability.
  Describe a person's situation or assistive technology neutrally.
- Use diverse examples without assigning stereotypical identities to job
  roles, authority, technical ability, or behavior.
- If a non-inclusive term is an unavoidable literal in existing code or a
  command, format it as code, explain it on first use, and use preferred prose
  afterward. Do not propagate the code term as general terminology.
- If an established industry term lacks an exact alternative, introduce the
  precise preferred description first and include the established term once
  only when readers need it for recognition or search.

## Use precise terminology

- Avoid jargon that the audience does not need. Jargon includes figurative
  technical phrases and overloaded words such as **solution**, **support**, or
  **workload** when their meaning is not explicit.
- If readers search for or expect a necessary term, define it briefly on first
  use or link to an authoritative definition. Use it consistently afterward.
- Spell out an unfamiliar abbreviation on first use, followed immediately by
  the abbreviation in parentheses. In Google style, italicize both the spelled
  out term and the abbreviation when introducing them.
- Do not spell out universally familiar developer abbreviations merely to obey
  a formula. Audience-common forms such as API, URL, HTML, PDF, XML, REST, and
  AI usually need no expansion.
- If an abbreviation appears first in a heading, use it there only when it is
  the commonly known form; define it in the first paragraph that follows.
- Do not introduce an abbreviation used only once unless the abbreviation is
  at least as useful to the reader as its expansion.
- Do not use **e.g.** or **i.e.**; use **for example** and **that is**. Avoid
  internet slang abbreviations and unnecessary **etc.**.
- Do not use an acronym or shortened word as a verb. Write **Use SSH to sign in**
  rather than **SSH into**.
- Choose **a** or **an** by pronunciation, not spelling. Preserve
  audience-established pronunciation when it varies.

## Keep grammar explicit

- Prefer active voice because it identifies the actor. Passive voice is
  acceptable when the object matters more, the actor is irrelevant, or naming
  the actor would unfairly assign blame.
- Use present tense for general and current behavior. Use future tense only for
  an action that genuinely occurs later, not as a default description of what
  software does.
- Put a condition, circumstance, location, or goal before the instruction that
  depends on it. This order lets readers skip actions that do not apply.
- Make pronoun antecedents unmistakable. Follow demonstratives such as **this**
  and **these** with a noun when the referent might be unclear.
- Use **that** for a restrictive clause and **which**, preceded by a comma, for
  a nonrestrictive clause. Use **who** for people when appropriate, but do not
  create awkward prose merely to avoid **that**.
- Include articles **a**, **an**, and **the**, including in headings. Compressed
  headings such as **Create VM instance** are harder to understand and
  translate than **Create a VM instance**.
- A preposition can end a sentence. Put it where the sentence is easiest to
  read. Include a preposition when it adds clarity and remove it when it adds
  nothing.
- Follow normal US English pluralization. Do not use an apostrophe to form a
  plural. Use a plural after **one or more** and a singular after **more than
  one**.
- Do not put optional plurals in parentheses. Choose a singular or plural
  construction, or use **one or more** when the distinction matters.
- Avoid possessive forms of product names, trademarks, and code items. Use the
  name as a modifier, add a descriptive noun, or rephrase with **of**.

## Express requirements and recommendations

Prescriptive documentation recommends the clearest path instead of presenting
every possible path. Choose the procedure, example, and command that fit the
most common relevant use case, then link to complete reference material when
needed.

- Required action: use an imperative or **must**.
- Recommended action: state **We recommend ...** or name the recommending
  authority. Use **should** only for a broadly recognized recommendation whose
  optional status is already clear.
- Optional action or permission: use **can**.
- Possible outcome: use **might** or **can**.
- Expected outcome: state what happens in present tense.
- Actual state: name the actor or source of the state. Do not write **The value
  should be true** when you mean that the reader must set it, the server sets
  it, or it is already true.

Do not make the user choose among low-value alternatives when one documented
path reliably meets the goal. Preserve alternatives when they materially
change supported platforms, cost, security, or the reader's outcome.

## Structure headings and paragraphs

- Use a unique level-1 heading for each page and use it only once.
- Use sentence case for titles, headings, navigation, image labels, table
  headings, and captions unless an official name or literal casing overrides
  it.
- Base the document title on the page's primary purpose. A primarily procedural
  page gets a task-based title even if it contains conceptual background.
- Start task headings with a base-form verb: **Create an instance**, not
  **Creating an instance**.
- Use a noun phrase for a conceptual or reference heading, avoiding an **-ing**
  word at the start when a clearer phrase exists.
- Prefix a genuinely optional section with **Optional:** rather than placing
  **(optional)** after the heading.
- Keep headings descriptive and unique. Avoid unnecessary punctuation,
  sequence numbers, links, and bare code items in headings.
- Use code in a heading only when necessary and add a descriptive noun, such as
  **The `deploy` command**.
- Maintain a logical hierarchy and do not skip levels. Do not use a heading
  element merely to obtain a visual size.
- Do not repeat the exact page title as an internal heading. Do not leave a
  heading without associated content.
- When introducing a group of lower-level sections, call them **the following
  sections**, not the ambiguous **this section** or **these sections**.
- Put one idea in each paragraph and the critical information first. A
  paragraph longer than five or six sentences is a signal to check for mixed
  ideas, not an automatic failure.
- Left-align prose. Do not force hard line breaks inside rendered sentences or
  paragraphs.

## Use lists, tables, notices, and footnotes intentionally

- Use a numbered list for steps, phases, priorities, or any sequence whose
  order matters.
- Use a bulleted list for nonsequential options, requirements, or examples.
  State whether all, any, or one of the items applies.
- Use a description list for term-definition or name-description pairs.
- Do not create a list for one item. Keep items grammatically parallel and use
  consistent capitalization and end punctuation.
- Introduce a list with a complete sentence when the heading does not supply
  enough context. A colon is natural when the list follows immediately.
- Use a table when each item has three or more related dimensions. Prefer a
  list for one dimension and a description list for two.
- Introduce every table in prose. Use concise headers, semantic header cells,
  and a caption when multiple nearby tables need identification.
- Avoid tables for layout, code, one-dimensional lists, or procedural steps.
  Do not merge cells unless a higher-authority platform requirement makes it
  unavoidable.
- Use a note for useful but nonessential information. Use a caution when the
  reader must proceed carefully. Use a warning for serious or irreversible
  harm such as permanent data loss, financial loss, or a security exposure.
- Keep prerequisites, required actions, results, and essential success
  information in the normal flow. Consecutive notices are a signal to
  reorganize the content.
- Avoid footnotes because they interrupt reading, accessibility, and
  localization. If unavoidable, use numbered superscript markers and put the
  note where the publication format expects it.

## Apply punctuation and formatting consistently

- Use the serial comma in a series of three or more items.
- Introduce a list with a colon only after a complete sentence. In running text,
  lowercase the first word after a colon unless a proper noun, heading, quote,
  or defined notice label requires capitalization.
- Use an em dash without surrounding spaces for a genuine interruption. Do not
  use an en dash. Prefer a colon or period to a dash between a label and its
  description.
- Use hyphens where they prevent misreading or bind a compound modifier before
  a noun. Follow project usage, then the Google word list, then the preferred
  dictionary for uncertain compounds.
- Avoid semicolons where a period or simpler sentence works. Use them only for
  closely related independent clauses, before a conjunctive adverb, or to
  separate complex list items.
- Avoid slashes outside code, paths, URLs, and established technical notation.
  Write **and** or **or** explicitly; avoid **and/or**.
- Avoid ellipses in prose and UI instructions. In quoted text, use three
  periods for an internal omission. Follow code- and command-specific rules for
  omissions rather than this prose convention.
- Keep parenthetical content short and nonessential. Move important or lengthy
  information into the sentence or its own paragraph.
- Use straight quotation marks and apostrophes in developer documentation.
  Put literal input in code font instead of quotation marks where possible.
- Use italics sparingly: for a newly defined term on first use, a word discussed
  as a word, semantic emphasis, full-length work titles, and mathematical
  variables. Reserve bold for UI labels, run-in headings, and notice labels.
- Reserve underlining for links. Do not override a site's global font, size, or
  color merely for emphasis.

## Format dates, numbers, units, and mathematics

- Spell out month names and use a four-digit year: **January 19, 2026**. If a
  numeric-only date is required, use ISO order: **2026-01-19**.
- Put the date before the time. Use the publication's established clock format;
  in ordinary US English prose, Google style prefers **3 PM** or **3:45 PM**.
- Avoid time zones unless needed. When a zone matters, identify the region and
  include its UTC offset; do not rely on an ambiguous abbreviation.
- Do not express dates with slashes. Avoid seasons; use dates, months, quarters,
  or the relevant physical condition.
- Spell out zero through nine in general prose. Use numerals for 10 and greater
  and for technical quantities, versions, pages, chapters, steps, prices,
  measurements, decimals, negative numbers, ranges, percentages, and
  dimensions.
- Spell out ordinals in prose. Avoid referring to step numbers; when necessary,
  use the numeral.
- Use a leading zero for a decimal smaller than one. Treat decimal quantities
  as plural. Use a comma for groups of thousands and a period as the decimal
  point in US English.
- Use numerals with the percent sign and no intervening space: **40%**. Spell
  out a percentage that starts a sentence.
- Use a hyphen without spaces for a numeric range. Do not use an en dash.
- Put a space, preferably nonbreaking, between a numeral and an abbreviated
  unit: **64 GB**. Do not pluralize the unit abbreviation.
- Distinguish decimal units from binary units when the difference matters: GB
  is not GiB.
- Use actual mathematical symbols or appropriate HTML entities, not lookalike
  punctuation. Italicize variables, not operators. Use nonbreaking spaces
  around operators in a single expression when the rendering format supports
  them.
- Use standard superscript and subscript markup for exponents and indices.
  Prefer a decimal to a written fraction when practical. Use a dedicated math
  renderer or accessible diagram for complex multiline equations.

## Make visuals and interactions accessible

- Use an image only when a visual explanation is materially clearer than text.
  Prefer actual text for code, commands, output, and prose.
- Introduce an informative image in the surrounding text. Give it concise alt
  text that communicates the image's purpose in context; use empty alt text for
  decorative or fully redundant images.
- Give a complex diagram a text description that communicates the same
  information. Do not put new required information only in the image.
- Use SVG for diagrams when practical and a high-resolution raster image when
  SVG is unsuitable. Prefer a compressed video format to animated GIF.
- Crop screenshots to the relevant UI. Remove personally identifying
  information with an opaque overlay and flatten layered exports; a reversible
  blur is not sufficient.
- Provide captions or transcripts for audio and video. Avoid flickering or
  flashing content.
- Use native and semantic structures so headings, lists, tables, forms, and
  controls retain meaning for assistive technology.
- Ensure links work out of context, controls have labels, tables have headers,
  and interactive elements are introduced before use.
- Make the reading and interaction order match the visual order. Do not rely on
  color, size, sound, direction, or location as the only signal.

## Keep claims, time, and sources trustworthy

- Avoid unverifiable performance, cost, security, and competitive claims.
  Support specific quantitative claims with a source that readers can inspect.
- Avoid superlatives and absolutes such as **best**, **fastest**, **simplest**,
  **always**, **never**, **ensure**, and **guarantee** unless the evidence and
  scope truly make them exact.
- Describe a security feature's function or design; do not promise that it
  prevents every incident.
- Document the supported present state. Avoid **currently**, **as of this
  writing**, **new**, **latest**, **soon**, **old**, and **future** in durable
  product documentation.
- Time-based words are acceptable in explicitly dated release notes, blog
  posts, status notices, and transition steps when their reference point is
  clear.
- Do not pre-announce future features or strategy without the required legal
  and organizational approval.
- Do not copy third-party text, images, code, logos, or speech merely because it
  is public. Paraphrase and link unless licensing and attribution requirements
  are known and authorized.

## Resolve exact word choices

For an exact spelling, compound, capitalization, or disputed term:

1. Follow the project glossary and established product documentation.
2. Check the live [Google word list](https://developers.google.com/style/word-list).
3. Check the relevant topic page, such as jargon, inclusive language,
   hyphenation, or capitalization.
4. Use the project's preferred dictionary. Google style uses the first spelling
   in Merriam-Webster when no higher authority decides the form.

The word list distinguishes **Use with caution** from **Don't use**. A cautious
term can be used when it is the clearest precise term for the audience, usually
with a definition. A **Don't use** term should be replaced or written around,
including when its literal code form must be mentioned separately.
