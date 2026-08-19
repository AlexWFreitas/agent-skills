# Technical elements

Read this reference when documentation contains code, commands, placeholders,
API reference text, UI instructions, links, HTML, Markdown, filenames, or
example data. Preserve the project's syntax, renderer, code-style rules, and
technical truth when they differ from the editorial defaults here.

## Preserve literals and contracts

- Copy public identifiers, method names, field names, flags, status codes,
  paths, filenames, versions, and literal UI labels exactly from an
  authoritative source.
- Never rewrite a command or code sample solely to make the surrounding prose
  smoother. A change to syntax or behavior requires technical evidence and the
  user's authorization for that scope.
- Do not infer a missing flag, default, return value, error, permission,
  supported version, or expected output from naming conventions.
- Keep a distinction between verified runnable examples, illustrative
  fragments, syntax patterns, and pseudocode. Label the distinction when a
  reader could mistake one for another.
- Preserve copied error messages, console output, and API literals verbatim.
  Explain them outside the literal block rather than editing them.

## Code in ordinary text

Use code font when text represents a code entity, exact input, or exact output.
In Markdown, use backticks; in HTML, use the `code` element.

Common code-font items include:

- Attributes and values, classes, methods, functions, constants, enums,
  namespaces, language keywords, package names, and data types.
- Commands, command-line utilities, flags, arguments, environment variables,
  paths, directories, filenames, filename extensions, and text that the reader
  enters.
- Database objects, HTTP methods, HTTP status codes, header and content-type
  values, DNS record types, IAM role names, IP addresses, port numbers, query
  parameters, and literal strings.
- Placeholders and values that appear as code-derived UI content.

Do not use code font merely because a term is technical. Product, service, and
organization names remain ordinary text. A domain name or URL that the reader
follows in a browser is normally a descriptive link, not code; the same string
is code when it appears as a literal in a command or configuration.

Conditional cases:

- Format literal Boolean values such as `true` and `false` as code. Use ordinary
  text for whether a condition evaluates as true or false in explanatory prose.
- Format an email address as code when the reader enters or receives it as
  data. Use a `mailto` link or ordinary linked text when it is contact
  information.
- Use both bold and code styling when a named UI element displays a literal
  code-derived value. Follow the project's renderer syntax for combined styles.

Do not put quotation marks around code-font text unless the quotation marks are
part of the literal.

## Treat code elements grammatically

- Add a descriptive noun after a code element: the `settings.yaml` file, the
  `POST` request, the `close` method, or `Intent` objects.
- Do not turn an HTTP method, command, acronym, class, or filename into an
  English verb.
- Do not manually pluralize or make a possessive from a class, product,
  trademark, or bare code name. Inflect the descriptive noun instead.
- Omit a class qualifier from a method name in prose unless it prevents
  ambiguity.
- Match code capitalization exactly. Do not insert spaces or punctuation into
  an identifier.
- Refer to an HTML or XML element by its element name without angle brackets in
  prose, unless the actual tag syntax is the subject.

For HTTP status codes, prefer forms such as an HTTP `400 Bad Request` status
code or an HTTP `2xx` status code. Call it a status code unless a higher
authority uses another precise term.

## Code samples

- Introduce a sample with a complete sentence or paragraph that explains its
  purpose. Use a colon when the introduction immediately precedes the block and
  a period when intervening material separates them.
- Follow the project's language-specific code style and indentation. Do not
  reformat generated or canonical code to a generic two-space rule.
- Prefer lines at or below 80 characters when the language and project style
  permit. Never insert a line break that changes the program.
- Use the publication format's semantic preformatted block. Preserve the local
  choice of fenced Markdown, indented Markdown, or HTML `pre` markup.
- Use a language comment to explain omitted code. Do not use an ellipsis as the
  omission marker inside a runnable instructional sample.
- Do not make a fragment with omitted code appear click-to-copy or runnable.
- Include only the code needed to demonstrate the point, but keep any required
  context, imports, setup, and error handling that make the example accurate.
- Link to the applicable project or language code-style guide when a reader
  needs more than the sample demonstrates.

## Commands and command output

### Present a task command

1. State what the command accomplishes; avoid the empty introduction **Run the
   following command**.
2. Link the command name to its authoritative reference where helpful.
3. Show the shortest recommended command that completes the stated task.
4. Put the command in a copyable preformatted block using the project's shell
   and renderer convention.
