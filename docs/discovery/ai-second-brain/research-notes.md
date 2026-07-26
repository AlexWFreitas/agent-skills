# Research Notes: Provider Limits, Local Inference, and Product Options

Last verified: `2026-07-26T16:25:46-03:00`

Purpose: establish whether a cloud-hosted model can credibly guarantee
unlimited use for the AI second brain. These are current provider facts, not a
provider selection.

## Verified evidence

| Source | Supported claim | Evidence class | Freshness or limitation |
| --- | --- | --- | --- |
| [OpenAI API rate limits](https://developers.openai.com/api/docs/guides/rate-limits#usage-tiers) | OpenAI applies request/token rate limits and monthly usage limits by usage tier; higher spend generally raises the tier rather than removing limits. | `verified` | Fetched from official OpenAI developer documentation on 2026-07-26. Actual limits depend on the organization, project, tier, and model. |
| [Anthropic API rate limits](https://platform.claude.com/docs/en/api/rate-limits) | Anthropic enforces organization-level spend and rate limits, returns `429` when limits are exceeded, and describes published limits as maximums rather than guaranteed minimum capacity. | `verified` | Fetched from official Claude Platform documentation on 2026-07-26. Account-specific and custom-tier terms can differ. |
| [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits) | Gemini evaluates requests against rate dimensions such as requests and tokens per minute; limits depend on model and usage tier, and documented capacity is not guaranteed. | `verified` | Fetched from official Google AI documentation on 2026-07-26. Active project limits are shown in AI Studio and can change. |
| [Ollama FAQ](https://docs.ollama.com/faq#how-do-i-disable-ollamas-cloud-features) | Ollama can run in local-only mode with cloud features disabled, so inference is not subject to a hosted model provider's account quota. | `verified` | Fetched from official Ollama documentation on 2026-07-26. Throughput, context, model quality, and concurrency remain bounded by local hardware and software. |
| [OpenAI Codex pricing and plan limits](https://learn.chatgpt.com/docs/pricing#usage-limits) | ChatGPT Pro supports Codex through local clients and scripted workflows, but Pro is offered with 5x or 20x higher limits than Plus. Local messages use a shared five-hour usage window and additional weekly limits may apply. API-key use is separately usage-priced. | `verified` | Fetched through the official OpenAI documentation service on 2026-07-26. The user's exact Pro tier and live account allowance were not inspected. |
| [ChatGPT Voice in Desktop](https://learn.chatgpt.com/docs/pricing#chatgpt-voice-in-desktop) | Desktop voice has a plan-dependent allowance; even unlimited voice on the highest Pro tier does not make Codex task work unlimited because tasks consume the Codex usage budget. | `verified` | Fetched through the official OpenAI documentation service on 2026-07-26. Plan entitlements may change. |
| [OpenAI plugin overview](https://learn.chatgpt.com/docs/plugins) | A skill is reusable instructions plus optional references or helper scripts, whereas connectors and MCP servers can call external systems with their own authentication and service terms. | `verified` | Fetched through the official OpenAI documentation service on 2026-07-26. A particular plugin still requires dependency-by-dependency inspection. |
| [OpenAI Codex glossary](https://learn.chatgpt.com/docs/glossary) | Codex app-server is a local JSON-RPC server for custom clients; a stdio MCP server is launched as a local process. These mechanisms can be implemented without a separately hosted service. | `verified` | Fetched through the official OpenAI documentation service on 2026-07-26. Local operation does not eliminate ChatGPT Pro model usage or local hardware/software limits. |
| [Codex voice dictation](https://learn.chatgpt.com/docs/prompting#use-voice-dictation) | In the ChatGPT desktop app, holding `Ctrl+M` while the composer is visible records speech and transcribes it into editable prompt text. | `verified` | Fetched through the official OpenAI documentation service on 2026-07-26. This is foreground dictation, not an arbitrary global push-to-talk capture API. |
| [How Obsidian stores data](https://obsidian.md/help/Files%2Band%2Bfolders/How%2BObsidian%2Bstores%2Bdata) | Obsidian stores notes as Markdown plain-text files in a local folder and refreshes when files are changed externally. | `verified` | Fetched from official Obsidian documentation on 2026-07-26. Obsidian is a storage and editing companion, not the reasoning engine. |
| [Obsidian pricing](https://obsidian.md/pricing) | The core app is free without limits; Sync and Publish are optional paid services. Local-only use does not add a hosted quota. | `verified` | Fetched from the official Obsidian site on 2026-07-26. Optional services and community plugins require separate evaluation. |
| [LM Studio offline operation](https://www.lmstudio.ai/docs/app/offline) | After models are downloaded, local chat, document use, and the local server can operate offline without sending data from the device. | `verified` | Fetched from official LM Studio documentation on 2026-07-26. Capability and speed depend on the chosen model and PC hardware. |
| [LM Studio system requirements](https://lmstudio.ai/docs/app/system-requirements) | Windows is supported; 16 GB RAM and at least 4 GB of dedicated VRAM are recommended, with AVX2 required on x64. | `verified` | Fetched from official LM Studio documentation on 2026-07-26. The user's hardware has not yet been inspected. |
| [AnythingLLM Desktop overview](https://docs.anythingllm.com/installation-desktop/overview) | AnythingLLM Desktop is a one-click local app for local LLMs, RAG, agents, private documents, and Whisper support on Windows. | `verified` | Fetched from official AnythingLLM documentation on 2026-07-26. Its optional Pro and cloud features are outside the required local path. |
| [AnythingLLM Desktop storage](https://docs.anythingllm.com/installation-desktop/storage) | On Windows, AnythingLLM stores its state under AppData using SQLite, LanceDB, parsed documents, embeddings, model files, and plugin data. | `verified` | Fetched from official AnythingLLM documentation on 2026-07-26. This makes the product's native store less transparent and portable than a Markdown-authoritative vault. |
| [AnythingLLM local transcription](https://docs.anythingllm.com/setup/transcription-model-configuration/local/built-in) | AnythingLLM ships with a local Whisper transcription model that downloads on first use. | `verified` | Fetched from official AnythingLLM documentation on 2026-07-26. Local processing can stall constrained PCs, and the docs recommend media files under 10 MB. |
| [Open WebUI overview](https://docs.openwebui.com/) | Open WebUI is a self-hosted platform that can run entirely offline and connect to local Ollama or OpenAI-compatible model servers. | `verified` | Fetched from official Open WebUI documentation on 2026-07-26. Setup and ongoing administration are greater than for a native desktop app. |
| [Open WebUI features](https://docs.openwebui.com/features/) | Open WebUI supports files and images, voice/audio, folders and tags, memory, knowledge/RAG, notes, tools, MCP, and model presets. | `verified` | Fetched from official Open WebUI documentation on 2026-07-26. Some optional integrations are cloud-backed and would have to remain disabled. |
| [Notion API request limits](https://developers.notion.com/reference/request-limits) | The Notion API is rate limited per connection and per workspace. The published per-connection rate is an average of three requests per second; workspace capacity is shared and plan-scaled. | `verified` | Fetched from official Notion developer documentation on 2026-07-26. These are API/tool-call limits, not Codex model-call allowances. |
| [Codex for Linear](https://learn.chatgpt.com/docs/third-party/linear) | Assigning or mentioning Codex in Linear creates a Codex cloud chat. Local Codex access can instead use Linear's hosted MCP server. | `verified` | Fetched through the official OpenAI documentation service on 2026-07-26. The page does not publish a separate Linear-specific allowance for Codex model calls. |
| [Linear API rate limits](https://linear.app/developers/rate-limiting) | Linear applies request, endpoint-specific, and query-complexity limits. The current table publishes 5,000 OAuth requests per user or app user per hour. | `verified` | Fetched from official Linear developer documentation on 2026-07-26. The same page contains inconsistent prose for API-key request counts, so only the OAuth table is used here. |
| [Linear MCP server](https://linear.app/docs/mcp) | Linear's MCP endpoint is centrally hosted and managed and supports Codex through authenticated remote MCP. | `verified` | Fetched from official Linear documentation on 2026-07-26. No separate MCP-specific usage allowance was documented on the reviewed page; underlying service and API limits still apply. |
| [Codex developer commands](https://learn.chatgpt.com/docs/developer-commands#command-overview) | Codex supports prompt and image attachments. | `verified` | Fetched through the official OpenAI documentation service on 2026-07-26. The reviewed documentation does not establish that every desktop image attachment is exposed as a copyable local path; durable copying therefore remains an implementation verification gate with a save-first fallback. |

## Implementation consequences

- A literal guarantee of unlimited, immediate cloud inference is not a sound
  requirement for a consumer or standard pay-as-you-go hosted service.
- Uninterrupted **capture** is achievable independently: write each input to a
  durable local inbox before attempting transcription, vision analysis, or
  model organization.
- High-limit pay-as-you-go cloud APIs can make throttling unlikely for ordinary
  personal play, but the harness still needs explicit retry/backoff and visible
  pending state.
- If immediate AI responses must continue during provider throttling or outage,
  the architecture needs a local inference fallback or another independently
  limited provider. Multiple cloud providers reduce correlated interruption but
  do not create a true no-limit guarantee.
- The user's ChatGPT Pro subscription makes ChatGPT desktop/Codex the only
  currently evidenced cloud-model route inside the stated cost ceiling.
  Ordinary OpenAI API calls remain out of scope because they are usage-priced.
- Codex is a viable harness candidate because the Pro plan includes local
  clients and scriptable workflows, but the architecture cannot treat its model
  capacity as unlimited.
- A locally authored skill and direct filesystem access add no independent
  service quota. A hosted connector or MCP dependency can add one and must be
  excluded unless individually shown to have no relevant allowance.
- A custom Windows companion can be built over Codex app-server without buying
  another hosted AI service, but it adds significantly more implementation and
  maintenance than using the ChatGPT/Codex desktop interface directly.
- Selecting a viable local multimodal fallback requires the Windows PC's
  hardware profile and an acceptable quality/latency threshold.
- Obsidian can improve browsing and manual editing without becoming a second
  AI dependency: Codex and Obsidian can operate on the same Markdown folder.
- AnythingLLM Desktop and Open WebUI provide more built-in second-brain
  features, but their native workspace state is more application-managed than
  the settled Markdown-authoritative design.
- A fully local product removes hosted inference quotas, but does not remove
  limits: context size, throughput, memory, vision support, and answer quality
  become functions of the local model and hardware.
- Obsidian does not create an additional AI or API quota when Codex edits the
  vault files directly. Notion and Linear do create external service boundaries
  and should not be the sole authoritative store under the user's constraint.
- Notion AI or Linear's own AI features are separate from using Codex to read or
  write those products. Their AI plan limits should not be conflated with their
  connector or API rate limits.
