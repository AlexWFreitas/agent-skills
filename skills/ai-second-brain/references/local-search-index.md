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
module with FTS5.
No hosted service, API key, embedding model, vector extension, or third-party
Python package is required. If Python or FTS5 is unavailable, continue with
`rg` and direct file reads; the missing index is never a capture or retrieval
blocker.

Keep one database per context at:

```text
<vault>/.index/ai-second-brain/<collection>--<context>.sqlite
```

Add `/.index/` to the vault's `.gitignore` when the vault is versioned. The
index is generated output, not evidence. Never place it under a context's
`_evidence/`, `library/`, attachments, or human notebook.

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

Do not rebuild during fast intake. Refresh an existing index after an explicit
checkpoint or immediately before indexed retrieval when the query reports that
the database is stale.

## Search

Use natural terms by default:

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

## Staleness and fallback

The index stores a context-tree fingerprint and each document's SHA-256. Every
query checks the current tree fingerprint and verifies returned files against
their indexed hash.

- If `IndexStale` is true, rebuild before relying on completeness.
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

This first implementation is lexical FTS5 search only. Do not add embeddings,
visual vectors, or a vector database unless a measured query suite shows that
heading-aware full-text retrieval materially misses important synonym or
description-based evidence.
