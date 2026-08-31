# Game Playthrough Activity

Use this activity reference only when the selected context declares
`Activity template: game-playthrough`.

The game is a collection and one playthrough is a context. The generic vault
contract remains authoritative; game-specific organization must not rename or
replace its core files.

## Human playthrough notebook

Make `README.md` the obvious starting point. During an active run, show the
current position, immediate objective, important carried state, and links to
the guide and journal. After completion, replace the immediate objective with a
short completion result and preserve the route in the journal.

Use `guide/index.md` as a compact contents page. Create naturally named guide
notes only when evidence exists. Common useful notes include:

- `story-and-characters.md` for plot facts, relationships, motives, and named
  people;
- `locations-and-route.md` for floors, areas, access routes, and landmarks;
- `items-and-equipment.md` for acquisitions, uses, and confirmed equipment;
- `puzzles-and-solutions.md` for reusable clues, sequences, and solved rooms;
- `bosses-and-combat.md` for encounters and rewards;
- `mechanics-and-resources.md` for repeatable systems, shops, farming, and
  traversal rules.

These names are examples, not a mandatory empty taxonomy. Merge or split notes
according to the actual playthrough. Give each fact one canonical guide home
and link to it from other notes.

Write `journal/` entries as readable sessions or chapters. Group adjacent
captures into meaningful developments such as entering a floor, solving a
puzzle chain, defeating a boss, or reaching the ending. Never mirror one raw
capture into one journal bullet by default.

When the playthrough accumulates recurring item instances, resources,
plantings, Secrets, or pending objectives, create canonical human-readable
tables under `trackers/` using [state-tracking.md](state-tracking.md). The guide
explains the game; trackers answer current-state and exhaustive-list questions.
Do not maintain the same current count independently in several guide
paragraphs.

An unknown detail is not automatically an open question. Track it in
`open-questions.md` only when resolving it would help the player, explain a
material conflict, or support an active hypothesis. If the user says a detail
does not matter, the game does not expose it, or the playthrough has moved on,
remove it from active questions while retaining its evidence and any useful
guide fact.

## Rapid play-session intake

Gameplay logging must not require the player to wait for full assimilation
after every discovery. A standalone note, screenshot, or clip supplied as a
record is a fast intake: persist it with a short title grounded in the user's
words when possible, leave it `pending`, acknowledge it, and return. Do not
open or rewrite the guide, journal, open questions, or state merely to log that
entry. Corrections and urgent contradictions remain immediate exceptions.

Process pending entries when the user asks what media shows, requests
assimilation or a checkpoint, asks a recall question that depends on them, or
ends the play session. Work in chronological bounded batches so new intake can
continue in a later turn without depending on the current task's history.

If the user explicitly selected quick capture, capture an ordinary correction
and its mechanically known `supersedes` or `resolves` relation without
rewriting the notebook. Reconcile it at the next requested checkpoint. Urgent
contradictions remain immediate exceptions.

## Stateful gameplay systems

Treat acquisitions, identifications, consumption, planting, harvesting,
handoffs, rewards, and task completion as transitions on stable tracker rows,
not as disconnected prose observations.

- **Rings and unidentified items:** create one instance per pickup when the
  source is known. A batch appraisal changes the aggregate unidentified count
  even when name-to-source mapping remains unresolved. Keep `identified but
  source-unassigned` separate from `still awaiting appraisal`.
- **Planting and harvest:** create separate planting and harvest IDs. A
  supported `harvest-of` relation moves the planting to harvested. Never
  create a harvest merely because a nearby chest or similar scene exists.
- **Secrets and cross-game handoffs:** track discovery, recipient, delivery,
  challenge, reward, return password, and return-password use as distinct
  lifecycle stages. An exhaustive Secret list enumerates every discovered row,
  not only search-ranked notes.
- **Inventory and quantities:** record a state transition when an item is used,
  lost, upgraded, or identified. Update the quantity even if provenance for
  individual units remains uncertain.
- **Pending objectives:** close the tracker row when the user completes or
  scope-closes it. Preserve the route history in the guide or journal without
  leaving it in the active list.

## Game visual references

Use the optional `library/` for recurring visual subjects that a player or
future agent may need to recognize again. Good candidates include items,
terrain, interactable objects, map symbols, teleport tiles, seed or nut forms,
heart pieces and containers, fonts, glyphs, and visually similar variants.

Create one reference page per stable subject, not one per screenshot. Preserve
user-confirmed names and aliases, embed representative positive examples, and
record visible differences from confusable subjects. Link later captures to
the same stable reference ID. For image-only captures, inspect the durable
image and existing exemplars rather than treating a missing caption as missing
visual evidence. If identity remains uncertain, keep a candidate label without
merging it into a confirmed reference.

Treat a visible map as relevant evidence even when the caption discusses only
the item, route, or character. Record an era-aware map anchor and connect the
event through `located-at`. Match later positions by the stored cell or marker
geometry and landmarks, not by area name alone.

## Eligible captures

Typical deliberate inputs include:

- discoveries and observations;
- locations and routes;
- characters, factions, and relationships;
- items, resources, and mechanics;
- quests, objectives, decisions, and consequences observed so far;
- player hypotheses, questions, reminders, and corrections;
- screenshots with a user caption;
- corrected foreground voice transcripts.

Create guide notes only after enough evidence exists. Do not pre-create an
empty taxonomy.

## Spoiler boundary

In firsthand-only mode, pretend no game knowledge exists outside the active
playthrough record. Do not:

- complete a name or relationship from model memory;
- reveal or rule out later outcomes;
- hint that a hypothesis is close or wrong;
- steer the player away from an undiscovered danger or toward a hidden reward;
- use genre conventions or guide knowledge as extra confidence.

When asked what the record supports, distinguish:

- user-observed fact;
- direct screenshot observation;
- AI inference with confidence;
- unresolved hypothesis;
- missing information.

Only urgent contradictions and explicitly time-sensitive reminders interrupt
capture. Save non-urgent connections and pattern observations for the next
checkpoint.

Before reporting a completed playthrough, run the context completion audit and
terminally disposition every accepted capture. Use `scope-closed` for credits,
optional clips, or side questions the user explicitly does not want processed;
do not leave them in the pending queue.
