---
name: evidence-first
description: Grounding discipline for any non-trivial claim about code behavior, production paths, or repository state — "is this used", "is this safe", "already implemented", investigation, analysis, and security conclusions. Use before asserting how code behaves in messy or unfamiliar repositories. Not for system-level design (use architecture-review) or deletion decisions (use legacy-cleanup).
version: 2.0.0
---

# Evidence-First Repository Work

Use this skill to avoid false confidence in messy or legacy repositories. Treat filenames, comments, docs, tests, and directory names as hints, not proof.

## Core Rule

Do not make non-trivial claims without checking the code path. Prefer evidence from executable wiring: entrypoints; imports and references; call chains; runtime configuration; route, job, workflow, or command registration; dependency injection; package exports; environment and feature flags; tests that actually execute the path; build and deployment scripts; observed runtime behavior. If proof is missing, say so directly.

Self-critique is not proof. Rereading the same unsupported answer, or asserting it more confidently, is not verification. Check the central, load-bearing claim against executable evidence or an authoritative source. Revise when the evidence changes, not when the prompt pressures you to.

## Production-Path Check

Before editing or reviewing behavior:

1. Identify likely entrypoints: app/server startup, CLI entrypoints, route registration, job/workflow registration, package exports, framework bootstrapping, build/deploy config.
2. Trace from entrypoint to target code: imports, calls, dependency injection, config selection, feature flags, route/controller/service wiring.
3. Classify the target: confirmed production path / likely production path / test-only / dev-tooling / generated-vendor / legacy-dead / uncertain.
4. Only then claim behavior.

```text
Path status: <classification>
Evidence:
Missing evidence:
```

## Observation vs Interpretation

Separate what is directly observed from what is inferred; do not collapse inference into fact:

```text
Observed:
Inferred:
Uncertain:
Conclusion:
```

## Assumptions, Gotchas, Depth

For non-trivial tasks, make implementation, test, security, performance, or production-impacting assumptions explicit: the assumption, why it is reasonable, its validation status (confirmed / not confirmed / contradicted / unknown), and what would invalidate it.

List meaningful gotchas and edge cases before implementation or review. Afterward, revisit each and state whether the code handles it — a comment, TODO, or mocked-away test is not handling.

When depth matters, state it honestly: what was actually checked, what was not, and the risk of this answer being wrong. Do not pad shallow reasoning with confident wording.

## No Hidden Signal Loss Or Silent Shortcuts

Never silently improve speed, cost, apparent correctness, test pass rate, or metric performance while reducing useful signal. This includes: filtering or truncating before understanding what matters, skipping expensive paths without reporting the skip, ignoring or swallowing errors, silent fallback defaults, mocks replacing real behavior, partial results returned as complete, unknown states hidden behind success states, and heuristics biased toward easy cases.

The same applies to brittle one-off choices: magic numbers, arbitrary thresholds, special cases, brittle string/path matching, broad try/catch, fixed sleeps and retries, fake success states, simplified parsers, tests asserting implementation details.

When using any of these, report it:

```text
Shortcut / optimization:
Why used:
Signal potentially lost / risk:
How to validate it is acceptable:
Decision: use / avoid / use temporarily with explicit validation
```

## Before Saying "Already Implemented"

Do not say something already exists unless you have confirmed: where it is implemented, whether it is reachable from the relevant production path, whether it covers the requested behavior, whether it is enabled by default or behind config, whether it has tests, and whether multiple conflicting implementations exist.

```text
Existing implementation found: yes / no / partial
Location:
Production-path status:
Matches requested behavior: yes / no / partial
Gaps:
Recommendation: reuse / modify / replace / ignore
```

## Search Strategy

Investigate in this order: (1) entrypoints and route/job/command registration, (2) imports and references from active code, (3) configuration and feature flags, (4) tests that exercise the path, (5) implementation details, (6) comments and docs last. Look for duplicate implementations, old/new versions, adapters, wrappers, framework magic, runtime registration, generated clients, and environment-specific behavior.

## Output Discipline

Prefer concise findings, concrete file paths, direct evidence, explicit uncertainty, documented assumptions, gotchas, and a next action. Preserve uncertainty when proof is incomplete.
