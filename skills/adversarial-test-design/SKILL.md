---
name: adversarial-test-design
description: This skill should be used when the user asks to "write adversarial tests", "design unit tests", "improve tests", "review tests", "test security-sensitive logic", "test correctness-critical code", "test parsers", "test validators", "test authorization", "test workflows", "test AI/LLM pipelines", "test pruning", "test classifiers", or asks for tests where happy-path coverage is insufficient.
version: 1.0.0
---

# Adversarial Test Design

Use this skill when writing, reviewing, or improving tests for security-sensitive logic, correctness-critical code, parsers, classifiers, validators, authorization checks, workflows, AI/LLM pipelines, data-processing systems, or any code where normal happy-path tests are insufficient.

The goal is not to increase coverage numbers. The goal is to make the implementation fail loudly when its assumptions are wrong.

For detailed categories, fixture rules, AI/LLM testing, performance optimization tests, anti-patterns, and audit checklists, read `references/adversarial-test-reference.md` before writing non-trivial adversarial tests.

## Core Principle

Adversarial tests are not ordinary edge-case tests.

Ordinary tests ask:

```text
Does the code work when used as intended?
```

Adversarial tests ask:

```text
How can this code be tricked into appearing correct while violating the real invariant?
```

The test should attack the assumption, not merely exercise the function.

## Required Mindset

When writing adversarial tests, think like:

- a malicious user
- a confused legitimate user
- a caller using a stale API contract
- a concurrent worker racing another worker
- a migration where old and new formats coexist
- a parser receiving malformed but valid-looking input
- a security reviewer trying to bypass an enforcement point
- a production incident where dependencies lie, timeout, reorder, retry, or partially fail
- an evaluator trying to make a metric look good without solving the task

Do not assume callers are well-behaved. Do not assume input is clean. Do not assume names describe truth. Do not assume mocks behave like real dependencies. Do not assume the implementation path under test is the production path.

## First Step: Identify The Invariant

Before writing any adversarial test, identify the invariant being protected.

Bad invariant:

```text
The function should work.
```

Better invariants:

```text
A user must never access data belonging to another tenant, even if they control the resource ID, request body, headers, or query params.
```

```text
A finding should only be marked PR-scoped when there is concrete evidence linking the finding anchor to the changed diff range, not merely because the file is reachable from changed code.
```

```text
A pruning optimization must reduce tokens without removing any signal required to reconstruct the vulnerability path.
```

Every adversarial test should map to one invariant.

Required output before writing tests:

```text
Invariant under test:
- ...

What would violate it:
- ...

Why normal tests may miss it:
- ...
```

## Evidence First: Confirm The Tested Path

Before writing tests, confirm the test exercises the real implementation path.

Check:

- Is this the production function, class, or module?
- Is this path reachable from the real entrypoint?
- Is the test using the same wiring as production?
- Are mocks hiding behavior that matters?
- Are config flags and defaults realistic?
- Are old and new implementations both present?
- Is the code under test only a wrapper while the real behavior lives elsewhere?

Required output:

```text
Tested path status:
- confirmed production path / likely production path / isolated unit only / uncertain

Evidence:
- ...

Limitations:
- ...
```

Do not claim an adversarial test protects production behavior if it only tests an isolated helper.

## Design Workflow

Follow this sequence.

### 1. Define the asset or behavior being protected

Examples:

- user data
- tenant boundary
- secret material
- approval workflow
- finding relevance
- vulnerability signal
- billing state
- scan scope
- idempotency guarantee
- cache correctness
- parser correctness

### 2. Define attacker or failure capabilities

Ask what the caller or failure can control:

- IDs, headers, serialized input, ordering, retries, partial failures, stale cache, casing, encoding, path syntax, concurrency, dependency behavior
- inconsistent dependency responses
- malformed but valid-looking input

### 3. Define the incorrect implementation that might pass normal tests

For each test, ask:

```text
What broken implementation would this test catch?
```

If the answer is unclear, the test is probably not adversarial.

Examples:

