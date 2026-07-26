# Solution Comparison: AI Second Brain

Last verified: `2026-07-26T15:44:03-03:00`

Decision status: **Selected — Codex plus optional Obsidian over one
Markdown-authoritative folder.**

This comparison applies the settled constraints without assuming a product:

- one Windows PC;
- typed messages, screenshots, and deliberate voice capture;
- a local, user-owned, Markdown-authoritative folder;
- no pay-as-you-go API or additional paid AI subscription;
- no ordinary-use dependency on a separately metered hosted plugin, MCP,
  transcription service, vector database, or search service;
- firsthand-only behavior by default, with explicit and attributed overrides;
- fresh-chat or fresh-session continuity from durable files.

## Shortlist

| Product shape | Model and quota boundary | Fit with authoritative Markdown | Capture fit | Main tradeoff |
| --- | --- | --- | --- | --- |
| **Codex directly** | Uses the existing ChatGPT Pro allowance; no API billing or second AI subscription. | Strong: Codex can organize the user-owned folder directly under a local skill contract. | Strong for foreground text, image attachment, and `Ctrl+M` voice dictation. | Lowest setup and strongest hosted reasoning, but still subject to the accepted Pro limits and requires switching to the app. |
| **Codex plus Obsidian** | Same ChatGPT Pro boundary; Obsidian adds no AI quota. | Strongest: Obsidian natively treats the folder's Markdown files as the vault and notices external edits. | Same Codex capture path; Obsidian improves browsing, linking, search, and manual correction. | Two applications instead of one, but each has one clear responsibility. |
| **LM Studio directly** | Fully local inference after model download; no hosted inference quota. | Moderate: it can chat with local documents and expose local APIs/MCP, but a separate workflow must perform disciplined folder updates. | Text and image depend on the selected model; voice capture needs another local mechanism. | Smallest local-model stack, but not a complete durable second-brain workflow by itself. |
| **AnythingLLM Desktop plus a local model** | Fully local LLM, embeddings, vector store, and Whisper are available. Optional cloud and Pro features must stay unused. | Weak-to-moderate: its native state centers on SQLite, LanceDB, parsed documents, and embedding caches rather than ordinary Markdown as sole authority. | Strong for chat, documents, local transcription, RAG, and agents; screenshot behavior still depends on the chosen vision model and UI path. | Easiest all-in-one local workspace, but creates a second application-owned knowledge system that must be synchronized with the authoritative folder. |
| **Open WebUI plus Ollama or LM Studio** | Can run entirely offline against local models; cloud providers and hosted integrations must remain disabled. | Moderate: it offers notes and knowledge/RAG, but native conversations, memory, and knowledge live in the self-hosted application rather than directly defining the folder contract. | Strong built-in file/image upload, voice/audio, conversations, knowledge, notes, and tools. | Broadest capability and control, but highest setup, security, update, and maintenance burden. |

## Products that are complementary rather than substitutes

- **Obsidian** is an excellent local knowledge-folder interface, but it is not
  an LLM harness by itself. Its best role here is beside Codex, reading and
  editing the exact same Markdown vault.
- **Ollama** is an excellent local model runtime, but it is not the full capture,
  organization, provenance, and continuity experience. It belongs underneath
  AnythingLLM, Open WebUI, or a custom workflow.
- **Windows voice typing or a local Whisper tool** can provide capture, but it
  does not supply the reasoning or durable organization layer.

## Notion and Linear

Neither is a better governing store for this task than local Markdown:

- **Notion** is a plausible cloud knowledge UI, but Codex must reach it through
  a remote plugin, connector, or API. Notion's API is rate limited per
  connection and workspace, and the data is no longer simply a user-owned local
  folder. Using Codex through the connector does not require Notion AI, so
  Notion AI's separate fair-use policy is not the relevant limit.
- **Linear** is useful for actionable work, status, and issue tracking. It is
  not designed to hold the full lossless evidence and evolving knowledge record
  for arbitrary activities. Codex for Linear creates Codex cloud chats, while
  local access uses Linear's centrally hosted MCP server. Linear's API has
  request and query-complexity limits.

In both cases, Codex model reasoning still consumes the user's normal
ChatGPT/Codex allowance. The external product adds tool-call limits; it does not
replace or expand the Codex allowance.

Use Notion or Linear later as explicitly requested publication targets:

- publish selected summaries to Notion;
- create selected actionable items in Linear;
- keep the local Markdown vault authoritative.

## Excluded product classes

- Another hosted AI subscription is outside the user's cost boundary.
- Token-billed OpenAI, Anthropic, Gemini, or routing APIs are outside the
  no-pay-as-you-go boundary.
- Notebook and productivity products whose AI or integrations have separate
  hosted allowances fail the no-secondary-quota requirement unless a specific
  local-only configuration is demonstrated.
- A bespoke overlay or app-server client adds implementation and maintenance
  without first proving that foreground capture is inadequate.

## Selected solution

Use **Codex plus optional Obsidian**:

1. Codex is the capture, reasoning, and folder-writing agent.
2. A local skill enforces firsthand-only behavior, capture IDs, checkpointing,
   provenance, and context isolation.
3. The Markdown folder remains authoritative.
4. Obsidian is an optional free local viewer/editor over that same folder, with
   no sync service or AI plugin required.

This is better overall than Codex alone once the vault is large enough to browse
manually. The smallest first version can still begin with Codex alone because
adding Obsidian later requires no migration: open the same folder as a vault.

This selection was approved on `2026-07-26T15:47:41-03:00`.

If the requirement later changes to eliminate hosted inference, trial
**AnythingLLM Desktop with its built-in local model and Whisper** first. Treat
its databases as disposable working indexes and require every durable fact to
be exported or reconciled into the Markdown folder.

Use **Open WebUI plus Ollama or LM Studio** only when its deeper customization,
voice features, or multi-model controls justify running and maintaining a
self-hosted service.

The local-model alternatives remain documented as fallbacks, not selected
first-version dependencies.
