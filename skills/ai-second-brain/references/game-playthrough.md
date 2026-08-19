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

An unknown detail is not automatically an open question. Track it in
`open-questions.md` only when resolving it would help the player, explain a
material conflict, or support an active hypothesis. If the user says a detail
does not matter, the game does not expose it, or the playthrough has moved on,
remove it from active questions while retaining its evidence and any useful
guide fact.

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
