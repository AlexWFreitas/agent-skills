# Style 6: Analogy-rich explainer

## Essence

This style begins with a familiar system that shares important relationships
with the unfamiliar subject. It maps the analogy explicitly, uses it to explain
the mechanism, and then states where the comparison fails.

## What is different

- A solar-powered workshop provides the main explanatory frame.
- A mapping table connects every image to scientific terminology.
- The analogy recurs consistently instead of changing metaphors mid-lesson.
- Exact biological explanations follow each figurative description.
- A dedicated boundary section prevents literal interpretation.
- The final summary discards the imagery and restates the science directly.

The organizing question is "Which familiar relationship can reduce the
learner's initial cognitive load without replacing the real model?"

## Candidate skill rules

An eventual skill based on this style would instruct the agent to:

1. Use an analogy only when relationships are genuinely similar.
2. Map each important analogy element to the actual term.
3. Keep one coherent analogy rather than stacking several partial ones.
4. Pair figurative language with a precise explanation.
5. Identify important mismatches before the reader can overgeneralize.
6. Avoid analogy for literal instructions, contracts, or sensitive decisions.
7. End with the accurate model in nonfigurative language.

## Chat behavior

In chat, this voice makes unfamiliar mechanisms approachable quickly. It is
particularly useful when the user says a concept feels abstract or asks for an
explanation "in simple terms."

The agent should not reach for analogies automatically. A direct answer is
better when the domain term is already familiar or when the analogy would add
another model to learn.

## Strengths

- Lowers the barrier to first understanding.
- Makes relationships easier to visualize and remember.
- Offers a bridge from everyday knowledge to technical terminology.
- Can reveal the functional role of otherwise unfamiliar components.

## Tradeoffs

- Every analogy introduces inaccuracies.
- Readers may retain the image and lose the formal terms.
- Explanations become longer because mapping and limitations are necessary.
- An analogy that works for one audience may fail for another.

## Best fit

Choose this as the base style if you value accessibility, often approach
unfamiliar topics from first principles, and enjoy explanations grounded in
familiar systems.

## Evaluation signal

This candidate is a strong match if the analogy unlocks the process and the
boundary section feels sufficient. It is a weak match if you spend effort
translating the metaphor back into the actual subject.
