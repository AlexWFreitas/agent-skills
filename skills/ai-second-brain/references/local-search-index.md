# Local FTS5 Search Index

Use this reference only when building, refreshing, querying, validating, or
removing the optional local search index. Ordinary fast intake does not load or
update the index.

## Authority and purpose

Markdown and local media remain authoritative. The SQLite database is a
disposable retrieval cache that may be deleted and rebuilt at any time. Never
write a fact, correction, relationship, interpretation, or provenance record
only to the index, and never repair source notes by editing SQLite.

The index improves candidate ranking and snippets; it does not replace direct
file reads. After every query, open the original returned Markdown sections and
verify the answer there before responding.

## Runtime and location

The optional helpers use Python 3.10 or later and its standard-library `sqlite3`
module with FTS5. Lexical indexing requires no hosted service, API key,
embedding model, vector extension, or third-party Python package. If Python or
FTS5 is unavailable, continue with `rg` and direct file reads; the missing index
is never a capture or retrieval blocker.

Search mode `auto` prefers semantic indexing when the configured Ollama model
is already installed and responding locally. It calls that model through a
loopback-only `http://127.0.0.1`, `localhost`, or `::1` `/api/embed` endpoint.
The helper rejects credentials, non-loopback hosts, HTTPS/remote endpoints,
alternate paths, and redirects. Automatic setup never installs, pulls, repairs,
or starts Ollama or an embedding model; those actions still require explicit
authorization.

Keep one database per context at:

```text
<vault>/.index/ai-second-brain/<collection>--<context>.sqlite
```

Automatic setup adds `/.index/` to the vault's `.gitignore` without rewriting
existing bytes. The index is generated output, not evidence. Never place it
under a context's `_evidence/`, `library/`, attachments, or human notebook.

The initializer records the following preferences in `_evidence/state.md`:

```text
Search mode: `auto`
Embedding model: `embeddinggemma`
Embedding endpoint: `http://127.0.0.1:11434`
```

Supported modes are `auto`, `off`, `lexical`, and `hybrid`. `auto` is the
portable default: use hybrid search when the configured already installed
model is available, otherwise use lexical FTS5, otherwise use ordinary file
search. The endpoint is persisted so a non-default authorized loopback port
continues to work in later tasks. `off` disables automatic creation and refresh
but does not make an already generated database authoritative. Legacy contexts
without these fields
also resolve to `auto` and `embeddinggemma` unless the caller supplies an
override.

## Indexed material

The builder indexes Markdown one heading-aligned section per row. It records
the context-relative path, source tier, note kind, capture ID, title, aliases,
heading path, body, and source hash.

Default scope includes the selected context's human notebook and textual
evidence. `external/` is absent by default. The builder also excludes:

- sibling contexts and collections;
- `external/` outside-knowledge notes;
- attachments and other binary media;
- media-processing and visual-exemplar derivatives;
- migration-preserved legacy synthesis duplicates;
- `.git/` and `.index/`.

Use `-HumanOnly` only when raw captures and interpretations are intentionally
out of retrieval scope. Include `external/` only during an explicit
outside-knowledge override, and pass `-IncludeExternal` separately to both the
build and query helpers. A normal firsthand-only search must never return
external rows even when an older index happens to contain them.

## Build or refresh

For ordinary operation, ensure the active context automatically:

```powershell
scripts/Ensure-SecondBrainSearchIndex.ps1 `
  -VaultPath 'D:\Work\Vaults' `
  -CollectionSlug 'oracle-of-ages' `
  -ContextSlug 'main' `
  -ForceRebuild
```

The ensure helper reads mode and model from `_evidence/state.md` unless the
caller supplies an override. In `auto`, it probes only the configured loopback
Ollama endpoint. It
builds hybrid when the configured model is listed, falls back to lexical FTS5
when Ollama or the model is unavailable, and reports ordinary-file fallback
when Python/FTS5 is unavailable. It never downloads a dependency. Call it after
initialization, after a completed checkpoint, or through the search wrapper's
automatic refresh—not during fast intake.

Preview the bounded output path:

```powershell
scripts/Build-SecondBrainSearchIndex.ps1 `
  -VaultPath 'D:\Work\Vaults' `
  -CollectionSlug 'oracle-of-ages' `
  -ContextSlug 'main' `
  -WhatIf
```

Build after the preview or refresh an existing index:

```powershell
scripts/Build-SecondBrainSearchIndex.ps1 `
  -VaultPath 'D:\Work\Vaults' `
  -CollectionSlug 'oracle-of-ages' `
  -ContextSlug 'main' `
  -Confirm:$false
