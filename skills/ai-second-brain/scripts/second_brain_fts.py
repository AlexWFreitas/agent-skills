#!/usr/bin/env python3
"""Build and query a disposable SQLite FTS5 index for one second-brain context."""

from __future__ import annotations

import argparse
from datetime import datetime
import hashlib
import json
import math
import os
from pathlib import Path
import re
import sqlite3
import struct
import sys
import tempfile
from typing import Any, Iterable
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse, urlunparse
from urllib.request import build_opener, HTTPRedirectHandler, Request


SCHEMA_VERSION = "1"
SKIPPED_DIRECTORIES = {
    ".git",
    ".index",
    "attachments",
    "media-processing",
    "visual-exemplars",
    "legacy-synthesis",
}
STOP_WORDS = {
    "a",
    "an",
    "and",
    "are",
    "as",
    "at",
    "be",
    "did",
    "do",
    "does",
    "for",
    "from",
    "how",
    "i",
    "in",
    "is",
    "it",
    "me",
    "my",
    "of",
    "on",
    "or",
    "show",
    "that",
    "the",
    "this",
    "to",
    "was",
    "were",
    "what",
    "when",
    "where",
    "which",
    "with",
}


def _json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def _resolve_context(vault: str, collection: str, context: str) -> tuple[Path, Path]:
    vault_root = Path(vault).expanduser().resolve()
    if not (vault_root / "second-brain.md").is_file():
        raise ValueError(f"Not an initialized second-brain vault: {vault_root}")
    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", collection):
        raise ValueError(f"Invalid collection slug: {collection}")
    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", context):
        raise ValueError(f"Invalid context slug: {context}")
    context_root = (vault_root / "collections" / collection / "contexts" / context).resolve()
    try:
        context_root.relative_to(vault_root)
    except ValueError as exc:
        raise ValueError("Resolved context escapes the vault root") from exc
    if not context_root.is_dir():
        raise ValueError(f"Selected context does not exist: {context_root}")
    return vault_root, context_root


def _iter_markdown_files(
    context_root: Path,
    include_evidence: bool,
    include_external: bool,
) -> Iterable[Path]:
    for directory, child_directories, files in os.walk(context_root, followlinks=False):
        current = Path(directory)
        relative_directory = current.relative_to(context_root)
        filtered: list[str] = []
        for name in child_directories:
            candidate_parts = relative_directory.parts + (name,)
            if name in SKIPPED_DIRECTORIES:
                continue
            if not include_evidence and candidate_parts and candidate_parts[0] in {"_evidence", "inbox"}:
                continue
            if not include_external and candidate_parts and candidate_parts[0] == "external":
                continue
            candidate = current / name
            if candidate.is_symlink():
                continue
            filtered.append(name)
        child_directories[:] = filtered
        for name in files:
            if not name.lower().endswith(".md"):
                continue
            path = current / name
            if path.is_symlink():
                continue
            relative = path.relative_to(context_root)
            if not include_evidence and relative.parts[0] in {"_evidence", "inbox"}:
                continue
            if not include_external and relative.parts[0] == "external":
                continue
            yield path


def _tree_fingerprint(files: Iterable[Path], context_root: Path) -> str:
    digest = hashlib.sha256()
    for path in sorted(files, key=lambda item: item.as_posix().lower()):
        stat = path.stat()
        relative = path.relative_to(context_root).as_posix()
        digest.update(f"{relative}|{stat.st_size}|{stat.st_mtime_ns}\n".encode("utf-8"))
    return digest.hexdigest()


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig", errors="replace")


def _parse_frontmatter(text: str) -> tuple[dict[str, str], str]:
    normalized = text.replace("\r\n", "\n")
    if not normalized.startswith("---\n"):
        return {}, normalized
    end = normalized.find("\n---\n", 4)
    if end < 0:
        return {}, normalized
    values: dict[str, str] = {}
    for line in normalized[4:end].splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        values[key.strip()] = value.strip()
    return values, normalized[end + 5 :]


def _decode_frontmatter_value(value: str | None) -> Any:
    if value is None:
        return None
    try:
        return json.loads(value)
    except (json.JSONDecodeError, TypeError):
        return value.strip().strip('"').strip("'")


def _as_search_text(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, list):
        return " ".join(str(item) for item in value)
    return str(value)


