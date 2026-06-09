---
name: adversarial-test-design
description: Invariant-driven adversarial unit tests that attack assumptions instead of exercising happy paths. Use when writing, reviewing, or improving tests for security-sensitive, correctness-critical, parser, validator, authorization, workflow, migration, concurrency, or AI/LLM-pipeline logic, or whenever happy-path coverage is insufficient. Not for deciding what to threat-model in a design (use secure-design).
version: 2.0.0
---

# Adversarial Test Design

The goal is not coverage numbers. The goal is to make the implementation fail loudly when its assumptions are wrong.

Ordinary tests ask: does the code work when used as intended? Adversarial tests ask: **how can this code be tricked into appearing correct while violating the real invariant?** The test should attack the assumption, not merely exercise the function.

For detailed test categories, fixture rules, mocks vs fakes, property-based and metamorphic testing, AI/LLM-system testing, and anti-patterns, read `references/adversarial-test-reference.md` before writing non-trivial adversarial tests.

## Required Mindset

Think like: a malicious user; a confused legitimate user; a caller on a stale API contract; a concurrent worker racing another; a migration where old and new formats coexist; a parser receiving malformed but valid-looking input; a security reviewer trying to bypass an enforcement point; a production incident where dependencies lie, timeout, reorder, retry, or partially fail; an evaluator trying to make a metric look good without solving the task.

Do not assume callers are well-behaved, input is clean, names describe truth, mocks behave like real dependencies, or the path under test is the production path.

## Step 1: Identify The Invariant

Every adversarial test maps to one invariant. "The function should work" is not an invariant. These are:

- A user must never access data belonging to another tenant, even if they control the resource ID, request body, headers, or query params.
- A pruning optimization must reduce tokens without removing any signal required to reconstruct the vulnerability path.

Before writing tests, state: the invariant under test, what would violate it, and why normal tests may miss it.

## Step 2: Confirm The Tested Path

Confirm the test exercises the real implementation path: is this the production function, reachable from the real entrypoint, with production-like wiring, config, and defaults? Are mocks hiding behavior that matters? Is this only a wrapper while the real behavior lives elsewhere?

State the tested-path status (confirmed production path / likely / isolated unit only / uncertain) with evidence and limitations. Do not claim an adversarial test protects production behavior if it only tests an isolated helper.

## Step 3: Design The Attacks

For each test, work through:

1. **Asset or behavior protected**: user data, tenant boundary, secret material, approval workflow, billing state, idempotency, cache correctness, parser correctness…
2. **Attacker or failure capabilities**: what the caller or failure can control — IDs, headers, serialized input, ordering, retries, partial failures, stale cache, casing, encoding, path syntax, concurrency, inconsistent dependency responses.
3. **The broken implementation this test would catch.** If you cannot name one, the test is probably not adversarial. Examples: checks ownership after fetching instead of before; validates extension but not path traversal; catches and ignores errors to keep the workflow green; returns empty results on dependency failure; trusts a user-controlled tenant ID; prunes files by name and drops security-relevant config.
4. **Input designed to break assumptions**: valid-looking but wrong tenant ID, duplicate records with conflicting truth, stale cache entries, reordered events, retry after partial write, malformed encoding, empty-but-valid structures, nested objects bypassing shallow validation, real dependency errors instead of mocked success.
5. **Assert the invariant, not the implementation detail.** "Cross-tenant access is denied regardless of which helper runs" beats "function X calls helper Y". Assert implementation details only when the detail is itself the contract.

## Plan, Then Audit

For non-trivial test work, write a short plan first: invariant, production path and evidence, attacker/failure model, the weakness of existing normal tests, and the adversarial cases (each with the assumption attacked, the broken implementation caught, and the expected behavior), plus fixtures and fakes needed.

Audit the plan before writing, and the tests after writing:

1. **Coverage illusion** — do these tests check the invariant, or only raise line coverage?
2. **Reward hacking** — could the implementation pass via a fake fix, empty result, swallowed error, or mocked-away behavior?
3. **Fixture weakness** — are fixtures too clean, unique, ordered, or implementation-shaped? (See the reference for fixture rules.)
4. **Production-path weakness** — does the test exercise the real path or only a convenient helper?
5. **Lazy paths** — which cases were skipped because they are hard, slow, or flaky? Name them.
6. **Drift (post only)** — what differs from the planned tests, and why? Is every planned gotcha actually tested?

## Final Rule

A test is adversarial only if it would fail against a plausible broken implementation that normal tests could miss. If the test does not attack an assumption, it is not adversarial.
