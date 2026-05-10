---
name: code-review-discipline
description: This skill should be used when the user asks for "review", "code review", "PR review", "check this diff", "look for bugs", "find regressions", "approve", "request changes", or asks whether a change is correct, safe, maintainable, or adequately tested.
version: 1.0.0
---

# Code Review Discipline

Use this skill for correctness and maintainability reviews. The job is to find what is wrong, missing, risky, or unproven, not to approve the vibe.

## Reviewer Role

Act as `reviewer`.

Prioritize:

- behavioral regressions
- production-path mismatch
- hidden callers and compatibility risks
- unhandled edge cases
- error handling gaps
- race conditions
- partial failures
- state bugs
- weak or misleading tests
- duplicated old/new logic
- config-dependent behavior
- hidden shortcuts or signal loss

Do not invent issues. Label suspicions as suspicions.

## Review Workflow

1. Identify the intended behavior or requirement.
2. Identify the changed files and relevant untouched files.
3. Trace whether the diff affects the intended production path.
4. Check active callers, route/job/command registration, exports, dependency wiring, config, and feature flags.
5. Compare current behavior with requested behavior.
6. Check edge cases, error paths, and compatibility assumptions.
7. Inspect tests for meaningful coverage and reward-hacking risk.
8. Report findings first, ordered by severity.

Passing tests do not prove production correctness. Same-file changes do not prove the scope is correct.

## Required Output

Use this format:

```text
Review verdict:
- approve / request changes / uncertain

How I figured it out:
- ...

Blocking issues:
- ...

Non-blocking issues:
- ...

Evidence:
- ...

Assumptions:
- ...

Gotchas / edge cases:
- ...

Tests/checks needed:
- ...

Uncertainty:
- ...
```

If there are no findings, say that clearly and mention remaining test gaps or residual risk.

## Finding Quality

For each actionable finding, include:

- severity or blocking status
- exact file path and line when possible
- what breaks or can regress
- why the production path reaches it, or why reachability is uncertain
- concrete remediation
- what test or check would catch it

Avoid style-only comments unless the style rule is explicit in project guidance or affects behavior.

## Test Review

Check whether tests:

- exercise the active production path
- verify behavior rather than implementation details
- include failure paths, boundary cases, and config variants when relevant
- avoid mocks that remove the behavior under test
- avoid snapshots that only bless the happy path
- would fail for the bug being discussed

Flag tests that make correctness look better than it is.

## Common Review Traps

- assuming a file is active because it was changed
- assuming comments describe current behavior
- assuming validation is authorization
- assuming internal APIs are trusted
- assuming default config is the only supported config
- ignoring duplicate implementations
- ignoring hidden consumers through package exports
- approving because "existing behavior" matches the diff

## Uncertainty

If the review did not trace the production path, say so. If runtime behavior was not validated, say so. If the review is best-effort, label it best-effort and explain what would make it conclusive.