5. Explain every placeholder immediately after the command.
6. Explain non-obvious behavior, permissions, side effects, or irreversible
   consequences before the reader runs the command.
7. Show output only when readers need it to verify the result, copy a value, or
   understand the next step.

Commands that are intended to be copied should not contain syntax notation
that breaks execution. Avoid raw optional brackets, mutually exclusive braces
and pipes, and repetition ellipses in a click-to-copy block. Prefer one of the
following:

- Omit optional arguments and link to the full command reference.
- Provide separate runnable blocks for materially different choices.
- Put optional variants in separate sections or tasks.
- If syntax notation is unavoidable, state clearly that the reader must edit
  it and do not present the block as directly runnable.

For formal syntax rather than a runnable example:

- Use `[OPTIONAL]` for one optional item.
- Use `{CHOICE_1|CHOICE_2}` for exactly one required choice.
- Use `...` for a repeatable argument.
- Keep notation outside placeholder styling and define it.

For a multiline command:

- Break at a syntactically safe point and use the correct continuation
  character for the documented shell.
- Indent continuation lines consistently, commonly by four spaces.
- Do not show a working-directory path in the prompt unless the path itself is
  essential context.
- Make local, remote, privileged, container, or other execution contexts
  explicit when the prompt alone would not distinguish them.

The prompt symbol is optional for one command. If a block contains several
input lines, put a prompt on each input line or use the project's established
input styling. Separate input from output whenever practical.

### Present output

Introduce output with one of these forms:

- **The output is the following:** when the text is exact and stable.
- **The output is similar to the following:** when values or ordering can vary.
- A customized sentence that names the field or line the reader must inspect.

Use `...` on its own line to represent omitted command output. Preserve actual
ellipses that are part of a literal. Explain placeholder values in output when
readers need to interpret them.

Do not show output for every command. If a command succeeds silently or the
next step is the meaningful verification, state that instead.

## Placeholders

- Use a descriptive all-uppercase name with underscore separators, such as
  `PROJECT_ID` or `SERVICE_ACCOUNT_NAME`, unless the target syntax or project
  convention requires another form.
- Do not use `x`, repeated `x` characters, `foo`, `bar`, `baz`, `my`, or `your`
  as a placeholder when a meaningful name is possible.
- Distinguish a placeholder from shell variable syntax. `${PROJECT_ID}` and
  `PROJECT_ID` do not mean the same thing in every context.
- Apply the publication's placeholder styling. At minimum, keep a placeholder
  visually distinct as code; use semantic `var` markup when the renderer
  supports it.
- Explain a placeholder the first time it appears. Repeat the explanation only
  when the document is long, non-linear, or contains enough placeholders that
  the reminder materially helps.

For one placeholder, use this pattern:

> Replace `PLACEHOLDER` with a precise description of the required value.

For two or more placeholders:

1. Introduce a list with **Replace the following:**
2. List placeholders in the order in which they occur.
3. Follow each placeholder with a colon and a lowercase description.
4. State format, allowed range, source, or example when the reader cannot infer
   it safely.

Use **This output includes the following values:** for placeholders in output
that the reader observes rather than supplies.

## API reference documentation

Use the language's documentation-comment syntax and reference generator. The
editorial guidance here does not replace a programming-language or API design
standard.

### Coverage

Document every public class, interface, struct, constant, field, enum, type,
method, parameter, return value, exception, permission, and relevant
dependency. If coverage is intentionally partial, do not present it as a
complete reference.

### First sentences

- Give every reference item a short, distinctive first sentence because tools
  often extract it into indexes and summaries.
- For a class or interface, state its purpose without repeating **This class**
  or the class name.
- For a method, state what it does in present tense: **Creates**, **Gets**,
  **Lists**, **Returns**, or **Checks whether**. Do not use the imperative
  **Create** or describe only what a developer can use it to do.
- Avoid abbreviations containing periods in the first sentence when a generator
  might truncate at the first period.

### Methods and members

- Operation plus returned data: **Creates ... and returns ...**
- Boolean getter: **Checks whether ...**
- Non-Boolean getter: **Gets ...**
- Setter or update: **Sets ...** or **Updates ...**
- Deletion: **Deletes ...**
- Registration: **Registers ...**
- Callback: **Called by ...** when that pattern matches the API.
- Factory or constructor-like convenience method: **Creates a ...**

After the first sentence, describe when and why to use the item, prerequisites,
permissions, side effects, idempotency, errors, related APIs, and pitfalls only
as the authoritative contract supports them.

