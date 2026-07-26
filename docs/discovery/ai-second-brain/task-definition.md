# Task Definition: AI Second Brain

Status: `ready-for-handoff` · Task: `ai-second-brain` · Last updated:
`2026-07-26T16:25:46-03:00` · Supporting record:
`discovery-record.md`

## Objective

Create a durable AI-assisted second brain that initially supports game
playthroughs and can later support other knowledge-building activities without
restructuring its storage model. The user should be able to provide discoveries
and context through a conversational interface, have the system organize useful
knowledge outside the model's transient chat context, and later ask questions
or receive help grounded in the accumulated firsthand record.

Success should reduce the player's note-taking and recall burden without
silently inventing game facts, losing provenance, or making the knowledge
unusable when a chat session or model changes. It must also prevent the model's
pre-existing game knowledge from leaking spoilers or influencing normal
playthrough assistance.

## Implementation context

The initial idea combines three distinct responsibilities that must not be
treated as interchangeable:

- a capture interface used while playing;
- an AI process that classifies, summarizes, relates, and retrieves information;
- a durable, inspectable knowledge folder that remains authoritative across
  chat sessions.

The first activity template is a game playthrough, but non-game reuse is a
governing architecture requirement. The storage, capture, provenance,
correction, and retrieval core must use domain-neutral concepts. Activity
templates may add game-specific or other domain-specific organization without
changing the core folder contract.

The user is comfortable sending captured content to a cloud-hosted model but
will not pay for metered API usage or another AI subscription. The existing
ChatGPT Pro subscription is the maximum recurring AI-service spend.

Official documentation confirms that ChatGPT Pro can be used with Codex local
clients and scripted workflows. The user accepts the Pro plan's own finite
usage windows. [research-notes.md](research-notes.md) governs that current
external evidence.

The direct Codex harness cannot write a submitted message into the knowledge
folder before the model receives it. Inbox persistence is therefore the first
agent action after Codex accepts the message. Inputs that Codex never accepts
because of an outage or exhausted allowance are outside the durability
guarantee. The user accepts this boundary; a pre-model capture companion and a
local fallback model are not required.

### Dependency and quota boundary

ChatGPT Pro is the only permitted hosted AI dependency. Its own plan usage
limits are acceptable. Added capabilities must not introduce a separate
free-tier allowance, usage quota, token billing, or recurring subscription.
This excludes hosted plugins, connectors, MCP services, transcription APIs,
vector databases, and similar dependencies when ordinary play can be
interrupted by their independent quota.

Local skills, scripts, file tools, and locally launched MCP processes are
eligible because they do not create another hosted-service allowance. A
component described as a plugin or MCP server is not automatically eligible:
its runtime and every transitive external service must satisfy this boundary.
The first version does not require an embedded database.

### Target environment

The first version targets a single Windows PC. The user plays the game and
interacts with the second brain on that same computer. Capture, conversation,
and the user-owned knowledge folder should therefore work locally on Windows
without depending on a phone, tablet, or cross-device relay.

Cross-device access is not required. The interaction surface is the Codex
desktop app, optionally accompanied by Obsidian as a local view over the same
folder.

### Selected harness and knowledge interface

The first version uses the Codex desktop app authenticated through the user's
existing ChatGPT Pro subscription. Codex is the conversational capture,
reasoning, and folder-writing agent. A purpose-built local skill governs
firsthand-only behavior, lossless capture, organization, retrieval, correction,
checkpointing, provenance, and context isolation.

Obsidian is the selected optional human-facing knowledge interface. It opens the
same local Markdown folder as a vault and provides browsing, search, links,
graph navigation, and manual editing. It is not an AI dependency and must not
mediate Codex's file access.

The complete workflow must remain usable when Obsidian is closed, absent, or
later removed. No Obsidian AI plugin, community plugin, Sync service, Publish
service, hosted connector, or Obsidian-specific database is required. The
authoritative files must remain ordinary portable Markdown and media.

### Epistemic and spoiler boundary

