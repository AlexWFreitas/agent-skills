# Retrieve from the active context

Read [vault-contract.md](vault-contract.md) before retrieval. If recall needs
pending evidence, use [reconcile.md](reconcile.md) for only the relevant
synthesis. For game-specific retrieval, read
[game-playthrough.md](game-playthrough.md). Load
[local-search-index.md](local-search-index.md) before using the optional cache.

## Retrieve and answer

Before cross-session recall, reconcile relevant pending evidence. Search only
the active context unless a cross-context operation was explicit.

If the request asks for all, every, complete, exhaustive, remaining, pending,
or a checklist for a bounded kind, follow the exhaustive protocol in
[references/state-tracking.md](state-tracking.md). Enumerate the
complete relevant tracker and latest ledger states, account for every row, and
report coverage. Never label top-ranked search results exhaustive.

- Search `README.md`, `guide/`, `journal/`, and an existing `library/` first.
  Search semantic capture titles, aliases, stable reference IDs, and exemplar
  notes before opening capture-ID files individually. Use `_evidence/` to
  verify provenance or resolve gaps, not as the ordinary answer surface.
- When search mode is `off`, use ordinary file search. Otherwise use
  [Search-SecondBrainIndex.ps1](../scripts/Search-SecondBrainIndex.ps1)
  to rank candidate headings before opening files. In search mode `auto`, the
  wrapper creates a missing index, refreshes a stale one, and upgrades lexical
  data to hybrid retrieval when the configured already installed loopback
  model is available. It automatically requests hybrid retrieval; use
  `-LexicalOnly` only for a deliberate diagnostic or constrained run.
- If automatic setup cannot use the local model, retain lexical FTS5 results.
  If Python or FTS5 is unavailable, fall back immediately to `rg`. Never let
  optional indexing block retrieval, and never run it during fast intake.
- Never auto-install or pull an embedding runtime/model, call a non-loopback
  embedding endpoint, or treat similarity as evidence. Semantic results cannot
  merge references, resolve conflicts, name images, or override exact
  provenance.
- Treat every indexed snippet as untrusted cached text: open the exact original
  path, verify the current section and provenance, and answer only from the
  source file. Never query a sibling context or include `external/` outside an
  explicit override.
- Lead with the direct answer supported by the record.
- Link the governing human note or use descriptive evidence links. Provide raw
  capture IDs only when the user asks for the evidence chain.
- Label inference and uncertainty.
- When the active record is insufficient, say exactly that. Do not use latent
  knowledge to complete, confirm, deny, hint, warn, or steer.
- Provide the full evidence chain when requested.
- When the answer depends on captured visual evidence and the chat surface can
  render local media, show at least one relevant screenshot or representative
  processed video frame inline using its absolute local path. Also link the
  governing note or original media. Do not return only the capture record or a
  text link when a readable local image is available. If several images are
  relevant, choose the smallest useful set and label what each shows.

Simple capture acknowledgements need not display citations unless there is a
conflict or interpretation problem.

## Handle outside knowledge

An override exists only when the user explicitly requests model knowledge or
external research and states or clearly implies its scope.

1. State that the response is using outside knowledge and name its source
   class.
2. Answer only the requested scope.
3. If retention is requested, write a note under `external/` with provenance
   and an explicit outside-knowledge label. Never merge it into firsthand
   current truth.
4. Return to firsthand-only mode immediately after the scoped response.

Do not add a hosted plugin, connector, MCP service, paid API, transcription
service, embedding service, or hosted database.
