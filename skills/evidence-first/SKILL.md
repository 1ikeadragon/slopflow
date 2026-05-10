---
name: evidence-first
description: This skill should be used when the user asks for reasoning, investigation, analysis, implementation, review, refactor, cleanup, security conclusions, "is this used", "is this safe", "already implemented", or any non-trivial claim about code behavior, production paths, or repository state.
version: 1.0.0
---

# Evidence-First Repository Work

Use this skill to avoid false confidence in messy or legacy repositories. Treat filenames, comments, docs, tests, and directory names as hints, not proof.

## Core Rule

Do not make non-trivial claims without checking the code path. Prefer evidence from executable wiring:

- entrypoints
- imports and references
- call chains
- runtime configuration
- route, job, workflow, or command registration
- dependency injection wiring
- package exports
- environment and feature flags
- tests that actually execute the path
- build and deployment scripts
- observed runtime behavior

If proof is missing, say so directly.

## Production-Path Check

Before editing or reviewing behavior:

1. Identify likely entrypoints:
   - app/server startup
   - CLI entrypoints
   - route registration
   - job/workflow registration
   - package exports
   - framework bootstrapping
   - build/deploy config

2. Trace from entrypoint to target code:
   - imports
   - function or class calls
   - dependency injection
   - config selection
   - feature flags
   - route/controller/service wiring

3. Classify target code:
   - confirmed production path
   - likely production path
   - test-only
   - dev/tooling
   - generated/vendor
   - legacy/dead
   - uncertain

4. Only then claim behavior.

Use this compact format when helpful:

```text
Path status:
- confirmed production path / likely production path / test-only / dev-tooling / generated-vendor / legacy-dead / uncertain

Evidence:
- ...

Missing evidence:
- ...
```

## Observation vs Interpretation

Separate what is directly observed from what is inferred:

```text
Observed:
- ...

Inferred:
- ...

Uncertain:
- ...

Conclusion:
- ...
```

Do not collapse inference into fact.

## Assumptions

For non-trivial tasks, document assumptions:

```text
Assumptions:
- Assumption: ...
  Reason: ...
  Validation status: confirmed / not confirmed / contradicted / unknown
  What would invalidate it: ...
```

Make implementation, test, security, performance, or production-impacting assumptions explicit.

## Gotchas And Edge Cases

Before implementation or review, list meaningful gotchas:

```text
Gotchas / edge cases:
- ...
```

After implementation, revisit each gotcha and state whether code handles it. A comment, TODO, or mocked-away test is not handling.

## No Hidden Signal Loss

Never silently improve speed, cost, latency, apparent correctness, test pass rate, or metric performance while reducing useful signal.

Examples of signal loss:

- filtering files before understanding whether they matter
- skipping expensive paths without reporting the skip
- reducing search depth
- truncating context
- ignoring errors
- falling back to defaults silently
- swallowing exceptions
- replacing real behavior with mocks
- returning partial results as complete
- hiding unknown states behind success states
- deduplicating or summarizing away important variance
- using heuristics that bias results toward easy cases

If using an optimization or shortcut, report:

```text
Optimization / shortcut:
- ...

Why used:
- ...

Signal potentially lost:
- ...

How this could fail:
- ...

How to validate it is acceptable:
- ...
```

## No Silent Shortcuts

Call out brittle or temporary choices before using them:

- magic numbers
- arbitrary thresholds
- special cases
- one-off string matching
- brittle path checks
- broad try/catch blocks
- ignored failures
- fixed sleeps, timeouts, or retries
- fake success states
- simplified parsers
- optimistic config assumptions
- tests that assert implementation details instead of behavior

Use:

```text
Potential shortcut:
- ...

Why it is tempting:
- ...

Risk:
- ...

Cleaner alternative:
- ...

Decision:
- use / avoid / use temporarily with explicit validation
```

## Before Saying "Already Implemented"

Do not say something already exists unless these are confirmed:

- where it is implemented
- whether it is reachable from the relevant production path
- whether it covers the requested behavior
- whether it is enabled by default or behind config
- whether it has tests
- whether there are multiple conflicting implementations

Use:

```text
Existing implementation found: yes/no/partial
Location: ...
Production-path status: ...
Matches requested behavior: yes/no/partial
Gaps: ...
Recommendation: reuse / modify / replace / ignore
```

## Depth Honesty

When reasoning, analysis, review, architecture, or security work is requested, state the depth when useful:

```text
Depth of analysis:
- deep / moderate / shallow / best-effort

What I actually checked:
- ...

What I did not check:
- ...

Risk of this answer being wrong:
- ...
```

Do not pad shallow reasoning with confident wording.

## Search Strategy

Prefer this investigation order:

1. Entrypoints and route/job/command registration
2. Imports and references from active code
3. Configuration and feature flags
4. Tests that exercise the path
5. Implementation details
6. Comments and docs last

Look for duplicate implementations, old/new versions, adapters, wrappers, framework magic, runtime registration, generated clients, and environment-specific behavior.

## Output Discipline

Prefer concise findings, concrete file paths, direct evidence, explicit uncertainty, documented assumptions, gotchas, and next action. Preserve uncertainty when proof is incomplete.