Normal operation is **firsthand-only mode**. In this mode, the authoritative
knowledge universe consists only of information deliberately provided by the
user and conclusions supportable from that accumulated evidence. The model
must behave as if it has no other game knowledge, even when its training data
contains the answer.

In firsthand-only mode, the system must not:

- reveal, confirm, deny, hint at, or steer around an undiscovered game fact;
- use latent model knowledge to strengthen a hypothesis beyond the recorded
  evidence;
- fill missing names, relationships, locations, mechanics, outcomes, or quest
  steps from memory;
- perform web research or consult guides;
- silently incorporate outside information into the firsthand record.

When the user asks for outside knowledge, the override applies only to the
requested question or explicitly stated scope. The response must identify that
it is using model knowledge or external research. Any durable outside material
must be stored separately from firsthand observations and must retain its
provenance. After the scoped request, the system returns to firsthand-only
mode.

This is a behavioral control rather than a claim that latent model knowledge
can be technically removed. The skill instructions, folder contract, prompts,
and validation scenarios must collectively enforce non-use and non-disclosure.

### Capture requirements

The first usable version must accept all of the following deliberate user
inputs:

- typed messages;
- messages containing screenshots;
- voice capture.

Voice capture means that the user intentionally records or submits speech. It
does not currently imply an always-listening microphone. Continuous or
automatic observation of the game screen is not required.

For the first version, voice evidence consists of the corrected transcript,
capture timestamp, voice input type, and stable capture ID. Raw microphone audio
is not retained. Native Codex foreground dictation is sufficient; no separate
recorder or audio-file lifecycle is required.

Submitted screenshots are copied into the active context's `attachments/`
folder using a stable capture-ID filename. The original accepted image is
immutable evidence; later annotation or optimization must create a derivative
rather than overwrite it.

Current Codex documentation confirms image attachments but does not establish
that every desktop attachment is exposed to the agent as a copyable local path.
Implementation must verify this before claiming durable screenshot intake. If
the attachment cannot be copied, the safe first-version fallback is to have the
user save or place the image in `attachments/` and then reference that file in
Codex. The capture remains visibly pending until the durable image exists; the
system must not silently treat model-visible-only image data as retained
evidence. [research-notes.md](research-notes.md) owns this managed unknown.

Screenshot processing distinguishes:

- **evidence** — the original image and the user's accompanying caption;
- **AI observation** — visible text, objects, spatial relationships, UI state,
  and other directly image-supported details;
- **AI inference** — proposed meaning, identity, relationship, or consequence,
  explicitly labeled with confidence and linked to its supporting observations.

Unclear or unreadable visual material remains marked as such. The AI must not
fill visual gaps from latent game or domain knowledge while in firsthand-only
mode. Reconciliation may promote supported observations into current knowledge,
but it must retain the originating capture ID and must not rewrite an inference
as a direct user observation.

### Capture and consolidation policy

Every deliberate user input must be appended immediately to a lossless session
inbox as the first agent action after Codex accepts it and before it is
interpreted or reorganized. Each entry must preserve its timestamp, input type,
original text or transcript, screenshot reference when applicable, and
processing state. The inbox is evidence and must not be silently rewritten into
a cleaner history.

Organized knowledge is reconciled at these checkpoints:

- when the user explicitly asks to organize or checkpoint;
- before answering a question that requires current cross-session knowledge;
- when the user ends a play session.

Corrections and material state changes are applied immediately so the current
knowledge does not remain knowingly wrong. Reconciliation must retain a
traceable relationship to inbox entries and must mark processed entries without
destroying them.

### Correction and conflict policy

The system classifies apparent conflicts before changing current knowledge:

- An **explicit correction** immediately supersedes the incorrect current
  claim while preserving its capture, supersession link, and historical
  provenance.
- A **state transition** records both the previous and new states on the
  timeline with their applicable times; it is not treated as an error.
- An **ambiguous conflict** preserves both claims, marks the affected current
  state as uncertain, and asks the user to resolve it. The AI must not select a
  winner using latent knowledge, unsupported confidence, or recency alone.

