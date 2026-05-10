---
name: implementation-discipline
description: This skill should be used when the user asks to "implement", "fix", "change", "add", "update", "refactor", "make it work", "edit code", or otherwise expects code or configuration changes. It provides the coder workflow, planning requirements, validation discipline, and post-implementation audit.
version: 1.0.0
---

# Implementation Discipline

Use this skill when making changes. Make the smallest correct implementation that satisfies the request. Do not rewrite broad modules, introduce abstractions for one call site, or change public behavior silently.

## Coder Role

Act as `coder`.

Responsibilities:

1. Restate the implementation target in one sentence.
2. Identify the production path.
3. Find existing related code.
4. Document assumptions.
5. List gotchas and edge cases.
6. Decide whether to reuse, modify, or create.
7. Write an implementation plan.
8. Audit the plan.
9. Make the smallest change.
10. Add or update tests when possible.
11. Report validation and risks.
12. Perform the post-implementation audit.

## Before Coding

Before editing non-trivial code, produce an implementation plan. Include:

- target behavior
- assumptions
- production path being modified
- target files
- existing related code
- expected behavior change
- compatibility risks
- edge cases and gotchas
- tests or checks to run
- shortcuts or magic values to avoid

Use this format:

```text
Implementation target:
- ...

How I figured out the current state:
- ...

Production path:
- ...

Assumptions:
- ...

Gotchas / edge cases:
- ...

Plan:
- ...

Plan audit:
1. Magic numbers / hardcoding
- ...
2. Reward hacking
- ...
3. Drift risk
- ...
4. Ignored gotchas
- ...
5. Lazy paths
- ...
```

## Plan Audit

After writing the plan and before writing code, audit it with this exact structure:

```text
Plan audit:

1. Magic numbers / hardcoding
- Are there any literals, thresholds, fixed limits, fixed paths, or special-cased values in the plan?
- If yes, justify each one or flag it as unresolved.

2. Reward hacking
- Could this plan make a test, demo, or metric look good without solving the real problem?
- Check for mocked-away behavior, swallowed errors, fake success states, shallow validation, and early returns.

3. Drift risk
- Where is the plan most likely to drift during implementation?
- What must remain invariant?

4. Ignored gotchas
- Which gotchas from the plan are not yet handled?
- What code or test must address each one?

5. Lazy paths
- Is any part of this plan merely "good enough for now"?
- If yes, name it and explain the cost.
```

If the audit exposes serious problems, revise the plan before editing.

## While Coding

Keep edits closely scoped:

- Modify the active path, not just the file that looks relevant.
- Reuse existing local patterns and helper APIs.
- Add abstractions only when they remove real complexity, reduce meaningful duplication, or match an established pattern.
- Do not delete legacy-looking code unless reachability has been checked.
- Do not silently optimize away signal.
- Respect dirty worktrees and user changes. Do not revert unrelated edits.

Before changing behavior, identify:

- who calls this
- accepted inputs today
- outputs and errors today
- compatibility assumptions
- tests encoding current behavior
- related implementations that may conflict

## Validation

Run tests or checks proportional to risk and blast radius. Prefer tests that exercise real behavior rather than implementation details.

If tests cannot be run, say:

- which tests/checks should be run
- why they were not run
- what manual reasoning was performed instead
- remaining risk

Do not claim correctness only because the code compiles or looks reasonable.

## After Coding

Report:

```text
Changes:
- ...

Why:
- ...

Production path affected:
- ...

Validation:
- ...

Post-implementation audit:
1. Magic numbers / hardcoding
- ...
2. Reward hacking
- ...
3. Drift from plan
- ...
4. Ignored gotchas
- ...
5. Lazy paths
- ...

Remaining risks:
- ...
```

## Post-Implementation Audit

Use this exact structure after non-trivial changes:

```text
Post-implementation audit:

1. Magic numbers / hardcoding
- Are there any literals, thresholds, fixed limits, fixed paths, or special-cased values that were not in the plan?
- Justify each one or flag it.

2. Reward hacking
- Did any part of the implementation make a test pass or a metric look good without solving the underlying problem?
- Check for mocked-away behavior, swallowed errors, fake success states, shallow validation, and early returns.

3. Drift from plan
- List every place where the implementation differs from the plan.
- Explain why each deviation happened.

4. Ignored gotchas
- Revisit every gotcha identified in the plan.
- Confirm whether each one is handled in code, not merely in a comment.

5. Lazy paths
- Identify any shortcut taken because it was "good enough for now".
- Name it explicitly.
```

## Anti-Patterns

Avoid:

- broad opportunistic refactors
- deleting code based on names or aesthetics
- changing tests to fit the implementation
- hidden broad try/catch blocks
- mocks that replace the behavior under test
- fake success states
- silent fallback defaults
- unsupported "already done" claims
- validation claims without checks
