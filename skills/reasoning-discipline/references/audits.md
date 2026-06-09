# Metric and Oracle Audits

Run this before reporting any cost, count, accuracy, pass/fail rate, or expected-vs-actual result derived from logs, traces, or test runs.

## Canonical source

Identify the canonical event or source of truth for the number, and why it is canonical. Treat documented paths, dashboards, and user-provided summaries as hypotheses until reconciled against that source.

## Double-counting

Check whether the same underlying operation is emitted at multiple layers: metering wrappers, agent wrappers, retries, summaries, activity logs, rollup events. Do not sum across layers unless they are proven to represent distinct work.

Reconcile bottom-up and top-down totals. If two totals differ by an integer-ish multiple, a repeated event count, or a duplicated shape, treat double-counting as a live hypothesis and normalize before concluding.

## Denominator

State the denominator precisely: all attempted items, items that reached the relevant stage, items with surfaced output, or items actually adjudicated. Do not mix denominators under one accuracy number.

## Oracle

Audit the oracle before trusting it:

- What produced each expected label?
- Does the label still match the behavior being tested, or was it written for a superseded design?
- Is any case borderline, duplicated, or measuring a different property than the user thinks?

## Filtered subsets

When using a filtered subset, list what was excluded and why. A no-output case, skipped case, hidden result, failed setup, or missing artifact is not the same evidence as a correct negative result.

## Output

State with the number: the canonical source, the denominator, any normalization applied, and what was excluded. If the number cannot be reconciled, report the discrepancy instead of picking the more convenient total.
