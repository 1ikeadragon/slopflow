---
name: implementation-discipline
description: The coding workflow for any change that edits code or configuration scope calibration, implementation plan, plan audit, validation, and post-implementation audit. Use when implementing, fixing, adding, updating, or refactoring. Not for deciding whether code is safe to delete use legacy-cleanup or for review of someone else's change use code-review-discipline.
version: 2.0.0
---

# Implementation Discipline

Act as `coder`. Make the smallest change that correctly fixes the actual problem — not the smallest change that merely silences a symptom, and not an opportunistic broad rewrite. Do not introduce abstractions for one call site or change public behavior silently.

## Calibrate The Scope

The most common scope failure is tunnel vision: patching the first obvious line when the real fix is structural; less often, widening a small fix into a broad rewrite. Right scope is a deliberate choice.

Before planning a non-trivial change, hold both options in view:

- In-situ: the local fix at the obvious site.
- Structural: fix the shared cause, route through the right abstraction or seam, or correct every sibling occurrence, accepting a larger blast radius.

Questions that usually decide it:

- Symptom or cause? Would the in-situ fix leave the same bug class alive, or only hide this instance?
- Siblings? Does the same issue exist in other call sites, copies, or branches? Fixing one and not the rest creates inconsistency.
- Right seam? Is there an existing abstraction this should go through, or is the local fix patching around it and adding drift?
- Cost both ways? Weigh the in-situ fix's correctness and debt cost against the structural fix's blast radius, regression risk, and reversibility.

Commit to a scope and state the alternative you rejected. In-situ: name the structural issue you are deliberately leaving and why. Structural: justify why the smaller change is insufficient, not merely nicer. For a genuinely close call, use `reasoning-discipline` (Generate options → Decide).

Scale to stakes: an obvious one-line fix does not need this. Reach for it when the change touches shared code, repeats a pattern, fixes a reported bug, or the obvious fix feels like it treats a symptom.

## Before Coding

For non-trivial changes, produce an implementation plan, then audit it before editing:

```text
Implementation target:
- one sentence

How I figured out the current state:
Production path being modified:
Existing related code:
Assumptions:
Gotchas / edge cases:
Expected behavior change and compatibility risks:
Tests or checks to run:
Scope: in-situ / structural, and the alternative rejected
Plan:
```

### The Audit

Apply these five checks to the plan before coding, and again to the implementation after coding:

1. **Magic numbers / hardcoding** — literals, thresholds, fixed limits, fixed paths, or special-cased values. Justify each or flag it as unresolved.
2. **Reward hacking** — could this make a test, demo, or metric look good without solving the real problem? Check for mocked-away behavior, swallowed errors, fake success states, shallow validation, and early returns.
3. **Drift** — before coding: where is the plan most likely to drift, and what must remain invariant? After coding: list every place the implementation differs from the plan and why.
4. **Ignored gotchas** — which gotchas are not yet handled, and what code or test must address each? After coding: confirm each is handled in code, not merely in a comment.
5. **Lazy paths** — is any part merely "good enough for now"? Name it and its cost.

If the pre-coding audit exposes serious problems, revise the plan before editing. Also if you're unsure about the tech stack involved always search about the docs online to refresh your memory on best practises for both teach stack and programming paradigms that are used in the codebase.

## While Coding

- Modify the active path, not just the file that looks relevant.
- Reuse existing local patterns and helper APIs. Add abstractions only when they remove real complexity, reduce meaningful duplication, or match an established pattern.
- Before changing behavior, identify: who calls this, accepted inputs today, outputs and errors today, compatibility assumptions, tests encoding current behavior, and related implementations that may conflict.
- Do not delete legacy-looking code unless reachability has been checked.
- Do not silently optimize away signal.
- Respect dirty worktrees and user changes; do not revert unrelated edits.
- Do not fall back to flaky heuristics. Especially for codebases using LLMs and agents as primitives, keep them first-class and ask user if unsure what to do as fallback. When features are asked to be implemented or planned try to ground them in those primitives instead of opting for flaky heuristics based determinstic processes.

## Validation

Run tests or checks proportional to risk and blast radius. Prefer tests that exercise real behavior rather than implementation details.

If tests cannot be run, say which tests/checks should run, why they were not run, what manual reasoning was done instead, and the remaining risk. Do not claim correctness because the code compiles or looks reasonable.

## After Coding

Report:

```text
Changes:
Why:
Production path affected:
Validation:
Post-implementation audit:  # the five audit checks above, applied to the result
Remaining risks:
```

## Anti-Patterns

- broad opportunistic refactors
- deleting code based on names or aesthetics
- changing tests to fit the implementation
- hidden broad try/catch blocks
- mocks that replace the behavior under test
- fake success states and silent fallback defaults
- unsupported "already done" claims
- validation claims without checks
