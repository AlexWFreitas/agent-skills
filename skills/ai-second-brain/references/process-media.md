# Interpret captured evidence

After durable capture, read [vault-contract.md](vault-contract.md) and
[visual-library.md](visual-library.md) for screenshots or video frames.
For video, also read [video-processing.md](video-processing.md). Load
[state-tracking.md](state-tracking.md) for maps, relations, and recurring state;
load [game-playthrough.md](game-playthrough.md) for game-specific interpretation.

Interpret only the active context. A logged attachment uses fast intake;
requested interpretation proceeds through preparation and analysis in the same
turn, or reports the actual technical limitation. Do not ask an uncaptioned
sender for an extra intent decision merely to save an entry.

## Interpret a capture

Use only the active context and the captured evidence.

- For text or voice, distinguish the user's direct statement, a proposed
  interpretation, and uncertainty.
- For a screenshot with durable media, create
  `_evidence/interpretations/<capture-id>.md` with `Direct observations`,
  `AI inferences`, and `Unresolved`. Link every inference to its supporting
  observation and label confidence. Use `inbox/interpretations/` only for an
  intact unmigrated legacy context.
- A user caption improves provenance but is not a prerequisite for useful
  image assimilation. Inspect the durable image itself, record visible objects
  and text, and search the active `library/` by titles, aliases, stable
  reference IDs, and prior visual exemplars. Do not make interpretation quality
  depend entirely on the user's prose.
- After visual review, create or update
  `library/captures/<descriptive-slug>--<capture-id>.md` with a natural title,
  searchable aliases/keywords, an embedded preview, the immutable source link,
  and stable visual-reference links. Keep the capture-ID file immutable even
  if this derived descriptor is later renamed or corrected.
- Reuse one `library/references/<reference-slug>.md` page for recurring visual
  subjects. Preserve user-confirmed names, positive exemplars, confusable
  subjects, and visible distinctions. Use provenance-linked glyph crops and
  confirmed mappings for custom fonts. Never merge two subjects or confirm an
  OCR glyph from visual similarity alone.
- If a screenshot contains a map, record a stable map-anchor tracker row with
  the visible era, label, selected cell or normalized marker position,
  viewport, landmarks, confidence, and capture provenance even when the caption
  does not call the position important. Connect the event with `located-at`;
  same region without a supported cell or landmark match remains a candidate.
- For a screenshot still pending save-first, do not claim visual evidence is
  retained. Ask the user to save the image locally and keep the item blocked or
  pending.
- For a video with durable media, run
  [scripts/Process-SecondBrainVideo.ps1](../scripts/Process-SecondBrainVideo.ps1)
  before interpretation. Omit Whisper path arguments when no override is
  needed; the helper reuses the active vault runtime record, the stable Codex
  local-tools installation, or `PATH`. Do not substitute a hosted
  transcription service.
- Treat source frame rate and review sample rate as separate. The helper's
  automatic overview is 8 fps for clips up to 30 seconds, 4 fps up to 120
  seconds, and 2 fps for longer clips before any automatic frame-cap reduction.
  When the user calls out an fps value because fast information may be lost,
  treat it as the requested review rate and pass `-FrameSampleFps`; never
  silently fall back to one frame per second. If existing derivatives use a
  lower rate, rerun with `-Reprocess`. Report both source and effective sample
  rates and any remaining temporal gap.
- Interpret the prepared video using the required separate visual, onscreen
  text, audible speech, non-speech audio, combined timeline, inference, and
  unresolved layers in
  [references/video-processing.md](video-processing.md). Treat the
  offline speech transcript as fallible derived evidence, not as the user's
  direct statement.
- Before declaring the local transcription runtime/model unavailable, inspect
  the durable runtime record and the bounded stable local-tools location. This
  read-only discovery is ordinary processing and does not require a separate
  permission turn. A prior vault record that explicitly grants install/use
  permission remains authorization to reuse or repair that same local runtime
  and model unless the user revokes it.
- If installation or repair is already authorized, perform it in a stable
  local-tools directory, persist or refresh the runtime record, retry media
  processing, and continue interpretation in the same assistant turn. Do not
  redownload a working runtime/model or ask again for authorization already
  recorded in the vault or supplied in the conversation.
- Only if a video is pending save-first, or contains audio but the local
  transcription runtime/model remains genuinely unavailable after bounded
  discovery and any authorized repair, append `blocked` and do not claim
  complete interpretation. Report the exact checked locations or failed tool
  action; never describe an unperformed search as a permission problem.
- Append an `interpreted`, `blocked`, or `conflicted` event through
  [scripts/Add-SecondBrainProcessingEvent.ps1](../scripts/Add-SecondBrainProcessingEvent.ps1).
- Do not rewrite the immutable capture or completed attachment.

If interpretation exposes a material ambiguity that only the user can resolve,
ask one concise question. Return the requested interpretation and defer only
non-urgent connections to the next checkpoint.

If the user requested notebook updates or the answer needs cross-session
synthesis, continue with [reconcile.md](reconcile.md). Otherwise return the
requested interpretation and its evidence limits.
