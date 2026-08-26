# Visual Library

Use this reference when assimilating screenshots or video frames, connecting
later media to a recurring visual subject, maintaining a custom font or symbol
map, or retrieving an answer that depends on visual evidence. Do not load it
for ordinary fast intake.

The capture-ID backend provides stable provenance but is not a usable visual
catalog by itself. Keep the optional human-facing library separate from
immutable evidence:

```text
library/
  index.md
  captures/
    <descriptive-slug>--<capture-id>.md
  references/
    <reference-slug>.md
_evidence/
  visual-exemplars/
    <reference-slug>/
      <derived-crop-or-comparison-image>
```

Create `library/` only when the first media descriptor or recurring reference
is justified. Use the active context's selected Markdown or Obsidian link
style. Original captures and attachments remain immutable; library notes and
derived crops may be renamed or corrected with provenance.

## Semantic capture descriptors

After durable media has been visually reviewed, create one descriptor at
`library/captures/<descriptive-slug>--<capture-id>.md`. Include:

- a natural title plus useful aliases and search keywords;
- input type and capture time;
- an inline original screenshot or representative processed video frame;
- a link to the immutable capture and original media;
- stable reference IDs for recurring subjects it depicts;
- a short distinction between direct visual content and uncertain identity.

Do not copy the full interpretation into the descriptor. Its job is naming,
search, preview, and routing. Keep the capture ID at the end of the filename so
two similarly titled captures remain distinct.

## Canonical recurring references

Create one page under `library/references/` for each stable recurring visual
subject, not one page per capture. Use a durable identifier such as
`ref-soft-earth` in the page and in linked interpretations. Record:

- the user-confirmed preferred name and aliases;
- subject kind, such as item, terrain, interactable, character, UI, glyph, or
  map symbol;
- recognition traits supported by the visible examples;
- positive exemplars embedded from original media or provenance-linked crops;
- confusable subjects and visible differences;
- unresolved or low-confidence candidate matches;
- a source link for every exemplar and confirmed mapping.

When a later capture depicts the same subject, add it as another exemplar on
the existing reference page and link its interpretation with relation
`depicts` or `same-object`. Use `mentions` for text-only evidence and
`confusable-with` only when the visible comparison is actually relevant.

User naming or correction is authoritative evidence. A clear active-context
match may support a proposed identity, but visual similarity alone does not
authorize merging two references. Keep ambiguous candidates separate until
the evidence or user resolves them.

## Derived exemplars and crops

Use an original screenshot when the subject is already clear. If the subject
is small, create a lossless or high-quality crop under
`_evidence/visual-exemplars/<reference-slug>/` and link it to the source capture
and pixel bounds or derivation note. Never overwrite or crop the original
attachment in place.

Prefer a few representative positive examples over a gallery of near
duplicates. Preserve examples that show materially different orientation,
state, palette, scale, or surrounding context when those differences improve
future recognition.

## Fonts, glyphs, and OCR corrections

Keep a glyph table on the relevant reference page. Each confirmed row includes
the actual embedded glyph crop, the user-confirmed character or meaning, source
capture, and known confusions. For example, preserve separate `W` and `H`
examples when the game font makes them easy to confuse.

OCR or model transcription is a candidate reading, not confirmation. Compare
uncertain text against the active glyph examples, mark unclear characters, and
ask the user only when the distinction materially affects the record. Add the
answer as captured evidence before updating the mapping.

## Retrieval and chat presentation

Search `library/index.md`, descriptor titles, aliases, keywords, reference IDs,
and reference pages before opening raw capture files individually. Verify any
material claim against the interpretation or immutable capture.

When the answer relies on visual evidence and the chat surface supports local
media, render at least one relevant original screenshot or representative
processed frame inline with an absolute local path. Also link the governing
human note or original media. Use the smallest useful image set and label what
each image demonstrates.

## Checkpoint maintenance

At a media checkpoint:

1. create descriptors for newly interpreted media;
2. search existing reference names and aliases before creating new references;
3. connect supported repeat appearances to stable reference IDs;
4. update confusable distinctions and glyph mappings from confirmed evidence;
5. keep `library/index.md` compact and searchable;
6. leave uncertain candidates visible without merging them.
