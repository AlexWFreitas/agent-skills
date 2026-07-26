# AI Second Brain Verification Evidence

Last updated: `2026-07-26T19:36:17-03:00`

This document records reproducible source and isolated-fixture evidence. Live
Codex behavior in the installed user vault remains a P05 gate.

## Automated matrix

| Command | PowerShell 7 | Windows PowerShell 5.1 |
| --- | --- | --- |
| `scripts/Test-Repository.ps1` | Pass; 0 warnings | Pass; 0 warnings with process-scoped `-ExecutionPolicy Bypass` |
| `tests/Run-Tests.ps1` | Pass; 21 tests | Pass; 21 tests with process-scoped `-ExecutionPolicy Bypass` |

The `ERROR:` lines emitted after the test pass summary are expected output from
negative installer tests. Both processes exited `0`.

The optional system `skill-creator/scripts/quick_validate.py` was attempted but
could not start because PyYAML is not installed. No dependency was added. The
repository's dependency-free validator is authoritative for this catalog and
passes in both supported shells.

## Deterministic coverage

The added tests verify:

- complete generic initialization and token replacement;
- compatible no-op re-entry;
- incompatible collision refusal without overwrite;
- immutable text and corrected voice-transcript capture;
- unique capture IDs and one initial append-only event;
- local screenshot copy and composer-only pending fallback;
- completion of a pending screenshot against the same capture ID;
- retry with an existing capture ID without duplicate evidence/event;
- later processing events without capture rewrites;
- helper resource resolution from an unrelated working directory.

## Integrated synthetic fixture

An isolated vault under a GUID-named system temporary directory was initialized,
used, inspected, and removed. It contained five immutable captures:

1. an observed red seal;
2. an explicit correction to blue;
3. a north-direction claim;
4. a conflicting south-direction claim;
5. a timed transition from sealed to open.

The checkpoint synthesis:

- preserved all five capture files;
- produced ten append-only events: five initial pending, three reconciled, and
  two conflicted;
- linked all five distinct capture IDs from current state, timeline, open
  items, or a justified topic note;
- represented red-to-blue as explicit supersession;
- represented sealed-to-open as a timed state transition;
- retained north/south as an unresolved ambiguous conflict;
- made no unsupported claim about the door's purpose, destination, or
  consequences.

The fixture was removed only after its resolved absolute path was verified to
be inside the system temporary root and match the task-specific GUID prefix.

## Package and dependency audit

The source package contains fourteen files: one portable `SKILL.md`, optional
Codex metadata, four vault templates, three focused references, and four
dependency-free PowerShell helpers.

- No secret-like value was found.
- No network call, API key, package installation, database, or runtime
  dependency is present.
- Hosted-service terminology appears only in explicit prohibitions.
- `policy.allow_implicit_invocation` is `false`.
- The existing installed target
  `C:\Users\otaru\.agents\skills\ai-second-brain` does not currently exist, so
  P05 installation will create rather than replace it if state remains
  unchanged.

## Behavioral acceptance state

| Acceptance | P04 evidence | Remaining P05 evidence |
| --- | --- | --- |
| A01-A03 | Verified by dual-shell validators/tests | None |
| A04 | Verified exactly-once text capture and retry | First real capture |
| A05 | Both local-copy and save-first completion verified | Determine which Codex attachment route is available |
| A06 | Verified transcript-only voice evidence | One real dictated/corrected transcript |
| A07-A09 | Skill/vault cold-read, adversarial scenarios, and synthetic correction/conflict fixture | Live firsthand-only and scoped-override prompts |
| A10 | Context isolation and fresh-task procedures are explicit and scenario-mapped | Fresh Codex task in the activated vault |
| A11 | Archive/delete procedure and disposable-fixture scenario are explicit | No destructive real-vault test required |
| A12 | Dependency and portability audit passes | Confirm initialized output remains ordinary files |
| A13 | Not applicable before activation | Install exact skill and initialize approved vault |
| A14 | Plan and evidence reconciled through P04 | Final closure snapshot |

Passing behavioral scenarios are evidence, not a technical removal of latent
model knowledge. A demonstrated reveal, confirmation, denial, hint, or steering
failure remains unacceptable.

## P05 activation evidence

- Explicit user-scope installation approval was obtained after the
  external-write reviewer required a separate confirmation.
- The installer created
  `C:\Users\otaru\.agents\skills\ai-second-brain`.
- All fourteen installed files match the validated source by SHA-256; there are
  zero missing, extra, or different files.
- The approved vault `D:\Work\Vaults` was initialized with collection
  `oracle-of-ages`, context `main`, and activity `game-playthrough`.
- All eleven required vault paths exist and no template token remains.
- The real vault contains zero captures and zero processing events, so
  activation did not pollute the user's record with synthetic validation data.
- Task `019fa091-4fa3-7db1-abbc-d74036e5284a`, titled
  `OracleOfAges Second Brain`, announced `oracle-of-ages/main`, confirmed
  firsthand-only mode, and reported that no evidence was created.
- Read-only inspection after startup confirmed zero captures and zero
  processing events. This verifies fresh-task startup without polluting the
  record.
- Real text, dictated transcript, and screenshot attachment-route behavior
  remain to be exercised by the user in that task.
