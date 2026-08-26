# Writing-style comparison for a future chat skill

This comparison pack contains eight pure writing styles and one controlled
hybrid answering the same request:

> Write a sample lesson that explains photosynthesis to a curious adult who
> remembers only basic school science.

Photosynthesis is a better comparison topic than a software implementation
because the reader can focus on voice, pacing, explanation, and teaching
choices without also judging framework-specific code.

The first eight candidates are deliberately distinct rather than ranked from
best to worst. Candidate 9 combines the three styles that transfer most reliably
to general chat. Candidate 9 was selected and implemented as the explicit-only
[`controlled-writing-style`](../../skills/controlled-writing-style/SKILL.md)
skill.

## Comparison set

| Candidate | Primary move | Tone | Information shape | Best fit | Main risk |
| --- | --- | --- | --- | --- | --- |
| [1. Concise and direct](01-concise-direct-sample.md) | States the mechanism first and compresses supporting detail | Crisp and restrained | Short sections, lists, and a compact summary | Fast explanations and experienced readers | Can feel abrupt or too dense |
| [2. Guided teacher](02-guided-teacher-sample.md) | Teaches one layer at a time with learning checks | Patient and encouraging | Objectives, staged explanation, checkpoints, and recap | Learning an unfamiliar subject | Can be longer than the question requires |
| [3. Causal mental model](03-causal-mental-model-sample.md) | Separates energy flow from matter flow and traces cause to effect | Analytical and clarifying | Two linked systems, causal chains, and predictions | Deep understanding and diagnosis | Can feel abstract before it becomes concrete |
| [4. Story-driven narrative](04-story-driven-narrative-sample.md) | Follows a photon, water molecule, and carbon atom through a leaf | Vivid and immersive | Chronological journey with scientific interpretation | Memory, engagement, and intuitive learning | Narrative can obscure exact boundaries if uncontrolled |
| [5. Formal textbook](05-formal-textbook-sample.md) | Defines the process systematically and neutrally | Precise and academic | Definition, structures, stages, accounting, factors, and review | Durable educational reference | Can feel distant or heavy in chat |
| [6. Analogy-rich explainer](06-analogy-rich-explainer-sample.md) | Maps the chloroplast to a solar-powered workshop | Accessible and illustrative | Analogy, explicit mapping, limits, and exact science | First exposure to a complex mechanism | Readers may remember the analogy more than the science |
| [7. Conversational mentor](07-conversational-mentor-sample.md) | Explains as a knowledgeable colleague beside the reader | Warm, calm, and candid | Natural discussion around the important distinctions | General-purpose collaboration in chat | Warmth and transitions can add words |
| [8. Socratic dialogue](08-socratic-dialogue-sample.md) | Advances through purposeful questions and direct answers | Curious and reflective | Question-and-answer progression with a final self-check | Teaching, discovery, and misconception repair | Too many questions can slow a simple answer |
| [9. Controlled hybrid (recommended)](09-controlled-hybrid-sample.md) | Uses conversational voice, concise delivery, and causal depth when relationships are difficult | Warm, direct, and analytical | Answer-first explanation that expands only around material distinctions | A general-purpose chat default | Requires judgment so the three influences do not become a rigid formula |

Each sample has a separate analysis that describes its rules, strengths,
tradeoffs, and likely behavior in chat:

- [Concise and direct style notes](01-concise-direct-style-notes.md)
- [Guided teacher style notes](02-guided-teacher-style-notes.md)
- [Causal mental model style notes](03-causal-mental-model-style-notes.md)
- [Story-driven narrative style notes](04-story-driven-narrative-style-notes.md)
- [Formal textbook style notes](05-formal-textbook-style-notes.md)
- [Analogy-rich explainer style notes](06-analogy-rich-explainer-style-notes.md)
- [Conversational mentor style notes](07-conversational-mentor-style-notes.md)
- [Socratic dialogue style notes](08-socratic-dialogue-style-notes.md)
- [Controlled hybrid style notes](09-controlled-hybrid-style-notes.md)

## What remains constant

The [controlled lesson baseline](content-baseline.md) fixes the audience,
scientific scope, learning objectives, required facts, terminology, common
misconceptions, and source basis. Every sample explains the same process:

- Photosynthesis converts light energy into chemical energy.
- Light-dependent reactions in thylakoid membranes produce ATP and NADPH and
  release oxygen from water.
- The Calvin cycle in the stroma uses ATP and NADPH to fix carbon dioxide into
  G3P, a starting material for sugars and other organic molecules.
- Energy and matter follow different paths.
- Plants both photosynthesize and perform cellular respiration.
- Environmental conditions affect the rate of photosynthesis.

Length may vary because compression or deliberate pacing is part of the style.
The candidates may reorder facts, choose different transitions, or use a story
or analogy, but none may change the scientific model.

## How to compare the candidates

Read each sample as if it were the agent's answer in a real conversation. Score
it from 1 to 5 on these dimensions:

1. **Clarity:** How quickly did the process make sense?
2. **Retention:** Which explanation would be easiest to remember tomorrow?
3. **Precision:** Did the style preserve scientific distinctions and limits?
4. **Naturalness:** Would you enjoy receiving this voice repeatedly in chat?
5. **Pace:** Did the answer move at the right speed for its value?
6. **Transfer:** Would the same voice work for planning, debugging, reviews,
   personal questions, and other explanations?

A useful selection can combine a base voice with one or two modifiers. The
[controlled hybrid sample](09-controlled-hybrid-sample.md) implements this
combination:

> Use candidate 7 as the base voice, candidate 1 for brevity, and candidate 3
> when causal relationships are the hard part.

Candidate 9 is therefore not another pure style. It tests whether this
combination produces a better general chat voice than any one candidate alone.

## Selected implementation

The canonical skill package is
[`skills/controlled-writing-style/`](../../skills/controlled-writing-style/SKILL.md).
Invoke it as `$controlled-writing-style`. It applies only after explicit
invocation and does not install or activate automatically from this catalog
checkout.

## Scientific sources

The shared scientific content was checked on August 26, 2026, against:

- [OpenStax Biology 2e: Overview of Photosynthesis](https://openstax.org/books/biology-2e/pages/8-1-overview-of-photosynthesis)
- [NCBI Bookshelf: Chloroplasts and Photosynthesis](https://www.ncbi.nlm.nih.gov/books/NBK26819/)
- [Photosynthesis, a peer-reviewed overview](https://pmc.ncbi.nlm.nih.gov/articles/PMC5264509/)