def _first_heading(body: str) -> str:
    match = re.search(r"(?m)^#\s+(.+?)\s*$", body)
    return match.group(1).strip() if match else ""


def _classify(relative: Path) -> tuple[str, str]:
    parts = relative.parts
    if not parts:
        return "human", "note"
    if parts[0] in {"_evidence", "inbox"}:
        kind = "evidence-note"
        if "captures" in parts:
            kind = "capture"
        elif "interpretations" in parts:
            kind = "interpretation"
        elif relative.name == "state.md":
            kind = "state"
        return "evidence", kind
    if parts[0] == "external":
        return "external", "external-note"
    if parts[0] == "guide":
        return "human", "guide"
    if parts[0] == "journal":
        return "human", "journal"
    if parts[0] == "trackers":
        return "human", "state-tracker"
    if parts[0] == "library" and len(parts) > 1 and parts[1] == "references":
        return "human", "visual-reference"
    if parts[0] == "library" and len(parts) > 1 and parts[1] == "captures":
        return "human", "media-descriptor"
    if relative.name.lower() == "readme.md":
        return "human", "home"
    if relative.name.lower() == "open-questions.md":
        return "human", "open-questions"
    return "human", "note"


def _sections(body: str, fallback_title: str) -> list[tuple[str, str]]:
    lines = body.replace("\r\n", "\n").splitlines()
    stack: list[str] = []
    current_heading = fallback_title
    current_body: list[str] = []
    output: list[tuple[str, str]] = []

    def flush() -> None:
        text = "\n".join(current_body).strip()
        if text or current_heading:
            output.append((current_heading, text))

    for line in lines:
        match = re.match(r"^(#{1,6})\s+(.+?)\s*$", line)
        if not match:
            current_body.append(line)
            continue
        flush()
        level = len(match.group(1))
        heading = match.group(2).strip()
        del stack[level - 1 :]
        while len(stack) < level - 1:
            stack.append("")
        stack.append(heading)
        current_heading = " > ".join(item for item in stack if item)
        current_body = []
    flush()
    return output or [(fallback_title, body.strip())]


def _document(path: Path, context_root: Path) -> dict[str, Any]:
    raw = path.read_bytes()
    text = raw.decode("utf-8-sig", errors="replace")
    frontmatter, body = _parse_frontmatter(text)
    relative = path.relative_to(context_root)
    source_tier, kind = _classify(relative)
    display_title = _decode_frontmatter_value(frontmatter.get("display_title"))
    preferred_name = _decode_frontmatter_value(frontmatter.get("preferred_name"))
    title = str(display_title or preferred_name or _first_heading(body) or path.stem)
    aliases = " ".join(
        filter(
            None,
            (
                _as_search_text(_decode_frontmatter_value(frontmatter.get("aliases"))),
                _as_search_text(_decode_frontmatter_value(frontmatter.get("keywords"))),
                _as_search_text(_decode_frontmatter_value(frontmatter.get("search_keywords"))),
                _as_search_text(_decode_frontmatter_value(frontmatter.get("reference_ids"))),
            ),
        )
    )
    capture_value = _decode_frontmatter_value(frontmatter.get("capture_id"))
    capture_match = re.search(r"CAP-[A-Za-z0-9-]+", path.name)
    capture_id = str(capture_value or (capture_match.group(0) if capture_match else ""))
    return {
        "relative_path": relative.as_posix(),
        "source_tier": source_tier,
        "kind": kind,
        "capture_id": capture_id,
        "content_hash": hashlib.sha256(raw).hexdigest(),
        "title": title,
        "aliases": aliases,
        "sections": _sections(body, title),
    }


def _metadata(connection: sqlite3.Connection) -> dict[str, str]:
    try:
        return dict(connection.execute("SELECT key, value FROM index_metadata"))
    except sqlite3.DatabaseError as exc:
        raise ValueError("Search index is missing compatible metadata") from exc


class _NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):  # type: ignore[no-untyped-def]
        raise HTTPError(req.full_url, code, "Embedding endpoint redirects are disabled", headers, fp)


