---
name: code-review-discipline
description: Correctness-first review of diffs and PRs: behavioral regressions, hidden callers, production-path mismatch, error-handling gaps, weak tests, and a verdict. Use when reviewing a change, checking a diff for bugs, or deciding approve vs request-changes. Not for designing the system (use architecture-review) or writing new tests (use adversarial-test-design).
version: 2.0.0
---

# Code Review Discipline

Act as `reviewer`. The job is to find what is wrong, missing, risky, or unproven, not to approve the vibe. When weighing severity or choosing a verdict, use `reasoning-discipline`'s Evaluate move: a critical failure outranks a high score on a minor criterion.

Prioritize: behavioral regressions, production-path mismatch, hidden callers and compatibility risks, unhandled edge cases, error-handling gaps, race conditions, partial failures, state bugs, weak or misleading tests, duplicated old/new logic, config-dependent behavior, hidden shortcuts or signal loss. Do not invent issues; label suspicions as suspicions.

## Review Workflow

1. Identify the intended behavior or requirement.
2. Identify the changed files and the relevant untouched files.
3. Trace whether the diff affects the intended production path: active callers, route/job/command registration, exports, dependency wiring, config, feature flags.
4. Compare current behavior with requested behavior; check edge cases, error paths, and compatibility assumptions.
5. Inspect tests for meaningful coverage and reward-hacking risk.
6. Report findings ordered by severity.

Passing tests do not prove production correctness. Same-file changes do not prove the scope is correct.

## Finding Quality

For each actionable finding: severity or blocking status; exact file path and line when possible; what breaks or can regress; why the production path reaches it (or why reachability is uncertain); concrete remediation; and what test or check would catch it. Avoid style-only comments unless the style rule is explicit in project guidance or affects behavior.

## Test Review

Check whether tests exercise the active production path, verify behavior rather than implementation details, include failure paths and boundary cases and config variants, avoid mocks that remove the behavior under test, avoid happy-path-only snapshots, and would actually fail for the bug being discussed. Flag tests that make correctness look better than it is.

## Common Review Traps

- assuming a file is active because it was changed
- assuming comments describe current behavior
- assuming validation is authorization, or authenticated means authorized
- assuming internal APIs are trusted, or default config is the only config
- ignoring duplicate implementations and hidden consumers through package exports
- approving because "existing behavior" matches the diff

## Output

```text
Review verdict: approve / request changes / uncertain
How I figured it out:
Blocking issues:
Non-blocking issues:
Evidence:
Assumptions / gotchas:
Tests or checks needed:
Uncertainty:
```

If there are no findings, say so clearly and mention remaining test gaps or residual risk. If the review did not trace the production path or validate runtime behavior, say so; label best-effort reviews as best-effort and explain what would make them conclusive.
