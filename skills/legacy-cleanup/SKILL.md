---
name: legacy-cleanup
description: Reachability-based classification of dead, duplicated, stale, or migration-leftover code before deletion, with quarantine/delete decisions and validation. Use when removing dead code, deleting unused files, deduplicating implementations, or deciding whether code is stale, unused, reachable, or safe to remove. Not for general refactoring of live code (use implementation-discipline).
version: 2.0.0
---

# Legacy Cleanup

Act as `legacy-cleaner`. Identify dead, duplicated, stale, misleading, or migration-leftover code without breaking active behavior. Do not clean based on aesthetics, and do not infer reachability from names: active production code may look ugly, legacy-looking code may be reachable, and polished code may be unused.

## Classification

Classify each target as one of:

```text
active-production / active-dev-tooling / test-only / generated-vendor /
legacy-but-reachable / dead-likely / dead-confirmed / uncertain
```

Use `dead-confirmed` only when entrypoint, reference, config, test, export, and deployment checks all support removal.

## Cleanup Workflow

1. Find references and imports (direct and dynamic), then trace from known entrypoints.
2. Check runtime registration, config references, framework auto-discovery, and dependency injection bindings.
3. Check tests and fixtures, package exports and public API, and build/deploy scripts (including scripts that reference paths dynamically).
4. Document assumptions and gotchas.
5. Only then recommend deletion, quarantine, migration, or leaving it alone.

Use broad search first, then narrow. Prefer executable wiring over comments and names; check documentation only after executable wiring.

## Removal Safety

Before deleting anything, check: public API exports and hidden consumers, generated-code regeneration, tests or fixtures that encode edge cases, docs or examples that carry useful signal, migration rollback paths, and config variants that still select the code. If uncertainty remains, prefer quarantine or a deprecation marker over deletion.

Cleanup can remove signal. When removing or quarantining examples, tests, fixtures, docs, edge-case coverage, or migration notes, state how to preserve the useful signal first.

## Duplicate Implementations

When duplicate old/new logic exists: identify all implementations; determine which are reachable from production entrypoints; check config or feature flags that select between them; compare behavior and edge cases; recommend consolidation only after preserving active behavior. Do not assume the newest or cleanest implementation is active.

## Output

```text
Target:
Classification:
How I figured it out:
Evidence / references:
Assumptions / gotchas:
Risk if removed:
Recommendation: delete / quarantine / leave / migrate / add deprecation marker
Validation needed:
```

## Anti-Patterns

- deletion from vibes, or because a filename says `legacy`, or because tests do not mention it
- deletion of exported public API without consumer checks
- broad cleanup during narrow feature work
- hiding uncertainty to make cleanup look cleaner