def _ollama_embed_url(endpoint: str) -> str:
    parsed = urlparse(endpoint)
    if parsed.scheme.lower() != "http":
        raise ValueError("EmbeddingEndpoint must use http on a loopback host")
    if parsed.username or parsed.password:
        raise ValueError("EmbeddingEndpoint must not contain credentials")
    if (parsed.hostname or "").lower() not in {"127.0.0.1", "localhost", "::1"}:
        raise ValueError("EmbeddingEndpoint must use 127.0.0.1, localhost, or ::1")
    path = parsed.path.rstrip("/")
    if not path:
        path = "/api/embed"
    elif path != "/api/embed":
        raise ValueError("EmbeddingEndpoint path must be empty or /api/embed")
    return urlunparse((parsed.scheme, parsed.netloc, path, "", "", ""))


def _normalize_vector(values: Any) -> list[float]:
    if not isinstance(values, list) or not values:
        raise ValueError("Embedding endpoint returned an empty or invalid vector")
    vector = [float(value) for value in values]
    if not all(math.isfinite(value) for value in vector):
        raise ValueError("Embedding endpoint returned a non-finite vector")
    norm = math.sqrt(sum(value * value for value in vector))
    if norm <= 0:
        raise ValueError("Embedding endpoint returned a zero-length vector")
    return [value / norm for value in vector]


def _embed_ollama(
    endpoint: str,
    model: str,
    inputs: list[str],
    timeout_seconds: int,
) -> list[list[float]]:
    if not model.strip():
        raise ValueError("EmbeddingModel is required for semantic indexing")
    url = _ollama_embed_url(endpoint)
    request = Request(
        url,
        data=_json({"model": model, "input": inputs, "truncate": True}).encode("utf-8"),
        headers={"Content-Type": "application/json", "Accept": "application/json"},
        method="POST",
    )
    opener = build_opener(_NoRedirect())
    try:
        with opener.open(request, timeout=timeout_seconds) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except (HTTPError, URLError, TimeoutError, json.JSONDecodeError) as exc:
        raise RuntimeError(f"Local Ollama embedding request failed: {exc}") from exc
    embeddings = payload.get("embeddings") if isinstance(payload, dict) else None
    if not isinstance(embeddings, list) or len(embeddings) != len(inputs):
        raise ValueError("Embedding endpoint returned the wrong number of vectors")
    normalized = [_normalize_vector(vector) for vector in embeddings]
    dimensions = {len(vector) for vector in normalized}
    if len(dimensions) != 1:
        raise ValueError("Embedding endpoint returned inconsistent vector dimensions")
    return normalized


def _pack_vector(vector: list[float]) -> bytes:
    return struct.pack(f"<{len(vector)}f", *vector)


def _unpack_vector(blob: bytes, dimension: int) -> tuple[float, ...]:
    expected = dimension * 4
    if len(blob) != expected:
        raise ValueError("Stored embedding byte length does not match its dimension")
    return struct.unpack(f"<{dimension}f", blob)


def _embedding_text(
    title: str,
    aliases: str,
    heading: str,
    body: str,
    maximum_characters: int,
) -> str:
    combined = "\n".join(filter(None, (title, aliases, heading, body))).strip()
    if len(combined) <= maximum_characters:
        return combined
    return combined[:maximum_characters]


