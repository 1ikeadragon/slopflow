---
name: data-validation
description: Programmatically validate datasets, parsed records, tables, CSV/JSON/YAML/XML/log outputs, benchmark outputs, metric reports, matrix results, counts, percentages, joins, migrations, exports, imports, and any claim that depends on data being read correctly. Use when the user asks to validate data, verify numbers, check parsing, compare expected vs actual data, audit metrics/results, or confirm that nothing was misread.
---

# Data Validation

Use this after `reasoning-discipline` frames the request. For any count, cost, accuracy, score, rate, pass/fail number, benchmark result, or confusion/result matrix, also run the metric/oracle audit in `reasoning-discipline/references/audits.md`.

## Non-Negotiables

- Do not validate data by eyeballing rendered text, screenshots, markdown tables, or model summaries when raw data or machine-readable output is available.
- Do not trust a parse until code has loaded it and checked shape, counts, types, nulls, duplicate keys/rows, and rejected/unknown fields.
- Do not report derived numbers until they have been recomputed from the canonical source or reconciled against the system that owns them.
- Do not silently coerce malformed values, drop rows, deduplicate, round, truncate, sample, or normalize. If a transform is necessary, name it and show its effect.
- Preserve raw input boundaries: file path, query, API response, log range, artifact ID, commit, timestamp, filters, and row denominator.

## Workflow

1. Pin the validation target:
   - State the exact claim, field, dataset, metric, matrix, or parsing behavior being validated.
   - Identify the canonical source of truth and every intermediate representation.
   - Define the denominator and inclusion/exclusion rules before calculating.

2. Load data with a real parser:
   - CSV/TSV: use a CSV library, not string splitting.
   - JSON/YAML/XML: use structured parsers and fail on invalid input when possible.
   - Logs/plain text: write explicit extraction code and validate match counts.
   - SQL/dataframes/spreadsheets: use typed query/dataframe APIs and keep the query/filter visible.
   - If only screenshots or prose are available, say that validation is limited and ask for raw data when the result matters.

3. Run structural checks before semantic checks:
   - Row/item count.
   - Column/key set.
   - Required fields present.
   - Type distribution and failed coercions.
   - Null/blank/missing values.
   - Duplicate IDs or duplicate natural keys.
   - Range checks, enum checks, timestamp/timezone checks, and units.
   - Parse rejects, skipped lines, warnings, and fallback paths.

4. Recompute derived results:
   - Calculate counts, rates, percentages, aggregates, rankings, confusion matrices, score matrices, and benchmark summaries from raw records.
   - Reconcile totals across layers: raw source, parsed records, filtered records, grouped records, and final output.
   - Use integer counts before percentages. Show rounding only after reconciliation.
   - For joins, prove join cardinality and orphan rows before trusting output.

5. Use an adversarial validator for result claims:
   - When the user asks for metrics, matrix results, benchmark results, counts, rates, accuracy, pass/fail summaries, or any decision-driving numeric result, spin up an adversarial subagent if subagents are available.
   - Give the subagent the raw data/artifact and the claim to validate, not your conclusion or implementation notes.
   - Require the subagent to independently parse or compute the result, list mismatches, and identify possible denominator, filtering, rounding, or label-oracle errors.
   - If subagents are unavailable, perform a second independent implementation yourself using different code structure or toolchain, and state that no subagent was available.

6. Resolve disagreements:
   - Treat mismatches as evidence, not noise.
   - Compare raw row IDs or records causing the difference.
   - Check filters, deduping, grouping keys, timezone boundaries, ordering, rounding, null handling, and label mapping.
   - Do not average conflicting answers. Find the cause or report unresolved uncertainty.

## Output

Return:

- Source: raw files, queries, artifacts, log ranges, or APIs used.
- Parser/checks: tools or code used to load and validate structure.
- Denominator: exact included/excluded records and why.
- Result: recomputed values with units and rounding policy.
- Cross-check: independent calculation or adversarial subagent result.
- Mismatches: every discrepancy found and how it was resolved.
- Limits: unavailable raw data, partial samples, unvalidated fields, lossy parsing, or remaining uncertainty.

## Shortcuts To Call Out

- Manual extraction from rendered output.
- Regex parsing where a structured parser exists.
- Sampling instead of full-data validation.
- Ignoring parser warnings.
- Dropping malformed records.
- Assuming row order is stable.
- Treating displayed percentages as source-of-truth counts.
- Trusting inherited expected labels without oracle audit.