### Bounded initiative

The assistant may interrupt normal capture only for an urgent contradiction, a
safety-relevant conflict, or an explicitly time-sensitive reminder. It must
collect non-urgent connections, recurring patterns, unresolved threads,
possible contradictions, and hypotheses for the next checkpoint unless the
user asks for analysis sooner.

Initiative never expands the evidence boundary. In firsthand-only mode, every
proactive observation must be supported by the user's accumulated record and
must distinguish direct evidence from inference. The assistant must not use
latent or external knowledge to decide what to emphasize, warn about, or hint
at.

### Generic container hierarchy

The vault uses the following domain-neutral identity structure:

```text
collections/
  <subject>/
    contexts/
      <context>/
```

A **collection** is a broad subject such as a game, research topic, or learning
area. A **context** is an isolated body of accumulated evidence, such as a
particular playthrough, research direction, course, or time period. The first
context is created automatically as `main`; additional contexts are created
only when requested.

Information does not cross context boundaries automatically. Sharing,
importing, comparing, or promoting knowledge across contexts requires an
explicit user instruction and retained provenance. For the initial game
template, the game is the collection and the playthrough is the context.

### Authoritative storage format

Markdown files and ordinary local media files are authoritative. Stable capture
identifiers connect synthesized facts and corrections to their source inbox
entries. A small append-only structured ledger may be used where Markdown alone
would make lossless intake unsafe, but it must remain inspectable and portable.

SQLite and vector databases are not required in the first version. A future
local index is acceptable only when it is disposable and fully rebuildable from
the authoritative files. No hosted search or embedding service is permitted
under the no-secondary-quota constraint.

### Default context file contract

Every context begins with this compact generic structure:

```text
<context>/
  context.md
  timeline.md
  open-items.md
  inbox/
  topics/
  attachments/
  external/
```

- `context.md` contains identity, scope, selected activity template, epistemic
  mode, current state, and the latest checkpoint.
- `timeline.md` records meaningful developments chronologically without
  replacing the lossless inbox.
- `open-items.md` separates actionable tasks, unresolved questions,
  contradictions, and hypotheses.
- `inbox/` contains immutable chronological session captures and processing
  state.
- `topics/` contains notes created on demand as accumulated material justifies
  them; empty speculative categories are not pre-created.
- `attachments/` contains durable copies of screenshots and other retained
  media referenced by capture ID.
- `external/` contains explicitly requested outside knowledge and its
  provenance, isolated from firsthand material.

Activity templates may recommend optional topic notes or derived views. They
must not rename, replace, or create a second authoritative core.

### Chat and session lifecycle

Each activity session uses one harness conversation. A later session may start
a fresh conversation and resume the selected collection/context entirely from
durable files. Resuming the same conversation remains optional convenience and
must not change the result.

At session start, the skill identifies the active context, loads its current
summary, open items, governing activity template, and only the recent evidence
needed to continue safely. It must not hydrate from sibling contexts. At session
end, it reconciles the lossless inbox, writes a durable checkpoint, and reports
any pending or conflicted items.

On a fresh session, the skill resumes the most recently active context and
announces the selected collection/context before substantive work. It asks for
confirmation only when the opening input indicates another subject, multiple
contexts plausibly match, or the prior context is unavailable. It must not read
or write substantive content while the active context is ambiguous.

Harness chat history is non-authoritative working context. No fact, correction,
decision, open question, or provenance needed for continuity may exist only in
the chat.

### Answer provenance

Normal factual recall and AI inference include compact references to supporting
capture IDs or governing topic notes. Uncertainty and inference remain visibly
labeled. The user may request the complete evidence chain, including original
captures and screenshot observations.

Simple capture acknowledgements do not display citations unless a conflict,
interpretation problem, or requested verification makes them useful. Compact
provenance must remain readable and must not replace a direct answer.

### Retention, archive, and deletion safety

The system never deletes captures automatically. Archiving an inactive context
changes its lifecycle state without rewriting or removing its evidence.

