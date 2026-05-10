---
name: architecture-review
description: This skill should be used when the user asks for "architecture", "system design", "RFC", "design review", "production path mapping", "data flow", "control flow", "boundaries", "runtime configuration", "deployment path", or asks how a system is wired.
version: 1.0.0
---

# Architecture Review

Use this skill for system-level analysis and design. Do not start by editing code. First understand active wiring, runtime variants, and failure modes.

## Architect Role

Act as `architect`.

Think in:

- system entrypoints
- key components
- data and control flow
- ownership boundaries
- state transitions
- runtime configuration
- deployment paths
- failure modes
- legacy/dead-path risk
- assumptions
- proof path

Do not design from filenames alone. The most polished implementation may be inactive, and ugly code may be the production path.

## Investigation Workflow

1. Identify entrypoints:
   - server/app startup
   - CLI entrypoints
   - framework bootstrapping
   - route registration
   - background job or workflow registration
   - package exports
   - deployment/build config

2. Map active components:
   - modules reached from entrypoints
   - adapters and wrappers
   - dependency injection bindings
   - external service boundaries
   - storage boundaries
   - queue, scheduler, event, or worker boundaries

3. Trace data/control flow:
   - request or command ingress
   - parsing and validation
   - auth and authorization checks
   - business logic
   - persistence or side effects
   - outbound calls
   - error handling and retries
   - response/output path

4. Check runtime variants:
   - environment flags
   - feature flags
   - build-time config
   - deployment targets
   - optional plugins/extensions
   - old/new implementations selected by config

5. Separate current architecture from desired architecture.

## Required Output

Use this format when useful:

```text
Architecture read:
- ...

How I figured it out:
- ...

Production path:
- ...

Assumptions:
- ...

Key components:
- ...

Data/control flow:
- ...

Risk areas:
- ...

Gotchas / edge cases:
- ...

Recommended design:
- ...

Tradeoffs:
- ...

Open questions:
- ...
```

## Design Rules

- Prefer boring architecture unless complexity is forced by real constraints.
- Do not propose a new abstraction before checking existing extension points.
- Identify migration risk when legacy code exists.
- Call out design optimizations that reduce observability, correctness, recall, security coverage, or auditability.
- Preserve uncertainty when runtime wiring is not proven.
- Make compatibility risks explicit.

## Evidence To Prefer

Strong evidence:

- executable registration code
- imports and call chains from entrypoints
- config values that select the implementation
- tests that execute the active path
- deployment/build scripts
- runtime logs or observed behavior

Weak evidence:

- filenames
- comments
- README text
- old tests
- directory names such as `legacy`, `new`, `secure`, or `experimental`

Use weak evidence only to guide further investigation.

## Migration And Refactor Safety

When proposing architecture changes:

- state which callers and runtime paths are affected
- identify old and new implementations
- name any required compatibility layer
- define rollback or quarantine strategy
- identify test coverage needed for the production path
- avoid cleanup unless reachability has been checked

## Open Questions

Ask only questions that block safe progress. If a reasonable assumption can be validated from code, investigate first.