### Parameters, returns, and exceptions

- Capitalize a parameter description and end it with appropriate punctuation.
  Start a non-Boolean parameter with **The** or **A** when natural.
- For a control Boolean, describe both `true` and `false` behavior explicitly.
- For a state Boolean, use **True if ...; false otherwise.** In this prose
  pattern, follow the generator's convention for whether the words are code.
- For a default, explain behavior across relevant values before stating
  **Default:** and the actual default.
- Keep return descriptions brief. Use **The ...** for a non-Boolean return and
  **True if ...; false otherwise.** for a Boolean return.
- If the generator supplies **Throws**, begin the condition with **If ...**;
  otherwise, use **Thrown when ...** if that matches the project convention.

### Deprecations

Put the critical migration information first:

- State that the item is deprecated.
- Name and link the supported replacement.
- State the version in which deprecation began when versioning is part of the
  contract.
- Explain the minimal change needed to keep existing code working.
- Include the rationale only after the actionable replacement information.

## UI instructions

Focus first on the reader's goal: **Refresh the page** can be better than
**Click Refresh** when the control is obvious. Name the control when readers
need it to find or perform the action.

- Put visible UI labels in bold. Do not use quotation marks around them.
- Match official UI capitalization, except normalize an inconsistent or
  all-uppercase label to sentence case when the project convention allows it.
- Do not bold a product or feature name unless it is also the literal label of
  the referenced element.
- Use both bold and code font for a UI value derived from code or text that the
  reader entered.
- Contextualize a UI label used outside a procedure by naming the application,
  console, page, pane, or feature that contains it.
- Do not use a UI element as a verb. Write **In the Name field, enter ...**
  rather than **Name ...**.

Use precise UI nouns when they add clarity:

- **Window** for a desktop application window or separately opened modular
  window.
- **Page** for a web page or console subpage.
- **Dialog** for a smaller detached window in front of another window.
- **Pane** or **panel** for a rectangular region within a larger window.
- **Section** for a labeled grouping of controls.
- **Menu** for the collection and **command** for an item in a menu.
- **Navigation menu** for a list that moves between app or site pages.
- **Toolbar** for a set of action buttons.
- **Tab**, **list**, **box**, or **field** with its label when the type matters.

In Google Cloud and Google Workspace contexts, the guide prefers **field** to
**box**. In other products, follow the product's established terminology.

For menu paths, write the sequence as one bold unit, such as **File > New >
Document**. In HTML, give the angle brackets an accessible label such as **and
then** if the platform requires it. Do not use this notation to collapse a
mixed sequence of unrelated UI elements.

For buttons and icons:

- Refer to a labeled button by its label: **Click OK**, not **click the OK
  button**.
- For an icon-only button, use its accessible name or tooltip and include the
  icon only when the publication format supports it accessibly.
- If the accessible name is unknown, inspect the element's ARIA or label
  attributes. Do not invent a name from its appearance.
- Omit a trailing UI ellipsis unless omission creates ambiguity.
- Avoid directional descriptions. Add control context or a screenshot when the
  element is hard to find.

Use `kbd` markup for keys when the publication supports it. Capitalize letter
keys, spell modifier names consistently, and include **press Enter** in the
same procedural step when it is required. Do not substitute a keyboard shortcut
for the primary accessible UI path unless the shortcut is the subject.

## Links and cross-references

- Be selective. Each link adds a choice and a way for the reader to lose their
  place. Put short necessary context on the current page.
- Link to the most relevant page or section, not a product home page or a set
  of roughly equivalent destinations.
- Avoid duplicate links in one page unless the document is long or has distinct
  entry points where the repeated link materially helps.
- Use the exact destination title or a short descriptive phrase. Put the most
  important words first and make the link understandable out of context.
- Avoid **click here**, **this document**, **read more**, and bare URLs as link
  text.
- Include both the long form and abbreviation in the link when introducing an
  abbreviation.
- Include a descriptive noun with linked code when it reads naturally, such as
  linking the `--hostname` flag rather than only `--hostname`.
- Introduce a separate cross-reference sentence consistently with **For more
  information, see ...** or **For more information about ..., see ...**. Use
  **about**, not **on**, when naming the topic.
- Explain an unexpected link action in the link text: file download and type,
  email action, same-page jump, or forced new tab.
- Let links open in the current tab by default. If the platform forces a new
  tab, tell the reader.
