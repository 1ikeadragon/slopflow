# Adversarial Test Reference

Use this reference before writing non-trivial adversarial tests.

## Required Test Categories

### 1. Negative Authorization Tests

Prove unauthorized access fails. Do not only test that authorized access succeeds.

Examples:

- user A cannot access user B resource
- tenant A cannot read tenant B object by guessing ID
- admin-like field in request body is ignored
- ownership is checked against server-side identity, not user input
- scoped token cannot access global resource

### 2. Boundary Confusion Tests

Test places where two concepts can be confused:

- same file vs same diff range
- reachable path vs causally changed path
- validation vs authorization
- authenticated vs authorized
- internal route vs trusted route
- test config vs production config
- old model result vs current scan result
- parsed path vs raw path
- display name vs canonical ID

### 3. Missing Or Partial Data Tests

Production data is often incomplete:

- `symbol_id = null`
- missing file path
- empty evidence list
- partial call graph
- dependency timeout
- stale metadata
- legacy record without new field
- duplicate IDs
- invalid enum from old version

The test should verify conservative behavior.

### 4. Ambiguity Tests

When evidence is ambiguous, the system should not invent certainty.

Expected behavior should usually be:

- mark uncertain
- require further validation
- do not auto-approve
- do not silently drop

### 5. Signal-Loss Tests

Use when code compresses, filters, summarizes, ranks, prunes, deduplicates, truncates, caches, or optimizes.

The test must prove that performance improvements do not remove required signal.

Ask:

- What information is required to make the downstream decision?
- Can the optimization remove that information?
- Does the test fail if the signal is removed?
- Does the test only check size reduction while ignoring correctness?

Example invariant:

```text
Pruning may remove irrelevant files, but must retain all files necessary to reconstruct source to sink reachability for the finding.
```

### 6. Reward-Hacking Tests

Test that the implementation does not merely satisfy a metric or test shape.

Catch patterns like:

- returning empty results to avoid false positives
- swallowing errors to keep workflow successful
- mocking the hard dependency away
- filtering all low-confidence findings without preserving audit trail
- hardcoding known benchmark cases
- passing only because fixture names match expected values
- lowering severity instead of fixing evidence logic
- retrying forever instead of surfacing failure

### 7. Regression-Generalization Tests

A bug fix should not only handle the exact reproduction. For every bug reproduction, write at least one generalized variant:

- different path
- different casing
- different ordering
- different ID
- different nesting
- different config
- different caller
- same invariant violation, different surface form

### 8. Concurrency And Ordering Tests

Use when state, retries, queues, workflows, or async jobs are involved:

- duplicate event delivered twice
- retry after partial write
- out-of-order messages
- two workers process same job
- cancellation during write
- timeout after side effect but before ack
- cache invalidation races

Assert idempotency and final state.

### 9. Parser And Normalization Tests

Use for paths, URLs, headers, languages, package names, file extensions, or user input:

- Unicode normalization
- mixed slash/backslash paths
- encoded traversal
- double encoding
- case-insensitive filesystems
- symlink-like paths
- trailing dots/spaces
- null bytes if language/runtime relevant
- equivalent URLs with different textual forms
- duplicate headers

### 10. Legacy Coexistence Tests

Use when the codebase has old and new implementations:

- old record format still processed safely
- new path does not silently ignore old fields
- migration fallback does not bypass validation
- legacy adapter preserves security checks
- duplicate implementations do not disagree silently

## Test Naming Convention

Prefer names that describe the violated assumption.

Bad:

```text
test_validation_works
```

Better:

```text
test_rejects_cross_tenant_resource_id_even_when_request_body_claims_same_tenant
```

Bad:

```text
test_pr_scope
```

Better:

```text
test_same_file_finding_is_not_pr_scoped_without_diff_range_overlap
```

Names should reveal the adversarial condition.

## Fixture Design Rules

Fixtures should not accidentally make the test easy.

Avoid:

