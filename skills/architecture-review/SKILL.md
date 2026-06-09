---
name: architecture-review
description: System-level analysis and design mapping entrypoints, active wiring, data/control flow, runtime variants, boundaries, and failure modes before proposing a design. Use for architecture questions, system design, RFCs, design reviews, production-path mapping, or "how is this system wired". Not for line-level correctness review of a diff (use code-review-discipline).
version: 2.0.0
---

# Architecture Review

Act as `architect`. Do not start by editing code; first understand active wiring, runtime variants, and failure modes. Do not design from filenames: the most polished implementation may be inactive, and ugly code may be the production path.

## Investigation Workflow

1. Identify entrypoints: server/app startup, CLI entrypoints, framework bootstrapping, route registration, background job or workflow registration, package exports, deployment/build config.
2. Map active components: modules reached from entrypoints, adapters and wrappers, dependency injection bindings, external service / storage / queue / worker boundaries.
3. Trace data and control flow: ingress, parsing and validation, auth checks, business logic, persistence and side effects, outbound calls, error handling and retries, response path.
4. Check runtime variants: environment and feature flags, build-time config, deployment targets, optional plugins, old/new implementations selected by config.
5. Separate current architecture from desired architecture.

## Evidence To Prefer

Strong: executable registration code, imports and call chains from entrypoints, config values that select the implementation, tests that execute the active path, deployment/build scripts, observed runtime behavior.

Weak: filenames, comments, README text, old tests, directory names such as `legacy`, `new`, `secure`, or `experimental`. Use weak evidence only to guide further investigation.

## Design Rules

- Before committing to a design, generate at least two structurally different approaches and compare them on the criteria that matter; then commit with `reasoning-discipline`'s Decide move: name the dominant criterion and main tradeoff, and state what would change the recommendation.
- Prefer boring architecture unless complexity is forced by real constraints.
- Do not propose a new abstraction before checking existing extension points.
- Call out design optimizations that reduce observability, correctness, recall, security coverage, or auditability.
- Preserve uncertainty when runtime wiring is not proven; make compatibility risks explicit.

## Migration And Refactor Safety

When proposing architecture changes: state which callers and runtime paths are affected; identify old and new implementations and any required compatibility layer; define a rollback or quarantine strategy; identify test coverage needed for the production path; avoid cleanup unless reachability has been checked.

## Output

Use this shape when useful:

```text
Architecture read:
How I figured it out:
Production path:
Assumptions:
Key components and data/control flow:
Risk areas / gotchas:
Recommended design:
Tradeoffs:
Open questions:
```

Ask only questions that block safe progress; if a reasonable assumption can be validated from code, investigate first.
