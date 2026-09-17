# Jira description examples

Use these examples to calibrate the amount and kind of detail. The first uses
only a supplied ticket excerpt as its source. The bug and epic examples use
explicitly fictional requirements. None describes verified live Jira state.

## Technical task: restore missing source needed by a build

An agent note might say:

> Preserve recovery evidence, restore typed source, reconcile surfaces, and
> update the work checklist. Initial build and focused tests pass; full checks
> are still in progress.

The reader needs the build problem, the affected components, the intended
result, and how to verify it. Here is a draft of the **source-recovery portion**
of the OD-5110 excerpt. The excerpt also requests catalog reconciliation; that
work is addressed below rather than silently removed from a full rewrite.

### Summary

Restore missing QA coverage source so OttoMCP builds from a clean checkout

### Problem and intended change

The reported build failure on `epic/OD-5110` is caused by two missing QA
coverage source modules. The ticket identifies a broad `coverage/` ignore rule
that excludes their source directory. Existing compiled copies are available
locally, but their original build provenance has not been verified.

Restore the typed source for the coverage policy and deterministic analysis
enricher so developers can build the branch from the checked-in source.
Adjust the ignore rules so these source files can be tracked while generated
test coverage remains ignored. Preserve existing public contracts and keep
archived tools disabled.

### Acceptance criteria

- The branch builds from a clean checkout without relying on locally retained
  compiled copies of the missing modules.
- The restored modules satisfy the existing regression expectations. Compare
  their outputs with the preserved compiled copies and document discrepancies;
  those copies are supporting evidence, not a verified original-source baseline.
- Git includes the restored source files and continues to ignore generated
  test coverage output.
- Existing public contracts remain unchanged, and archived tools remain
  disabled.

### Verification context

Verify this repair with a clean build, the focused module regressions, and the
existing server test suite. Check both source inclusion and generated coverage
exclusion in Git. Record the tested revision, results, and remaining limits
with the test evidence. Deployment is outside this repair's scope.

The supplied excerpt names the foundation review at
`docs/epics/OD-5110-OttoMCP/reviews/phase-2-foundation.md` but does not provide
the exact module paths, build commands, comparison fixtures, or definitions of
the modules' outputs. Inspect that review and the tracked consumers before
finalizing the implementation and verification details. Preserve the excerpt's
uncertainty about the compiled copies until their provenance is established.

### How to handle the rest of the source material

This is a bounded illustration, not a complete replacement for the supplied
ticket. A full rewrite must also preserve or resolve these items:

- **Catalog reconciliation:** The excerpt requires checking runtime tool
  registration and schemas against 75 released catalog entries. Establish its
  relationship to the repair and the expected treatment of discrepancies. If
  it remains in this issue, describe that compatibility outcome and its checks
  explicitly. Do not invent a discrepancy policy or split the issue without
  authority.
- **Manual QA handoff and known gaps:** Keep the information QA needs to act,
  including any checks automated tests do not cover. Clarify missing manual
  scenarios from the sources; do not manufacture them.
- **Partial results:** The reported initial build and 15 focused passing tests
  belong with dated verification evidence. They do not establish that the full
  suite, manual QA, catalog review, or deployment is complete. Preserve the
  only record of those results before removing them during an authorized rewrite.
- **Agent operating constraints:** Rules about avoiding duplicate external
  writes govern execution. Include them in the description only if they are
  requirements of the system being built; otherwise apply them in the workflow.

This draft improves the explanation but remains limited by the excerpt.
Do not invent the modules' business semantics to make it look ready. Replace
the source path with an accessible repository link only after verifying it.

## Bug: keep actual behavior separate from the suspected cause

Fictional source facts: In staging, a project administrator clears a project's
notification email and saves it. The page reports success, but reloading shows
the previous address. The approved behavior allows an empty address to disable
email notifications. A serializer defect is suspected, not verified.

### Summary

Clearing a project's notification email does not persist

### Problem

Project administrators cannot disable email notifications by clearing the
notification address. In staging, saving an empty address reports success,
but reloading the settings page restores the previous address.

### Reproduce

1. As a project administrator in staging, open notification settings for a
   project with a saved email address.
2. Clear the address and save. The page reports success.
3. Reload the page. The previous address is displayed again.

The expected result is that the address stays empty and email notifications
are disabled for the project. Investigate how an empty address is saved; the
cause has not been confirmed.

### Acceptance criteria

- After an administrator clears and saves the address, reloading settings
  shows an empty address.
- After that change, an event that normally triggers a project email sends
  no email notification.
- Saving a valid nonempty address still persists it and allows notifications.

For verification, use a test project and a controlled inbox. Trigger the same
notification event with a saved address and after clearing it. Confirm the
saved setting and delivery result in each case.

The source facts support the empty-address requirement. Without that approved
rule, the writer must resolve whether empty means disabled or invalid before
writing these criteria. Do not claim that stale display proves email delivery
continues; delivery is a separate check.

## Epic: express the complete capability

Fictional approved scope: Project administrators need to schedule nightly test
runs, inspect the next run time, pause schedules, and see run results. Each
scheduled time must create at most one run. Schedule configuration uses the
project's time zone. Editing a running test and retry policies are excluded.

### Summary

Let project administrators schedule and monitor nightly test runs

### Purpose and outcome

Project administrators need recurring overnight test runs without starting
each run manually. Provide a schedule they can configure and pause, show when
the next run will start, and make the results of scheduled runs easy to find.

### Scope

Include schedule configuration in the project's time zone, the next run time,
pause and resume controls, scheduled execution, and access to each run's
status and results. Editing an already running test and defining retry policies
are outside this epic.

### Epic acceptance criteria

- An administrator can configure a nightly schedule and see the next run time
  in the project's time zone.
- An enabled schedule creates at most one run for each scheduled time.
- A paused schedule starts no further runs until resumed.
- Administrators can find the status and results of runs created by a schedule.

Validate the complete flow from configuring a schedule through execution and
viewing results, including a paused schedule and duplicate-trigger handling.
Child tickets should define detailed behavior and checks for configuration,
execution, and result visibility.

Before implementation, resolve how schedules behave when local times repeat
or do not occur during daylight-saving changes. The source scope selects a
time zone but does not settle that behavior. Record the decision where the
scheduling work and its tests can use it.

This epic states an integrated outcome. It does not merely list backend,
frontend, and QA tasks, and it does not invent exact scheduling or retry rules.