- Put sentence punctuation and quotation marks outside link text where
  possible. Do not wrap linked titles in quotation marks or italics.
- Prefer HTTPS for external destinations. Do not rely on an external-link icon
  to explain that a reader leaves the current domain.
- Avoid external destinations in a documentation set's main navigation when an
  in-set page can provide the context and link.

For same-site links, follow the repository's established path convention.
Google style favors site-root-relative URLs when that convention is available.

## Stable heading targets

- Do not rename a linked heading casually. Search for inbound references where
  the repository makes that possible.
- Use a custom anchor for frequently linked content or when a heading might be
  edited without changing the conceptual target.
- Make custom IDs short, descriptive, lowercase, and hyphen-separated.
- When revising a heading with an automatically generated anchor, preserve the
  old ID as a custom anchor when the renderer supports it.
- Change an existing custom anchor only when necessary, such as removing a
  harmful term, and update known links.
- Follow the target renderer's supported anchor syntax; do not copy a
  DevSite-specific attribute form into an incompatible Markdown engine.

## HTML and Markdown

- Follow the project's existing source format and renderer. Markdown is easier
  to read as source; HTML offers more semantic control. Use HTML inside
  Markdown only when the required semantics are not available otherwise.
- Use semantic elements for their intended meaning. Use headings for
  hierarchy, lists for lists, tables for tabular data, `em` for emphasis, `i`
  for non-emphasis italics, `strong` for importance, `b` for visual attention,
  and `code` or `pre` for code.
- Do not use tables or frames for layout. Do not use `br` elements to simulate
  paragraph spacing.
- Use the site's CSS for layout and visual appearance. Do not add inline font,
  size, or color styling for ordinary emphasis.
- In HTML source, use lowercase element and attribute names, spaces rather than
  tabs, and the project's indentation. Google style commonly uses two spaces.
- Avoid trailing whitespace. Wrap source near the project's limit, commonly 80
  characters, except where a URL, metadata value, or literal cannot safely
  wrap.
- Do not omit optional HTML elements if the project's publication tooling or
  accessibility expectations require explicit structure.

## Filenames, products, trademarks, and examples

### Filenames and file types

- Preserve the existing directory convention. For a new standalone convention,
  prefer lowercase ASCII names with hyphens between words and a descriptive
  name.
- Refer to a literal filename in code font and add the noun **file** when it
  improves grammar: the `build.sh` file.
- Use the exact on-disk spelling even if it violates the preferred naming
  style.
- Name the file type rather than using its extension as a generic noun: **a
  JSON file**, not **a `.json` file**.
- Do not use a file type as a verb. Write **Extract the zip file**, not **Unzip
  the file**, unless the command or product terminology requires the verb.

### Product and trademark names

- Use the official spelling and capitalization from the owner or authoritative
  product documentation.
- Treat feature names as lowercase unless the official name or literal UI
  label is capitalized.
- Use the approved full product name. Do not invent a shortened name.
- Do not use a product or trademark as a verb, plural, or possessive. Use it as
  a modifier followed by a generic noun where the owner's guidelines require
  that form.
- Follow the owner's trademark attribution and marking requirements; this
  skill does not supply legal advice.

### Safe example data

- Never copy real personal data, secrets, customer identifiers, production
  domains, real phone numbers, or live resource names into examples.
- Prefer IANA-reserved domains `example.com`, `example.org`, and `example.net`.
- Use documentation-reserved IP address ranges, such as `192.0.2.0/24`,
  `198.51.100.0/24`, `203.0.113.0/24`, and `2001:db8::/32`.
- Use the reserved North American example phone-number range
  `800-555-0100` through `800-555-0199`.
- Use diverse, non-stereotyped fictional people. Prefer a given name plus a
  surname initial when a surname is needed.
- Use descriptive project and resource names. Avoid meaningless `foo`, `bar`,
  and `baz` outside contexts where those metavariables are themselves the
  established subject.
- Make obvious which values are fixed examples and which are placeholders the
  reader must replace.

## Verification boundaries

Before finalizing technical material, record what you actually checked:

- Static source comparison only.
- Syntax or lint validation.
- Command help or API schema comparison.
- Safe local execution.
- End-to-end behavior in a disposable environment.
- Link checking.
- UI label and navigation confirmation.
- Keyboard and screen-reader testing.

Do not turn a style edit into a production command, account mutation, publish,
deployment, or data change. If stronger verification needs new authority, state
the boundary and ask rather than implying the example is proven.