Permanent deletion requires an explicit user request and confirmation. Before
confirmation, the system identifies the contexts, captures, attachments,
derived notes, and cross-references that will be affected. Deletion and repair
of dangling references occur as one bounded operation; partial cleanup must
remain visible and recoverable rather than being reported as complete.

## Scope and non-goals

**In scope**

- Define and implement a conversational capture workflow for text,
  screenshots, and voice concerning playthrough facts, hypotheses, tasks,
  decisions, locations, characters, items, and progress.
- Use the Codex desktop app authenticated through the user's ChatGPT Pro
  subscription with a purpose-built local skill as its behavioral contract.
- Operate within the user's existing ChatGPT Pro subscription and local
  computing resources without token-billed API usage.
- Implement added organization and retrieval locally. Use Codex's included
  foreground voice dictation rather than a separately metered transcription
  dependency.
- Persist organized knowledge in a user-owned folder independently of any one
  chat session or model context window.
- Retrieve relevant stored knowledge for grounded questions and playthrough
  assistance.
- Preserve enough source and confidence information to distinguish what the
  user observed, what the AI inferred, and what remains uncertain.
- Enforce firsthand-only mode by default, with a narrow and visibly attributed
  outside-knowledge override only when explicitly requested.
- Provide a practical continuity model across sessions and corrections.
- Resume from a fresh harness conversation using only the selected context's
  durable files.
- Support additional activity templates without migrating or renaming the
  domain-neutral storage core.
- Create and isolate collections and contexts using the settled generic
  hierarchy, with `main` as the low-friction default.

**Not in scope**

- Assuming that the model's chat history alone is durable or authoritative.
- Automatically scraping game files, consulting online guides, or exposing
  spoilers during firsthand-only mode.
- Always-on microphone capture or continuous game-screen observation.
- Implementing every possible non-game activity template in the first version;
  only the generic core and the game-playthrough template are initially
  required.
- Requiring phone, tablet, console, or cross-device access in the first
  version.
- Pay-as-you-go model APIs or an additional paid AI subscription.
- A hosted plugin, connector, MCP server, transcription service, vector
  database, or other dependency whose separate quota can interrupt ordinary
  play.
- A custom game overlay, always-on-top companion, or bespoke capture client in
  the first version.

## Deliverables

| Deliverable | Required outcome |
| --- | --- |
| Codex project and optional Obsidian vault | Opens the user-owned second-brain folder directly in Codex and, optionally, as an Obsidian vault without making Obsidian necessary for operation. |
| AI second-brain skill | Reusable local workflow for capture, organization, grounded retrieval, correction, and session continuity. |
| Solution architecture | Separates conversational capture, AI organization/retrieval, and durable storage, with explicit data flow and ownership. |
| Interaction workflow | Describes how the player uses text, screenshots, and voice dictation to record information, ask questions, correct mistakes, and resume later. |
| Session lifecycle | Defines context selection, startup hydration, end-of-session checkpointing, and fresh-chat resumption. |
| Lossless session inbox | Preserves every capture in chronological form with source type, timestamp, and processing state. |
| Knowledge-folder contract | Defines durable formats, organization, provenance, confidence, and safe update behavior. |
| Generic collection/context layout | Supports game and non-game activity templates with isolated contexts and explicit cross-context sharing. |
| Epistemic-mode contract | Defines firsthand-only behavior, explicit outside-knowledge overrides, provenance separation, and spoiler-leak prevention. |
| Harness and model integration | Provides the selected conversational runtime and the bounded tools it may use to read or update the knowledge folder. |
| Retrieval behavior | Grounds answers in the relevant playthrough record and handles missing or conflicting information transparently. |
| Validation evidence | Demonstrates capture, organization, retrieval, correction, continuity, and non-hallucination behavior on representative playthrough scenarios. |

## Recommended implementation approach

1. **Establish the portable vault contract** — create the generic
   collection/context hierarchy, compact context file set, capture-ID scheme,
   append-only inbox behavior, and bounded permissions before adding
   domain-specific organization.
