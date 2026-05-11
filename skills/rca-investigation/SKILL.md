---
name: rca-investigation
description: This skill should be used when the user asks for "RCA", "root cause analysis", "wide and deep RCA", "incident analysis", "workflow failure analysis", "why did this fail", "investigate a failed run", "OOM analysis", "API limit analysis", "restart analysis", "stale endpoint analysis", or asks to trace logs, metrics, DB artifacts, code paths, and systemic fixes without jumping to conclusions.
version: 1.0.0
---

# RCA Investigation

Use this skill for wide and deep root-cause analysis. Do not jump to a root cause early. Start with competing hypotheses, define what would prove or weaken each one, and identify the artifact type needed: logs, metrics, DB, code, config, or runtime trace.

## Start With Competing Hypotheses

List 3-5 plausible hypotheses before investigating.

For each hypothesis, state:

- what evidence would prove it
- what evidence would weaken it
- what artifact type is needed: logs, metrics, DB, code, config, or runtime trace

Do not infer cause from timestamp adjacency alone.

## 1. Identify The Exact Incident

Capture:

- workflow id
- repo/PR
- sandbox id, pod, or namespace
- failing timestamp
- artifact paths, especially DB or logs

If any of these are unknown, list them under `Still unknown` and state how to find them.

## 2. Build A Timeline

Query logs before, during, and after the failure.

Requirements:

- capture exact timestamps
- separate symptoms from causes
- compare pre-failure, failure-window, and post-failure evidence
- avoid assigning causality from timestamps alone

## 3. Prove The Failure Mode

Match the alleged failure mode to hard evidence:

- If OOM: find kernel/cgroup OOM logs and memory metrics.
- If API limit: find the exact provider error.
- If restart: find pod/container lifecycle events.
- If stale endpoint: compare old/new IP or endpoint values.

Do not confuse token limit with OOM. Do not confuse cache existence with cache causality.

## 4. Inspect Persistent Artifacts

Locate or download DBs and artifacts.

Process:

1. Inspect schema first.
2. Write explicit SQL queries.
3. Compare against known-good runs.
4. Quantify magnitude, not just presence.

Use DB evidence only for what it actually proves.

## 5. Trace The Code Path

Find:

- where the bad input enters
- where filtering should have happened
- where memory, network, or LLM payload is materialized
- whether behavior is full build, partial build, or downstream scan behavior

Do not assume a filter ran because code exists. Prove the filter is on the active path and executed for the incident.

## 6. Separate Proof Levels

Use these labels:

```text
Proven by logs:
- ...

Proven by metrics:
- ...

Proven by DB:
- ...

Proven by code:
- ...

Inferred:
- ...

Still unknown:
- ...
```

## 7. Fight Premature Conclusions

Before giving RCA, ask:

- Could this be only a downstream symptom?
- Did I compare against a normal run?
- Did I prove the filter actually ran?
- Did I confuse token limit with OOM?
- Did I confuse cache existence with cache causality?
- Did I prove exact heap allocation, or only the strongest mechanism?

If any answer is unresolved, preserve uncertainty in the final RCA.

## 8. Recommend Systemic Fixes

Avoid symptom fixes like "increase memory" unless paired with root fixes.

For each fix, say:

- which failure boundary it addresses
- what signal it might lose
- how to report that signal instead of hiding it
- how to verify the fix with logs, DB, or metrics

## Final Answer Format

Use:

```text
Root cause:
- One sentence.

Timeline:
- ...

Strongest evidence:
- ...

What is inferred vs proven:
- ...

Systemic fix:
- ...

Gotchas:
- ...

Exact commands/queries used:
- ...
```

If a root cause is not proven, do not force one. State the strongest proven failure mode and what evidence is still needed.
