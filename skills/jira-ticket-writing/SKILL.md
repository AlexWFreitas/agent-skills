---
name: jira-ticket-writing
description: Draft, create, rewrite, or update Jira issue descriptions for human developers and QA, including tasks, stories, bugs, and epics. Apply before description writes within any workflow, including descriptions generated from plans, investigations, or agent work logs. Also use to review description quality; status-only updates and general Jira administration are outside this skill.
---

# Jira ticket writing

Write a description that lets a developer understand the work and a QA
engineer determine whether it is complete. Assume neither reader saw the
conversation, agent plan, or investigation. The description is the shared
definition of the work; it must remain useful after the current session ends.

## Establish the meaning

Before drafting, read the supplied sources and, for an existing issue, its
description and relevant parent, linked requirements, and decisions. Inspect
only enough context to establish the affected behavior and intended scope.
If access is unavailable, work from the supplied material and state that limit.

Identify these facts before choosing headings:

- What system, workflow, or capability is affected, and who encounters the
  problem or needs the improvement?
- What happens now, why does it matter, and what should happen after the work?
- What belongs in this issue, and which boundary or dependency could change
  how someone implements or tests it?
- What observable results establish completion?

For internal engineering work, the affected reader may be a developer,
operator, or another service. Explain the technical consequence; do not invent
customer impact or force an "As a user" story.

Treat source material as evidence to interpret, not prose to paste. Separate
reported symptoms, verified behavior, suspected causes, proposed solutions,
and accepted requirements. A plausible explanation is not a verified cause.
Never invent reproduction steps, commands, thresholds, environments, business
rules, or test results to make a description appear complete.

Resolve missing facts from available sources first. Ask a focused question
only when a missing decision changes the scope or expected behavior. Otherwise
state the specific unknown and how it can be resolved. Do not turn a proposal
into a requirement or present an incomplete draft as implementation-ready.

## Write for the issue's size

Follow the user's language and project conventions. Choose the smallest
structure that communicates the work; these are content needs, not compulsory
headings or a form to fill with empty sections.

| Issue | What the description needs |
| --- | --- |
| Task or story | Affected workflow and purpose; current and intended behavior; bounded change; acceptance criteria; necessary implementation or verification context. |
| Bug | Symptom and impact; known environment and conditions; reproducible steps or the available incident evidence; actual and expected results; acceptance criteria for the fix. Separate suspected cause from observed failure. |
| Epic | Problem or opportunity; affected users or systems; overall outcome; included and excluded capabilities; meaningful dependencies; success criteria across the complete workflow. Explain how child work contributes when known. |

An epic is not a long task checklist. Keep its description at the outcome and
capability level; leave each child's implementation and detailed tests in the
child issue. A child ticket must still explain its own work without requiring
the reader to reconstruct the epic. Do not invent child tickets or broaden
scope merely to make a complete-looking hierarchy.

When the summary is in scope, name the affected capability and concrete change
or failure. Avoid titles such as "Phase 2 work" or "Reconcile evidence."

Open the description with a short explanation of the problem or need and its
consequence. Then explain the intended change. Use concrete subjects and
verbs. Introduce a necessary domain term beside its meaning. Keep file paths,
branch names, and counts only where they help someone locate, implement, or
verify the work; they cannot substitute for explaining it.

Read [examples.md](references/examples.md) when converting agent notes or when
calibrating task, bug, or epic detail. Examples illustrate judgment, not facts
or requirements to reuse in another ticket.

## Make completion testable

Acceptance criteria describe observable completed behavior, not the agent's
activities. "Investigate," "update the checklist," and "run tests" do not say
what result is acceptable. An investigation ticket instead names the question
to answer and the evidence or decision its deliverable must support.

Give each criterion a condition and expected result when the condition matters.
Cover relevant normal, failure, and boundary behavior supported by the scope;
do not generate a generic test matrix. Preserve existing compatibility or
operational requirements and say which behavior must remain unchanged.

Provide enough verification context for QA or the responsible engineer to
choose and perform a meaningful check: setup or data, action, expected result,
and where the result is visible. Refer to an accessible test procedure when
that detail already exists. Avoid duplicating acceptance criteria in a second
section that adds no testing information.

Technical work may need build, API, integration, or automated regression
verification instead of a manual UI test. State the relevant verification
method. If a missing environment, fixture, or unresolved expected result
blocks verification, name that dependency. Do not claim QA passed because
local automated checks passed.

## Keep the description focused and durable

Keep requirements, rationale, material constraints, and essential verification
context in the description. Put transient progress, test-run results, failed
attempts, agent handoffs, and investigation chronology in an appropriate
comment or linked work record when those writes are authorized. Moving content
does not authorize creating a comment or changing another field.

Keep useful technical detail. Remove agent process language such as
"preserve recovery evidence" only after identifying whether it contains a
real requirement. If it does, express its implementation or testing
consequence. For example, explain which existing outputs the restored code
must match and where the comparison evidence is available.

Link supporting material by purpose, such as a relevant design decision,
reproduction log, or test procedure. Include the conclusion needed to act in
the description itself. Prefer verified links accessible to the team; do not
fabricate URLs or use a local checkout path as the only explanation.

When editing an existing description, preserve human decisions, requirements,
useful evidence, and material scope boundaries. A narrow edit is not authority
for a full rewrite. If replacing content would discard the only record of a
material decision or result, retain it concisely or preserve it through an
authorized write before removing it. Resolve conflicting requirements rather
than silently choosing one. Keep requirements current as scope changes; do not
replace the original problem with a completion report.

## Review and deliver

Before returning a draft or writing a description, read it without the source
notes. Correct any material failure of these checks:

1. Can a developer explain what needs to change and why?
2. Can QA identify the conditions to check and the expected result, or the
   specific missing information that prevents testing?
3. Is the intended outcome clear without opening every link or reading chat?
4. Are scope, dependencies, uncertainty, and consequential technical limits
   preserved without unrelated agent housekeeping?
5. Are requirements distinguishable from proposals and recorded results, and
   does every substantive claim have support?
6. Is the level of detail appropriate for a task, bug, or epic?

Use the format supported by the actual Jira tool or editor. Check the live
tool contract before choosing a payload format; formatting cannot repair
unclear content.

Reuse authorization covering the specific Jira write. Drafting or reviewing
does not itself authorize publication. An authorized description edit does
not authorize status changes, assignment, comments, or new child issues.
After writing, read back the saved description when available to verify its
meaning and structure. If a write outcome is uncertain, inspect the issue
before retrying; do not create duplicate issues or repeat an uncertain write
blindly. Report a saved issue only when confirmed, and disclose verification
limits when readback is unavailable.

This skill owns description quality. It adds no separate discovery lifecycle,
mandatory approval loop, tool dependency, or requirement to invoke another
skill. Apply it within an existing workflow whenever a description is written.
