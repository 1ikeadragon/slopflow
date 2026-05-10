---
name: legacy-cleanup
description: This skill should be used when the user asks to "clean up legacy code", "remove dead code", "delete unused files", "deduplicate implementations", "refactor safely", "classify old code", "migration cleanup", or asks whether code is stale, unused, reachable, or safe to remove.
version: 1.0.0
---

# Legacy Cleanup

Use this skill to identify dead, duplicated, stale, misleading, or migration-leftover code without breaking active behavior. Do not clean based on aesthetics.

## Legacy Cleaner Role

Act as `legacy-cleaner`.

This repository may contain:

- active production code that looks ugly
- legacy-looking code that is still reachable
- polished code that is unused
- misleading filenames
- stale comments
- old tests
- duplicate implementations
- generated/vendor files
- partial migrations

Do not infer reachability from names alone.

## Classification

Classify targets as one of:

```text
active-production
active-dev-tooling
test-only
generated/vendor
legacy-but-reachable
dead-likely
dead-confirmed
uncertain
```

Use `dead-confirmed` only when entrypoint, reference, config, test, export, and deployment checks support removal.

## Cleanup Workflow

1. Find references and imports.
2. Trace from known entrypoints.
3. Check runtime registration and config.
4. Check tests.
5. Check package exports and public API.
6. Check deployment and build scripts.
7. Document assumptions.
8. List gotchas.
9. Only then recommend deletion, quarantine, migration, or leaving it alone.

## Required Output

Use this format:

```text
Target:
- ...

Classification:
- ...

How I figured it out:
- ...

Evidence:
- ...

References:
- ...

Assumptions:
- ...

Gotchas / edge cases:
- ...

Risk if removed:
- ...

Recommendation:
- delete / quarantine / leave / migrate / add deprecation marker

Validation needed:
- ...
```

## Evidence To Check

Look for:

- direct imports
- dynamic imports
- package exports
- route registration
- job/workflow registration
- CLI command registration
- dependency injection binding
- framework auto-discovery
- config references
- build/deploy scripts
- generated code references
- tests and fixtures
- documentation only after executable wiring

Use broad search first, then narrow. Prefer executable wiring over comments and names.

## Removal Safety

Before deleting anything, check:

- public API exports
- hidden consumers
- generated-code regeneration
- tests or fixtures that encode edge cases
- docs/examples that may provide useful signal
- migration rollback paths
- config variants that still select the code
- scripts that reference paths dynamically

If uncertainty remains, prefer quarantine or a deprecation marker over deletion.

## Duplicate Implementations

When duplicate old/new logic exists:

1. Identify all implementations.
2. Determine which are reachable from production entrypoints.
3. Check config or feature flags that select between them.
4. Compare behavior and edge cases.
5. Recommend consolidation only after preserving active behavior.

Do not assume the newest or cleanest implementation is active.

## Signal Loss

Cleanup can remove signal. Report when removing or quarantining:

- examples
- tests
- fixtures
- docs
- edge-case coverage
- migration notes
- debugging scripts

State how to preserve useful signal before deletion.

## Anti-Patterns

Avoid:

- deletion from vibes
- deletion because a filename says `legacy`
- deletion because tests do not mention it
- deletion of exported public API without consumer checks
- broad cleanup during narrow feature work
- hiding uncertainty to make cleanup look cleaner