```

The builder creates a complete database beside the target and atomically
replaces the old index only after the new build succeeds. It never incrementally
patches an uncertain index. Capture, interpretation, media, ledger, and human
note bytes remain unchanged.

To include local text embeddings, name a model that is already installed in
Ollama:

```powershell
scripts/Build-SecondBrainSearchIndex.ps1 `
  -VaultPath 'D:\Work\Vaults' `
  -CollectionSlug 'oracle-of-ages' `
  -ContextSlug 'main' `
  -Semantic `
  -EmbeddingModel '<installed-embedding-model>' `
  -Confirm:$false
```

The model name, loopback endpoint, vector dimension, and semantic row count are
recorded as disposable index metadata. Every heading-aligned FTS5 row receives
one normalized vector stored as an ordinary SQLite BLOB. The current corpus is
small enough for exact cosine comparison; no vector extension or approximate
nearest-neighbor index is used.

The same embedding model must serve both build and query operations. Changing
the model requires a full rebuild. If any embedding batch fails, the temporary
database is discarded and the prior completed index remains intact.

Do not rebuild during fast intake. Initialization bootstraps the first index.
The search wrapper automatically creates a missing index, refreshes a stale
one, and upgrades a current lexical index when automatic semantic retrieval is
requested and the configured model has become available. A completed
checkpoint calls the ensure helper with `-ForceRebuild`.

## Search

Use natural terms by default. A context in `auto` or `hybrid` mode requests
hybrid retrieval without needing a separate switch:

```powershell
$search = scripts/Search-SecondBrainIndex.ps1 `
  -VaultPath 'D:\Work\Vaults' `
  -CollectionSlug 'oracle-of-ages' `
  -ContextSlug 'main' `
  -Query 'soil plot used to plant Gasha Seeds' `
  -Limit 10

$search.Results
```

The natural-query path removes ordinary question words, tries an AND query,
then falls back to OR when the strict query has no result. Use `-RawQuery` only
for deliberate FTS5 syntax such as phrases, prefixes, boolean operators, or
NEAR expressions.

Each result contains a rank, BM25 score, absolute and relative paths, source
tier, note kind, capture ID, title, heading, snippet, and source-staleness
flags. Treat results as candidates, not answers.

`-Semantic` remains an explicit compatibility override for a context configured
as `lexical`. Use `-LexicalOnly` to suppress semantic retrieval for one
diagnostic query:

```powershell
$search = scripts/Search-SecondBrainIndex.ps1 `
  -VaultPath 'D:\Work\Vaults' `
  -Query 'the soil patch where random reward seeds grow' `
  -LexicalOnly `
  -Limit 10
```

Hybrid mode always runs lexical FTS5 and then attempts semantic retrieval. It
uses exact cosine similarity over the stored vectors and reciprocal-rank fusion
to merge lexical and semantic candidate ranks. Results expose lexical rank,
semantic rank, cosine similarity, fused score, and which retrieval modes found
the section.

If the local embedding endpoint, model, or semantic table is unavailable, the
query returns the lexical FTS5 results plus a semantic error. The wrapper warns
about the degradation but does not fail an otherwise valid lexical retrieval.

## Staleness and fallback

The index stores a context-tree fingerprint and each document's SHA-256. Every
query checks the current tree fingerprint and verifies returned files against
their indexed hash.

- By default, the search wrapper rebuilds a stale index atomically and reruns
  the query before returning. `-NoAutoRefresh` exposes stale state for
  diagnostics without rebuilding.
- If a result has `SourceStale` or its file is missing, ignore its cached
  snippet and read current files directly.
- If rebuilding is unavailable or disproportionate, use `rg`; never answer
  from stale SQLite content merely because it ranked well.

Rebuilding is the only repair operation. Deleting the `.sqlite` file is always
safe because it contains no authoritative knowledge.

## Retrieval boundary

The Python engine verifies that the database metadata belongs to the exact
vault collection/context selected by the PowerShell wrapper. The wrapper also
restricts index paths to the vault's `.index/ai-second-brain/` directory. Do
not bypass either check or combine contexts into one database.

Semantic similarity is retrieval metadata, not evidence. It must not merge
visual references, resolve conflicts, identify an object, promote an inference,
or add a fact. Open and verify original files exactly as with lexical results.

This implementation embeds text only. It does not compare screenshot pixels or
create visual vectors. Keep visual recognition grounded in the curated visual
library unless a separately measured and authorized visual-similarity feature
is added later.
