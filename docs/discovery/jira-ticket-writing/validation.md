# Jira ticket writing validation

Historical record: the skill was removed from the catalog on October 21, 2026.

Validated locally on September 17, 2026. This record covers the former
`skills/jira-ticket-writing/SKILL.md` and its `references/examples.md`.

## Semantic review

These are static reviews of the authored instructions and examples, not
independent model executions or live Jira tests.

| Scenario | Review result |
| --- | --- |
| Convert the supplied agent work log | The skill requires purpose, consequence, intended change, and testable completion. The technical example rewrites the source-recovery portion and explicitly preserves the remaining scope for resolution. |
| Internal engineering task with no UI | Build and regression verification is appropriate. The skill does not invent a customer persona or require manual UI QA. |
| Bug with an unverified cause | Observed behavior remains separate from the hypothesis. The fictional example does not infer notification delivery from a stale settings display. |
| Epic containing several workstreams | The epic example states the complete capability and integrated success criteria. It leaves detailed child implementation separate and surfaces an unresolved time-zone rule. |
| Missing expected behavior | The skill requires source inspection or a focused decision, and forbids making an incomplete draft appear ready through invented rules. |
| Narrow edit to an existing issue | Existing requirements, human decisions, and sole evidence records must survive. A limited edit does not expand into a full rewrite. |
| Description update during a larger workflow | The trigger covers description writes inside other workflows; instructions introduce no new discovery lifecycle or redundant approval loop. |
| Draft versus live write | The skill preserves the authorization boundary. An uncertain write requires inspection before retrying, and readback verifies saved content when available. |
| Investigation ticket | Acceptance can be an answered question and evidence-backed deliverable; it need not pretend the investigation changes product behavior. |

## Automated checks

| Check | Result |
| --- | --- |
| `pwsh -NoProfile -File scripts/Test-Repository.ps1` | Passed, zero warnings. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Test-Repository.ps1` | Passed, zero warnings. |
| `pwsh -NoProfile -File tests/Run-Tests.ps1` | All 34 tests passed. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests/Run-Tests.ps1` | All 34 tests passed. |
| Bundled `skill-creator/scripts/quick_validate.py` | Could not start because the available Python lacks `yaml` (PyYAML). No global dependency was installed; the repository's dependency-free validator passed. |

The suites use isolated temporary destinations. No real skill installation or
live Jira write was performed. Repository checks verify packaging and existing
tooling behavior; they do not prove automatic skill selection, future model
compliance, rendered Jira formatting, or the software claims in the user's
excerpt. Optional Codex metadata allows implicit invocation once installed and
discovered by the host.