- one user, tenant, file, finding, branch, or role
- globally unique names
- IDs that reveal ownership through naming
- fixtures where correct answer can be guessed from order
- fixtures that mirror implementation internals

Prefer:

- at least two tenants/users/resources
- conflicting names
- duplicate-looking records
- reordered inputs
- missing optional fields
- irrelevant distractor data
- realistic legacy fields
- real path-like strings
- realistic config variants

## Assertions: What To Prefer

Prefer assertions on externally observable behavior:

- denied access
- preserved evidence
- explicit uncertainty
- emitted error
- no state mutation
- idempotent final state
- audit log exists
- result is not marked confirmed
- finding is not silently dropped
- retry produces same final state

Avoid overfitting to internals unless the invariant requires a specific enforcement point.

## Mocks And Fakes

Mocks are dangerous in adversarial testing because they often remove the adversary.

Before using a mock, ask:

- Does this mock hide a failure mode?
- Does it always return clean data?
- Does it preserve ordering, latency, retries, and errors?
- Does it behave like the real dependency?
- Does it make the test pass by deleting the hard part?

Use fakes when possible. A fake should model relevant bad behavior:

- timeout
- partial failure
- duplicate response
- stale data
- reordered result
- inconsistent metadata
- permission denial
- rate limit
- malformed response

If a mock is used, state what it removes from the test:

```text
Mock limitation:
- This test does not exercise real dependency behavior for ...
```

## Property-Based And Fuzz Testing

Use property-based tests when correctness depends on a broad input space.

Good targets:

- parsers, normalizers, path/URL handling, authorization matrices
- state transitions, deduplication, ranking/filtering
- serialization/deserialization, migration compatibility

Do not use fuzzing as a substitute for understanding the invariant.

## Metamorphic Tests

Use metamorphic tests when exact expected output is hard to know, but relationships should hold.

Examples:

```text
Reordering independent findings should not change which findings are marked PR-scoped.
```

```text
Adding irrelevant files should not remove a vulnerability signal from the summarized context.
```

Metamorphic tests are useful for AI/LLM pipelines, ranking systems, pruning systems, and classifiers.

## AI / LLM / Agentic Systems

For LLM or agentic systems, test the harness, not just the model output.

Key distinction:

```text
Model-sensitive failure:
- The model lacks the capability to infer the issue even with sufficient context.

Harness-sensitive failure:
- The system failed because context, tools, prompt, retrieval, validation, or scoring prevented the model from finding or proving the issue.
```

Test categories:

- context omission
- distractor resistance
- evidence requirement
- uncertainty preservation
- tool failure
- prompt anchoring
- validation integrity

## Security Review Systems

For vulnerability detection or PR review systems, test against false causality and false certainty.

Important adversarial cases:

- same file but no diff-range overlap
- reachable from changed code but not causally introduced by the PR
- `symbol_id = null`
- finding path differs from evidence path
- generated file references source file
- test file references production file
- old finding exists before PR
- dependency finding unrelated to changed package
- call graph edge exists but exploit path is impossible
- vulnerability evidence exists but attacker path is missing
- attacker path exists but impact is overstated

Expected behavior should distinguish:

```text
confirmed PR-scoped
likely PR-scoped
repo-existing / unrelated to PR
uncertain
not enough evidence
```

Never collapse reachability into causality.

## Performance Optimizations

Any optimization that reduces work can lose signal:

- pruning files
- summarizing code
- truncating logs
- ranking findings
- deduplicating alerts
- limiting graph hops
- caching analysis
- skipping validation
- sampling events
- early returns

For every such optimization, write at least one signal-preservation test.

Required test questions:

```text
What signal could be lost?
- ...

Why does downstream logic need it?
- ...

What input would tempt the optimizer to drop it?
- ...

How does this test fail if the signal is dropped?
- ...
```

## Anti-Patterns

Avoid:

- snapshot-only adversarial tests
- one-fixture tests
- mocking away the adversary
- testing the patch, not the bug class
- coverage gaming
- over-brittle implementation tests
- silent degraded behavior