def build(args: argparse.Namespace) -> dict[str, Any]:
    _, context_root = _resolve_context(args.vault, args.collection, args.context)
    if args.semantic and not args.embedding_model:
        raise ValueError("EmbeddingModel is required when semantic indexing is enabled")
    if not 1 <= args.embedding_batch_size <= 128:
        raise ValueError("EmbeddingBatchSize must be between 1 and 128")
    if not 1 <= args.embedding_timeout_seconds <= 600:
        raise ValueError("EmbeddingTimeoutSeconds must be between 1 and 600")
    if not 1000 <= args.embedding_max_characters <= 50000:
        raise ValueError("EmbeddingMaxCharacters must be between 1000 and 50000")
    embedding_endpoint = (
        _ollama_embed_url(args.embedding_endpoint) if args.semantic else ""
    )
    index_path = Path(args.index).expanduser().resolve()
    files = list(
        _iter_markdown_files(
            context_root,
            include_evidence=not args.exclude_evidence,
            include_external=args.include_external,
        )
    )
    fingerprint = _tree_fingerprint(files, context_root)
    index_path.parent.mkdir(parents=True, exist_ok=True)
    handle, temporary_name = tempfile.mkstemp(
        prefix=f".{index_path.name}.", suffix=".tmp", dir=str(index_path.parent)
    )
    os.close(handle)
    temporary_path = Path(temporary_name)
    section_count = 0
    semantic_section_count = 0
    embedding_dimension = 0
    try:
        connection = sqlite3.connect(str(temporary_path))
        try:
            connection.execute("PRAGMA journal_mode=OFF")
            connection.execute("PRAGMA synchronous=OFF")
            connection.execute(
                "CREATE TABLE index_metadata(key TEXT PRIMARY KEY, value TEXT NOT NULL)"
            )
            try:
                connection.execute(
                    """
                    CREATE VIRTUAL TABLE search_sections USING fts5(
                        relative_path UNINDEXED,
                        source_tier UNINDEXED,
                        kind UNINDEXED,
                        capture_id UNINDEXED,
                        content_hash UNINDEXED,
                        title,
                        aliases,
                        heading,
                        body,
                        tokenize='unicode61 remove_diacritics 2',
                        prefix='2 3 4'
                    )
                    """
                )
            except sqlite3.OperationalError as exc:
                raise RuntimeError("This Python SQLite build does not provide FTS5") from exc
            embedding_rows: list[tuple[int, str]] = []
            for path in files:
                document = _document(path, context_root)
                for heading, section_body in document["sections"]:
                    cursor = connection.execute(
                        """
                        INSERT INTO search_sections(
                            relative_path, source_tier, kind, capture_id,
                            content_hash, title, aliases, heading, body
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        (
                            document["relative_path"],
                            document["source_tier"],
                            document["kind"],
                            document["capture_id"],
                            document["content_hash"],
                            document["title"],
                            document["aliases"],
                            heading,
                            section_body,
                        ),
                    )
                    if args.semantic:
                        embedding_rows.append(
                            (
                                int(cursor.lastrowid),
                                _embedding_text(
                                    document["title"],
                                    document["aliases"],
                                    heading,
                                    section_body,
                                    args.embedding_max_characters,
                                ),
                            )
                        )
                    section_count += 1
            if args.semantic:
                connection.execute(
                    """
                    CREATE TABLE semantic_embeddings(
                        rowid INTEGER PRIMARY KEY,
                        dimension INTEGER NOT NULL,
                        vector BLOB NOT NULL
                    )
                    """
                )
                for offset in range(0, len(embedding_rows), args.embedding_batch_size):
                    batch = embedding_rows[offset : offset + args.embedding_batch_size]
                    vectors = _embed_ollama(
                        embedding_endpoint,
                        args.embedding_model,
                        [text for _, text in batch],
                        args.embedding_timeout_seconds,
                    )
                    for (rowid, _), vector in zip(batch, vectors):
                        if embedding_dimension == 0:
                            embedding_dimension = len(vector)
                        elif len(vector) != embedding_dimension:
                            raise ValueError(
                                "Embedding dimension changed during one index build"
                            )
                        connection.execute(
                            "INSERT INTO semantic_embeddings(rowid, dimension, vector) VALUES (?, ?, ?)",
                            (rowid, embedding_dimension, _pack_vector(vector)),
                        )
                        semantic_section_count += 1
            generated_at = datetime.now().astimezone().isoformat()
            metadata = {
                "schema_version": SCHEMA_VERSION,
                "generated_at": generated_at,
                "context_root": str(context_root),
                "collection": args.collection,
                "context": args.context,
                "include_evidence": str(not args.exclude_evidence).lower(),
                "include_external": str(args.include_external).lower(),
                "file_count": str(len(files)),
                "section_count": str(section_count),
                "tree_fingerprint": fingerprint,
                "sqlite_version": sqlite3.sqlite_version,
                "semantic_enabled": str(args.semantic).lower(),
                "embedding_provider": args.embedding_provider if args.semantic else "",
                "embedding_model": args.embedding_model if args.semantic else "",
                "embedding_endpoint": embedding_endpoint,
                "embedding_dimension": str(embedding_dimension),
                "semantic_section_count": str(semantic_section_count),
            }
            connection.executemany(
                "INSERT INTO index_metadata(key, value) VALUES (?, ?)", metadata.items()
            )
            connection.commit()
        finally:
            connection.close()
        os.replace(temporary_path, index_path)
    finally:
        if temporary_path.exists():
            temporary_path.unlink()
    return {
        "state": "built",
        "index_path": str(index_path),
        "context_root": str(context_root),
        "collection": args.collection,
        "context": args.context,
        "files": len(files),
        "sections": section_count,
        "tree_fingerprint": fingerprint,
        "sqlite_version": sqlite3.sqlite_version,
        "include_evidence": not args.exclude_evidence,
        "include_external": args.include_external,
        "semantic_enabled": args.semantic,
        "embedding_provider": args.embedding_provider if args.semantic else None,
        "embedding_model": args.embedding_model if args.semantic else None,
        "embedding_endpoint": embedding_endpoint or None,
        "embedding_dimension": embedding_dimension,
        "semantic_sections": semantic_section_count,
    }


def _natural_fts_query(query: str) -> tuple[str, str | None]:
    phrases = [match.strip() for match in re.findall(r'"([^"]+)"', query) if match.strip()]
    remainder = re.sub(r'"[^"]+"', " ", query)
    tokens = [
        token
        for token in re.findall(r"[^\W_]+(?:['’-][^\W_]+)*", remainder.lower())
        if len(token) > 1 and token not in STOP_WORDS
    ]
    terms = phrases + tokens
    if not terms:
        raise ValueError("Search query contains no indexable terms")

    def quote(term: str) -> str:
        return '"' + term.replace('"', '""') + '"'

    and_query = " AND ".join(quote(term) for term in terms)
    or_query = " OR ".join(quote(term) for term in terms) if len(terms) > 1 else None
    return and_query, or_query


def _run_query(
    connection: sqlite3.Connection,
    fts_query: str,
    limit: int,
    include_external: bool,
) -> list[sqlite3.Row]:
    external_filter = "" if include_external else "AND source_tier != 'external'"
    return list(
        connection.execute(
            f"""
            SELECT
                rowid AS section_rowid,
                relative_path,
                source_tier,
                kind,
                capture_id,
                content_hash,
                title,
                heading,
                body,
                bm25(search_sections, 0.0, 0.0, 0.0, 0.0, 0.0, 8.0, 6.0, 4.0, 1.0) AS score,
                snippet(search_sections, 8, '[', ']', '…', 32) AS snippet
            FROM search_sections
            WHERE search_sections MATCH ?
            {external_filter}
            ORDER BY score
            LIMIT ?
            """,
            (fts_query, limit),
        )
    )


def _fetch_sections(
    connection: sqlite3.Connection,
    rowids: Iterable[int],
    include_external: bool,
) -> dict[int, sqlite3.Row]:
    identifiers = sorted(set(int(rowid) for rowid in rowids))
    if not identifiers:
        return {}
    placeholders = ",".join("?" for _ in identifiers)
    external_filter = "" if include_external else "AND source_tier != 'external'"
    rows = connection.execute(
        f"""
        SELECT
            rowid AS section_rowid,
            relative_path,
            source_tier,
            kind,
            capture_id,
            content_hash,
            title,
            heading,
            body
        FROM search_sections
        WHERE rowid IN ({placeholders})
        {external_filter}
        """,
        identifiers,
    )
    return {int(row["section_rowid"]): row for row in rows}


def _semantic_candidates(
    connection: sqlite3.Connection,
    query_vector: list[float],
    limit: int,
    include_external: bool,
) -> list[tuple[int, float]]:
    external_filter = "" if include_external else "WHERE s.source_tier != 'external'"
    rows = connection.execute(
        f"""
        SELECT e.rowid, e.dimension, e.vector
        FROM semantic_embeddings AS e
        JOIN search_sections AS s ON s.rowid = e.rowid
        {external_filter}
        """
    )
    scored: list[tuple[int, float]] = []
    for row in rows:
        dimension = int(row["dimension"])
        if dimension != len(query_vector):
            raise ValueError("Query embedding dimension does not match the index")
        vector = _unpack_vector(row["vector"], dimension)
        similarity = sum(left * right for left, right in zip(query_vector, vector))
        scored.append((int(row["rowid"]), float(similarity)))
    scored.sort(key=lambda item: item[1], reverse=True)
    return scored[:limit]


def _plain_snippet(body: str, maximum_characters: int = 320) -> str:
    compact = re.sub(r"\s+", " ", body).strip()
    if len(compact) <= maximum_characters:
        return compact
    return compact[: maximum_characters - 1].rstrip() + "…"


def query(args: argparse.Namespace) -> dict[str, Any]:
    _, expected_context_root = _resolve_context(
        args.vault, args.collection, args.context
    )
    if not 1 <= args.embedding_timeout_seconds <= 600:
        raise ValueError("EmbeddingTimeoutSeconds must be between 1 and 600")
    index_path = Path(args.index).expanduser().resolve()
    if not index_path.is_file():
        raise ValueError(f"Search index does not exist: {index_path}")
    connection = sqlite3.connect(f"file:{index_path.as_posix()}?mode=ro", uri=True)
    connection.row_factory = sqlite3.Row
    try:
        metadata = _metadata(connection)
        if metadata.get("schema_version") != SCHEMA_VERSION:
            raise ValueError("Search index schema is stale; rebuild it")
        context_root = Path(metadata["context_root"]).resolve()
        if (
            context_root != expected_context_root
            or metadata.get("collection") != args.collection
            or metadata.get("context") != args.context
        ):
            raise ValueError("Search index belongs to a different context")
        include_evidence = metadata.get("include_evidence") == "true"
        include_external = metadata.get("include_external") == "true"
        files = list(
            _iter_markdown_files(context_root, include_evidence, include_external)
        )
        current_fingerprint = _tree_fingerprint(files, context_root)
        index_stale = current_fingerprint != metadata.get("tree_fingerprint")
        fallback_used = False
        if args.raw_query:
            effective_query = args.query
            fallback_query = None
        else:
            effective_query, fallback_query = _natural_fts_query(args.query)
        candidate_limit = min(200, max(args.limit * 4, 20)) if args.semantic else args.limit
        lexical_rows = _run_query(
            connection, effective_query, candidate_limit, args.include_external
        )
        if not lexical_rows and fallback_query:
            effective_query = fallback_query
            lexical_rows = _run_query(
                connection, effective_query, candidate_limit, args.include_external
            )
            fallback_used = True

        lexical_by_id = {
            int(row["section_rowid"]): row for row in lexical_rows
        }
        lexical_rank = {
            int(row["section_rowid"]): rank
            for rank, row in enumerate(lexical_rows, start=1)
        }
        semantic_requested = bool(args.semantic)
        semantic_used = False
        semantic_error: str | None = None
        semantic_rank: dict[int, int] = {}
        semantic_similarity: dict[int, float] = {}
        if semantic_requested:
            try:
                if metadata.get("semantic_enabled") != "true":
                    raise ValueError("Index has no semantic embeddings; rebuild with -Semantic")
                provider = metadata.get("embedding_provider")
                if provider != "ollama":
                    raise ValueError(f"Unsupported indexed embedding provider: {provider}")
                embedding_model = metadata.get("embedding_model") or ""
                endpoint = args.embedding_endpoint or metadata.get("embedding_endpoint") or ""
                query_vector = _embed_ollama(
                    endpoint,
                    embedding_model,
                    [args.query],
                    args.embedding_timeout_seconds,
                )[0]
                expected_dimension = int(metadata.get("embedding_dimension") or "0")
                if expected_dimension <= 0 or len(query_vector) != expected_dimension:
                    raise ValueError("Query embedding dimension does not match index metadata")
                semantic_rows = _semantic_candidates(
                    connection,
                    query_vector,
                    candidate_limit,
                    args.include_external,
                )
                semantic_rank = {
                    rowid: rank for rank, (rowid, _) in enumerate(semantic_rows, start=1)
                }
                semantic_similarity = dict(semantic_rows)
                semantic_used = True
            except Exception as exc:  # noqa: BLE001 - semantic failure degrades to FTS5
                semantic_error = str(exc)

        candidate_ids = set(lexical_rank) | set(semantic_rank)
        section_rows = _fetch_sections(
            connection, candidate_ids, args.include_external
        )
        if semantic_used:
            reciprocal_rank_scores: dict[int, float] = {}
            for rowid, rank in lexical_rank.items():
                reciprocal_rank_scores[rowid] = reciprocal_rank_scores.get(rowid, 0.0) + 1.0 / (60 + rank)
            for rowid, rank in semantic_rank.items():
                reciprocal_rank_scores[rowid] = reciprocal_rank_scores.get(rowid, 0.0) + 1.0 / (60 + rank)
            ordered_ids = sorted(
                candidate_ids,
                key=lambda rowid: (
                    reciprocal_rank_scores.get(rowid, 0.0),
                    semantic_similarity.get(rowid, -1.0),
                    -lexical_rank.get(rowid, 10**9),
                ),
                reverse=True,
            )[: args.limit]
        else:
            reciprocal_rank_scores = {}
            ordered_ids = [int(row["section_rowid"]) for row in lexical_rows[: args.limit]]

        results: list[dict[str, Any]] = []
        for rank, rowid in enumerate(ordered_ids, start=1):
            row = section_rows.get(rowid) or lexical_by_id.get(rowid)
            if row is None:
                continue
            source_path = (context_root / row["relative_path"]).resolve()
            try:
                source_path.relative_to(context_root)
            except ValueError:
                continue
            source_exists = source_path.is_file()
            source_stale = True
            if source_exists:
                source_stale = (
                    hashlib.sha256(source_path.read_bytes()).hexdigest()
                    != row["content_hash"]
                )
            results.append(
                {
                    "rank": rank,
                    "score": lexical_by_id[rowid]["score"] if rowid in lexical_by_id else None,
                    "lexical_rank": lexical_rank.get(rowid),
                    "semantic_rank": semantic_rank.get(rowid),
                    "semantic_similarity": semantic_similarity.get(rowid),
                    "hybrid_score": reciprocal_rank_scores.get(rowid) if semantic_used else None,
                    "retrieval_modes": [
                        mode
                        for mode, present in (
                            ("lexical", rowid in lexical_rank),
                            ("semantic", rowid in semantic_rank),
                        )
                        if present
                    ],
                    "relative_path": row["relative_path"],
                    "absolute_path": str(source_path),
                    "source_tier": row["source_tier"],
                    "kind": row["kind"],
                    "capture_id": row["capture_id"],
                    "title": row["title"],
                    "heading": row["heading"],
                    "snippet": (
                        lexical_by_id[rowid]["snippet"]
                        if rowid in lexical_by_id
                        else _plain_snippet(row["body"])
                    ),
                    "source_exists": source_exists,
                    "source_stale": source_stale,
                }
            )
    finally:
        connection.close()
    return {
        "state": "searched",
        "index_path": str(index_path),
        "index_generated_at": metadata.get("generated_at"),
        "index_stale": index_stale,
        "query": args.query,
        "effective_query": effective_query,
        "fallback_used": fallback_used,
        "semantic_requested": semantic_requested,
        "semantic_used": semantic_used,
        "semantic_error": semantic_error,
        "embedding_model": metadata.get("embedding_model") or None,
        "results": results,
    }


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(description=__doc__)
    subcommands = root.add_subparsers(dest="command", required=True)
    build_parser = subcommands.add_parser("build")
    build_parser.add_argument("--vault", required=True)
    build_parser.add_argument("--collection", required=True)
    build_parser.add_argument("--context", required=True)
    build_parser.add_argument("--index", required=True)
    build_parser.add_argument("--exclude-evidence", action="store_true")
    build_parser.add_argument("--include-external", action="store_true")
    build_parser.add_argument("--semantic", action="store_true")
    build_parser.add_argument("--embedding-provider", choices=("ollama",), default="ollama")
    build_parser.add_argument("--embedding-model")
    build_parser.add_argument(
        "--embedding-endpoint", default="http://127.0.0.1:11434"
    )
    build_parser.add_argument("--embedding-batch-size", type=int, default=32)
    build_parser.add_argument(
        "--embedding-timeout-seconds", type=int, default=120
    )
    build_parser.add_argument(
        "--embedding-max-characters", type=int, default=8000
    )
    query_parser = subcommands.add_parser("query")
    query_parser.add_argument("--vault", required=True)
    query_parser.add_argument("--collection", required=True)
    query_parser.add_argument("--context", required=True)
    query_parser.add_argument("--index", required=True)
    query_parser.add_argument("--query", required=True)
    query_parser.add_argument("--limit", type=int, default=10, choices=range(1, 51))
    query_parser.add_argument("--raw-query", action="store_true")
    query_parser.add_argument("--include-external", action="store_true")
    query_parser.add_argument("--semantic", action="store_true")
    query_parser.add_argument("--embedding-endpoint")
    query_parser.add_argument(
        "--embedding-timeout-seconds", type=int, default=120
    )
    return root


def main() -> int:
    args = parser().parse_args()
    try:
        result = build(args) if args.command == "build" else query(args)
        print(_json(result))
        return 0
    except Exception as exc:  # noqa: BLE001 - CLI boundary returns concise failure
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