2. **Implement the Codex behavioral layer** — provide the local skill,
   persistent project guidance, firsthand-only mode, scoped outside-knowledge
   override, conflict policy, bounded initiative, and compact provenance.
3. **Add the initial activity template and capture paths** — implement the
   game-playthrough template plus text, screenshot, and transcript-only voice
   intake without adding a custom companion or hosted dependency.
4. **Implement reconciliation and continuity** — update current state,
   timeline, open items, and topic notes at the defined checkpoints; support
   context-safe fresh-session resumption and optional Obsidian viewing.
5. **Validate the governing boundaries** — exercise progressive discoveries,
   screenshot interpretation, corrections, ambiguous conflicts, provider
   interruption after message acceptance, fresh sessions, context isolation,
   explicit outside-knowledge overrides, archival, and guarded deletion.

## Verification and definition of done

| Check | Evidence of completion |
| --- | --- |
| Low-friction capture | Text, image attachment, and foreground voice dictation work through the Codex desktop composer without a custom overlay or recorder. |
| Lossless intake | Every message accepted by Codex appears once in the chronological inbox as the first agent action and before interpretation; checkpoint processing never deletes its original evidence. Messages Codex never accepts are explicitly outside this guarantee. |
| Checkpoint reconciliation | Explicit organize requests, cross-session questions, and play-session closure bring synthesized knowledge up to date; corrections and material state changes update it immediately. |
| Accepted-message resilience | If processing fails after Codex accepts a message and writes its inbox entry, the entry remains visibly pending and retryable without duplicate capture. |
| No secondary quota | Normal use does not depend on a hosted plugin, MCP service, transcription API, database, or other component with an allowance separate from ChatGPT Pro. |
| Durable organization | New observations are placed predictably in the user-owned folder and survive chat/model restarts. |
| Screenshot evidence | The implementation first proves that Codex attachments can be copied locally or activates the documented save-first fallback. Each completed screenshot capture then has an immutable capture-ID copy, separate user caption, direct AI observations, and labeled AI inference; unreadable details remain unresolved. |
| Voice evidence | Voice input persists as corrected transcript, timestamp, input type, and capture ID without retaining raw audio. |
| Grounded recall | Answers identify supporting stored information and state when the record is insufficient. |
| Provenance and uncertainty | User observations, AI inferences, and unresolved hypotheses remain distinguishable. |
| Firsthand-only grounding | With known game answers available to the model but absent from the folder, responses state that the record is insufficient and do not reveal, confirm, deny, or hint at the answer. |
| Explicit outside-knowledge override | When the user explicitly requests outside knowledge, the response labels its source class, scopes the override, and does not merge it into firsthand truth. |
| Correction safety | A user correction updates the governing knowledge without leaving an undisclosed contradictory summary. |
| Conflict classification | State transitions preserve chronology, explicit corrections preserve supersession history, and ambiguous conflicts remain unresolved until the user decides. |
| Bounded initiative | Only urgent contradictions and explicitly time-sensitive reminders interrupt capture; non-urgent connections wait for a checkpoint and remain grounded in firsthand evidence. |
| Session continuity | A fresh session can resume the same playthrough from the folder without depending on hidden prior-chat state. |
| Context selection | A fresh session announces the most recently active context and stops for confirmation when the opening input makes that selection ambiguous. |
| Chat independence | Deleting or abandoning a prior harness conversation does not remove any material fact, correction, decision, provenance, or unresolved item required to continue. |
| Context isolation | Information from another context is neither read into answers nor merged into the active context unless the user explicitly requests the cross-context operation. |
| Retention and deletion | Captures are never deleted automatically; archive preserves evidence; permanent deletion requires an impact preview and confirmation and leaves no undisclosed dangling references. |
| Scope control | The system does not fetch guides, reveal spoilers, or modify unrelated files unless explicitly authorized. |

The task is complete when the selected solution is implemented, the player can
use it through representative playthrough scenarios, the checks above pass,
and the stated non-goals have not been absorbed into implementation.