- checks ownership after fetching data instead of before
- validates file extension but not path traversal
- uses same-file match instead of diff-range overlap
- catches and ignores errors to keep workflow green
- returns empty result on dependency failure
- trusts user-controlled tenant ID
- uses first match instead of strongest anchor
- prunes files based on name and drops security-relevant config
- mocks away retry or concurrency behavior
- only tests current implementation shape, not invariant

### 4. Construct malicious or failure-oriented input

Inputs should be designed to break assumptions:

- valid-looking but wrong tenant ID
- changed file with unrelated finding in same file
- symbol ID missing but path present
- duplicate records with conflicting truth
- stale cache entry
- reordered events
- retry after partial write
- malformed encoding
- mixed separators in paths
- empty but valid structure
- very large but valid input
- nested object that bypasses shallow validation
- real dependency error instead of mocked success

### 5. Assert the invariant, not the implementation detail

Bad:

```text
expects function X to call helper Y
```

Better:

```text
expects cross-tenant access to be denied regardless of whether helper Y is used
```

Use implementation-detail assertions only when the implementation detail is itself the contract.

## Quality Bar

Every adversarial test must answer:

```text
Invariant:
- What property is protected?

Attack/failure mode:
- What assumption is being attacked?

Broken implementation caught:
- What specific bad implementation would fail this test?

Production relevance:
- Why can this happen in production?

Expected behavior:
- What should the system do instead?
```

If a test cannot answer these, it is probably just a normal test.

## Required Pre-Test Plan

Before writing adversarial tests, produce:

```text
Adversarial test plan:

Invariant:
- ...

Production path under test:
- ...

Evidence that this is the right path:
- ...

Attacker/failure model:
- ...

Normal test weakness:
- ...

Adversarial cases:
- Case 1: ...
  - Assumption attacked: ...
  - Broken implementation caught: ...
  - Expected behavior: ...

- Case 2: ...
  - Assumption attacked: ...
  - Broken implementation caught: ...
  - Expected behavior: ...

Fixtures needed:
- ...

Mocks/fakes needed:
- ...

Gotchas:
- ...
```

Do not write tests before this plan unless the task is trivial.

## Required Plan Audit Before Writing Tests

After drafting the test plan, audit it:

```text
Plan audit:

1. Magic numbers / hardcoding
- Are there thresholds, counts, paths, fixture names, or special cases that need justification?

2. Reward hacking
- Could the proposed tests pass through a fake fix, empty result, swallowed error, or mocked-away behavior?

3. Coverage illusion
- Are these tests actually checking the invariant, or only increasing line/branch coverage?

4. Fixture weakness
- Are fixtures too clean, unique, ordered, or implementation-shaped?

5. Production-path weakness
- Is the test exercising the real path or only a convenient helper?

6. Ignored gotchas
- Which gotchas remain untested?

7. Lazy paths
- Is any case omitted because it is annoying to test?
```

If the audit exposes weakness, update the plan before coding.

## Required Post-Test Audit

After writing the tests, answer:

```text
Post-test audit:

1. Magic numbers / hardcoding
- Are there literals, thresholds, fixture names, or special-cased values not justified in the plan?

2. Reward hacking
- Could the implementation pass by returning empty output, swallowing errors, mocking real behavior away, or avoiding real work?

3. Drift from plan
- What differs from the planned tests, and why?

4. Ignored gotchas
- For each gotcha identified in the plan, is it actually tested?

5. Lazy paths
- What did I skip because it was hard, slow, flaky, or inconvenient?

6. Production relevance
- Do these tests exercise the real implementation path? If not, what remains unproven?

7. Broken implementation caught
- For each test, what broken implementation would fail?
```

## Output Format When Writing Tests

Use:

```text
Using skill:
- adversarial-test-design

Invariant:
- ...

Production path status:
- ...

Adversarial test plan:
- ...

Plan audit:
- ...

Tests written:
- ...

Validation:
- tests run / not run
- result

Post-test audit:
- ...

Remaining gaps:
- ...
```

## Final Rule

A test is adversarial only if it would fail against a plausible broken implementation that normal tests could miss.

If the test does not attack an assumption, it is not adversarial.
